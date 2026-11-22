"""
Creates .scripts/shared/icon.png (128x128, a white S on a dark blue square) when missing and adds it to every package.

Usage: python -I .scripts/add-package-icon.py <container root> [<container root> ...]
For every <package>/<package>/<package>.csproj that has PackageReadmeFile but no PackageIcon: copies icon.png next to the csproj,
adds <PackageIcon>icon.png</PackageIcon> and a packing <None Include> item. Idempotent.
"""
import os
import re
import shutil
import struct
import sys
import zlib

SIZE = 128
BACKGROUND = (22, 42, 84)
FOREGROUND = (255, 255, 255)
# 5x7 bitmap of the letter S, scaled 12x
GLYPH = ["01111", "10000", "10000", "01110", "00001", "00001", "11110"]


def build_png():
    """Returns the bytes of the generated icon."""
    scale = 12
    left = (SIZE - 5 * scale) // 2
    top = (SIZE - 7 * scale) // 2
    rows = []
    for y in range(SIZE):
        row = bytearray([0])
        for x in range(SIZE):
            gx, gy = (x - left) // scale, (y - top) // scale
            on = 0 <= gx < 5 and 0 <= gy < 7 and GLYPH[gy][gx] == "1" and x >= left and y >= top
            row += bytes(FOREGROUND if on else BACKGROUND)
        rows.append(bytes(row))

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(b"".join(rows), 9)) + chunk(b"IEND", b"")


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    icon = os.path.join(here, "shared", "icon.png")
    if not os.path.exists(icon):
        os.makedirs(os.path.dirname(icon), exist_ok=True)
        open(icon, "wb").write(build_png())
    changed = 0
    for root in sys.argv[1:]:
        for package in sorted(os.listdir(root)):
            folder = os.path.join(root, package, package)
            project = os.path.join(folder, package + ".csproj")
            if not os.path.exists(project):
                continue
            raw = open(project, "rb").read()
            text = raw.decode("utf-8-sig")
            if "<PackageIcon>" in text or "<PackageReadmeFile>" not in text:
                continue
            nl = "\r\n" if "\r\n" in text else "\n"
            text = re.sub(r"([ \t]*)(<PackageReadmeFile>[^<]*</PackageReadmeFile>)", lambda m: m.group(1) + m.group(2) + nl + m.group(1) + "<PackageIcon>icon.png</PackageIcon>", text, count=1)
            text = re.sub(r"([ \t]*)(<None Include=\"readme\.md\"[^>]*/>)", lambda m: m.group(1) + m.group(2) + nl + m.group(1) + '<None Include="icon.png" Pack="True" PackagePath="." />', text, count=1)
            if '<None Include="icon.png"' not in text:
                continue
            shutil.copyfile(icon, os.path.join(folder, "icon.png"))
            open(project, "wb").write((b"\xef\xbb\xbf" if raw.startswith(b"\xef\xbb\xbf") else b"") + text.encode("utf-8"))
            changed += 1
    print("packages updated:", changed)


if __name__ == "__main__":
    main()
