"""
Checks the package rules of a container (pinp, wnp, pinpf) and exits with 1 when a rule is broken.

Usage: python -I .scripts/check-rules.py <container root> [--max-lines 500] [--changed <package> ...]
Rules:
  flat      a package csproj must not reference another package of the container (Runner* and *.Tests are exempt)
  prefix    every package folder starts with Sunamo (Runner* is exempt)
  xlf       no XlfKeys or Translate.FromKey in .cs files
  czech     no Czech comments or identifiers (uses czech-audit.py and .docs/czech-audit.json of the pinp container)
  size      .cs files over --max-lines lines are reported as warnings (they do not fail the check)
"""
import importlib.util
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("czech_audit", os.path.join(HERE, "czech-audit.py"))
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)

REFERENCE = re.compile(r'<(?:Package|Project)Reference\s+Include="([^"]+)"')
SKIP_DIRS = {".git", "bin", "obj", "node_modules", ".docs", ".scripts", ".claudehistory"}


def packages(root, only):
    """Returns the package folder names of the container."""
    names = [d for d in sorted(os.listdir(root)) if os.path.isdir(os.path.join(root, d)) and not d.startswith(".")]
    names = [d for d in names if not d.startswith("_") and any(f.endswith(".csproj") for _, _, fs in os.walk(os.path.join(root, d)) for f in fs)]
    return [d for d in names if not only or d in only]


def walk(folder):
    """Yields (path, file name) of every file under folder except build output."""
    for dirpath, dirs, files in os.walk(folder):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for name in files:
            yield os.path.join(dirpath, name), name


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    root = os.path.abspath(sys.argv[1])
    max_lines = int(sys.argv[sys.argv.index("--max-lines") + 1]) if "--max-lines" in sys.argv else 500
    only = set(sys.argv[sys.argv.index("--changed") + 1:]) if "--changed" in sys.argv else set()
    czech = audit.load_set(os.path.join(HERE, "shared", "czech-words.txt"))
    allow = audit.load_set(os.path.join(HERE, "shared", "czech-allow.txt"))
    exempt = [l.split("	")[0] for l in open(os.path.join(root, ".docs", "czech-audit-exempt.txt"), encoding="utf-8")] if os.path.exists(os.path.join(root, ".docs", "czech-audit-exempt.txt")) else []
    exempt = [l for l in exempt if l.strip() and not l.startswith("#")]
    names = packages(root, only)
    all_names = set(packages(root, set()))
    errors, warnings = [], []
    for package in names:
        if not package.startswith(("Sunamo", "Runner")):
            errors.append(f"prefix: {package} does not start with Sunamo")
        for path, name in walk(os.path.join(root, package)):
            rel = os.path.relpath(path, root)
            is_test = ".Tests" in rel.split(os.sep)[1] if len(rel.split(os.sep)) > 1 else False
            if name.endswith(".csproj") and not name.startswith("Runner") and ".Tests" not in name:
                text = re.sub(r"<!--.*?-->", "", open(path, encoding="utf-8-sig", errors="replace").read(), flags=re.S)
                for reference in REFERENCE.findall(text):
                    target = os.path.basename(reference.replace("\\", "/")).replace(".csproj", "").replace(".Net48", "")
                    if target in all_names and target != package and not target.startswith("Runner"):
                        errors.append(f"flat: {rel} references {target}")
            if not name.endswith(".cs"):
                continue
            raw = open(path, "rb").read()
            try:
                text = raw.decode("utf-8-sig")
            except UnicodeDecodeError:
                errors.append(f"encoding: {rel} is not UTF-8")
                continue
            if re.search(r"\bXlfKeys\b|Translate\.FromKey", text):
                errors.append(f"xlf: {rel} mentions XlfKeys or Translate.FromKey")
            comments, idents, strings = audit.audit_text(text, czech, allow)
            if (comments or idents) and not any(rel.replace("\\", "/").startswith(prefix) for prefix in exempt):
                errors.append(f"czech: {rel} {' '.join((comments + idents)[:5])}")
            lines = text.count("\n") + 1
            if lines > max_lines:
                warnings.append(f"size: {rel} has {lines} lines")
    for line in warnings:
        print("WARN", line)
    for line in errors:
        print("FAIL", line)
    print(f"packages={len(names)} errors={len(errors)} warnings={len(warnings)}")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
