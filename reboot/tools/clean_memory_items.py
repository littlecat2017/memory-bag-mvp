from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ITEM_DIR = ROOT / "assets" / "generated" / "mvp_art" / "memory_items"
SOURCE_SHEET = ROOT / "assets" / "generated" / "mvp_art" / "memory_item_sheet.png"
CELL_SIZE = (72, 64)
CELL_GAP = (8, 8)
PADDING = 4

ITEM_SPECS = {
    "mem_mothers_soup": {"tile": (0, 0), "grid": (1, 1)},
    "mem_wooden_sword": {"tile": (1, 0), "grid": (4, 1), "special": "horizontal_sword"},
    "mem_reason_to_depart": {"tile": (2, 0), "grid": (2, 3)},
    "mem_my_name": {"tile": (3, 0), "grid": (2, 1)},
    "mem_someone_waits": {"tile": (0, 1), "grid": (2, 1)},
    "mem_abandoned_afternoon": {"tile": (1, 1), "grid": (2, 1)},
    "mem_no_more_explaining": {"tile": (2, 1), "grid": (2, 1)},
    "mem_empty_nameplate": {"tile": (3, 1), "grid": (2, 1)},
    "mem_masters_scolding": {"tile": (0, 2), "grid": (1, 2)},
    "mem_battle_instinct": {"tile": (1, 2), "grid": (2, 2)},
    "mem_prove_with_wound": {"tile": (2, 2), "grid": (2, 2)},
    "mem_rusty_victory": {"tile": (3, 2), "grid": (1, 1)},
    "mem_rain_lamp": {"tile": (0, 3), "grid": (1, 2)},
    "mem_want_to_go_home": {"tile": (1, 3), "grid": (2, 2)},
    "mem_crown_without_name": {"tile": (2, 3), "grid": (1, 1)},
    "mem_not_let_go": {"tile": (3, 3), "grid": (2, 2)},
}


def target_size(grid_size: tuple[int, int]) -> tuple[int, int]:
    columns, rows = grid_size
    width = columns * CELL_SIZE[0] + max(0, columns - 1) * CELL_GAP[0]
    height = rows * CELL_SIZE[1] + max(0, rows - 1) * CELL_GAP[1]
    return width, height


def is_sheet_background(r: int, g: int, b: int, _a: int) -> bool:
    chroma = max(r, g, b) - min(r, g, b)
    return r >= 226 and g >= 222 and b >= 214 and chroma <= 38


def source_tile(source_sheet: Image.Image, tile_position: tuple[int, int]) -> Image.Image:
    column, row = tile_position
    tile_width = source_sheet.width / 4.0
    tile_height = source_sheet.height / 4.0
    return source_sheet.crop(
        (
            round(column * tile_width),
            round(row * tile_height),
            round((column + 1) * tile_width),
            round((row + 1) * tile_height),
        )
    )


def remove_connected_sheet_background(image: Image.Image) -> Image.Image:
    source = image.convert("RGBA")
    width, height = source.size
    pixels = source.load()
    background = set()
    queue: deque[tuple[int, int]] = deque()
    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))
    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= width or y >= height or (x, y) in background:
            continue
        if not is_sheet_background(*pixels[x, y]):
            continue
        background.add((x, y))
        queue.append((x + 1, y))
        queue.append((x - 1, y))
        queue.append((x, y + 1))
        queue.append((x, y - 1))

    clean = Image.new("RGBA", source.size, (0, 0, 0, 0))
    clean_pixels = clean.load()
    for y in range(height):
        for x in range(width):
            if (x, y) not in background:
                clean_pixels[x, y] = pixels[x, y]
    bbox = clean.getbbox()
    if bbox is None:
        return clean
    return clean.crop(bbox)


def fit_cutout(cutout: Image.Image, size: tuple[int, int]) -> Image.Image:
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    max_width = max(1, size[0] - PADDING * 2)
    max_height = max(1, size[1] - PADDING * 2)
    scale = min(max_width / cutout.width, max_height / cutout.height)
    fitted_size = (max(1, round(cutout.width * scale)), max(1, round(cutout.height * scale)))
    fitted = cutout.resize(fitted_size, Image.Resampling.LANCZOS)
    offset = ((size[0] - fitted.width) // 2, (size[1] - fitted.height) // 2)
    canvas.alpha_composite(fitted, offset)
    return canvas


def make_horizontal_sword(tile: Image.Image, size: tuple[int, int]) -> Image.Image:
    sword_mask = Image.new("L", tile.size, 0)
    draw = ImageDraw.Draw(sword_mask)
    parts = [
        [(112, 148), (226, 49), (275, 44), (258, 88), (158, 205), (136, 192)],
        [(62, 230), (100, 193), (135, 232), (103, 277)],
        [(79, 171), (104, 148), (176, 202), (151, 232)],
        [(75, 184), (155, 172), (172, 215), (102, 228)],
    ]
    for polygon in parts:
        draw.polygon(polygon, fill=255)
    sword_mask = sword_mask.filter(ImageFilter.GaussianBlur(0.8))
    sword = Image.new("RGBA", tile.size, (0, 0, 0, 0))
    sword.alpha_composite(tile)
    sword.putalpha(sword_mask)
    bbox = sword.getbbox()
    if bbox is not None:
        sword = sword.crop(bbox)
    sword = sword.rotate(-45, expand=True, resample=Image.Resampling.BICUBIC)
    bbox = sword.getbbox()
    if bbox is not None:
        sword = sword.crop(bbox)

    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    fitted = sword.resize((size[0] - PADDING * 2, size[1] - PADDING * 2), Image.Resampling.LANCZOS)
    canvas.alpha_composite(fitted, (PADDING, PADDING))
    return canvas


def main() -> None:
    if not SOURCE_SHEET.exists():
        raise FileNotFoundError(SOURCE_SHEET)
    source_sheet = Image.open(SOURCE_SHEET).convert("RGBA")
    for memory_id, spec in ITEM_SPECS.items():
        path = ITEM_DIR / f"{memory_id}.png"
        tile = source_tile(source_sheet, spec["tile"])
        size = target_size(spec["grid"])
        if spec.get("special") == "horizontal_sword":
            final = make_horizontal_sword(tile, size)
        else:
            cutout = remove_connected_sheet_background(tile)
            final = fit_cutout(cutout, size)
        final.save(path)
        print(f"{path.name}: {final.size[0]}x{final.size[1]}")


if __name__ == "__main__":
    main()
