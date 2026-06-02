from pathlib import Path
import struct
import zlib


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "effects" / "fx_slash_basic_sheet.png"


def read_png(path: Path):
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    pos = 8
    width = height = color_type = None
    idat = bytearray()
    while pos < len(data):
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        chunk_type = data[pos + 4 : pos + 8]
        chunk_data = data[pos + 8 : pos + 8 + length]
        pos += 12 + length
        if chunk_type == b"IHDR":
            width, height, bit_depth, color_type, _compression, _filter, _interlace = struct.unpack(
                ">IIBBBBB", chunk_data
            )
            if bit_depth != 8 or color_type not in (2, 6):
                raise ValueError("expected 8-bit RGB/RGBA PNG")
        elif chunk_type == b"IDAT":
            idat.extend(chunk_data)
        elif chunk_type == b"IEND":
            break
    return width, height, color_type, bytes(idat)


def paeth(a: int, b: int, c: int) -> int:
    p = a + b - c
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def unfilter(raw: bytes, width: int, height: int, bpp: int) -> bytearray:
    stride = width * bpp
    out = bytearray(height * stride)
    src = 0
    for y in range(height):
        filter_type = raw[src]
        src += 1
        row = bytearray(raw[src : src + stride])
        src += stride
        prior_start = (y - 1) * stride
        out_start = y * stride
        for x in range(stride):
            left = row[x - bpp] if x >= bpp else 0
            up = out[prior_start + x] if y > 0 else 0
            up_left = out[prior_start + x - bpp] if y > 0 and x >= bpp else 0
            if filter_type == 1:
                row[x] = (row[x] + left) & 0xFF
            elif filter_type == 2:
                row[x] = (row[x] + up) & 0xFF
            elif filter_type == 3:
                row[x] = (row[x] + ((left + up) >> 1)) & 0xFF
            elif filter_type == 4:
                row[x] = (row[x] + paeth(left, up, up_left)) & 0xFF
            elif filter_type != 0:
                raise ValueError(f"unsupported PNG filter {filter_type}")
        out[out_start : out_start + stride] = row
    return out


def write_png(path: Path, width: int, height: int, pixels: bytearray) -> None:
    stride = width * 4
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        start = y * stride
        raw.extend(pixels[start : start + stride])
    compressed = zlib.compress(bytes(raw), level=9)

    def chunk(kind: bytes, payload: bytes) -> bytes:
        crc = zlib.crc32(kind)
        crc = zlib.crc32(payload, crc) & 0xFFFFFFFF
        return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", compressed) + chunk(b"IEND", b""))


def should_hide_checker(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    # Generated effect sheet used a painted transparency checkerboard. Remove
    # neutral gray cells while preserving the near-white slash and spark pixels.
    neutral = max(r, g, b) - min(r, g, b) <= 14
    gray = 135 <= r <= 215 and 135 <= g <= 215 and 135 <= b <= 215
    bright_slash = r >= 225 and g >= 225 and b >= 225
    return neutral and gray and not bright_slash


def main() -> None:
    width, height, _color_type, idat = read_png(SOURCE)
    bpp = 4 if _color_type == 6 else 3
    raw_pixels = unfilter(zlib.decompress(idat), width, height, bpp)
    pixels = bytearray()
    if bpp == 4:
        pixels = raw_pixels
    else:
        for offset in range(0, len(raw_pixels), 3):
            pixels.extend(raw_pixels[offset : offset + 3])
            pixels.append(255)
    hidden = 0
    for offset in range(0, len(pixels), 4):
        r, g, b, a = pixels[offset : offset + 4]
        if should_hide_checker(r, g, b, a):
            pixels[offset + 3] = 0
            hidden += 1
    write_png(SOURCE, width, height, pixels)
    print(f"clean_slash_effect_alpha: hidden={hidden} source={SOURCE}")


if __name__ == "__main__":
    main()
