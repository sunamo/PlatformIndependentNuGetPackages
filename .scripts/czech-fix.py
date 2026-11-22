"""
Fixes Czech left in C# comments and identifiers, driven by the detector in czech-audit.py.

Usage:
  python -I .scripts/czech-fix.py comments-extract <root> <texts.json>
  python -I .scripts/czech-fix.py comments-apply   <root> <texts.json> <translations.json> [--apply]
  python -I .scripts/czech-fix.py idents-list      <root>                     lists identifiers that contain Czech parts
  python -I .scripts/czech-fix.py idents-apply     <root> <map.json> [--apply]
map.json = {"components": {"nazev": "name"}, "whole": {"Číslo": "Number"}}; components are matched case-insensitively
without diacritics on camelCase parts, whole identifiers are matched exactly. Only code (not strings or comments) is changed.
Exempt files from .docs/czech-audit-exempt.txt are never touched.
"""
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("czech_audit", os.path.join(HERE, "czech-audit.py"))
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)

IDENT = re.compile(r"[A-Za-zÀ-ž_][A-Za-zÀ-ž_0-9]*")
PARTS = re.compile(r"[A-Z]+(?![a-z])|[A-Z]?[a-z]+|[0-9]+|_|[À-ž]+")


def code_positions(scanner, line):
    """Returns (code_mask, comment_text) for the line using the scanner state machine."""
    mask = [False] * len(line)
    text_code, comment, strings = scanner.split(line)
    for index in scanner.pos:
        mask[index] = True
    return mask, comment


def walk(root, exempt):
    """Yields (relative path, full path) of non-exempt .cs files."""
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules", ".docs")]
        for name in files:
            if name.endswith(".cs"):
                path = os.path.join(folder, name)
                rel = os.path.relpath(path, root).replace("\\", "/")
                if not any(rel.startswith(prefix) for prefix in exempt):
                    yield rel, path


def load_exempt(root):
    """Returns the exempt path prefixes."""
    path = os.path.join(root, ".docs", "czech-audit-exempt.txt")
    if not os.path.exists(path):
        return []
    return [line.split("\t")[0] for line in open(path, encoding="utf-8") if line.strip() and not line.startswith("#")]


def read(path):
    """Returns (bom, text) or None when the file is not UTF-8."""
    raw = open(path, "rb").read()
    try:
        return raw.startswith(b"\xef\xbb\xbf"), raw.decode("utf-8-sig")
    except UnicodeDecodeError:
        return None


def write(path, bom, text):
    """Writes text back with the original BOM."""
    open(path, "wb").write((b"\xef\xbb\xbf" if bom else b"") + text.encode("utf-8"))


def collect_repo_identifiers(root, repo, exempt):
    """Returns every identifier-like token in the repo, used to avoid name collisions after renames."""
    names = set()
    for rel, path in walk(os.path.join(root, repo), exempt):
        data = read(path)
        if data:
            names.update(IDENT.findall(data[1]))
    return names


def rename_identifier(token, mapping):
    """Returns the English identifier for token or token itself when nothing maps."""
    if token in mapping["whole"]:
        return mapping["whole"][token]
    out, changed = [], False
    for part in PARTS.findall(token):
        key = audit.deaccent(part)
        english = mapping["components"].get(key)
        if english is None:
            out.append(part)
            continue
        changed = True
        words = english.split()
        rendered = []
        for index, word in enumerate(words):
            if part.isupper() and len(part) > 1:
                rendered.append(word.upper())
            elif part[0].isupper() or index > 0:
                rendered.append(word.capitalize())
            else:
                rendered.append(word.lower())
        out.append("".join(rendered))
    return "".join(out) if changed else token


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    mode, root = sys.argv[1], sys.argv[2]
    apply = "--apply" in sys.argv
    czech = audit.load_set(os.path.join(HERE, "shared", "czech-words.txt"))
    allow = audit.load_set(os.path.join(HERE, "shared", "czech-allow.txt"))
    exempt = load_exempt(root)

    if mode == "comments-extract":
        texts = {}
        for rel, path in walk(root, exempt):
            data = read(path)
            if not data:
                continue
            scanner = audit.Scanner()
            for line in data[1].splitlines():
                code, comment, strings = scanner.split(line)
                if audit.czech_tokens(comment, czech, allow, True):
                    texts.setdefault(comment.strip(), None)
        ordered = {str(i): t for i, t in enumerate(sorted(texts))}
        json.dump(ordered, open(sys.argv[3], "w", encoding="utf-8"), ensure_ascii=False, indent=0)
        print(f"uniqueComments={len(ordered)}")

    elif mode == "comments-apply":
        texts = json.load(open(sys.argv[3], encoding="utf-8"))
        translated = json.load(open(sys.argv[4], encoding="utf-8"))
        mapping = {texts[k]: translated[k] for k in texts if translated.get(k)}
        changed = unresolved = 0
        for rel, path in walk(root, exempt):
            data = read(path)
            if not data:
                continue
            bom, text = data
            scanner = audit.Scanner()
            lines = text.splitlines(keepends=True)
            out, modified = [], False
            for line in lines:
                body = line.rstrip("\r\n")
                eol = line[len(body):]
                code, comment, strings = scanner.split(body)
                key = comment.strip()
                if key in mapping and audit.czech_tokens(comment, czech, allow, True):
                    position = body.rfind(key)
                    if position == -1:
                        unresolved += 1
                    else:
                        body = body[:position] + mapping[key] + body[position + len(key):]
                        modified = True
                out.append(body + eol)
            if modified:
                changed += 1
                if apply:
                    write(path, bom, "".join(out))
        print(f"changedFiles={changed} unresolved={unresolved} apply={apply}")

    elif mode == "idents-list":
        found = {}
        for rel, path in walk(root, exempt):
            data = read(path)
            if not data:
                continue
            scanner = audit.Scanner()
            for line in data[1].splitlines():
                mask, comment = code_positions(scanner, line)
                for match in IDENT.finditer(line):
                    if all(mask[match.start():match.end()]) and audit.czech_tokens(match.group(0), czech, allow, False):
                        found.setdefault(match.group(0), set()).add(rel.split("/")[0])
        for token in sorted(found):
            print(token, len(found[token]))
        print("total", len(found))

    elif mode == "idents-apply":
        mapping = json.load(open(sys.argv[3], encoding="utf-8"))
        mapping.setdefault("components", {})
        mapping.setdefault("whole", {})
        changed = renamed = 0
        touched_repos = set()
        repo_identifiers = {}
        for rel, path in walk(root, exempt):
            data = read(path)
            if not data:
                continue
            bom, text = data
            scanner = audit.Scanner()
            out, modified = [], False
            existing = repo_identifiers.setdefault(rel.split('/')[0], None) or repo_identifiers.__setitem__(rel.split('/')[0], collect_repo_identifiers(root, rel.split('/')[0], exempt)) or repo_identifiers[rel.split('/')[0]]
            for line in text.splitlines(keepends=True):
                body = line.rstrip("\r\n")
                eol = line[len(body):]
                mask, comment = code_positions(scanner, body)
                pieces, last = [], 0
                for match in IDENT.finditer(body):
                    if not all(mask[match.start():match.end()]):
                        continue
                    new = rename_identifier(match.group(0), mapping)
                    if new != match.group(0) and new in existing:
                        new = new + "Cs"
                    if new != match.group(0):
                        pieces.append(body[last:match.start()])
                        pieces.append(new)
                        last = match.end()
                        renamed += 1
                        modified = True
                pieces.append(body[last:])
                out.append("".join(pieces) + eol)
            if modified:
                changed += 1
                touched_repos.add(rel.split("/")[0])
                if apply:
                    write(path, bom, "".join(out))
        print(f"changedFiles={changed} renamedTokens={renamed} repos={len(touched_repos)} apply={apply}")
        print(" ".join(sorted(touched_repos)))


if __name__ == "__main__":
    main()
