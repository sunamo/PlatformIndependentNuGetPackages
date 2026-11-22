"""
Builds every non-Runner csproj in the given repos (one target framework per project, 3 builds in parallel).
Usage: python -I .scripts/build-repos.py <root> <result.json> <repo> [<repo> ...]
Result JSON: {"<csproj>": {"ok": bool, "errors": [first 5 error lines]}}.
"""
import glob
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor


def build(project):
    """Builds one project and returns (project, result dict)."""
    text = open(project, encoding="utf-8-sig", errors="replace").read()
    frameworks = re.search(r"<TargetFrameworks?>(.*?)</TargetFrameworks?>", text)
    args = ["dotnet", "build", project, "-c", "Debug", "-v", "q", "-nologo", "-p:TreatWarningsAsErrors=false"]
    if frameworks:
        options = frameworks.group(1).split(";")
        if len(options) > 1:
            pick = next((f for f in options if f.startswith("net8.0")), options[-1])
            args += ["-f", pick]
    try:
        run = subprocess.run(args, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=280)
    except subprocess.TimeoutExpired:
        return project, {"ok": False, "errors": ["timeout 280 s"]}
    errors = sorted({line.strip() for line in run.stdout.splitlines() if ": error " in line})
    return project, {"ok": run.returncode == 0, "errors": errors[:5]}


def main():
    root, out = sys.argv[1], sys.argv[2]
    projects = []
    for repo in sys.argv[3:]:
        for path in glob.glob(os.path.join(root, repo, "**", "*.csproj"), recursive=True):
            norm = path.replace("\\", "/")
            if "/bin/" in norm or "/obj/" in norm or "/Runner" in norm or ".Net48" in norm:
                continue
            projects.append(path)
    results = {}
    with ThreadPoolExecutor(max_workers=3) as pool:
        for project, result in pool.map(build, projects):
            results[os.path.relpath(project, root)] = result
            print(("OK   " if result["ok"] else "FAIL ") + os.path.relpath(project, root), flush=True)
            json.dump(results, open(out, "w", encoding="utf-8"), indent=1)
    print("done", sum(1 for r in results.values() if r["ok"]), "ok of", len(results))


if __name__ == "__main__":
    main()
