"""
Audits C# files for Czech left in comments and identifiers and keeps a map of already audited files.

Usage: python -I .scripts/czech-audit.py <root> [--map-update] [--show N] [--words]
- Tokens come from comments (including #region names) and from code identifiers.
  String literals are only counted: Czech user-facing texts and Czech data are allowed.
- A token is Czech when it has Czech diacritics, is a short Czech marker word (comments only), or its de-accented
  lowercase form is in .scripts/shared/czech-words.txt (frequent Czech words that are not English words).
- .scripts/shared/czech-allow.txt lists false positives (one lowercase word per line).
- .docs/czech-audit-exempt.txt lists "path-prefix<TAB>reason" lines for files that must keep Czech
  (Czech language processing, external API field names, Czech site names).
- .docs/czech-audit.json maps file -> content hash of files that were clean; unchanged files are skipped on later runs.
- --map-update writes the hashes of all files that are clean or exempt now. --words prints all hit words.
"""
import hashlib
import json
import os
import re
import sys
import unicodedata

DIACRITICS = re.compile(r"[áčďéěíňóřšťúůýžÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]")
SHORT_MARKERS = {"je", "se", "jsem", "jen", "uz", "ale", "pro", "tak"}
WORD = re.compile(r"[A-Za-zÀ-ž]+")
CAMEL = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?![a-z])|[À-ž]+")


def deaccent(word):
    """Returns the lowercase word without diacritics."""
    return "".join(c for c in unicodedata.normalize("NFD", word.lower()) if unicodedata.category(c) != "Mn")


def load_set(path):
    """Loads a one-word-per-line file into a set."""
    if not os.path.exists(path):
        return set()
    return {line.strip() for line in open(path, encoding="utf-8") if line.strip()}


class Scanner:
    """Line scanner that keeps string and block-comment state across lines."""

    def __init__(self):
        self.block = False
        self.verbatim = False
        self.raw = 0

    def split(self, line):
        """Returns (code, comment, strings_count) for one line; string contents are dropped from code."""
        code, comment = [], []
        self.pos = []
        strings = 0
        i, n = 0, len(line)
        stripped = line.strip()
        if not (self.block or self.verbatim or self.raw) and stripped.startswith("#region"):
            return "", stripped[7:], 0
        while i < n:
            if self.block:
                end = line.find("*/", i)
                if end == -1:
                    comment.append(line[i:])
                    return " ".join(code), " ".join(comment), strings
                comment.append(line[i:end])
                i = end + 2
                self.block = False
                continue
            if self.raw:
                end = line.find('"' * self.raw, i)
                if end == -1:
                    return " ".join(code), " ".join(comment), strings
                i = end + self.raw
                self.raw = 0
                continue
            if self.verbatim:
                j = i
                while j < n:
                    if line[j] == '"' and line[j + 1:j + 2] == '"':
                        j += 2
                        continue
                    if line[j] == '"':
                        break
                    j += 1
                if j >= n:
                    return " ".join(code), " ".join(comment), strings
                self.verbatim = False
                i = j + 1
                continue
            ch = line[i]
            if ch == '"':
                quotes = 1
                while line[i + quotes:i + quotes + 1] == '"':
                    quotes += 1
                if quotes >= 3:
                    self.raw = quotes
                    strings += 1
                    i += quotes
                    continue
                strings += 1
                prefix = line[max(0, i - 2):i]
                if "@" in prefix:
                    self.verbatim = True
                    i += 1
                    continue
                j = i + 1
                while j < n:
                    if line[j] == "\\":
                        j += 2
                        continue
                    if line[j] == '"':
                        break
                    j += 1
                i = j + 1
            elif ch == "'" and i + 2 < n and (line[i + 2] == "'" or line[i + 1] == "\\"):
                i += 3 if line[i + 1] != "\\" else line.find("'", i + 2) + 1 - i if line.find("'", i + 2) != -1 else 3
            elif line.startswith("//", i):
                comment.append(line[i + 2:])
                break
            elif line.startswith("/*", i):
                self.block = True
                i += 2
            else:
                code.append(ch)
                self.pos.append(i)
                i += 1
        return "".join(code), " ".join(comment), strings


def czech_tokens(text, czech, allow, comment):
    """Returns the Czech-looking tokens found in text."""
    found = []
    for word in WORD.findall(text):
        for part in CAMEL.findall(word) or [word]:
            low = deaccent(part)
            if low in allow:
                continue
            if DIACRITICS.search(part) or (comment and low in SHORT_MARKERS and part == part.lower()) or (len(low) >= 3 and low in czech):
                found.append(part)
    return found


def audit_text(text, czech, allow):
    """Returns (comment_hits, identifier_hits, string_count) for the file text."""
    scanner = Scanner()
    comments, idents, strings = [], [], 0
    for line in text.splitlines():
        code, comment, count = scanner.split(line)
        strings += count
        comments += czech_tokens(comment, czech, allow, True)
        idents += czech_tokens(code, czech, allow, False)
    return sorted(set(comments)), sorted(set(idents)), strings


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    root = sys.argv[1]
    update = "--map-update" in sys.argv
    show = int(sys.argv[sys.argv.index("--show") + 1]) if "--show" in sys.argv else 40
    here = os.path.dirname(os.path.abspath(__file__))
    czech = load_set(os.path.join(here, "shared", "czech-words.txt"))
    allow = load_set(os.path.join(here, "shared", "czech-allow.txt"))
    exempt_path = os.path.join(root, ".docs", "czech-audit-exempt.txt")
    exempt = [line.split("\t")[0] for line in open(exempt_path, encoding="utf-8") if line.strip() and not line.startswith("#")] if os.path.exists(exempt_path) else []
    map_path = os.path.join(root, ".docs", "czech-audit.json")
    audited = json.load(open(map_path, encoding="utf-8")) if os.path.exists(map_path) else {}
    skipped = scanned = exempted = 0
    dirty, clean_now = [], {}
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules", ".docs")]
        for name in files:
            if not name.endswith(".cs"):
                continue
            path = os.path.join(folder, name)
            rel = os.path.relpath(path, root).replace("\\", "/")
            raw = open(path, "rb").read()
            digest = hashlib.sha1(raw).hexdigest()[:12]
            if any(rel.startswith(prefix) for prefix in exempt):
                exempted += 1
                clean_now[rel] = digest
                continue
            if audited.get(rel) == digest:
                skipped += 1
                clean_now[rel] = digest
                continue
            try:
                text = raw.decode("utf-8-sig")
            except UnicodeDecodeError:
                dirty.append((rel, (["<not utf-8>"], [], 0)))
                continue
            scanned += 1
            result = audit_text(text, czech, allow)
            if result[0] or result[1]:
                dirty.append((rel, result))
            else:
                clean_now[rel] = digest
    print(f"scanned={scanned} skippedAlreadyClean={skipped} exempt={exempted} withHits={len(dirty)}")
    words = {}
    for rel, (c, i, s) in dirty:
        for w in c + i:
            words[deaccent(w)] = words.get(deaccent(w), 0) + 1
    if "--words" in sys.argv:
        print("words:", " ".join(w for w, count in sorted(words.items(), key=lambda kv: -kv[1])))
    for rel, (c, i, s) in dirty[:show]:
        print(f"{rel}\tcomments: {' '.join(c[:8])}\tidentifiers: {' '.join(i[:8])}")
    if update:
        json.dump(clean_now, open(map_path, "w", encoding="utf-8"), indent=0, sort_keys=True)
        print("map written:", len(clean_now))


if __name__ == "__main__":
    main()
