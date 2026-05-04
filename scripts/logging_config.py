#!/usr/bin/env python3
"""
Centralized Logging Configuration

Usage:
    from scripts.logging_config import setup_logging, log_subprocess_result, log_file_operation
    logger = setup_logging("backend")

Categories (default rotation):
    backend, frontend  — 50MB × 10 backups
    tests              — 10MB × 5 backups
    deployment, build  — 10MB × 3 backups
    Custom categories   — 10MB × 5 backups (override with params)

Features:
    - Rotating file handlers with gzip compression on rotation
    - Archived logs moved to Logs/logging/archive/
    - Archives older than 90 days auto-cleaned on rotation
    - Obsidian error summary generated on rotation
    - Console handler (INFO+) + file handler (DEBUG+)
    - Bootstrap fallback if logging setup itself fails
    - Global exception handler
    - Startup diagnostics
    - @log_timing / @log_timing_async decorators
    - Helper functions for subprocess, file ops, external calls, DB queries, config loading
    - Optional JSON structured output (STRUCTURED_LOGGING=true env var)
"""

from __future__ import annotations

import functools
import gzip
import logging
import logging.handlers
import os
import platform
import shutil
import subprocess
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Callable

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

_LOG_DIR = Path("Logs/logging")
_ARCHIVE_DIR = _LOG_DIR / "archive"
_ARCHIVE_RETENTION_DAYS = 90

_CATEGORY_DEFAULTS: dict[str, tuple[int, int]] = {
    "backend": (50 * 1024 * 1024, 10),
    "frontend": (50 * 1024 * 1024, 10),
    "tests": (10 * 1024 * 1024, 5),
    "deployment": (10 * 1024 * 1024, 3),
    "build": (10 * 1024 * 1024, 3),
    "terminal": (10 * 1024 * 1024, 5),
}

_DEFAULT_MAX_BYTES = 10 * 1024 * 1024
_DEFAULT_BACKUP_COUNT = 5

_FORMAT = "%(asctime)s.%(msecs)03d | %(name)s | %(levelname)s | %(module)s.%(funcName)s:%(lineno)d | %(message)s"
_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

_JSON_FORMAT = (
    '{{"timestamp":"%(asctime)s.%(msecs)03d","level":"%(levelname)s",'
    '"logger":"%(name)s","module":"%(module)s","function":"%(funcName)s",'
    '"line":%(lineno)d,"message":"%(message)s"}}'
)

# ---------------------------------------------------------------------------
# Compressed rotation + archive + cleanup
# ---------------------------------------------------------------------------


def _gzip_rotator(source: str, dest: str) -> None:
    """Compress rotated log file and move to archive directory."""
    _ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_name = Path(source).stem
    archive_name = _ARCHIVE_DIR / f"{base_name}_{timestamp}.log.gz"

    with open(source, "rb") as f_in:
        with gzip.open(archive_name, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    os.remove(source)

    _cleanup_old_archives()
    _write_obsidian_error_summary(source, base_name, timestamp)


def _gzip_namer(name: str) -> str:
    return name + ".gz"


def _cleanup_old_archives() -> None:
    """Delete archive files older than retention period."""
    if not _ARCHIVE_DIR.exists():
        return
    cutoff = datetime.now() - timedelta(days=_ARCHIVE_RETENTION_DAYS)
    for gz_file in _ARCHIVE_DIR.glob("*.log.gz"):
        try:
            mtime = datetime.fromtimestamp(gz_file.stat().st_mtime)
            if mtime < cutoff:
                gz_file.unlink()
        except OSError:
            pass


def _write_obsidian_error_summary(source: str, category: str, timestamp: str) -> None:
    """Extract ERROR/WARNING/CRITICAL lines and write summary to Logs/logging/."""
    summary_dir = _LOG_DIR / "summaries"
    summary_dir.mkdir(parents=True, exist_ok=True)

    date_str = datetime.now().strftime("%Y-%m-%d")
    summary_path = summary_dir / f"{date_str}-{category}-summary.md"

    errors: list[str] = []
    warnings: list[str] = []
    total_lines = 0

    archive_path = _ARCHIVE_DIR / f"{category}_{timestamp}.log.gz"
    try:
        with gzip.open(archive_path, "rt", encoding="utf-8", errors="replace") as f:
            for line in f:
                total_lines += 1
                if "| ERROR |" in line or "| CRITICAL |" in line:
                    errors.append(line.strip())
                elif "| WARNING |" in line:
                    warnings.append(line.strip())
    except (OSError, gzip.BadGzipFile):
        return

    content = f"# Log Summary: {category} {date_str}\n\n"
    content += f"## Errors ({len(errors)})\n"
    for e in errors[-50:]:
        content += f"- {e}\n"
    content += f"\n## Warnings ({len(warnings)})\n"
    for w in warnings[-50:]:
        content += f"- {w}\n"
    content += f"\n## Stats\n- Total events: {total_lines:,}\n"
    content += f"- Errors: {len(errors)}\n- Warnings: {len(warnings)}\n"

    with open(summary_path, "w", encoding="utf-8") as f:
        f.write(content)


# ---------------------------------------------------------------------------
# Core setup
# ---------------------------------------------------------------------------


def setup_logging(
    category: str,
    max_bytes: int | None = None,
    backup_count: int | None = None,
) -> logging.Logger:
    """Configure and return a logger for the given category.

    Args:
        category: Logger name and log file prefix (e.g., "backend", "deployment").
        max_bytes: Max size per log file before rotation. Defaults per category.
        backup_count: Number of uncompressed backup files to keep. Defaults per category.

    Returns:
        Configured logger instance.
    """
    try:
        _LOG_DIR.mkdir(parents=True, exist_ok=True)
        _ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)

        defaults = _CATEGORY_DEFAULTS.get(
            category, (_DEFAULT_MAX_BYTES, _DEFAULT_BACKUP_COUNT)
        )
        if max_bytes is None:
            max_bytes = defaults[0]
        if backup_count is None:
            backup_count = defaults[1]

        logger = logging.getLogger(category)
        if logger.handlers:
            return logger
        logger.setLevel(logging.DEBUG)

        use_json = os.environ.get("STRUCTURED_LOGGING", "").lower() in (
            "true",
            "1",
            "yes",
        )
        fmt_str = _JSON_FORMAT if use_json else _FORMAT
        formatter = logging.Formatter(fmt_str, datefmt=_DATE_FORMAT)

        # File handler — DEBUG+, rotating, compressed archival
        file_handler = logging.handlers.RotatingFileHandler(
            _LOG_DIR / f"{category}.log",
            maxBytes=max_bytes,
            backupCount=backup_count,
            encoding="utf-8",
        )
        file_handler.rotator = _gzip_rotator
        file_handler.namer = _gzip_namer
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

        # Console handler — INFO+
        console_handler = logging.StreamHandler(sys.stderr)
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)

        logger.info(
            "Logging system initialized: category=%s, file=%s, max=%dMB, backups=%d",
            category,
            _LOG_DIR / f"{category}.log",
            max_bytes // (1024 * 1024),
            backup_count,
        )
        return logger

    except Exception:
        # Bootstrap fallback — if logging setup fails, at least stderr works
        logging.basicConfig(
            level=logging.DEBUG, stream=sys.stderr, format=_FORMAT, datefmt=_DATE_FORMAT
        )
        fallback = logging.getLogger(category)
        fallback.error(
            "Logging setup failed for category '%s', using stderr fallback",
            category,
            exc_info=True,
        )
        return fallback


# ---------------------------------------------------------------------------
# Global exception handler
# ---------------------------------------------------------------------------


def install_global_exception_handler(logger: logging.Logger | None = None) -> None:
    """Install a global exception handler that logs unhandled exceptions."""
    _logger = logger or logging.getLogger("unhandled")

    def _handler(exc_type: type, exc_value: BaseException, exc_tb: Any) -> None:
        if issubclass(exc_type, KeyboardInterrupt):
            sys.__excepthook__(exc_type, exc_value, exc_tb)
            return
        _logger.critical(
            "Unhandled exception",
            exc_info=(exc_type, exc_value, exc_tb),
        )

    sys.excepthook = _handler


# ---------------------------------------------------------------------------
# Startup diagnostics
# ---------------------------------------------------------------------------


def log_startup_diagnostics(logger: logging.Logger) -> None:
    """Log environment state at application startup."""
    logger.info("=== STARTUP DIAGNOSTICS ===")
    logger.info("Python: %s", sys.version)
    logger.info("Platform: %s %s", platform.system(), platform.release())
    logger.info("Machine: %s", platform.machine())
    logger.info("CWD: %s", os.getcwd())
    logger.info("PID: %d", os.getpid())

    # Log env vars (mask secrets)
    secret_keys = {
        "password",
        "secret",
        "key",
        "token",
        "credential",
        "sas",
        "connection",
    }
    for k, v in sorted(os.environ.items()):
        if any(s in k.lower() for s in secret_keys):
            logger.info("ENV %s = ****", k)
        else:
            logger.info("ENV %s = %s", k, v)

    # Disk space
    try:
        usage = shutil.disk_usage(os.getcwd())
        logger.info(
            "Disk: %.1fGB free / %.1fGB total",
            usage.free / (1024**3),
            usage.total / (1024**3),
        )
    except OSError:
        logger.warning("Could not read disk usage")

    # Installed packages
    try:
        result = subprocess.run(
            [sys.executable, "-m", "pip", "list", "--format=columns"],
            capture_output=True,
            text=True,
            timeout=15,
        )
        if result.returncode == 0:
            logger.info("Installed packages:\n%s", result.stdout)
        else:
            logger.warning("pip list failed: %s", result.stderr)
    except (subprocess.TimeoutExpired, FileNotFoundError):
        logger.warning("Could not list installed packages")

    logger.info("=== END STARTUP DIAGNOSTICS ===")


# ---------------------------------------------------------------------------
# Decorators
# ---------------------------------------------------------------------------


def log_timing(func: Callable) -> Callable:
    """Decorator that logs function entry, exit, timing, and errors."""

    @functools.wraps(func)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        logger = logging.getLogger(func.__module__)
        logger.debug("ENTER %s(args=%s, kwargs=%s)", func.__qualname__, args, kwargs)
        start = time.perf_counter()
        try:
            result = func(*args, **kwargs)
            elapsed = (time.perf_counter() - start) * 1000
            logger.debug(
                "EXIT  %s → %s (%.1fms)", func.__qualname__, _summarize(result), elapsed
            )
            return result
        except Exception as exc:
            elapsed = (time.perf_counter() - start) * 1000
            logger.error(
                "FAIL  %s raised %s: %s (%.1fms)",
                func.__qualname__,
                type(exc).__name__,
                exc,
                elapsed,
            )
            raise

    return wrapper


def log_timing_async(func: Callable) -> Callable:
    """Async version of log_timing."""

    @functools.wraps(func)
    async def wrapper(*args: Any, **kwargs: Any) -> Any:
        logger = logging.getLogger(func.__module__)
        logger.debug("ENTER %s(args=%s, kwargs=%s)", func.__qualname__, args, kwargs)
        start = time.perf_counter()
        try:
            result = await func(*args, **kwargs)
            elapsed = (time.perf_counter() - start) * 1000
            logger.debug(
                "EXIT  %s → %s (%.1fms)", func.__qualname__, _summarize(result), elapsed
            )
            return result
        except Exception as exc:
            elapsed = (time.perf_counter() - start) * 1000
            logger.error(
                "FAIL  %s raised %s: %s (%.1fms)",
                func.__qualname__,
                type(exc).__name__,
                exc,
                elapsed,
            )
            raise

    return wrapper


def _summarize(value: Any, max_len: int = 200) -> str:
    """Summarize a return value for logging without flooding."""
    s = repr(value)
    if len(s) > max_len:
        return s[:max_len] + "..."
    return s


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------


def log_subprocess_result(
    logger: logging.Logger,
    result: subprocess.CompletedProcess,
    command_desc: str = "",
) -> None:
    """Log the result of a subprocess call with full output."""
    desc = (
        command_desc or " ".join(str(a) for a in result.args)
        if result.args
        else "unknown"
    )
    logger.info("SUBPROCESS: %s → exit_code=%d", desc, result.returncode)
    if result.stdout:
        logger.debug(
            "STDOUT:\n%s",
            result.stdout
            if isinstance(result.stdout, str)
            else result.stdout.decode("utf-8", errors="replace"),
        )
    if result.stderr:
        log_level = logging.ERROR if result.returncode != 0 else logging.DEBUG
        logger.log(
            log_level,
            "STDERR:\n%s",
            result.stderr
            if isinstance(result.stderr, str)
            else result.stderr.decode("utf-8", errors="replace"),
        )


def log_file_operation(
    logger: logging.Logger,
    operation: str,
    path: str | Path,
    **extra: Any,
) -> None:
    """Log a file operation with path and size."""
    p = Path(path)
    size = p.stat().st_size if p.exists() else 0
    logger.info(
        "FILE %s: %s (%d bytes) %s",
        operation.upper(),
        p,
        size,
        " ".join(f"{k}={v}" for k, v in extra.items()) if extra else "",
    )


def log_external_call(
    logger: logging.Logger,
    url: str,
    method: str,
    status_code: int,
    elapsed_ms: float,
    **extra: Any,
) -> None:
    """Log an external HTTP call with timing."""
    level = logging.INFO if 200 <= status_code < 400 else logging.ERROR
    logger.log(
        level,
        "HTTP %s %s → %d (%.1fms) %s",
        method.upper(),
        url,
        status_code,
        elapsed_ms,
        " ".join(f"{k}={v}" for k, v in extra.items()) if extra else "",
    )


def log_db_query(
    logger: logging.Logger,
    query: str,
    params: Any = None,
    row_count: int | None = None,
    elapsed_ms: float = 0,
) -> None:
    """Log a database query with params, row count, and timing."""
    logger.info(
        "DB QUERY (%.1fms, %s rows): %s | params=%s",
        elapsed_ms,
        row_count if row_count is not None else "?",
        query[:500],
        params,
    )


def log_config_loaded(
    logger: logging.Logger,
    source: str,
    keys: list[str],
    secret_keys: set[str] | None = None,
) -> None:
    """Log config loading with key names (mask secret values)."""
    _secrets = secret_keys or {"password", "secret", "key", "token", "credential"}
    logger.info("CONFIG loaded from: %s", source)
    for k in keys:
        if any(s in k.lower() for s in _secrets):
            logger.info("  %s = ****", k)
        else:
            logger.info("  %s = (loaded)", k)
