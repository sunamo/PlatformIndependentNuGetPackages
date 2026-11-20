"""
Commits (and pushes to origin/claude) modified tracked files matching COMMIT_PATTERNS (default *.cs; COMMIT_UNTRACKED=1 adds untracked ones) in the parent repo and in every submodule.
Usage: python -I .scripts/commit-cs-changes-all-repos.py <root> <message-file> <result-json>
Only .cs files are staged; other local changes stay untouched. Commit and push each have a hard 20 s timeout.
The result JSON maps repo path -> {"hash": ..., "pushed": bool}.
"""
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ENV = dict(os.environ, GIT_TERMINAL_PROMPT="0", GCM_INTERACTIVE="never")


def git(repo, *args, timeout=20):
    """Runs a git command in the repo and returns the completed process."""
    return subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True, encoding="utf-8", timeout=timeout, env=ENV)


def handle(repo, message_file):
    """Stages modified .cs files, commits and pushes; returns a result dict or None when nothing changed."""
    patterns = os.environ.get("COMMIT_PATTERNS", "*.cs").split(",")
    files = [f for f in git(repo, "diff", "--name-only", "-z", "--", *patterns).stdout.split(chr(0)) if f]
    if os.environ.get("COMMIT_UNTRACKED") == "1":
        files += [f for f in git(repo, "ls-files", "--others", "--exclude-standard", "-z", "--", *patterns).stdout.split(chr(0)) if f]
    if not files:
        return None
    result = {"hash": None, "pushed": False, "files": len(files)}
    try:
        git(repo, "add", "--", *files)
        commit = git(repo, "commit", "-F", message_file)
        if commit.returncode != 0:
            result["error"] = "commit: " + (commit.stderr or commit.stdout)[-300:]
            return result
        result["hash"] = git(repo, "rev-parse", "HEAD").stdout.strip()
        push = git(repo, "push", "-u", "origin", "claude")
        result["pushed"] = push.returncode == 0
        if push.returncode != 0:
            result["error"] = "push: " + push.stderr[-300:]
    except subprocess.TimeoutExpired as ex:
        result["error"] = f"timeout: {ex.cmd[3:5]}"
        if result["hash"] is None:
            head = git(repo, "rev-parse", "HEAD").stdout.strip()
            result["hash"] = head
    return result


def main():
    root, message_file, out = sys.argv[1:4]
    names = git(root, "submodule", "--quiet", "foreach", "--recursive", "echo $displaypath").stdout.split()
    repos = [root] + [os.path.join(root, name) for name in names]
    results = {}
    with ThreadPoolExecutor(max_workers=6) as pool:
        for repo, res in zip(repos, pool.map(lambda r: handle(r, message_file), repos)):
            if res:
                results[os.path.relpath(repo, root) if repo != root else "."] = res
    with open(out, "w", encoding="utf-8") as handle_out:
        json.dump(results, handle_out, indent=1, ensure_ascii=False)
    failed = {k: v for k, v in results.items() if v.get("error")}
    print(f"repos committed: {len(results)}, with errors: {len(failed)}")
    for key, value in failed.items():
        print(key, value["error"])


if __name__ == "__main__":
    main()
