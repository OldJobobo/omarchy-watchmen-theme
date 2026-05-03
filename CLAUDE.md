# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

An Omarchy desktop theme inspired by the Watchmen comic. It ships static config files consumed directly by Omarchy's theme loader, plus Bash tooling that grades source wallpapers and generates composite wallpaper collages from scene YAML using ImageMagick.

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
| `palette/watchmen64.yaml` | Canonical Higgins 64-color palette reference |
| `watchmen64.yaml` | Legacy root-level palette snapshot kept with the theme files |

`colors.css` is the canonical palette. When updating colors, start here and propagate changes to the per-app files.

## Wallpaper collage pipeline

**Requires:** ImageMagick (`magick` or `convert`) and bash.

**Source images** live in `backgrounds-originals/` (raw) and `backgrounds-originals-graded/` (graded build input). Standalone graded wallpaper outputs from `scripts/grade-backgrounds.sh` are written to `backgrounds/`.

**Build command:**
```bash
./scripts/build-collages.sh [options]
```

Key options:
```
--src-dir PATH        Source image directory (default: backgrounds-originals-graded/)
--out-dir PATH        Output directory (default: approved-color-v2/)
--scenes-file PATH    Scene YAML (default: scripts/classic-scenes.yaml)
--bg-style STYLE      solid | vertical | diagonal | radial | random
--shadow-style STYLE  soft | hard
--validate-only       Validate scene definitions and geometry without rendering JPGs
--probe-render        Low-res preview render; defaults to hd unless overridden
--preview-contact-sheet  Build watchmen-preview-contact-sheet.jpg from rendered outputs
--brief / --silent    Control output verbosity
```

**Scene definitions** are YAML files in `scripts/`. Each scene specifies:
- `layout` — compositing layout (e.g. `monolith`, `contact_sheet`, `bridge_collapse`)
- `background` — gradient/solid fill with two hex color stops
- `treatment` — per-layer brightness/saturation settings keyed from a `treatments:` block
- `hero_slots` / `mid_slots` — `[width, height, rotation, x, y]` tuples for panel placement
- `hero_images` / `mid_images` — optional explicit image assignments; unspecified slots use the auto-allocator

For the full declarative scene-file schema, including top-level globals, `bg_image`, slot syntax, defaults, enums, and validation rules, see `SCENE_YAML_REFERENCE.md`.

Common scene files:

- `classic-scenes.yaml` — main shipped collage set
- `experimental-scenes.yaml` — compact alternate set
- `declarative-showcase-scenes.yaml` — declarative format examples
- `design-studio-scenes.yaml` / `feature-showcase-scenes.yaml` — larger exploratory sets

**Build output** goes to `approved-color-v2/`. A build report (`watchmen-build-report.txt`) is written alongside the JPGs recording which source images were used for each scene.

**Recommended authoring loop:**
```bash
bash -n scripts/build-collages.sh
yq -r '.scenes | length' path/to/scenes.yaml
bash scripts/build-collages.sh --scenes-file path/to/scenes.yaml --validate-only --brief
bash scripts/build-collages.sh --scenes-file path/to/scenes.yaml --probe-render --out-dir /tmp/watchmen-probe --brief
bash scripts/build-collages.sh --scenes-file path/to/scenes.yaml --probe-render --preview-contact-sheet --out-dir /tmp/watchmen-probe --brief
bash scripts/build-collages.sh --scenes-file path/to/scenes.yaml --out-dir /tmp/watchmen-test --brief
```

`--validate-only` is the fast first pass. It checks scene structure, treatment references, source existence, declarative image rules, automatic image assignment, and basic off-canvas geometry warnings without waiting for a full ImageMagick render.

`--probe-render` is the next step up: it renders a cheaper preview pass at `hd` by default, unless you explicitly override `--output-resolution`. `--preview-contact-sheet` writes a thumbnail overview image beside the probe outputs so you can assess an entire scene set quickly.

## Palette structure

The theme palette derives from the Watchmen Higgins 64-color grid (`palette/watchmen64.yaml`). Semantic roles:

- `bg` `#2C2D37` — dark navy/charcoal base
- `fg` `#CEB8B0` — warm paper/parchment foreground
- `accent` `#9287B0` — muted purple (primary interactive)
- `red` `#C13E46` — Comedian red (errors, keywords)
- `cyan` `#80BCC0` — Dr. Manhattan blue-cyan
- `yellow` `#D2833B` — amber/rust (warnings, numbers)
- `green` `#ADC4B3` — faded sage

All Base16 aliases in `colors.css` map `base00`–`base0F` to these palette entries.
