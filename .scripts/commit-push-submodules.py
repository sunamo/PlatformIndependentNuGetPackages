"""
Commits and pushes the given submodules of the container (only *.cs, *.csproj, *.md and *.resx changes), 20 s timeout per git call.
Usage: python -I .scripts/commit-push-submodules.py "<message>" <submodule> [<submodule> ...]
Prints "<submodule> <commit hash> push=<exit code>" per submodule.
"""
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ENV = dict(os.environ, GIT_TERMINAL_PROMPT="0", GCM_INTERACTIVE="never")
MESSAGE = sys.argv[1] + "\n\nCo-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>\n"


def git(folder, *args):
    """Runs git in folder with a 20 s timeout; returns (exit code, stdout)."""
    try:
        run = subprocess.run(["git", "-C", folder, *args], capture_output=True, text=True, env=ENV, timeout=20, input=MESSAGE if "-F" in args else None)
        return run.returncode, run.stdout.strip()
    except subprocess.TimeoutExpired:
        return 124, "timeout"


def process(folder):
    """Stages, commits and pushes one submodule."""
    for pattern in ("*.cs", "*.csproj", "*.md", "*.resx", "*.png", "LICENSE", "*.yml"):
        git(folder, "add", "-A", "--", pattern)
    code, out = git(folder, "commit", "-F", "-")
    if code != 0:
        return f"{folder} commit={code} {out[:80]}"
    head = git(folder, "rev-parse", "--short", "HEAD")[1]
    push, _ = git(folder, "push", "origin", "claude")
    return f"{folder} {head} push={push}"


with ThreadPoolExecutor(6) as pool:
    for line in pool.map(process, sys.argv[2:]):
        print(line)
