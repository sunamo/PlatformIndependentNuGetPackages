"""Ledger of complete per-file code quality reviews.

The ledger is `<repo>/.docs/file-reviews.jsonl`, one JSON object per line, append-only.
Each record says which file was read completely, when, why and what changed.

Usage:
  file-reviews.py add     --repo <root> --scope <scope> --reason <text> [--changes <text>]
                          [--tool <name>] [--run-id <id>] <file> [<file> ...]
  file-reviews.py pending --repo <root> --scope <scope> [--under <folder>] [--ext .cs]
  file-reviews.py status  --repo <root> [--scope <scope>] [--ext .cs]

`add` hashes the file as it is on disk right now, so call it after the last edit.
A file counts as reviewed for a scope only while its content hash still matches.
"""
import argparse
import datetime
import hashlib
import json
import os
import subprocess
import sys
import time
import uuid

LEDGER_RELATIVE_PATH = os.path.join(".docs", "file-reviews.jsonl")
LOCK_TIMEOUT_SECONDS = 30


def ledger_path(repo_root):
    """Return the absolute path of the ledger file of the repository."""
    return os.path.join(repo_root, LEDGER_RELATIVE_PATH)


def sha256_of_file(path):
    """Return the SHA256 hex digest of the file content."""
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for chunk in iter(lambda: stream.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_records(repo_root):
    """Read all ledger records; a missing ledger yields an empty list."""
    path = ledger_path(repo_root)
    if not os.path.exists(path):
        return []
    records = []
    with open(path, "r", encoding="utf-8") as stream:
        for line in stream:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    return records


def append_records(repo_root, records):
    """Append records to the ledger under an exclusive lock file, so parallel writers do not interleave."""
    path = ledger_path(repo_root)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    lock_path = path + ".lock"
    deadline = time.time() + LOCK_TIMEOUT_SECONDS
    while True:
        try:
            lock_handle = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
            break
        except FileExistsError:
            if time.time() > deadline:
                raise SystemExit(f"Ledger lock {lock_path} is held for more than {LOCK_TIMEOUT_SECONDS} s.")
            time.sleep(0.1)
    try:
        with open(path, "a", encoding="utf-8", newline="\n") as stream:
            for record in records:
                stream.write(json.dumps(record, ensure_ascii=False) + "\n")
    finally:
        os.close(lock_handle)
        os.remove(lock_path)


def tracked_files(repo_root, extension, under):
    """List tracked files of the repository including submodules, as forward-slash relative paths."""
    output = subprocess.run(
        ["git", "-C", repo_root, "ls-files", "--recurse-submodules"],
        capture_output=True, text=True, encoding="utf-8", check=True).stdout
    files = [line for line in output.splitlines() if line.lower().endswith(extension.lower())]
    if under:
        prefix = under.replace("\\", "/").rstrip("/") + "/"
        files = [file for file in files if file.startswith(prefix)]
    return files


def valid_reviews(repo_root, scope):
    """Map file -> latest record of the scope whose hash still matches the file on disk."""
    latest = {}
    for record in read_records(repo_root):
        if scope and record.get("scope") != scope:
            continue
        latest[record["file"]] = record
    valid = {}
    for file, record in latest.items():
        absolute = os.path.join(repo_root, file)
        if os.path.exists(absolute) and sha256_of_file(absolute) == record.get("sha256"):
            valid[file] = record
    return valid


def command_add(arguments):
    """Record a completed review of the given files."""
    repo_root = os.path.abspath(arguments.repo)
    run_id = arguments.run_id or uuid.uuid4().hex[:12]
    reviewed_utc = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    records = []
    for file in arguments.files:
        absolute = os.path.abspath(file if os.path.isabs(file) else os.path.join(repo_root, file))
        if not os.path.isfile(absolute):
            raise SystemExit(f"File not found: {absolute}")
        relative = os.path.relpath(absolute, repo_root).replace("\\", "/")
        records.append({
            "file": relative,
            "sha256": sha256_of_file(absolute),
            "reviewedUtc": reviewed_utc,
            "scope": arguments.scope,
            "reason": arguments.reason,
            "changes": arguments.changes or "",
            "tool": arguments.tool,
            "runId": run_id,
        })
    append_records(repo_root, records)
    print(f"Recorded {len(records)} file(s), runId {run_id}.")


def command_pending(arguments):
    """Print tracked files that have no valid review of the scope."""
    repo_root = os.path.abspath(arguments.repo)
    valid = valid_reviews(repo_root, arguments.scope)
    for file in tracked_files(repo_root, arguments.ext, arguments.under):
        if file not in valid:
            print(file)


def command_status(arguments):
    """Print reviewed / total counts per top-level folder."""
    repo_root = os.path.abspath(arguments.repo)
    valid = valid_reviews(repo_root, arguments.scope)
    totals = {}
    for file in tracked_files(repo_root, arguments.ext, None):
        top = file.split("/")[0]
        reviewed, total = totals.get(top, (0, 0))
        totals[top] = (reviewed + (1 if file in valid else 0), total + 1)
    reviewed_sum = sum(reviewed for reviewed, _ in totals.values())
    total_sum = sum(total for _, total in totals.values())
    for top in sorted(totals):
        reviewed, total = totals[top]
        if reviewed:
            print(f"{reviewed:5}/{total:<5} {top}")
    print(f"{reviewed_sum}/{total_sum} files reviewed")


def main():
    """Parse the command line and run the selected command."""
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)

    add = commands.add_parser("add")
    add.add_argument("--repo", required=True)
    add.add_argument("--scope", required=True)
    add.add_argument("--reason", required=True)
    add.add_argument("--changes")
    add.add_argument("--tool", default="AI")
    add.add_argument("--run-id")
    add.add_argument("files", nargs="+")
    add.set_defaults(handler=command_add)

    pending = commands.add_parser("pending")
    pending.add_argument("--repo", required=True)
    pending.add_argument("--scope", required=True)
    pending.add_argument("--under")
    pending.add_argument("--ext", default=".cs")
    pending.set_defaults(handler=command_pending)

    status = commands.add_parser("status")
    status.add_argument("--repo", required=True)
    status.add_argument("--scope")
    status.add_argument("--ext", default=".cs")
    status.set_defaults(handler=command_status)

    arguments = parser.parse_args()
    arguments.handler(arguments)


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
