"""Build a short, fixed-camera combat concept from the v0 reference art."""

from pathlib import Path
import math

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs/visual-progress/combat-motion-frames"
SIZE = (1280, 720)
FPS = 24


def prepare_cutout(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    alpha = np.asarray(image.getchannel("A"), dtype=np.float32)
    # The generated cutouts contain a broad decorative glow; keep the figure.
    clean = np.clip((alpha - 62.0) * 255.0 / 150.0, 0, 255).astype("uint8")
    image.putalpha(Image.fromarray(clean, "L"))
    return image


def place(image: Image.Image, scale: float, x: int, bottom: int) -> Image.Image:
    width = round(image.width * scale)
    height = round(image.height * scale)
    sprite = image.resize((width, height), Image.Resampling.LANCZOS)
    layer = Image.new("RGBA", SIZE)
    layer.alpha_composite(sprite, (x, bottom - height))
    return layer


def figure_frame(idle: Image.Image, strike: Image.Image, t: float) -> Image.Image:
    # One readable anticipation, strike and recovery; no simulated camera orbit.
    attacking = 0.82 <= t < 1.35
    lean = max(0.0, min(1.0, (t - 0.65) / 0.17)) if t < 1.35 else 0.0
    bob = round(2 * math.sin(t * 5))
    if attacking:
        return place(strike, 0.335, 462, 710 + bob)
    return place(idle, 0.335, 422 + round(24 * lean), 710 + bob)


def draw_effect(frame: Image.Image, t: float) -> Image.Image:
    intensity = max(0.0, 1.0 - abs(t - 0.97) / 0.23)
    if intensity == 0:
        return frame
    fx = Image.new("RGBA", SIZE)
    draw = ImageDraw.Draw(fx)
    points = [(710, 398), (744, 371), (785, 343), (835, 316), (895, 299)]
    draw.line(points, fill=(205, 237, 255, round(180 * intensity)), width=5, joint="curve")
    draw.line(points, fill=(255, 252, 239, round(230 * intensity)), width=2, joint="curve")
    bloom = fx.filter(ImageFilter.GaussianBlur(12))
    frame = Image.alpha_composite(frame, bloom)
    return Image.alpha_composite(frame, fx)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    background = Image.open(ROOT / "game/art/village_backdrop.png").convert("RGBA")
    background = background.resize(SIZE, Image.Resampling.LANCZOS)
    idle = prepare_cutout(ROOT / "source_assets/motion/idle.png")
    strike = prepare_cutout(ROOT / "source_assets/motion/strike.png")
    for index in range(72):
        t = index / FPS
        frame = Image.alpha_composite(background, figure_frame(idle, strike, t))
        frame = draw_effect(frame, t)
        frame.convert("RGB").save(OUT / f"frame_{index:03}.png")


if __name__ == "__main__":
    main()
