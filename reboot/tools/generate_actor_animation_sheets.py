from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ART_ROOT = ROOT / "assets" / "generated" / "mvp_art"
OUT_DIR = ART_ROOT / "actor_anim"
FRAME_SIZE = (256, 256)
SLASH_FRAME_SIZE = (256, 160)
HIT_BURST_FRAME_SIZE = (192, 192)


def trim_alpha(image: Image.Image) -> Image.Image:
    source = image.convert("RGBA")
    bbox = source.getbbox()
    if bbox is None:
        return source
    return source.crop(bbox)


def fit_actor(
    actor: Image.Image,
    *,
    scale: float = 1.0,
    rotate: float = 0.0,
    offset: tuple[int, int] = (0, 0),
    tint: tuple[float, float, float] | None = None,
) -> Image.Image:
    working = actor.convert("RGBA")
    if tint is not None:
        r_mul, g_mul, b_mul = tint
        pixels = working.load()
        for y in range(working.height):
            for x in range(working.width):
                r, g, b, a = pixels[x, y]
                pixels[x, y] = (
                    min(255, round(r * r_mul)),
                    min(255, round(g * g_mul)),
                    min(255, round(b * b_mul)),
                    a,
                )
    max_w = int(FRAME_SIZE[0] * 0.82 * scale)
    max_h = int(FRAME_SIZE[1] * 0.90 * scale)
    fit_scale = min(max_w / working.width, max_h / working.height)
    working = working.resize(
        (max(1, round(working.width * fit_scale)), max(1, round(working.height * fit_scale))),
        Image.Resampling.LANCZOS,
    )
    if abs(rotate) > 0.01:
        working = working.rotate(rotate, expand=True, resample=Image.Resampling.BICUBIC)
        bbox = working.getbbox()
        if bbox is not None:
            working = working.crop(bbox)
    canvas = Image.new("RGBA", FRAME_SIZE, (0, 0, 0, 0))
    x = (FRAME_SIZE[0] - working.width) // 2 + offset[0]
    y = FRAME_SIZE[1] - working.height - 8 + offset[1]
    canvas.alpha_composite(working, (x, y))
    return canvas


def make_sheet(frames: list[Image.Image]) -> Image.Image:
    width = FRAME_SIZE[0] * len(frames)
    sheet = Image.new("RGBA", (width, FRAME_SIZE[1]), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * FRAME_SIZE[0], 0))
    return sheet


def make_walk_sheet(actor: Image.Image) -> Image.Image:
    frames: list[Image.Image] = []
    for index in range(8):
        phase = index / 8.0 * math.tau
        frames.append(
            fit_actor(
                actor,
                scale=1.0 + math.sin(phase) * 0.015,
                rotate=math.sin(phase) * 2.0,
                offset=(round(math.sin(phase) * 5), round(-abs(math.sin(phase)) * 7)),
            )
        )
    return make_sheet(frames)


def make_attack_sheet(actor: Image.Image) -> Image.Image:
    offsets = [(0, 0), (-14, 5), (16, -4), (44, -8), (70, -6), (38, -2), (12, 0), (0, 0)]
    rotations = [-2, -5, -2, 5, 9, 3, 0, 0]
    scales = [1.0, 0.98, 1.02, 1.08, 1.10, 1.05, 1.0, 1.0]
    frames = [
        fit_actor(actor, scale=scales[index], rotate=rotations[index], offset=offsets[index])
        for index in range(8)
    ]
    return make_sheet(frames)


def make_enemy_idle_sheet(actor: Image.Image) -> Image.Image:
    frames: list[Image.Image] = []
    for index in range(8):
        phase = index / 8.0 * math.tau
        frames.append(
            fit_actor(
                actor,
                scale=1.0 + math.sin(phase) * 0.012,
                rotate=math.sin(phase) * 2.8,
                offset=(round(math.sin(phase) * 4), round(-abs(math.sin(phase)) * 4)),
            )
        )
    return make_sheet(frames)


def make_enemy_hit_sheet(actor: Image.Image) -> Image.Image:
    offsets = [(0, 0), (18, -3), (-14, 2), (12, -2), (-7, 1), (0, 0)]
    rotations = [0, 8, -7, 5, -3, 0]
    frames = [
        fit_actor(actor, scale=1.03, rotate=rotations[index], offset=offsets[index], tint=(1.2, 0.78, 0.72))
        for index in range(6)
    ]
    return make_sheet(frames)


def make_slash_sheet() -> Image.Image:
    width = SLASH_FRAME_SIZE[0] * 6
    sheet = Image.new("RGBA", (width, SLASH_FRAME_SIZE[1]), (0, 0, 0, 0))
    for index in range(6):
        frame = Image.new("RGBA", SLASH_FRAME_SIZE, (0, 0, 0, 0))
        draw = ImageDraw.Draw(frame)
        alpha = int(255 * (1.0 - abs(index - 2.2) / 3.4))
        alpha = max(70, alpha)
        spread = 8 + index * 7
        glow = Image.new("RGBA", SLASH_FRAME_SIZE, (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow)
        glow_draw.arc((12, 8 + spread, 244, 154 - spread // 2), 202, 340, fill=(255, 246, 181, int(alpha * 0.58)), width=28)
        glow_draw.arc((34, 24 + spread, 226, 142 - spread // 2), 206, 336, fill=(126, 207, 255, int(alpha * 0.40)), width=12)
        glow = glow.filter(ImageFilter.GaussianBlur(4.2))
        frame.alpha_composite(glow)
        draw.arc((20, 18 + spread, 240, 150 - spread // 2), 204, 338, fill=(255, 250, 216, alpha), width=16)
        draw.arc((42, 31 + spread, 218, 138 - spread // 2), 207, 336, fill=(126, 205, 255, int(alpha * 0.72)), width=5)
        draw.line((52 + index * 9, 118, 224, 36 + index * 3), fill=(255, 255, 255, int(alpha * 0.92)), width=5)
        draw.line((72 + index * 6, 125, 175, 78), fill=(255, 232, 166, int(alpha * 0.48)), width=3)
        frame = ImageEnhance.Sharpness(frame).enhance(1.55)
        sheet.alpha_composite(frame, (index * SLASH_FRAME_SIZE[0], 0))
    return sheet


def make_hit_burst_sheet() -> Image.Image:
    frame_count = 8
    width = HIT_BURST_FRAME_SIZE[0] * frame_count
    sheet = Image.new("RGBA", (width, HIT_BURST_FRAME_SIZE[1]), (0, 0, 0, 0))
    for index in range(frame_count):
        frame = Image.new("RGBA", HIT_BURST_FRAME_SIZE, (0, 0, 0, 0))
        draw = ImageDraw.Draw(frame)
        progress = index / float(frame_count - 1)
        center = (92 + round(progress * 12), 88 - round(progress * 5))
        radius = 18 + round(progress * 58)
        alpha = max(0, round(255 * (1.0 - progress)))

        glow = Image.new("RGBA", HIT_BURST_FRAME_SIZE, (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow)
        glow_draw.ellipse(
            (center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius),
            fill=(255, 216, 118, int(alpha * 0.30)),
        )
        glow = glow.filter(ImageFilter.GaussianBlur(7.0))
        frame.alpha_composite(glow)

        ring_width = max(2, round(8 * (1.0 - progress)))
        draw.ellipse(
            (center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius),
            outline=(255, 244, 190, int(alpha * 0.85)),
            width=ring_width,
        )
        for ray_index in range(12):
            angle = (ray_index / 12.0) * math.tau + progress * 0.55
            inner = 12 + progress * 18
            outer = radius + 12 + ray_index % 3 * 5
            start = (center[0] + math.cos(angle) * inner, center[1] + math.sin(angle) * inner)
            end = (center[0] + math.cos(angle) * outer, center[1] + math.sin(angle) * outer)
            color = (255, 247, 215, int(alpha * (0.88 if ray_index % 2 == 0 else 0.55)))
            draw.line((start[0], start[1], end[0], end[1]), fill=color, width=max(1, round(4 * (1.0 - progress))))
        for spark_index in range(9):
            angle = (spark_index / 9.0) * math.tau - 0.45 + progress
            distance = 26 + progress * (46 + spark_index % 4 * 7)
            point = (center[0] + math.cos(angle) * distance, center[1] + math.sin(angle) * distance)
            spark_radius = max(1, round(4 * (1.0 - progress)))
            draw.ellipse(
                (point[0] - spark_radius, point[1] - spark_radius, point[0] + spark_radius, point[1] + spark_radius),
                fill=(117, 208, 255, int(alpha * 0.72)),
            )
        if index <= 2:
            draw.polygon(
                [(center[0] - 16, center[1] + 3), (center[0] + 36, center[1] - 26), (center[0] + 18, center[1] + 15)],
                fill=(255, 255, 255, int(alpha * 0.85)),
            )
        sheet.alpha_composite(frame, (index * HIT_BURST_FRAME_SIZE[0], 0))
    return sheet


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    hero = trim_alpha(Image.open(ART_ROOT / "hero.png"))
    enemy = trim_alpha(Image.open(ART_ROOT / "enemy.png"))
    outputs = {
        "hero_walk_sheet.png": make_walk_sheet(hero),
        "hero_attack_sheet.png": make_attack_sheet(hero),
        "enemy_idle_sheet.png": make_enemy_idle_sheet(enemy),
        "enemy_hit_sheet.png": make_enemy_hit_sheet(enemy),
        "slash_effect_sheet.png": make_slash_sheet(),
        "hit_burst_sheet.png": make_hit_burst_sheet(),
    }
    for name, image in outputs.items():
        path = OUT_DIR / name
        image.save(path)
        print(f"{path.name}: {image.size[0]}x{image.size[1]}")


if __name__ == "__main__":
    main()
