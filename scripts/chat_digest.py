#!/usr/bin/env python3
"""Extract a readable chat digest from Copilot session log files.

Produces a condensed markdown file with:
- All user messages in full
- Assistant reasoning text (code blocks stripped — code is in the repo)

Strips: JSON overhead, tool calls/results, code blocks, metadata, turn markers.

Handles two formats:
- JSONL (line-delimited JSON with "type" field) — newer Copilot agent exports
- VS Code native (single JSON object with "requests" array) — older exports

Usage:
    python scripts/chat_digest.py Logs/chat/2026-04-29-session.jsonl
    python scripts/chat_digest.py --all                  # process all .jsonl files
    python scripts/chat_digest.py                        # auto-selects most recent
    python scripts/chat_digest.py --no-cap               # skip the 320KB size cap
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

# Maximum digest size in bytes. Marathon sessions (8+ hours) can produce 1MB+ digests
# that consume 35%+ of the context window. Capping at 320KB (~80K tokens) keeps startup
# at ~8% of the window. The full raw .jsonl is always preserved in Logs/chat/archive/.
MAX_DIGEST_BYTES = 320 * 1024  # 320KB

# Minimum length for assistant blocks to be included. Blocks shorter than this are
# procedural narration ("Now reading...", "Step 4:", "Let me check...") that carry
# no reasoning. The actual "because" is always in longer blocks.
MIN_ASSISTANT_BLOCK_CHARS = 100

from scripts.logging_config import setup_logging

logger = setup_logging("chat_digest")


def strip_code_blocks(text: str) -> str:
    """Remove fenced code blocks from text, keeping reasoning.

    Args:
        text: Markdown text potentially containing ```...``` blocks.

    Returns:
        Text with code blocks removed.
    """
    lines = text.split("\n")
    result: list[str] = []
    in_code = False
    for line in lines:
        if line.strip().startswith("```"):
            in_code = not in_code
            continue
        if not in_code:
            result.append(line)
    return "\n".join(result)


def extract_from_jsonl(path: Path) -> tuple[list[dict[str, str]], int]:
    """Extract messages from JSONL format (line-delimited, "type" field).

    Args:
        path: Path to the .jsonl file.

    Returns:
        Tuple of (message list, lines read). Each message has "role" and "content".
    """
    logger.info("extract_from_jsonl: path=%s", path)
    messages: list[dict[str, str]] = []
    lines_read = 0

    with open(path, encoding="utf-8") as f:
        for line in f:
            lines_read += 1
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg_type = obj.get("type", "")
            ts = obj.get("timestamp", "")
            ts_short = ts[11:19] if len(ts) >= 19 else ts

            if msg_type == "user.message":
                content = obj.get("data", {}).get("content", "")
                if content:
                    messages.append(
                        {"role": "USER", "content": content, "ts": ts_short}
                    )

            elif msg_type == "assistant.message":
                content = obj.get("data", {}).get("content", "")
                if content:
                    messages.append(
                        {"role": "ASSISTANT", "content": content, "ts": ts_short}
                    )

    logger.info(
        "extract_from_jsonl: %d lines, %d messages extracted", lines_read, len(messages)
    )
    return messages, lines_read


def extract_from_vscode_native(path: Path) -> tuple[list[dict[str, str]], int]:
    """Extract messages from VS Code native format (single or multi JSON with "requests" array).

    Args:
        path: Path to the .jsonl file.

    Returns:
        Tuple of (message list, lines read). Each message has "role" and "content".
    """
    logger.info("extract_from_vscode_native: path=%s", path)
    messages: list[dict[str, str]] = []

    # Parse line-delimited JSON objects (VS Code incremental patch format)
    # Line 0: base object with {kind, v: {requests: [...], ...}}
    # Lines 1+: patches with {kind, k: [path...], v: value}
    #   k=['requests'] → new request array (contains user messages)
    #   k=['requests', N, 'response'] → assistant response parts
    data_objects = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
                if isinstance(obj, dict):
                    data_objects.append(obj)
            except json.JSONDecodeError:
                continue

    for data in data_objects:
        k = data.get("k")
        v = data.get("v")

        # Base object (line 0): extract user messages from initial requests
        if k is None:
            inner = data.get("v", {})
            if isinstance(inner, dict):
                for req in inner.get("requests", []):
                    if isinstance(req, dict):
                        msg = req.get("message", {})
                        if isinstance(msg, dict):
                            text = msg.get("text", "") or msg.get("content", "")
                            if text:
                                messages.append(
                                    {"role": "USER", "content": text, "ts": ""}
                                )
            continue

        if not isinstance(k, list) or v is None:
            continue

        # Patch: k=['requests'] → full request array update with user messages
        if k == ["requests"] and isinstance(v, list):
            for req in v:
                if isinstance(req, dict):
                    msg = req.get("message", {})
                    if isinstance(msg, dict):
                        text = msg.get("text", "") or msg.get("content", "")
                        if text:
                            messages.append({"role": "USER", "content": text, "ts": ""})

        # Patch: k=['requests', N, 'response'] → assistant response parts
        if (
            len(k) == 3
            and k[0] == "requests"
            and k[2] == "response"
            and isinstance(v, list)
        ):
            for part in v:
                if not isinstance(part, dict):
                    continue
                kind = part.get("kind", "")
                # Skip tool invocations — only want markdown content
                if kind == "toolInvocationSerialized":
                    continue
                # markdownContent has content.value
                if kind == "markdownContent":
                    content = part.get("content", {})
                    if isinstance(content, dict):
                        val = content.get("value", "")
                        if val and isinstance(val, str):
                            messages.append(
                                {"role": "ASSISTANT", "content": val, "ts": ""}
                            )
                    continue
                # Other kinds may have a direct value string
                val = part.get("value", "")
                if isinstance(val, str) and len(val) > 20:
                    messages.append({"role": "ASSISTANT", "content": val, "ts": ""})

    logger.info(
        "extract_from_vscode_native: %d objects, %d messages extracted",
        len(data_objects),
        len(messages),
    )
    return messages, len(data_objects)


def detect_format(path: Path) -> str:
    """Detect whether a file is JSONL or VS Code native format.

    Args:
        path: Path to the file.

    Returns:
        "jsonl" or "vscode_native".
    """
    with open(path, encoding="utf-8") as f:
        first_line = f.readline().strip()

    try:
        obj = json.loads(first_line)
    except json.JSONDecodeError:
        return "jsonl"

    if "type" in obj:
        return "jsonl"
    if "kind" in obj or "v" in obj or "requests" in obj:
        return "vscode_native"
    return "jsonl"


def build_digest(
    messages: list[dict[str, str]], source_name: str, input_bytes: int
) -> str:
    """Build a markdown digest from extracted messages.

    Args:
        messages: List of message dicts with "role", "content", "ts".
        source_name: Name of the source file (for header).
        input_bytes: Size of the original file.

    Returns:
        Markdown-formatted conversation digest.
    """
    parts: list[str] = [f"# Chat Digest: {source_name}\n"]
    user_count = 0
    asst_count = 0

    for msg in messages:
        role = msg["role"]
        content = msg["content"]
        ts = msg.get("ts", "")
        ts_label = f"[{ts}] " if ts else ""

        if role == "USER":
            user_count += 1
            parts.append(f"\n## {ts_label}USER\n{content}\n")
        elif role == "ASSISTANT":
            cleaned = strip_code_blocks(content)
            if cleaned.strip():
                if len(cleaned.strip()) < MIN_ASSISTANT_BLOCK_CHARS:
                    continue
                asst_count += 1
                parts.append(f"\n## {ts_label}ASSISTANT\n{cleaned}\n")

    output = "".join(parts)
    output_bytes = len(output.encode("utf-8"))

    reduction = (1 - output_bytes / input_bytes) * 100 if input_bytes > 0 else 0
    summary = (
        f"\n---\n"
        f"**Digest stats:** {user_count} user + {asst_count} assistant messages | "
        f"Input: {input_bytes / 1024:.0f} KB → Output: {output_bytes / 1024:.0f} KB "
        f"({reduction:.0f}% reduction)\n"
    )
    output += summary

    logger.info(
        "build_digest: %d user, %d assistant, input=%d KB, output=%d KB (%.0f%% reduction)",
        user_count,
        asst_count,
        input_bytes // 1024,
        output_bytes // 1024,
        reduction,
    )

    return output


def process_file(jsonl_path: Path) -> Path:
    """Process a single chat log file into a digest.

    Args:
        jsonl_path: Path to the .jsonl file.

    Returns:
        Path to the written digest file.
    """
    logger.info("process_file: %s", jsonl_path)
    input_bytes = jsonl_path.stat().st_size

    fmt = detect_format(jsonl_path)
    logger.info("process_file: detected format=%s", fmt)

    if fmt == "vscode_native":
        messages, _ = extract_from_vscode_native(jsonl_path)
    else:
        messages, _ = extract_from_jsonl(jsonl_path)

    if not messages:
        logger.warning("process_file: no messages extracted from %s", jsonl_path)
        return jsonl_path

    digest = build_digest(messages, jsonl_path.stem, input_bytes)

    # Cap marathon digests: keep the most recent conversation (end of file)
    no_cap = "--no-cap" in sys.argv
    if not no_cap and len(digest.encode("utf-8")) > MAX_DIGEST_BYTES:
        original_size = len(digest.encode("utf-8"))
        # Truncate from the top, keeping the tail (most recent conversation)
        digest_bytes = digest.encode("utf-8")
        truncated = digest_bytes[-MAX_DIGEST_BYTES:].decode("utf-8", errors="ignore")
        # Find first complete section header to avoid partial content
        first_header = truncated.find("\n## ")
        if first_header > 0:
            truncated = truncated[first_header + 1 :]
        cap_note = (
            f"<!-- DIGEST CAPPED: {original_size // 1024}KB → {MAX_DIGEST_BYTES // 1024}KB. "
            f"Early conversation trimmed. Full raw .jsonl in Logs/chat/archive/ -->\n\n"
        )
        digest = cap_note + truncated
        logger.info(
            "process_file: capped digest %dKB → %dKB",
            original_size // 1024,
            len(digest.encode("utf-8")) // 1024,
        )

    # Always write digest to Logs/chat/ (not archive/)
    chat_dir = Path("Logs/chat")
    out_path = chat_dir / f"{jsonl_path.stem}-digest.md"
    out_path.write_text(digest, encoding="utf-8")
    logger.info("process_file: wrote %s (%d KB)", out_path, len(digest) // 1024)

    return out_path


def find_latest_chat_log() -> Path:
    """Find the most recent .jsonl in Logs/chat/ or Logs/chat/archive/.

    Returns:
        Path to the most recent .jsonl file.

    Raises:
        FileNotFoundError: If no .jsonl files exist.
    """
    chat_dir = Path("Logs/chat")
    if not chat_dir.exists():
        logger.error("find_latest_chat_log: Logs/chat/ not found")
        raise FileNotFoundError("Logs/chat/ directory not found")

    # Check both Logs/chat/ and Logs/chat/archive/
    jsonl_files = list(chat_dir.glob("*.jsonl"))
    archive_dir = chat_dir / "archive"
    if archive_dir.exists():
        jsonl_files.extend(archive_dir.glob("*.jsonl"))

    jsonl_files.sort(key=lambda p: p.stat().st_mtime)
    if not jsonl_files:
        logger.error("find_latest_chat_log: no .jsonl files found")
        raise FileNotFoundError("No .jsonl files in Logs/chat/ or Logs/chat/archive/")

    latest = jsonl_files[-1]
    logger.info("find_latest_chat_log: selected %s", latest)
    return latest


def main() -> None:
    """CLI entry point."""
    process_all = "--all" in sys.argv

    if process_all:
        chat_dir = Path("Logs/chat")
        # Collect .jsonl from both Logs/chat/ and Logs/chat/archive/
        jsonl_files = list(chat_dir.glob("*.jsonl"))
        archive_dir = chat_dir / "archive"
        if archive_dir.exists():
            jsonl_files.extend(archive_dir.glob("*.jsonl"))
        jsonl_files.sort(key=lambda p: p.name)

        logger.info("main: processing ALL %d .jsonl files", len(jsonl_files))
        for f in jsonl_files:
            digest_path = chat_dir / f"{f.stem}-digest.md"
            if digest_path.exists():
                logger.info("main: skip %s (digest exists)", f.name)
                sys.stderr.write(f"  SKIP {f.name} (digest exists)\n")
                continue
            out = process_file(f)
            out_size = out.stat().st_size if out.exists() else 0
            sys.stderr.write(f"  {f.name} → {out.name} ({out_size // 1024} KB)\n")
    else:
        if len(sys.argv) > 1 and not sys.argv[1].startswith("--"):
            jsonl_path = Path(sys.argv[1])
        else:
            jsonl_path = find_latest_chat_log()

        if not jsonl_path.exists():
            logger.error("main: file not found: %s", jsonl_path)
            sys.exit(1)

        out = process_file(jsonl_path)
        out_size = out.stat().st_size if out.exists() else 0
        sys.stderr.write(f"Wrote {out} ({out_size // 1024} KB)\n")


if __name__ == "__main__":
    main()
