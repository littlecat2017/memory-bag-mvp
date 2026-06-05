from __future__ import annotations

from collections import deque
import json
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ITEM_DIR = ROOT / "assets" / "generated" / "mvp_art" / "memory_items"
SOURCE_SHEET = ROOT / "assets" / "generated" / "mvp_art" / "memory_item_sheet.png"
LAYOUT_PATH = ROOT / "data" / "layout_contract.json"
PADDING = 5

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


def load_inventory_metrics() -> tuple[tuple[int, int], tuple[int, int]]:
    with LAYOUT_PATH.open("r", encoding="utf-8") as handle:
        layout = json.load(handle)
    inventory = layout["inventory"]
    columns, rows = inventory["grid"]
    gap_x, gap_y = inventory["gap"]
    board = layout["screens"]["travel"]["inventory_board"]
    cell_width = math.floor((board[2] - gap_x * (columns - 1)) / columns)
    cell_height = math.floor((board[3] - gap_y * (rows - 1)) / rows)
    return (cell_width, cell_height), (gap_x, gap_y)


CELL_SIZE, CELL_GAP = load_inventory_metrics()


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


def is_near_white_fringe(r: int, g: int, b: int) -> bool:
    return r >= 232 and g >= 228 and b >= 218 and max(r, g, b) - min(r, g, b) <= 42


def clean_final_edges(image: Image.Image) -> Image.Image:
    source = image.convert("RGBA")
    alpha = source.getchannel("A")
    opaque_mask = alpha.point(lambda value: 255 if value > 18 else 0)
    near_transparent = ImageChops.invert(opaque_mask).filter(ImageFilter.MaxFilter(7))
    pixels = source.load()
    near_pixels = near_transparent.load()
    width, height = source.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if near_pixels[x, y] > 0 and (a < 170 or is_near_white_fringe(r, g, b)):
                pixels[x, y] = (r, g, b, 0)

    alpha = source.getchannel("A")
    alpha = alpha.point(lambda value: 0 if value < 32 else value)
    alpha = alpha.filter(ImageFilter.MinFilter(3))
    source.putalpha(alpha)

    pixels = source.load()
    for x in range(width):
        pixels[x, 0] = (0, 0, 0, 0)
        pixels[x, height - 1] = (0, 0, 0, 0)
    for y in range(height):
        pixels[0, y] = (0, 0, 0, 0)
        pixels[width - 1, y] = (0, 0, 0, 0)
    return source


def make_horizontal_sword(tile: Image.Image, size: tuple[int, int]) -> Image.Image:
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    center_y = size[1] // 2 + 1
    blade_left = int(size[0] * 0.34)
    blade_right = size[0] - 12
    blade_half = 15

    shadow = Image.new("RGBA", size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((10, center_y + 11, blade_right - 8, center_y + 19), radius=4, fill=(67, 45, 29, 42))
    shadow = shadow.filter(ImageFilter.GaussianBlur(3.2))
    canvas.alpha_composite(shadow)

    handle_rect = (10, center_y - 12, blade_left - 22, center_y + 12)
    draw.rounded_rectangle(handle_rect, radius=7, fill=(116, 79, 45, 255), outline=(60, 48, 37, 230), width=2)
    for stripe_x in range(handle_rect[0] + 13, handle_rect[2], 24):
        draw.line((stripe_x, center_y - 13, stripe_x - 7, center_y + 13), fill=(191, 148, 88, 210), width=4)
        draw.line((stripe_x + 4, center_y - 13, stripe_x - 3, center_y + 13), fill=(67, 47, 35, 150), width=1)

    ribbon = [(blade_left - 34, center_y - 15), (blade_left - 18, center_y - 6), (blade_left - 34, center_y + 3), (blade_left - 50, center_y - 6)]
    draw.polygon(ribbon, fill=(55, 68, 83, 240), outline=(36, 44, 54, 220))
    draw.polygon([(blade_left - 26, center_y + 5), (blade_left - 7, center_y + 24), (blade_left - 20, center_y + 28), (blade_left - 39, center_y + 9)], fill=(68, 84, 103, 230), outline=(36, 44, 54, 200))

    guard = (blade_left - 31, center_y - 23, blade_left + 9, center_y + 23)
    draw.rounded_rectangle(guard, radius=6, fill=(191, 134, 58, 255), outline=(96, 61, 33, 235), width=2)
    draw.line((guard[0] + 5, center_y - 17, guard[2] - 4, center_y - 17), fill=(232, 185, 94, 210), width=2)

    blade = [(blade_left, center_y - blade_half), (blade_right - 20, center_y - blade_half + 2), (blade_right, center_y), (blade_right - 20, center_y + blade_half - 2), (blade_left, center_y + blade_half)]
    draw.polygon(blade, fill=(207, 148, 74, 255), outline=(96, 63, 34, 245))
    draw.polygon([(blade_left + 3, center_y - blade_half + 3), (blade_right - 28, center_y - blade_half + 5), (blade_right - 12, center_y), (blade_left + 3, center_y - 1)], fill=(238, 188, 107, 178))
    draw.line((blade_left + 2, center_y + 1, blade_right - 22, center_y + 1), fill=(125, 78, 40, 170), width=2)
    for grain_x in range(blade_left + 18, blade_right - 48, 36):
        draw.arc((grain_x, center_y - 11, grain_x + 40, center_y + 15), 190, 340, fill=(139, 88, 43, 96), width=1)

    return canvas


def main() -> None:
    if not SOURCE_SHEET.exists():
        raise FileNotFoundError(SOURCE_SHEET)
    source_sheet = Image.open(SOURCE_SHEET).convert("RGBA")
    ITEM_DIR.mkdir(parents=True, exist_ok=True)
    for memory_id, spec in ITEM_SPECS.items():
        path = ITEM_DIR / f"{memory_id}.png"
        tile = source_tile(source_sheet, spec["tile"])
        size = target_size(spec["grid"])
        if spec.get("special") == "horizontal_sword":
            final = make_horizontal_sword(tile, size)
        else:
            cutout = remove_connected_sheet_background(tile)
            final = fit_cutout(cutout, size)
        final = clean_final_edges(final)
        final.save(path)
        print(f"{path.name}: {final.size[0]}x{final.size[1]}")


if __name__ == "__main__":
    main()
