"""Pack PNG files into one .ico (the format accepts PNG images as they are).

Usage: python3 ico.py out.ico in-16.png in-32.png in-48.png
"""

import struct
import sys


def png_size(data: bytes) -> tuple[int, int]:
    # Width and height sit in the IHDR chunk, right after the 8-byte signature.
    return struct.unpack('>II', data[16:24])


def main() -> None:
    out, *inputs = sys.argv[1:]
    images = [open(path, 'rb').read() for path in inputs]
    header = struct.pack('<HHH', 0, 1, len(images))
    offset = len(header) + 16 * len(images)
    entries = b''
    for data in images:
        w, h = png_size(data)
        # 0 means 256 in the directory entry.
        entries += struct.pack('<BBBBHHII', w % 256, h % 256, 0, 0, 1, 32, len(data), offset)
        offset += len(data)
    with open(out, 'wb') as f:
        f.write(header + entries + b''.join(images))


if __name__ == '__main__':
    main()
