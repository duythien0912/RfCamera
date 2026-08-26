#!/usr/bin/env /usr/bin/python3
"""Cuts the camera out of assets/icon/rfcam_icon.png onto transparency.

The supplied icon is an opaque square: a 3D yellow camera on a near-flat dark
background (#29292B) with a slight vignette. Two consumers need the camera
*without* that square:

  * the adaptive-icon foreground, which is composited over a solid #29292B
    background layer and hard-cropped by the launcher's circle mask;
  * the splash marks, which sit on black.

A plain colour key does not work: the lens interior, the flash window and the
side dial are as dark as the background, so keying on colour alone punches
holes through them. Instead we key *and* require connectivity to the image
border -- the lens interior is enclosed by the yellow body, so it survives.

Two refinements keep the cut clean:

  * The background is not perfectly flat, so instead of keying against one
    constant we fit a quadratic surface per channel to the border ring and key
    against that local estimate. The vignette then costs us no tolerance
    budget, which keeps the near-black knob and dial safely out of the key.
  * The alpha is not binary. In a narrow band hugging the artwork it ramps
    with the colour distance, so the source's own anti-aliased rim survives as
    a soft edge; a light blur then takes the stair-stepping off the boundary.
    The ramp is confined to that band because the open background carries
    enough grain to otherwise leave a haze of half-opaque pixels all over it.

Run via tool/gen_icons.sh, or directly from rfcam_flutter/:

    /usr/bin/python3 tool/cutout_icon.py
"""

import os
import sys

import numpy as np
from PIL import Image

SRC = "assets/icon/rfcam_icon.png"
OUT_FG = "assets/icon/icon_fg.png"      # adaptive-icon foreground
OUT_SPLASH = "assets/icon/icon_splash.png"  # splash mark
CANVAS = 1024

# Colour distance (0-255 RGB euclidean) at which a pixel is fully background /
# fully foreground. Between the two the alpha ramps.
KEY_LO = 7.0
KEY_HI = 20.0
# Pixels further than this from the fitted background are never keyed, so the
# flood fill cannot leak through them.
KEY_MAX = 22.0
# Width, in px, of the band around the artwork where that ramp may apply.
EDGE_BAND = 3
BORDER = 48  # width of the ring used to fit the background surface


def fit_background(rgb):
    """Least-squares quadratic surface per channel, fitted to the border ring."""
    h, w, _ = rgb.shape
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float64)
    yn, xn = yy / h - 0.5, xx / w - 0.5
    basis = np.stack(
        [np.ones_like(xn), xn, yn, xn * xn, yn * yn, xn * yn], axis=-1
    )

    ring = np.zeros((h, w), bool)
    ring[:BORDER], ring[-BORDER:], ring[:, :BORDER], ring[:, -BORDER:] = (
        True,
        True,
        True,
        True,
    )
    a = basis[ring]
    field = np.empty_like(rgb, dtype=np.float64)
    for c in range(3):
        coef, *_ = np.linalg.lstsq(a, rgb[ring][:, c], rcond=None)
        # tensordot, not `basis @ coef`: the 3-D matmul path trips
        # spurious FP warnings in Accelerate's BLAS on macOS.
        field[..., c] = np.tensordot(basis, coef, axes=1)
    return field


def flood_from_border(candidate):
    """4-connected flood fill of `candidate` seeded from every border pixel."""
    reached = np.zeros_like(candidate)
    reached[0] = candidate[0]
    reached[-1] = candidate[-1]
    reached[:, 0] = candidate[:, 0]
    reached[:, -1] = candidate[:, -1]
    while True:
        grown = reached.copy()
        grown[1:] |= reached[:-1]
        grown[:-1] |= reached[1:]
        grown[:, 1:] |= reached[:, :-1]
        grown[:, :-1] |= reached[:, 1:]
        grown &= candidate
        if np.array_equal(grown, reached):
            return reached
        reached = grown


def dilate(mask, iters):
    """4-connected dilation of a boolean mask."""
    for _ in range(iters):
        grown = mask.copy()
        grown[1:] |= mask[:-1]
        grown[:-1] |= mask[1:]
        grown[:, 1:] |= mask[:, :-1]
        grown[:, :-1] |= mask[:, 1:]
        mask = grown
    return mask


def box_blur(a, r=1):
    """Separable box blur with edge clamping, via an integral image."""
    pad = np.pad(a, r, mode="edge")
    cs = np.cumsum(np.cumsum(pad, axis=0), axis=1)
    cs = np.pad(cs, ((1, 0), (1, 0)))
    k = 2 * r + 1
    h, w = a.shape
    return (
        cs[k : k + h, k : k + w]
        - cs[0:h, k : k + w]
        - cs[k : k + h, 0:w]
        + cs[0:h, 0:w]
    ) / (k * k)


def cut_out(path):
    rgb = np.asarray(Image.open(path).convert("RGB")).astype(np.float64)
    dist = np.sqrt(((rgb - fit_background(rgb)) ** 2).sum(axis=2))

    bg = flood_from_border(dist <= KEY_MAX)
    solid = ~bg
    # The ramp is only allowed in a narrow band hugging the solid region. The
    # open background carries enough grain that a global ramp would leave a
    # sparse haze of half-opaque pixels all over the square.
    band = dilate(solid, EDGE_BAND) & bg
    alpha = solid.astype(np.float64)
    alpha[band] = np.clip((dist[band] - KEY_LO) / (KEY_HI - KEY_LO), 0.0, 1.0)
    alpha = box_blur(box_blur(alpha))

    out = np.dstack([rgb, alpha * 255.0]).round().clip(0, 255).astype(np.uint8)
    return Image.fromarray(out), alpha


def place(img, frac):
    """Centre `img`, scaled so its long side is `frac` of a square canvas."""
    # Crop to the alpha channel: RGBA getbbox() would look at the colour
    # channels too, and those are non-zero across the whole square.
    box = img.getchannel("A").getbbox()
    art = img.crop(box)
    scale = (CANVAS * frac) / max(art.size)
    art = art.resize(
        (max(1, round(art.width * scale)), max(1, round(art.height * scale))),
        Image.LANCZOS,
    )
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    canvas.paste(art, ((CANVAS - art.width) // 2, (CANVAS - art.height) // 2))
    return canvas, art.size


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)
    if not os.path.exists(SRC):
        sys.exit(f"missing {SRC}")

    cut, alpha = cut_out(SRC)
    edge = ((alpha > 0.02) & (alpha < 0.98)).sum()
    print(f"cut-out: opaque {(alpha > 0.98).mean():.1%}, soft edge {edge} px")

    for out, frac in ((OUT_FG, 0.55), (OUT_SPLASH, 0.92)):
        canvas, size = place(cut, frac)
        canvas.save(out)
        print(f"{out}: art {size[0]}x{size[1]} on {CANVAS}x{CANVAS}")


if __name__ == "__main__":
    main()
