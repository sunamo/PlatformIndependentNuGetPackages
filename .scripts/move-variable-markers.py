"""
Removes the working markers "// variables names: ok" and "// Variable names have been checked ..." from .cs files
and records every touched file in .docs/variable-names-checked.md (the evidence of which files were reviewed).
Usage: python -I .scripts/move-variable-markers.py <root> [--apply]
"""
import os
import re
import sys

MARKER = re.compile(r"^\s*//\s*(variables names:\s*ok|Variable names have been checked.*)\s*$", re.I)


def main():
    root = sys.argv[1]
    apply = "--apply" in sys.argv
    found = {}
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules", ".docs")]
        for name in files:
            if not name.endswith(".cs"):
                continue
            path = os.path.join(folder, name)
            raw = open(path, "rb").read()
            bom = raw.startswith(b"\xef\xbb\xbf")
            try:
                text = (raw[3:] if bom else raw).decode("utf-8")
            except UnicodeDecodeError:
                continue
            lines = text.splitlines(keepends=True)
            kept = [line for line in lines[:6] if not MARKER.match(line.rstrip("\r\n"))]
            if len(kept) == min(len(lines), 6):
                continue
            new_lines = kept + lines[6:]
            rel = os.path.relpath(path, root).replace("\\", "/")
            parts = rel.split("/", 1)
            repo, inner = (parts[0], parts[1]) if len(parts) == 2 else (".", rel)
            found.setdefault(repo, []).append(inner)
            if apply:
                open(path, "wb").write((b"\xef\xbb\xbf" if bom else b"") + "".join(new_lines).encode("utf-8"))
    if apply:
        out = ["# Files whose variable names were reviewed", "",
               "These files carried the marker `// variables names: ok` (set after a manual review of variable names).",
               "The marker was removed from the code on 2026-11-20; this list is now the only record. Paths are relative to each repo.", ""]
        for repo in sorted(found, key=str.lower):
            out.append(f"## {repo}")
            out.extend(f"- {inner}" for inner in sorted(found[repo]))
            out.append("")
        os.makedirs(os.path.join(root, ".docs"), exist_ok=True)
        open(os.path.join(root, ".docs", "variable-names-checked.md"), "w", encoding="utf-8", newline="\n").write("\n".join(out))
    print(f"files={sum(len(v) for v in found.values())} repos={len(found)} apply={apply}")


if __name__ == "__main__":
    main()
