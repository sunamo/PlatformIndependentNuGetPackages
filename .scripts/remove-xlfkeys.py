"""
Removes the generated XlfKeys constants: every Translate.FromKey(XlfKeys.X) and bare XlfKeys.X in C# code becomes
an English string literal, the XlfKeys*/KeysXlf* definition files and their global usings are deleted.

Usage: python -I .scripts/remove-xlfkeys.py <root> [--apply] [--keys]
--keys keeps the key name as the literal (for apps whose i18n function really looks the key up in a dictionary or resources).
The English text is the key name split into words (sentence case) when it has 4 or more words, otherwise the key name itself,
so short technical keys (encoding names, XML element names) keep their exact value.
Keys whose constant value was Czech (names ending with Cs) lose the Cs suffix.
"""
import importlib.util
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("czech_audit", os.path.join(HERE, "czech-audit.py"))
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)

WRAPPED = re.compile(r"(?:\w+\s*\.\s*)*(?:FromKey|i18n)\(\s*XlfKeys\s*\.\s*(\w+)\s*\)")
INTERPOLATED = re.compile(r"\{\s*(?:(?:\w+\s*\.\s*)*(?:FromKey|i18n)\(\s*)?XlfKeys\s*\.\s*(\w+)\s*\)?\s*\}")
BARE = re.compile(r"\bXlfKeys\s*\.\s*(\w+)")
WORDS = re.compile(r"[A-Z]+(?![a-z])|[A-Z]?[a-z]+|[0-9]+")
GLOBAL_USING = re.compile(r"^\s*global using [\w\.]*SunamoXlfKeys;\s*$")
DEFINITION = re.compile(r"^(XlfKeys|KeysXlf)\d*\.cs$")


def text_for(name):
    """Returns the English literal text for a key name, or the key itself in --keys mode."""
    if "--keys" in sys.argv:
        return name
    if name.endswith("Cs") and len(name) > 2:
        name = name[:-2]
    words = WORDS.findall(name)
    if len(words) < 4:
        return name
    lowered = [w if (w.isupper() and len(w) > 1) else w.lower() for w in words]
    lowered[0] = lowered[0][:1].upper() + lowered[0][1:]
    return " ".join(lowered)


def replace_in_line(body, mask):
    """Replaces XlfKeys usages only where the match starts in code (not in comments or strings)."""
    def sub(match):
        if not mask[match.start()]:
            return match.group(0)
        return '"' + text_for(match.group(1)) + '"'
    body = INTERPOLATED.sub(lambda match: text_for(match.group(1)), body)
    return BARE.sub(sub, WRAPPED.sub(sub, body))


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    root = sys.argv[1]
    apply = "--apply" in sys.argv
    changed = removed_defs = replaced = commented = 0
    touched_dirs = set()
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules", ".docs", ".scripts", "AllProjectsSearchTestFiles")]
        if os.path.abspath(folder) == os.path.abspath(root):
            dirs[:] = [d for d in dirs if d != "SunamoXlfKeys"]
        for name in files:
            path = os.path.join(folder, name)
            if not name.endswith(".cs"):
                continue
            if DEFINITION.match(name):
                raw = open(path, "rb").read().decode("utf-8", errors="replace")
                if re.search(r"class (XlfKeys|KeysXlf)\b", raw):
                    removed_defs += 1
                    if apply:
                        os.remove(path)
                    continue
            raw = open(path, "rb").read()
            try:
                text = raw.decode("utf-8-sig")
            except UnicodeDecodeError:
                continue
            if "XlfKeys" not in text:
                continue
            bom = raw.startswith(b"\xef\xbb\xbf")
            scanner = audit.Scanner()
            out, modified = [], False
            for line in text.splitlines(keepends=True):
                body = line.rstrip("\r\n")
                eol = line[len(body):]
                if GLOBAL_USING.match(body):
                    modified = True
                    continue
                code, comment, strings = scanner.split(body)
                mask = [False] * len(body)
                for index in scanner.pos:
                    mask[index] = True
                if "XlfKeys" in body:
                    if body.lstrip().startswith("//") and "XlfKeys" in comment:
                        modified = True
                        commented += 1
                        continue
                    new = replace_in_line(body, mask)
                    if new != body:
                        replaced += len(BARE.findall(body)) or 1
                        body = new
                        modified = True
                out.append(body + eol)
            if modified:
                changed += 1
                touched_dirs.add(os.path.relpath(path, root).split(os.sep)[0])
                if apply:
                    open(path, "wb").write((b"\xef\xbb\xbf" if bom else b"") + "".join(out).encode("utf-8"))
    print(f"changedFiles={changed} replacedUsages~={replaced} removedCommentLines={commented} deletedDefinitionFiles={removed_defs} apply={apply}")
    print("repos:", " ".join(sorted(touched_dirs)))


if __name__ == "__main__":
    main()
