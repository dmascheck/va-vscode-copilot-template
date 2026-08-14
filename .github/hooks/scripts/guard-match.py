#!/usr/bin/env python3
"""guard-match.py - the semantic half of guard-tool.sh. Reads a command line on stdin,
writes one TAB-separated threat per line (category, severity, match, suggestion).

It lives in its OWN FILE rather than inside a `python3 -c '...'` string because an
apostrophe in any message silently terminates that
shell string and truncates the program. Measured 2026-08-14: the guard went FAIL-OPEN,
allowing 16 of 16 dangerous commands while reporting "clean". A file has no such edge.
"""

import re
import shlex
import sys

TEXT = sys.stdin.read()

# Commands that only READ. A segment led by one of these cannot execute the thing it
# names, so content patterns (SQL, sudo, npm publish) must not fire on it: `grep -rn
# "DROP TABLE" migrations/` is a search, not a schema change (measured false positive,
# 2026-08-14 fault-injection sweep).
READ_ONLY = {
    "grep",
    "egrep",
    "fgrep",
    "rg",
    "ag",
    "ack",
    "cat",
    "bat",
    "less",
    "more",
    "head",
    "tail",
    "wc",
    "jq",
    "yq",
    "ls",
    "stat",
    "file",
    "diff",
    "comm",
    "sort",
    "uniq",
    "echo",
    "printf",
    "awk",
    "cut",
    "tr",
    "column",
    "tee",
    "man",
    "which",
    "type",
    "command",
    "test",
    "true",
    "false",
    "pwd",
    "date",
    "basename",
    "dirname",
    "realpath",
}
# Absolute/system roots whose wholesale removal is catastrophic. A path DEEPER than
# these is ordinary work (`rm -rf /tmp/build-cache` is a cache clean, not a disaster).
PROTECTED = {
    "/",
    "/*",
    "~",
    "~/",
    "~/*",
    ".",
    "./",
    "./*",
    "..",
    "../",
    "$HOME",
    "${HOME}",
    "/bin",
    "/boot",
    "/dev",
    "/etc",
    "/home",
    "/lib",
    "/opt",
    "/private",
    "/root",
    "/sbin",
    "/System",
    "/tmp",
    "/usr",
    "/var",
    "/Users",
    "/Library",
    "/Applications",
}
SHELLS = {
    "bash",
    "sh",
    "zsh",
    "dash",
    "ksh",
    "fish",
    "python",
    "python3",
    "perl",
    "ruby",
    "node",
}
DB_CLIENTS = {
    "sqlite3",
    "psql",
    "mysql",
    "mariadb",
    "mongo",
    "mongosh",
    "sqlcmd",
    "bcp",
    "usql",
}
SENSITIVE_FILE = re.compile(
    r"\.(env|pem|key|p12|pfx|keystore)\b|id_rsa|id_ed25519|credential|secret", re.I
)

THREATS = []


def add(category, severity, match, suggestion):
    THREATS.append((category, severity, match[:160], suggestion))


def segments(text):
    """Split a command line into independently-analysable segments.

    Splitting on &&, ||, ;, | and newlines is what stops an `rm` in one segment pairing
    with an unrelated `.env` in another - the `(rm|del|unlink).*\\.env` rule matched
    `rm -f tmp.txt && cp .env.example .env.local` exactly that way.
    """
    parts = re.split(r"\s*(?:\|\||&&|[;|\n])\s*", text)
    return [p.strip() for p in parts if p.strip()]


def tokens(segment):
    try:
        return shlex.split(segment)
    except ValueError:
        return segment.split()


def head_command(toks):
    """First real command word, skipping env assignments and simple prefixes.

    Lower-cased: the old grep scan was case-insensitive, and while `RM` is not a real
    command on a case-sensitive lookup, dropping that coverage silently would be a
    reduction nobody asked for (found by the 2026-08-14 evasion sweep).
    """
    for t in toks:
        if re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", t):
            continue
        if t.lower() in ("time", "nohup", "exec", "nice", "env"):
            continue
        return t.rsplit("/", 1)[-1].lower()
    return ""


for seg in segments(TEXT):
    toks = tokens(seg)
    if not toks:
        continue
    cmd = head_command(toks)
    low = seg.lower()
    read_only = cmd in READ_ONLY

    # ---- rm: judge the TARGET, not the mere presence of the verb -------------
    if cmd in ("rm", "unlink") and not read_only:
        flags = "".join(t for t in toks[1:] if t.startswith("-"))
        recursive = "r" in flags.lower()
        targets = [t for t in toks[1:] if not t.startswith("-")]
        for tgt in targets:
            norm = tgt.rstrip("/") or "/"
            if (
                tgt in PROTECTED
                or norm in PROTECTED
                or re.fullmatch(r"/[A-Za-z]+/?\*?", tgt)
            ):
                add(
                    "destructive_file_ops",
                    "critical",
                    f"{cmd} {tgt}",
                    "Target a path inside the directory, not the root itself",
                )
            elif re.fullmatch(r"(~|\$HOME|\$\{HOME\})/?\*?", tgt):
                add(
                    "destructive_file_ops",
                    "critical",
                    f"{cmd} {tgt}",
                    "Target a path under the home directory, not home itself",
                )
            elif re.search(r"(^|/)\.git/?$", tgt):
                add(
                    "destructive_file_ops",
                    "critical",
                    f"{cmd} {tgt}",
                    "Never delete .git - use git commands to manage repository state",
                )
            elif SENSITIVE_FILE.search(tgt) and not tgt.endswith(
                (".env.example", ".env.project")
            ):
                add(
                    "destructive_file_ops",
                    "critical",
                    f"{cmd} {tgt}",
                    "Use 'mv' to back up a secret-bearing file before removing it",
                )
        if recursive and not targets:
            add(
                "destructive_file_ops",
                "critical",
                seg,
                "A recursive remove with no explicit target is unsafe",
            )

    # ---- git ----------------------------------------------------------------
    if cmd == "git":
        if (
            re.search(r"\bpush\b", low)
            and re.search(r"(--force(?!-with-lease)|(?<!\w)-f)\b", seg)
            and re.search(r"(?<![\w/-])(main|master)(?![\w/-])", seg)
        ):
            add(
                "destructive_git_ops",
                "critical",
                seg,
                "Use --force-with-lease, or push to a feature branch",
            )
        if re.search(r"\breset\b[^|]*--hard\b", low):
            add(
                "destructive_git_ops",
                "high",
                seg,
                "reset --hard discards uncommitted work - stash first, or use --soft",
            )
        if re.search(r"\bclean\b[^|]*(-[a-z]*f[a-z]*d|-[a-z]*d[a-z]*f)\b", low):
            add(
                "destructive_git_ops",
                "high",
                seg,
                "git clean deletes untracked files - run with -n first to preview",
            )

    # ---- SQL: only when a DB client is actually executing it -----------------
    sql_context = cmd in DB_CLIENTS or re.search(r"\b(az|aws)\b.*\bsql\b", low)
    if sql_context and not read_only:
        if re.search(r"\bdrop\s+(table|database)\b", low):
            add(
                "database_destruction",
                "critical",
                seg,
                "Use a reversible migration instead of DROP",
            )
        if re.search(r"\btruncate\s+table\b", low):
            add(
                "database_destruction",
                "critical",
                seg,
                "Use DELETE FROM ... WHERE for safer, reversible removal",
            )
        if re.search(
            r"\bdelete\s+from\s+[\w.\"`\[\]]+\s*(;|$|\")", low
        ) and not re.search(r"\bwhere\b", low):
            add(
                "database_destruction",
                "high",
                seg,
                "Add a WHERE clause - this deletes every row",
            )

    # ---- permissions --------------------------------------------------------
    if cmd in ("chmod", "chown") and re.search(r"(?<!\d)777(?!\d)", seg):
        add("permission_abuse", "high", seg, "Use 755 for directories or 644 for files")

    # ---- exfiltration: a download piped INTO an interpreter ------------------
    if cmd in ("curl", "wget"):
        if re.search(r"--data(-binary|-raw)?[= ]@", seg):
            arg = re.search(r"--data(?:-binary|-raw)?[= ]@(\S+)", seg)
            if arg and SENSITIVE_FILE.search(arg.group(1)):
                add(
                    "network_exfiltration",
                    "critical",
                    seg,
                    "This posts a secret-bearing file to a remote host",
                )

# A download piped into a shell interpreter is judged ACROSS segments: the pipe target
# has to actually be a shell (`curl ... | grep bash` is a search, not an execution).
raw_pipes = [p.strip() for p in re.split(r"\|(?!\|)", TEXT) if p.strip()]
for i, part in enumerate(raw_pipes[:-1]):
    src = head_command(tokens(part))
    dst = head_command(tokens(raw_pipes[i + 1]))
    if src in ("curl", "wget") and dst in SHELLS:
        add(
            "network_exfiltration",
            "critical",
            f"{part.strip()} | {raw_pipes[i + 1].strip()}",
            "Download the script, review it, then run it as a separate step",
        )

# ---- sudo / npm publish: judged on the COMMAND word, not a mention ----------
for seg in segments(TEXT):
    toks = tokens(seg)
    cmd = head_command(toks)
    if cmd == "sudo":
        add("system_danger", "high", seg, "Run with the least privilege needed")
    if (
        cmd == "npm"
        and re.search(r"\bpublish\b", seg)
        and not re.search(r"--dry-run\b", seg)
    ):
        add("system_danger", "high", seg, "Run 'npm publish --dry-run' first")

# ---- context-free safety net -------------------------------------------------
# Everything above judges CONTEXT (which command runs, what it targets), which is what
# removed 19 false positives. But a dangerous string can arrive in a payload shape this
# script cannot parse as a command line at all - an unrecognised tool field, a nested
# array. For a SMALL set of unmistakable strings, presence alone is enough: no benign
# command contains "DROP TABLE"/"DROP DATABASE" or a bare unqualified DELETE FROM, and a
# read-only mention (grep/cat) is excluded above by segments - so this net
# only sees payloads that produced no segment verdict at all.
# Only when NOTHING in the payload parsed as a runnable command - i.e. this is not a
# command line at all, so segment analysis had nothing to judge. A real command line
# (grep, cat, sqlite3...) has already been judged above and must not be re-judged here,
# which is exactly how `grep -rn "DROP TABLE" migrations/` stayed a false positive.
_looks_like_command = any(
    head_command(tokens(s)) in READ_ONLY | DB_CLIENTS | SHELLS
    or head_command(tokens(s))
    in ("rm", "git", "chmod", "chown", "curl", "wget", "sudo", "npm", "unlink")
    for s in segments(TEXT)
)
if not THREATS and not _looks_like_command:
    if re.search(r"\bdrop\s+(table|database)\b", TEXT, re.I):
        add(
            "database_destruction",
            "critical",
            TEXT.strip()[:120],
            "Use a reversible migration instead of DROP",
        )
    if re.search(r"\btruncate\s+table\b", TEXT, re.I):
        add(
            "database_destruction",
            "critical",
            TEXT.strip()[:120],
            "Use DELETE FROM ... WHERE for safer, reversible removal",
        )
    if re.search(
        r"\bdelete\s+from\s+[\w.\"`\[\]]+\s*(;|$)", TEXT, re.I
    ) and not re.search(r"\bwhere\b", TEXT, re.I):
        add(
            "database_destruction",
            "high",
            TEXT.strip()[:120],
            "Add a WHERE clause - this deletes every row",
        )

for category, severity, match, suggestion in THREATS:
    sys.stdout.write("\t".join((category, severity, match, suggestion)) + "\n")
