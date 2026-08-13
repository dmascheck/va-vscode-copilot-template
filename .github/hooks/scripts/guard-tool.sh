#!/bin/bash

# Tool Guardian Hook
# Blocks dangerous tool operations (destructive file ops, force pushes, DB drops, network
# exfiltration, permission abuse) before the Copilot coding agent executes them.
#
# WIRED 2026-08-12 on PreToolUse. Before that it sat in this directory for months with no call
# site anywhere - not in hooks.json, not in another script, not in docs - and it had never once
# been executed. When it finally was, it was broken in three separate ways. All three are fixed
# below and each has a case in selftest-guard-tool.sh so the fix cannot silently regress:
#
#   1. SILENT DEATH ON THE REAL PAYLOAD. It parsed "toolName"/"toolInput", but the hook payload
#      its own sibling pre-tool-use.sh reads uses "tool_name"/"tool_input". On any real payload
#      the jq extract returned empty, the grep fallback then matched nothing, and under
#      `set -euo pipefail` a no-match grep in a command substitution killed the script at line 47.
#      Measured: exit 1, no output, no log line. Wired as-is in block mode that reads as "blocked"
#      - so it would have denied every tool call in the project while explaining nothing.
#      Extraction is now python3 (the same dependency the four wired hooks already have), accepts
#      either spelling, flattens nested objects, and falls back to scanning every string in the
#      payload when it recognizes no input key at all. An unparseable payload can no longer make
#      the guard either die or go blind.
#
#   2. THE scan-secrets BUG CLASS, LATENT. Patterns were passed as `grep -qiE "$regex"` with no
#      `--` guard and stderr discarded. No shipped pattern starts with "-" today, so this was not
#      yet live - but `grep -qiE "-rf"` exits 2 (usage error), and `2>/dev/null` converts that
#      into "no match", which is exactly how scan-secrets.sh printed "[OK] No secrets detected"
#      over a planted RSA private key. Every grep here now carries `--`.
#
#   3. IT WAS NOT A HOOK. It printed a human table and exited 1. A PreToolUse hook has to return
#      the permissionDecision JSON its sibling returns, or nothing is blocked. It now does, and
#      the human table is still available for manual runs via GUARD_OUTPUT=text.
#
# QUIET ON THE CLEAN PATH, deliberately. It runs on every tool call, so a clean call prints
# nothing but the protocol continue and writes NO log line. Only threats are logged. A guard that
# appends a line per tool call is a guard that costs more than it catches.
#
# Environment variables:
#   GUARD_MODE           - "warn" (log only) or "block" (deny the call) (default: block)
#   GUARD_OUTPUT         - "hook" (permissionDecision JSON) or "text" (human table) (default: hook)
#   SKIP_TOOL_GUARD      - "true" to disable entirely (default: unset)
#   TOOL_GUARD_LOG_DIR   - Directory for guard logs (default: .github/logs/copilot/tool-guardian)
#   TOOL_GUARD_ALLOWLIST - Comma-separated substrings to skip (default: unset)

set -euo pipefail

MODE="${GUARD_MODE:-block}"
OUTPUT="${GUARD_OUTPUT:-hook}"

# ---------------------------------------------------------------------------
# Emit the protocol "allow" and leave. Used by every early exit so that a
# disabled or non-applicable guard can never stall the tool call.
# ---------------------------------------------------------------------------
allow_and_exit() {
  if [[ "$OUTPUT" == "hook" ]]; then
    echo '{"continue": true}'
  fi
  exit 0
}

if [[ "${SKIP_TOOL_GUARD:-}" == "true" ]]; then
  [[ "$OUTPUT" == "text" ]] && echo "[SKIP]  Tool guard skipped (SKIP_TOOL_GUARD=true)"
  allow_and_exit
fi

# ---------------------------------------------------------------------------
# Read tool invocation from stdin
# ---------------------------------------------------------------------------
INPUT=$(cat || true)

# Anchored on the PROJECT ROOT, not the working directory (fixed 2026-08-12).
#
# This was a bare relative ".github/logs/copilot/tool-guardian", resolved against whatever
# directory the hook happened to run in. Running the self-test from inside scripts/ therefore
# created scripts/.github/logs/copilot/tool-guardian/guard.log - a nested .github INSIDE the
# script directory. That stray then rode along with the hook tree into downstream repos and was
# committed there before anyone noticed what it was.
#
# CLAUDE_PROJECT_DIR is what Claude Code exports for exactly this; git rev-parse covers a hand
# run outside a hook; pwd is the last resort so the guard still logs rather than failing.
# Third instance of this same cwd-relative class found today, after logging_config.py and the
# stray Logs/ trees - a relative path in a tool that can be invoked from anywhere is a bug
# waiting for someone to change directory.
_GUARD_LOG_BASE="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
LOG_DIR="${TOOL_GUARD_LOG_DIR:-$_GUARD_LOG_BASE/.github/logs/copilot/tool-guardian}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ---------------------------------------------------------------------------
# Extract tool name and every string in the tool input.
#
# Accepts both field spellings because the two halves of this plugin disagree:
# pre-tool-use.sh reads tool_name/tool_input, this script historically read
# toolName/toolInput. Rather than bet on one, take either. If NEITHER input key
# is present, flatten the whole payload instead of scanning nothing - going
# blind is the failure mode that shipped last time.
# ---------------------------------------------------------------------------
EXTRACT=$(printf '%s' "$INPUT" | python3 -c '
import sys, json

raw = sys.stdin.read()
try:
    data = json.loads(raw)
except Exception:
    data = None
if not isinstance(data, dict):
    # Unparseable or non-object payload: scan the raw text rather than nothing.
    print("")
    print(" ".join(raw.split()))
    sys.exit(0)

name = ""
for key in ("toolName", "tool_name", "name"):
    value = data.get(key)
    if isinstance(value, str) and value:
        name = value
        break

target = None
for key in ("toolInput", "tool_input", "input", "arguments", "parameters"):
    if key in data:
        target = data[key]
        break
if target is None:
    target = data

parts = []


def flatten(node):
    if isinstance(node, str):
        parts.append(node)
    elif isinstance(node, dict):
        for value in node.values():
            flatten(value)
    elif isinstance(node, list):
        for value in node:
            flatten(value)
    elif node is not None:
        parts.append(str(node))


flatten(target)
print(name)
print(" ".join(" ".join(parts).split()))
' 2>/dev/null || true)

# AN INTERPRETER FAILURE MUST NOT MEAN "SCAN NOTHING".
#
# The block above already refuses to go blind on a payload it cannot PARSE - an unparseable body
# falls back to the raw text, and the comment at the top of this section says why. But the fallback
# lives INSIDE the Python, so it cannot run when the Python itself does not: `2>/dev/null || true`
# swallows a missing, broken, or shadowed python3, EXTRACT comes back empty, COMBINED becomes a
# single space, no pattern matches, and the guard allows the call. The clean path deliberately
# writes no log line, so a guard that is dead in this way leaves no trace anywhere.
#
# Measured 2026-08-12 with a python3 stub exiting 127: this script returned {"continue": true} and
# pre-tool-use.sh did the same, for a payload carrying `rm -rf /`. Both PreToolUse guards are wired
# in hooks.json and presented as overlapping defence, but they share one interpreter - so one
# broken python3 disarms the entire event at once.
#
# The fallback is the documented intent, done in bash so it needs nothing that can be missing:
# line 1 stays empty (no tool name) and line 2 carries the whitespace-collapsed raw payload, which
# is the exact shape the sed below expects. A dangerous string in the payload is still a dangerous
# string when nothing has parsed it.
if [[ -z "${EXTRACT//[[:space:]]/}" ]]; then
  echo "[WARN] guard-tool: payload extraction produced nothing (python3 missing or failing) - falling back to a raw-payload scan rather than allowing blind" >&2
  EXTRACT=$(printf '\n%s' "$(printf '%s' "$INPUT" | tr -s '[:space:]' ' ')")
fi

# DETECTING A THREAT IS ONLY HALF THE JOB - THE DENIAL HAS TO BE EXPRESSIBLE.
#
# python3 is used three times in this script: to extract the payload (above, now guarded), to
# append the JSONL audit line, and to emit the hook decision itself. The extraction guard alone
# left a hole that measured WORSE than the one it closed: with a python3 stub exiting 127 the raw
# scan correctly matched `rm -rf /`, and then the audit-log pipeline died under `set -euo pipefail`
# before any decision was printed. The script exited 127 with no JSON at all - and for a PreToolUse
# hook only exit 2 is a blocking error, so a 127 is a NON-blocking error and the tool runs anyway.
# Loudly failing open is still failing open.
#
# So probe the interpreter ONCE, here, and let the two consumers below degrade instead of dying:
# the audit line is best-effort (losing a log entry must never cost a block), and the decision
# falls back to a STATIC JSON string. Static is the whole point - with no interpolation there is
# no quoting to get wrong, which is the reason python3 owned this emission in the first place.
PY_OK=0
if python3 -c 'pass' >/dev/null 2>&1; then
  PY_OK=1
else
  echo "[WARN] guard-tool: python3 is unavailable - the audit line will be skipped and the decision emitted in a reduced, static form. The guard still BLOCKS." >&2
fi

TOOL_NAME=$(printf '%s' "$EXTRACT" | sed -n '1p')
TOOL_INPUT=$(printf '%s' "$EXTRACT" | sed -n '2p')
COMBINED="${TOOL_NAME} ${TOOL_INPUT}"

# ---------------------------------------------------------------------------
# TOOL SCOPING (2026-08-13, fixed after a live block): every pattern below is
# EXECUTION-shaped (rm, git push -f, DROP TABLE, sudo). A content-bearing tool -
# Write/Edit/plan/notebook - executes nothing, and scanning its file content with
# command regexes blocked a plan DOCUMENT whose prose contained "...form name..."
# and ".githooks" (matched '(rm|del|unlink).*\.git[^i]'). A SQL migration file
# legitimately contains DROP TABLE; docs legitimately mention sudo.
# Content-borne secrets are scan-secrets.sh's job, which handles content properly.
# Unknown/empty tool names still get scanned - conservative by default.
# ---------------------------------------------------------------------------
case "$(printf '%s' "$TOOL_NAME" | tr '[:upper:]' '[:lower:]')" in
  *write*|*edit*|*notebook*|*patch*|*plan*|*todo*|*create_file*|*insert_*|*replace_*)
    [[ "$OUTPUT" == "text" ]] && echo "[SKIP]  '$TOOL_NAME' writes content, does not execute - command patterns not applied"
    allow_and_exit
    ;;
esac

# ---------------------------------------------------------------------------
# Allowlist
# ---------------------------------------------------------------------------
ALLOWLIST=()
if [[ -n "${TOOL_GUARD_ALLOWLIST:-}" ]]; then
  IFS=',' read -ra ALLOWLIST <<< "$TOOL_GUARD_ALLOWLIST"
fi

is_allowlisted() {
  local text="$1"
  local pattern
  for pattern in "${ALLOWLIST[@]}"; do
    pattern=$(printf '%s' "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$pattern" ]] && continue
    if [[ "$text" == *"$pattern"* ]]; then
      return 0
    fi
  done
  return 1
}

if [[ ${#ALLOWLIST[@]} -gt 0 ]] && is_allowlisted "$COMBINED"; then
  [[ "$OUTPUT" == "text" ]] && echo "[SKIP]  Allowlisted, not scanned"
  allow_and_exit
fi

# ---------------------------------------------------------------------------
# Threat patterns. Each entry: "CATEGORY:::SEVERITY:::REGEX:::SUGGESTION"
# ::: is the delimiter so a regex may contain pipes.
#
# NOTE the overlap with pre-tool-use.sh, which also runs on PreToolUse: seven
# patterns are common to both, so a force-push is reported twice. Neither script
# dominates the other (pre-tool-use.sh alone carries mkfs./dd if=; this one alone
# carries exfiltration, permission abuse, TRUNCATE and unqualified DELETE, and it
# inspects every tool rather than only run_in_terminal). Collapsing them into one
# guard is the right end state and is recorded as a tangent in ACTIVE_TASK.md.
# ---------------------------------------------------------------------------
PATTERNS=(
  # Destructive file operations
  "destructive_file_ops:::critical:::rm -rf /:::Use targeted 'rm' on specific paths instead of root"
  "destructive_file_ops:::critical:::rm -rf ~:::Use targeted 'rm' on specific paths instead of home directory"
  "destructive_file_ops:::critical:::rm -rf \.:::Use targeted 'rm' on specific files instead of current directory"
  "destructive_file_ops:::critical:::rm -rf \.\.:::Never remove parent directories recursively"
  "destructive_file_ops:::critical:::(rm|del|unlink).*\.env:::Use 'mv' to back up .env files before removing"
  "destructive_file_ops:::critical:::(rm|del|unlink).*\.git[^i]:::Never delete .git directory - use 'git' commands to manage repo state"

  # Destructive git operations
  "destructive_git_ops:::critical:::git push --force.*(main|master):::Use 'git push --force-with-lease' or push to a feature branch"
  "destructive_git_ops:::critical:::git push -f.*(main|master):::Use 'git push --force-with-lease' or push to a feature branch"
  "destructive_git_ops:::high:::git reset --hard:::Use 'git stash' to preserve changes, or 'git reset --soft'"
  "destructive_git_ops:::high:::git clean -fd:::Use 'git clean -n' (dry run) first to preview what will be deleted"

  # Database destruction
  "database_destruction:::critical:::DROP TABLE:::Use 'ALTER TABLE' or create a migration with rollback support"
  "database_destruction:::critical:::DROP DATABASE:::Create a backup first; consider revoking DROP privileges"
  "database_destruction:::critical:::TRUNCATE:::Use 'DELETE FROM ... WHERE' with a condition for safer data removal"
  "database_destruction:::high:::DELETE FROM [a-zA-Z_]+ *;:::Add a WHERE clause to 'DELETE FROM' to avoid deleting all rows"

  # Permission abuse
  "permission_abuse:::high:::chmod 777:::Use 'chmod 755' for directories or 'chmod 644' for files"
  "permission_abuse:::high:::chmod -R 777:::Use specific permissions ('chmod -R 755') and limit scope"

  # Network exfiltration
  "network_exfiltration:::critical:::curl.*\|.*bash:::Download the script first, review it, then execute"
  "network_exfiltration:::critical:::wget.*\|.*sh:::Download the script first, review it, then execute"
  "network_exfiltration:::high:::curl.*--data.*@:::Review what data is being sent before using 'curl --data @file'"

  # System danger
  "system_danger:::high:::sudo :::Avoid 'sudo' - run commands with the least privilege needed"
  "system_danger:::high:::npm publish:::Use 'npm publish --dry-run' first to verify package contents"
)

# ---------------------------------------------------------------------------
# Scan. Every grep carries `--` so a pattern beginning with "-" is a pattern and
# not an option - the exact bug that made scan-secrets.sh report clean over a
# planted private key.
# ---------------------------------------------------------------------------
THREATS=()
THREAT_COUNT=0

for entry in "${PATTERNS[@]}"; do
  category="${entry%%:::*}"
  rest="${entry#*:::}"
  severity="${rest%%:::*}"
  rest="${rest#*:::}"
  regex="${rest%%:::*}"
  suggestion="${rest#*:::}"

  if printf '%s\n' "$COMBINED" | grep -qiE -- "$regex"; then
    match=$(printf '%s\n' "$COMBINED" | grep -oiE -- "$regex" | head -1 || true)
    THREATS+=("${category}	${severity}	${match}	${suggestion}")
    THREAT_COUNT=$((THREAT_COUNT + 1))
  fi
done

if [[ $THREAT_COUNT -eq 0 ]]; then
  # Clean: say nothing, log nothing.
  if [[ "$OUTPUT" == "text" ]]; then
    echo "[OK] Tool guard clean"
    exit 0
  fi
  allow_and_exit
fi

# ---------------------------------------------------------------------------
# Threats found. Build the report, log it, then answer in the requested form.
# ---------------------------------------------------------------------------
# LOGGING MUST NEVER DECIDE THE VERDICT.
#
# These two steps - creating the log dir, and the python3 that writes the entry - run under
# `set -euo pipefail` and sit BEFORE the deny is emitted. So on the THREAT path, and only on the
# threat path, an unwritable log directory or a missing python3 aborted the script before it could
# answer, and the caller read the absent deny as an allow. The guard failed open on exactly the
# path that matters and never on the clean path, where it writes nothing at all.
#
# Measured 2026-08-12: with a python3 stub exiting 127 and a payload carrying `rm -rf /`, this
# script exited 127 with empty output AFTER correctly detecting the threat.
#
# A lost log line is a real cost and it is the smaller one. Failing to record a blocked command is
# recoverable; failing to block it is not.
mkdir -p "$LOG_DIR" 2>/dev/null || true
LOG_FILE="$LOG_DIR/guard.log"

SUMMARY=""
for threat in "${THREATS[@]}"; do
  IFS=$'\t' read -r category severity match suggestion <<< "$threat"
  SUMMARY="${SUMMARY}[${severity}] ${category}: matched '${match}'. ${suggestion}
"
done

# python3 owns the JSON so quoting, tabs and backslashes in a matched command
# cannot produce a malformed hook response.
#
# BEST-EFFORT BY DESIGN: this writes the audit line only. If the interpreter is gone the entry is
# lost, which is a real cost - but it must never be paid with a missed BLOCK, and before the PY_OK
# guard this pipeline was what killed the script under `set -euo pipefail` before any decision was
# printed. A lost log line is recoverable; a dangerous command that ran is not.
if [[ "$PY_OK" == "1" ]]; then
printf '%s\t%s\t%s\t%s\t%s\t%s' \
  "$TIMESTAMP" "$MODE" "$TOOL_NAME" "$THREAT_COUNT" "$SUMMARY" "$(printf '%s\n' "${THREATS[@]}")" \
  | python3 -c '
import sys, json

raw = sys.stdin.read().split("\t", 5)
timestamp, mode, tool, count, summary, rows = raw
threats = []
for row in rows.strip().split("\n"):
    if not row.strip():
        continue
    field = row.split("\t")
    while len(field) < 4:
        field.append("")
    threats.append({
        "category": field[0],
        "severity": field[1],
        "match": field[2],
        "suggestion": field[3],
    })
entry = {
    "timestamp": timestamp,
    "event": "threats_detected",
    "mode": mode,
    "tool": tool,
    "threat_count": int(count),
    "threats": threats,
}
with open(sys.argv[1], "a", encoding="utf-8") as fh:
    fh.write(json.dumps(entry) + "\n")
' "$LOG_FILE" 2>/dev/null || echo "[WARN] guard-tool: could not write the guard log - the verdict below still stands" >&2
else
  echo "[WARN] guard-tool: skipping the audit line for $THREAT_COUNT threat(s) in '$TOOL_NAME' - python3 unavailable. The verdict below still stands." >&2
fi

if [[ "$OUTPUT" == "text" ]]; then
  echo ""
  echo "[GUARD]  Tool Guardian: $THREAT_COUNT threat(s) detected in '$TOOL_NAME' invocation"
  echo ""
  printf "  %-24s %-10s %-40s %s\n" "CATEGORY" "SEVERITY" "MATCH" "SUGGESTION"
  printf "  %-24s %-10s %-40s %s\n" "--------" "--------" "-----" "----------"
  for threat in "${THREATS[@]}"; do
    IFS=$'\t' read -r category severity match suggestion <<< "$threat"
    display_match="$match"
    if [[ ${#match} -gt 38 ]]; then
      display_match="${match:0:35}..."
    fi
    printf "  %-24s %-10s %-40s %s\n" "$category" "$severity" "$display_match" "$suggestion"
  done
  echo ""
  if [[ "$MODE" == "block" ]]; then
    echo "[BLOCKED] Operation blocked: resolve the threats above or adjust TOOL_GUARD_ALLOWLIST."
    echo "   Set GUARD_MODE=warn to log without blocking."
    exit 1
  fi
  echo "[WARN]  Threats logged in warn mode. Set GUARD_MODE=block to prevent dangerous operations."
  exit 0
fi

# Hook form: deny in block mode, advise in warn mode. Always exit 0 - the
# decision travels in the JSON, exactly as pre-tool-use.sh does it.
REASON="[BLOCKED] Tool Guardian: ${THREAT_COUNT} threat(s) detected.
${SUMMARY}Resolve these, or set TOOL_GUARD_ALLOWLIST / GUARD_MODE=warn if this is intended."

if printf '%s\t%s' "$MODE" "$REASON" | python3 -c '
import sys, json

mode, reason = sys.stdin.read().split("\t", 1)
if mode == "block":
    out = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }
else:
    out = {"systemMessage": reason, "continue": True}
print(json.dumps(out))
' 2>/dev/null; then
  exit 0
fi

# THE ANSWER ITSELF CANNOT DEPEND ON THE INTERPRETER.
#
# python3 builds the response so that a matched command containing quotes, tabs or backslashes
# cannot produce malformed JSON - that reasoning is sound and the normal path keeps it. But it
# meant a broken or missing python3 left the guard unable to SPEAK: threats detected, verdict
# decided, and then nothing on stdout and a non-zero exit. Measured 2026-08-12 with a python3 stub
# exiting 127 - this script exited 127 with empty output after correctly identifying `rm -rf /`.
#
# This fallback emits a STATIC response with no interpolation of any kind. That is deliberate:
# the reason text is the one thing that would need escaping, so it is dropped entirely rather than
# risking malformed JSON at the moment the guard is trying to block something. The detail is
# already on stderr and in the log; what has to survive is the DECISION.
echo "[WARN] guard-tool: python3 could not render the response - emitting a static verdict" >&2
if [[ "$MODE" == "block" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"[BLOCKED] Tool Guardian detected a dangerous operation. The full report could not be rendered because python3 is unavailable; see stderr and the guard log. Resolve the threat, or set TOOL_GUARD_ALLOWLIST / GUARD_MODE=warn if this is intended."}}'
else
  echo '{"systemMessage":"[WARN] Tool Guardian detected a threat in warn mode, but python3 is unavailable to render the detail. See stderr and the guard log.","continue":true}'
fi
exit 0
