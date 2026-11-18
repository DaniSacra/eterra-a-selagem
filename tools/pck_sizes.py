"""What goes into the exported game and how much each asset weighs there (asset audit, docs/qa/asset_report.md).

  python3 -I tools/pck_sizes.py build/windows/ASelagem.exe [--files]

Reads the pack embedded at the end of the exe (Godot 4.7: "GDPC" header, directory at dir_offset; entries are path,
offset, size, md5, flags), maps every .godot/imported/... entry back to its source through the `path=` of the
project's .import files, and prints the megabytes (10^6 bytes) per family; --files lists every entry, biggest first.
Also: --ctex FILE... reads the header of imported textures (size, mipmaps, storage: raw/VRAM, png, webp, basis; format).
"""
import collections
import os
import re
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STORE = {0: 'image', 1: 'png', 2: 'webp', 3: 'basis'}
FORMAT = {0: 'L8', 1: 'LA8', 2: 'R8', 3: 'RG8', 4: 'RGB8', 5: 'RGBA8', 17: 'DXT1', 18: 'DXT3', 19: 'DXT5',
          20: 'RGTC_R', 21: 'RGTC_RG', 22: 'BPTC_RGBA'}


def entries(exe):
    data = open(exe, 'rb').read()
    at = data.rfind(b'GDPC', 0, len(data) - 12)
    _base, dir_off = struct.unpack('<QQ', data[at + 24:at + 40])
    p = at + dir_off
    count, = struct.unpack('<I', data[p:p + 4])
    p += 4
    for _ in range(count):
        n, = struct.unpack('<I', data[p:p + 4])
        p += 4
        path = data[p:p + n].rstrip(b'\0').decode()
        p += n
        _off, size = struct.unpack('<QQ', data[p:p + 16])
        p += 16 + 16 + 4
        yield size, path


def sources():
    dest = {}
    for d, dirs, files in os.walk(ROOT):
        dirs[:] = [x for x in dirs if x not in ('.godot', '.git', 'build', '.claude')]
        for f in files:
            if f.endswith('.import'):
                src = os.path.relpath(os.path.join(d, f[:-7]), ROOT)
                for line in open(os.path.join(d, f), errors='ignore'):
                    m = re.match(r'path(?:\.\w+)?="res://(\.godot/imported/[^"]+)"', line)
                    if m:
                        dest[m.group(1)] = src
    return dest


def family(src):
    parts = src.split('/')
    if parts[0] == 'assets' and len(parts) > 2 and parts[1] == 'models':
        return '/'.join(parts[:4] if parts[2] == 'meshy' else parts[:3])
    if parts[0] in ('assets', 'audio') and len(parts) > 2:
        return '/'.join(parts[:2])
    return 'audio (sfx)' if parts[0] == 'audio' else parts[0]


def ctex(paths):
    for path in paths:
        head = open(path, 'rb').read(64)
        if head[:4] != b'GST2':
            print(path, 'not a GST2 texture')
            continue
        _ver, w, h = struct.unpack('<III', head[4:16])
        store, _sw, _sh, mips, fmt = struct.unpack('<IHHII', head[36:52])
        print('%s %dx%d store=%s mipmaps=%d format=%s' % (os.path.basename(path), w, h, STORE.get(store, store),
                                                          mips, FORMAT.get(fmt, fmt)))


def main():
    if len(sys.argv) > 2 and sys.argv[1] == '--ctex':
        ctex(sys.argv[2:])
        return
    dest = sources()
    rows = []
    for size, path in entries(sys.argv[1]):
        src = dest.get(path, path)
        rows.append((size, src[:-6] if src.endswith('.remap') else src))
    sums = collections.Counter()
    for size, src in rows:
        sums[family(src)] += size
    for name, size in sums.most_common():
        print('%8.2f MB  %s' % (size / 1e6, name))
    print('%8.2f MB  pack, %d entries; exe %.2f MB' % (sum(sums.values()) / 1e6, len(rows),
                                                         os.path.getsize(sys.argv[1]) / 1e6))
    if '--files' in sys.argv:
        for size, src in sorted(rows, reverse=True):
            print(size, src)


if __name__ == '__main__':
    main()
