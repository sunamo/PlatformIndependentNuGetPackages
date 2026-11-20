"""
Lists public members without XML documentation (compiler warning CS1591) for the given packages of a container.

Usage: python -I .scripts/doc-gaps.py <container root> <result.json> <package> [<package> ...]
Builds the main project of every package (not Tests or Runner) once with documentation warnings enabled and writes
{"<relative file>": [{"line": 12, "member": "Namespace.Type.Member"}, ...]} sorted by file.
Files of packages listed in .docs/doc-gaps-exempt.txt are skipped (third-party forks).
"""
import glob
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

WARNING = re.compile(r"^(?P<file>.+?)\((?P<line>\d+),\d+\): warning CS1591: Missing XML comment for publicly visible type or member '(?P<member>[^']+)'")


def build(root, project):
    """Builds one project and returns {relative file: [gaps]}."""
    text = open(project, encoding="utf-8-sig", errors="replace").read()
    args = ["dotnet", "build", project, "-c", "Debug", "-v", "q", "-nologo", "--no-incremental",
            "-p:TreatWarningsAsErrors=false", "-p:GenerateDocumentationFile=true", "-p:NoWarn=", "-p:WarningLevel=4"]
    frameworks = re.search(r"<TargetFrameworks?>(.*?)</TargetFrameworks?>", text)
    if frameworks and ";" in frameworks.group(1):
        options = frameworks.group(1).split(";")
        args += ["-f", next((f for f in options if f.startswith("net8.0")), options[-1])]
    try:
        run = subprocess.run(args, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=290)
    except subprocess.TimeoutExpired:
        return {"<timeout>": [{"line": 0, "member": project}]}
    gaps = {}
    for line in run.stdout.splitlines():
        match = WARNING.match(line.strip())
        if match:
            rel = os.path.relpath(match.group("file"), root).replace("\\", "/")
            entry = {"line": int(match.group("line")), "member": match.group("member")}
            if entry not in gaps.setdefault(rel, []):
                gaps[rel].append(entry)
    return gaps


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    root = os.path.abspath(sys.argv[1])
    exempt_path = os.path.join(root, ".docs", "doc-gaps-exempt.txt")
    exempt = [l.strip() for l in open(exempt_path, encoding="utf-8")] if os.path.exists(exempt_path) else []
    projects = []
    for package in sys.argv[3:]:
        if package in exempt:
            continue
        main_project = os.path.join(root, package, package, package + ".csproj")
        if os.path.exists(main_project):
            projects.append(main_project)
    result = {}
    with ThreadPoolExecutor(3) as pool:
        for gaps in pool.map(lambda p: build(root, p), projects):
            for rel, entries in gaps.items():
                result.setdefault(rel, []).extend(entries)
    for rel in result:
        result[rel].sort(key=lambda e: e["line"])
    json.dump(dict(sorted(result.items())), open(sys.argv[2], "w", encoding="utf-8"), indent=0)
    print(f"projects={len(projects)} files={len(result)} gaps={sum(len(v) for v in result.values())}")


if __name__ == "__main__":
    main()
