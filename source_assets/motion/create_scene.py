"""Render a lightweight full-scene combat motion from the v0 reference layers."""

from pathlib import Path
import math
import random

from PIL import Image, ImageDraw, ImageFilter

from create import FPS, OUT, ROOT, SIZE, draw_effect, figure_frame, prepare_cutout


def place_actor(frame: Image.Image, sprite: Image.Image, x: int, y: int, angle: float = 0) -> None:
    turned = sprite.rotate(angle, Image.Resampling.BICUBIC, expand=True)
    frame.alpha_composite(turned, (x - (turned.width - sprite.width) // 2, y - (turned.height - sprite.height) // 2))


def magic_layer(t: float) -> Image.Image:
    layer = Image.new("RGBA", SIZE)
    draw = ImageDraw.Draw(layer)
    pulse = 0.72 + 0.28 * math.sin(t * 10)
    center = (678, 382)
    draw.ellipse((center[0] - 70, center[1] - 45, center[0] + 70, center[1] + 45), fill=(190, 225, 255, round(115 * pulse)))
    layer = layer.filter(ImageFilter.GaussianBlur(23))
    draw = ImageDraw.Draw(layer)
    for index in range(6):
        phase = index * 0.9 + t * (1.6 if index % 2 else -1.3)
        rx = 95 + index * 10 + 7 * math.sin(t * 4 + index)
        ry = 30 + index * 8
        points = []
        for step in range(64):
            theta = step * 2 * math.pi / 63 + phase
            points.append((round(center[0] + rx * math.cos(theta)), round(center[1] + ry * math.sin(theta) - 20 * math.sin(theta * 2))))
        draw.line(points, fill=(169, 214, 255, round((72 + index * 9) * pulse)), width=2, joint="curve")
    glow = layer.filter(ImageFilter.GaussianBlur(9))
    layer = Image.alpha_composite(glow, layer)
    sparks = ImageDraw.Draw(layer)
    for index in range(22):
        angle = index * 2.399 + t * (1.2 + index % 3)
        radius = 24 + (index * 19) % 130
        x = round(center[0] + math.cos(angle) * radius)
        y = round(center[1] + math.sin(angle) * radius * 0.55)
        sparks.ellipse((x, y, x + 2, y + 2), fill=(225, 240, 255, 170))
    return layer


def debris_layer(t: float) -> Image.Image:
    layer = Image.new("RGBA", SIZE)
    draw = ImageDraw.Draw(layer)
    rng = random.Random(19)
    for index in range(7):
        x = 680 + rng.randrange(-95, 175)
        y = 245 + rng.randrange(-80, 155)
        drift = math.sin(t * 2.5 + index) * 9
        w = 10 + index % 3 * 3
        draw.polygon([(x + drift, y), (x + w + drift, y - 5), (x + w - 2 + drift, y + 9), (x - 3 + drift, y + 7)], fill=(244, 218, 171, 228))
    for index in range(12):
        x = 735 + rng.randrange(-90, 130)
        y = 320 + rng.randrange(-80, 115) - 5 * math.sin(t * 4 + index)
        r = 3 + index % 3
        draw.polygon([(x, y - r), (x + r, y), (x + 2, y + r), (x - r, y + 1)], fill=(112, 90, 74, 220))
    return layer


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    background = Image.open(ROOT / "concepts/v0-bellfold-square-reference.png").convert("RGBA")
    background = background.resize(SIZE, Image.Resampling.LANCZOS)
    guard_image = prepare_cutout(ROOT / "source_assets/motion/guard.png")
    guard = guard_image.resize((180, 262), Image.Resampling.LANCZOS)
    idle = prepare_cutout(ROOT / "source_assets/motion/idle.png")
    strike = prepare_cutout(ROOT / "source_assets/motion/strike.png")

    for index in range(72):
        t = index / FPS
        frame = background.copy()
        reaction = max(0.0, 1.0 - abs(t - 1.03) / 0.55)
        frame = Image.alpha_composite(frame, debris_layer(t))
        frame = Image.alpha_composite(frame, magic_layer(t))
        place_actor(frame, guard, 764 + round(30 * reaction), 183 - round(14 * reaction), -12 * reaction)
        frame = Image.alpha_composite(frame, figure_frame(idle, strike, t))
        frame = draw_effect(frame, t)
        frame.convert("RGB").save(OUT / f"frame_{index:03}.png")


if __name__ == "__main__":
    main()
