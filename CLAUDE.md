# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

An Omarchy desktop theme inspired by the Watchmen comic. It ships static config files consumed directly by Omarchy's theme loader, plus a bash script that generates composite wallpapers (collages) from source images using ImageMagick.

## Theme file roles

Each file targets a specific Omarchy consumer — they are independent and do not cross-reference each other:

| File | Consumer |
|---|---|
| `colors.css` | GTK / Waybar / CSS consumers — canonical palette source with both Omarchy tokens and Base16 aliases |
| `colors/watchmen.lua` | Neovim colorscheme |
| `neovim.lua` | Additional Neovim highlight overrides |
| `waybar.css` | Waybar bar styling |
| `gtk.css` | GTK application overrides |
| `foot.ini` | Foot terminal |
| `alacritty.toml` | Alacritty terminal |
| `kitty.conf` | Kitty terminal |
| `ghostty.conf` | Ghostty terminal |
| `warp.yaml` | Warp terminal |
| `hyprlock.conf` | Hyprlock screen lock |
| `mako.ini` | Mako notification daemon |
| `chromium.theme` | Chromium browser |
| `icons.theme` | Icon theme pointer |
| `vencord.theme.css` | Vencord/Discord |
| `watchmen.override.css` | CSS overrides layer |
| `watchmen.zed.json` | Zed editor |
| `watchmen64.yaml` | 64-color Higgins palette grid (source of truth for the 7×9 color grid) |

`colors.css` is the canonical palette. When updating colors, start here and propagate changes to the per-app files.

## Wallpaper collage pipeline

**Requires:** ImageMagick (`magick` or `convert`) and bash.

**Source images** live in `backgrounds-originals/` (raw) and `backgrounds-originals-graded/` (color-graded, used as actual build input).

**Build command:**
```bash
./scripts/build-color-collages-v2.sh [options]
```

Key options:
```
--src-dir PATH        Source image directory (default: backgrounds-originals-graded/)
--out-dir PATH        Output directory (default: approved-color-v2/)
--scenes-file PATH    Scene YAML (default: scripts/classic-scenes.yaml)
--bg-style STYLE      solid | vertical | diagonal | radial | random
--shadow-style STYLE  soft | hard
--brief / --silent    Control output verbosity
```

**Scene definitions** are YAML files in `scripts/`. Each scene specifies:
- `layout` — compositing layout (e.g. `monolith`, `contact_sheet`, `bridge_collapse`)
- `background` — gradient/solid fill with two hex color stops
- `treatment` — per-layer brightness/saturation settings keyed from a `treatments:` block
- `hero_slots` / `mid_slots` — `[width, height, rotation, x, y]` tuples for panel placement
- `hero_images` / `mid_images` — optional explicit image assignments; unspecified slots use the auto-allocator

`declarative-showcase-scenes.yaml` is the newer declarative format; `classic-scenes.yaml` is the original format.

**Build output** goes to `approved-color-v2/`. A manifest file (`watchmen-color-collage-v2-manifest.txt`) is written alongside the JPGs recording which source images were used for each scene.

## Palette structure

The theme palette derives from the Watchmen Higgins 64-color grid (`watchmen64.yaml`). Semantic roles:

- `bg` `#2C2D37` — dark navy/charcoal base
- `fg` `#CEB8B0` — warm paper/parchment foreground
- `accent` `#9287B0` — muted purple (primary interactive)
- `red` `#C13E46` — Comedian red (errors, keywords)
- `cyan` `#80BCC0` — Dr. Manhattan blue-cyan
- `yellow` `#D2833B` — amber/rust (warnings, numbers)
- `green` `#ADC4B3` — faded sage

All Base16 aliases in `colors.css` map `base00`–`base0F` to these palette entries.
