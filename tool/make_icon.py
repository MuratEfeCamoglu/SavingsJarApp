"""Draws the Savings Jar launcher icon (supersampled for smooth edges)."""
import os
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = sys.argv[1]
SIZE = 1024
SS = 4  # supersampling factor
W = SIZE * SS

BLUE_TOP = (30, 99, 230)
BLUE_BOTTOM = (0, 52, 160)
NAVY = (5, 28, 63)
GLASS = (234, 242, 255)
NECK = (214, 226, 248)
GREEN = (16, 185, 129)
GREEN_LIGHT = (52, 211, 153)
GOLD = (251, 191, 36)
GOLD_DARK = (245, 158, 11)
GOLD_TEXT = (180, 83, 9)


def gradient(size):
    img = Image.new("RGB", (size, size))
    d = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        c = tuple(round(a + (b - a) * t) for a, b in zip(BLUE_TOP, BLUE_BOTTOM))
        d.line([(0, y), (size, y)], fill=c)
    return img.convert("RGBA")


def draw_jar(canvas, f, with_shadow):
    """Draws the jar in a 1000-unit design space; f = pixels per unit."""
    cx = W / 2
    cy = W / 2 + 47.5 * f  # centre the content's bounding box

    def P(x, y):
        return (cx + x * f, cy + y * f)

    def box(x0, y0, x1, y1):
        return [P(x0, y0), P(x1, y1)]

    def layer():
        return Image.new("RGBA", (W, W), (0, 0, 0, 0))

    if with_shadow:
        sh = layer()
        ImageDraw.Draw(sh).ellipse(box(-250, 305, 250, 365), fill=(0, 0, 0, 90))
        canvas.alpha_composite(sh.filter(ImageFilter.GaussianBlur(18 * f)))

    # Coin goes in first so the lid covers its lower half (dropping into the slot)
    coin = layer()
    cd = ImageDraw.Draw(coin)
    cd.ellipse(box(-95, -425, 95, -235), fill=GOLD_DARK)
    cd.ellipse(box(-78, -408, 78, -252), fill=GOLD)
    font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", round(120 * f))
    cd.text(P(0, -333), "$", font=font, fill=GOLD_TEXT, anchor="mm")
    canvas.alpha_composite(coin)

    # Body mask, reused to clip the savings fill and the shine
    mask = Image.new("L", (W, W), 0)
    ImageDraw.Draw(mask).rounded_rectangle(box(-260, -150, 260, 330), radius=110 * f, fill=255)

    body = layer()
    bd = ImageDraw.Draw(body)
    bd.rounded_rectangle(box(-180, -215, 180, -140), radius=30 * f, fill=NECK)
    bd.rounded_rectangle(box(-260, -150, 260, 330), radius=110 * f, fill=GLASS)
    canvas.alpha_composite(body)

    fill = layer()
    fd = ImageDraw.Draw(fill)
    fd.rectangle(box(-300, 40, 300, 360), fill=GREEN)
    fd.ellipse(box(-300, 10, 300, 70), fill=GREEN_LIGHT)
    # Stacked coins visible through the glass
    for x, y in [(-120, 200), (0, 230), (120, 200), (-60, 120), (60, 120)]:
        fd.ellipse(box(x - 48, y - 48, x + 48, y + 48), fill=GOLD_DARK)
        fd.ellipse(box(x - 38, y - 38, x + 38, y + 38), fill=GOLD)
    clipped = layer()
    clipped.paste(fill, (0, 0), mask)
    canvas.alpha_composite(clipped)

    shine = layer()
    ImageDraw.Draw(shine).rounded_rectangle(
        box(-215, -110, -172, 180), radius=22 * f, fill=(255, 255, 255, 120))
    shine_clipped = layer()
    shine_clipped.paste(shine, (0, 0), mask)
    canvas.alpha_composite(shine_clipped)

    lid = layer()
    ld = ImageDraw.Draw(lid)
    ld.rounded_rectangle(box(-210, -300, 210, -205), radius=36 * f, fill=NAVY)
    ld.rounded_rectangle(box(-100, -266, 100, -240), radius=13 * f, fill=(0, 10, 26))
    canvas.alpha_composite(lid)


def save(img, name):
    img.resize((SIZE, SIZE), Image.LANCZOS).save(os.path.join(OUT, name))


os.makedirs(OUT, exist_ok=True)

# Full icon (iOS + legacy Android): content fills ~74% of the square
full = gradient(W)
draw_jar(full, 0.98 * SS, with_shadow=True)
save(full.convert("RGB"), "icon.png")

# Adaptive icon: content must stay inside the 66/108 safe circle
fg = Image.new("RGBA", (W, W), (0, 0, 0, 0))
draw_jar(fg, 0.70 * SS, with_shadow=False)
save(fg, "foreground.png")
save(gradient(W).convert("RGB"), "background.png")
print("ok")
