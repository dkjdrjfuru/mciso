#!/usr/bin/env python3
"""Generate ALL Netmask OS "hacker edition" visual assets.

Outputs (relative to the repo root):
  assets/netmask_logo.png      1920x1080 desktop wallpaper  (matrix rain + emblem + scanlines)
  assets/loading.png           1920x1080 boot/loading screen (wallpaper + progress bar shell)
  assets/scanlines.png         256x256 tileable CRT scanline texture (kitty background_image)
  assets/netmask_icon.png      256x256 transparent emblem
  assets/netmask_logo_48.png   48x48 polybar icon
  assets/plymouth/*.png        rain strips, logo, dialog overlay, progress frames
  assets/grub_theme/background.png

Palette (mandated): bg #0D0D1A · fg #E0E0E0 · cyan #00D9FF · red #E94560
                    matrix green #27AE60 · amber #F39C12 · muted #444444
Reproducible: python3 scripts/make_wallpaper.py
"""
from pathlib import Path
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

REPO = Path(__file__).resolve().parent.parent
ASSETS = REPO / "assets"

BG = (13, 13, 26)          # 0D0D1A
BG_LIGHT = (21, 21, 43)    # 15152B
FG = (224, 224, 224)       # E0E0E0
CYAN = (0, 217, 255)       # 00D9FF
RED = (233, 69, 96)        # E94560
GREEN = (39, 174, 96)      # 27AE60  (matrix green)
GREEN_HI = (107, 255, 158) # bright rain head
AMBER = (243, 156, 18)     # F39C12
GREY = (122, 122, 150)
DIM = (68, 68, 68)         # 444444

W, H = 1920, 1080
CX, CY = W // 2, 400

FONT_DIRS = [
    REPO / "mkosi.extra/usr/share/fonts/truetype/netmask",
    REPO / "mkosi.extra/usr/share/fonts/truetype/netmask-jetbrains",
    Path("/usr/share/fonts/truetype/dejavu"),
]


def load_font(names, size):
    for d in FONT_DIRS:
        for n in names:
            p = d / n
            if p.exists():
                return ImageFont.truetype(str(p), size)
    return ImageFont.load_default(size)


def font_any(size):
    return load_font(
        ["FiraCodeNerdFont-Bold.ttf", "JetBrainsMonoNerdFont-Bold.ttf",
         "DejaVuSans-Bold.ttf"], size)


def font_mono(size):
    return load_font(
        ["FiraCodeNerdFont-Regular.ttf", "JetBrainsMonoNerdFont-Regular.ttf",
         "DejaVuSansMono.ttf"], size)


def radial_mask(w, h, invert=False):
    g = Image.radial_gradient("L").resize((w, h))
    if g.getpixel((w // 2, h // 2)) > g.getpixel((0, 0)):
        g = g.point(lambda v: 255 - v)
    if invert:
        g = g.point(lambda v: 255 - v)
    return g


# ----------------------------------------------------------------- matrix rain
GLYPHS = "01" + "0123456789ABCDEF" + "█▓▒░<>/\\{}[]$#@*+=~"


def matrix_rain(w, h, seed=1337, density=1.0, alpha_scale=1.0):
    """Falling-code layer: green glyph columns with fading trails."""
    random.seed(seed)
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    f = font_mono(16)
    col_w, row_h = 20, 18
    for cx in range(0, w, col_w):
        if random.random() > density * 0.72:
            continue
        trail = random.randint(6, 26)
        head_y = random.randint(-h, h)
        for k in range(trail):
            y = head_y - k * row_h
            if y < -row_h or y >= h:
                continue
            fade = 1.0 - k / trail
            if k == 0:
                col, a = GREEN_HI, int(255 * alpha_scale)
            else:
                col, a = GREEN, int(200 * fade * fade * alpha_scale)
            g = random.choice(GLYPHS)
            d.text((cx, y), g, font=f, fill=col + (a,))
    return layer


def scanlines(w, h, alpha=26, step=3):
    """CRT scanline overlay: 1px dark row every `step` rows."""
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for y in range(0, h, step):
        d.line([(0, y), (w, y)], fill=(0, 0, 0, alpha), width=1)
    return layer


# -------------------------------------------------------------------- emblem
def eye_shape(s, center_x, center_y, angle, color):
    ew, eh = 88 * s, 30 * s
    eye = Image.new("RGBA", (int(ew + 40 * s), int(eh + 40 * s)), (0, 0, 0, 0))
    ed = ImageDraw.Draw(eye)
    o = 20 * s
    ed.rounded_rectangle([o, o, o + ew, o + eh], radius=13 * s, fill=color + (255,))
    eye = eye.rotate(angle, resample=Image.BICUBIC, expand=True)
    return eye, (int(center_x - eye.width / 2), int(center_y - eye.height / 2))


def draw_mask_emblem(canvas, cx, cy, s=1.0, glow=True, outline=CYAN, eyes=CYAN):
    """Draw the netmask emblem centered at (cx, cy) onto RGBA canvas."""
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    if glow:
        gl = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        gd = ImageDraw.Draw(gl)
        gd.rounded_rectangle(
            [cx - 190 * s, cy - 115 * s, cx + 190 * s, cy + 115 * s],
            radius=52 * s, outline=outline + (255,), width=max(1, int(10 * s)))
        for ex, ang in ((cx - 100 * s, -12), (cx + 100 * s, 12)):
            eye, pos = eye_shape(s, ex, cy, ang, eyes)
            gl.alpha_composite(eye, pos)
        gl = gl.filter(ImageFilter.GaussianBlur(26 * s))
        gl.putalpha(gl.split()[3].point(lambda v: int(v * 0.55)))
        layer.alpha_composite(gl)

    d.rounded_rectangle(
        [cx - 190 * s, cy - 115 * s, cx + 190 * s, cy + 115 * s],
        radius=52 * s, fill=(16, 16, 42, 215), outline=outline + (255,),
        width=max(1, int(10 * s)))
    for ex, ang in ((cx - 100 * s, -12), (cx + 100 * s, 12)):
        eye, pos = eye_shape(s, ex, cy, ang, eyes)
        layer.alpha_composite(eye, pos)

    p1 = (cx + 150 * s, cy - 168 * s)
    p2 = (cx + 252 * s, cy - 108 * s)
    d.line([p1, p2], fill=RED + (255,), width=max(1, int(7 * s)))
    r = max(1, int(3.5 * s))
    for p in (p1, p2):
        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=RED + (255,))
    canvas.alpha_composite(layer)
    return canvas


def tracked_text(d, xy, text, font, tracking, fill, anchor_center_x=None):
    widths = [d.textlength(ch, font=font) for ch in text]
    total = sum(widths) + tracking * (len(text) - 1)
    x = (anchor_center_x - total / 2) if anchor_center_x is not None else xy[0]
    y = xy[1]
    for ch, w in zip(text, widths):
        d.text((x, y), ch, font=font, fill=fill)
        x += w + tracking
    return total


def wordmark(img, y=636, big=96):
    d = ImageDraw.Draw(img)
    f_big = font_any(big)
    gap = 30
    nm_w = sum(d.textlength(c, font=f_big) for c in "NETMASK") + 14 * (len("NETMASK") - 1)
    os_w = sum(d.textlength(c, font=f_big) for c in "OS")
    start = CX - (nm_w + gap + os_w) / 2
    tracked_text(d, (start, y), "NETMASK", f_big, 14, CYAN + (255,))
    tracked_text(d, (start + nm_w + gap, y), "OS", f_big, 14, RED + (255,))
    return img


def base_scene(rain_seed=1337, rain_alpha=1.0):
    """Vignette + grid + matrix rain + emblem + wordmark + tagline."""
    img = Image.new("RGB", (W, H), BG)
    glow = Image.new("RGB", (W, H), BG_LIGHT)
    img = Image.composite(glow, img, radial_mask(W, H))
    vig = Image.new("RGB", (W, H), (9, 9, 18))
    img = Image.composite(vig, img, radial_mask(W, H, invert=True).point(lambda v: int(v * 0.75)))
    img = img.convert("RGBA")

    img.alpha_composite(matrix_rain(W, H, seed=rain_seed, alpha_scale=rain_alpha))

    ov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    for x in range(0, W + 1, 64):
        a = 16 if x % 320 == 0 else 8
        d.line([(x, 0), (x, H)], fill=CYAN + (a,), width=1)
    for y in range(0, H + 1, 64):
        a = 16 if y % 320 == 0 else 8
        d.line([(0, y), (W, y)], fill=CYAN + (a,), width=1)
    img = Image.alpha_composite(img, ov)

    # dark halo behind the emblem so it pops over the rain
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halo)
    hd.ellipse([CX - 430, CY - 300, CX + 430, CY + 330], fill=(8, 8, 18, 190))
    halo = halo.filter(ImageFilter.GaussianBlur(80))
    img.alpha_composite(halo)

    draw_mask_emblem(img, CX, CY, 1.0)
    wordmark(img)

    d = ImageDraw.Draw(img)
    d.rectangle([CX - 230, 772, CX + 230, 774], fill=CYAN + (70,))
    f_tag = font_any(28)
    tracked_text(d, (0, 800), "FULL SPECTRUM RE // ETHICAL HACKING",
                 f_tag, 6, GREEN_HI + (230,), anchor_center_x=CX)
    f_small = font_any(22)
    tracked_text(d, (44, 36), "255.255.255.0", f_small, 8, DIM + (255,))
    f_disc = font_any(24)
    tracked_text(d, (0, H - 56), "discord.gg/netmask", f_disc, 4, GREY + (255,),
                 anchor_center_x=W - 190)
    return img


def make_wallpaper():
    img = base_scene(rain_seed=1337)
    img.alpha_composite(scanlines(W, H, alpha=30))
    out = ASSETS / "netmask_logo.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")


def make_loading():
    img = base_scene(rain_seed=4242, rain_alpha=0.85)
    d = ImageDraw.Draw(img)
    # progress-bar shell (plymouth draws the live fill on top of its own copies)
    bx0, by0, bx1, by1 = CX - 320, H - 170, CX + 320, H - 150
    d.rounded_rectangle([bx0 - 2, by0 - 2, bx1 + 2, by1 + 2], radius=4,
                        fill=(10, 10, 20, 220), outline=CYAN + (255,), width=2)
    d.rectangle([bx0, by0, bx1, by1], fill=(16, 16, 34, 255))
    f_lbl = font_any(24)
    tracked_text(d, (0, H - 130), "N E T M A S K   O S   //   L O A D I N G . . .",
                 f_lbl, 4, FG + (255,), anchor_center_x=CX)
    img.alpha_composite(scanlines(W, H, alpha=34))
    out = ASSETS / "loading.png"
    img.convert("RGB").save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")


def make_scanlines():
    img = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for y in range(0, 256, 3):
        d.line([(0, y), (256, y)], fill=(0, 0, 0, 46), width=1)
    random.seed(7)
    for _ in range(40):
        x, y = random.randrange(256), random.randrange(256)
        d.point((x, y), fill=GREEN + (36,))
    out = ASSETS / "scanlines.png"
    img.save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")


def make_icons():
    ic = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    draw_mask_emblem(ic, 128, 128, 0.62, glow=True)
    out = ASSETS / "netmask_icon.png"
    ic.save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")

    ic48 = ic.resize((48, 48), Image.LANCZOS)
    out = ASSETS / "netmask_logo_48.png"
    ic48.save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")


# --------------------------------------------------------------------- plymouth
def plymouth_logo():
    """Emblem + wordmark on transparent, for the boot splash."""
    w, h = 900, 460
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw_mask_emblem(img, w // 2, 175, 1.05, glow=True)
    d = ImageDraw.Draw(img)
    f = font_any(64)
    tracked_text(d, (0, 340), "NETMASK OS", f, 10, CYAN + (255,), anchor_center_x=w // 2)
    out = ASSETS / "plymouth/logo.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")


def plymouth_rain_strips():
    """4 tall transparent strips of fading glyph trails (rain columns)."""
    f = font_mono(22)
    for i in range(4):
        random.seed(100 + i)
        w, h = 28, 900
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        row = 26
        n = h // row
        for k in range(n):
            y = h - (k + 1) * row          # head at the bottom of the strip
            fade = 1.0 - k / n
            if k == 0:
                col, a = GREEN_HI, 255
            elif k == 1:
                col, a = GREEN, 220
            else:
                col, a = GREEN, int(210 * fade * fade)
            g = random.choice(GLYPHS)
            d.text((4, y), g, font=f, fill=col + (a,))
        out = ASSETS / f"plymouth/rain-{i}.png"
        img.save(out, "PNG", optimize=True)
        print(f"wrote {out} {out.stat().st_size // 1024} KiB")


def plymouth_dialog_and_bar():
    ov = Image.new("RGBA", (W, H), (4, 4, 10, 168))
    out = ASSETS / "plymouth/overlay.png"
    ov.save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")

    # progress bar: bg + 11 fill frames (0%..100%)
    bw, bh = 640, 14
    bg = Image.new("RGBA", (bw + 4, bh + 4), (0, 0, 0, 0))
    d = ImageDraw.Draw(bg)
    d.rounded_rectangle([0, 0, bw + 3, bh + 3], radius=3,
                        fill=(10, 10, 20, 255), outline=CYAN + (255,), width=1)
    d.rectangle([2, 2, bw + 1, bh + 1], fill=(16, 16, 34, 255))
    out = ASSETS / "plymouth/bar-bg.png"
    bg.save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")

    for step in range(11):
        fw = int(bw * step / 10)
        fill = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
        fd = ImageDraw.Draw(fill)
        if fw > 0:
            fd.rectangle([0, 0, fw - 1, bh - 1], fill=CYAN + (235,))
            gl = fill.filter(ImageFilter.GaussianBlur(4))
            gl.putalpha(gl.split()[0].point(lambda v: int(v * 0.5)))
            base = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
            base.alpha_composite(gl)
            base.alpha_composite(fill)
            fill = base
        out = ASSETS / f"plymouth/fill-{step}.png"
        fill.save(out, "PNG", optimize=True)
    print("wrote plymouth/fill-0..10.png")


def make_grub_background():
    src = Image.open(ASSETS / "loading.png").convert("RGB")
    d = ImageDraw.Draw(src)
    # darken the menu zone so hidden-menu entries stay legible in debug mode
    zone = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    zd = ImageDraw.Draw(zone)
    zd.rectangle([int(W * 0.08), int(H * 0.30), int(W * 0.92), int(H * 0.72)],
                 fill=(5, 5, 12, 120))
    zone = zone.filter(ImageFilter.GaussianBlur(6))
    out = ASSETS / "grub_theme/background.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    src.convert("RGBA").alpha_composite(zone)
    src.convert("RGB").save(out, "PNG", optimize=True)
    print(f"wrote {out} {out.stat().st_size // 1024} KiB")


if __name__ == "__main__":
    make_wallpaper()
    make_loading()
    make_scanlines()
    make_icons()
    plymouth_logo()
    plymouth_rain_strips()
    plymouth_dialog_and_bar()
    make_grub_background()
    print("all assets generated")
