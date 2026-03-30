# Repository Guidelines

## Project Structure & Module Organization
This repository is an Omarchy theme bundle plus a wallpaper-generation workspace. Root-level theme files such as `hyprland.conf`, `waybar.css`, `foot.ini`, `ghostty.conf`, and `colors.css` define app- and shell-specific styling. Wallpaper inputs live in `backgrounds-originals/`, graded sources live in `backgrounds-originals-graded/`, and generated outputs are written to `approved-color-v2/`. Scene presets and build scripts live in `scripts/`, especially `scripts/build-color-collages-v2.sh`, `scripts/classic-scenes.yaml`, and `scripts/experimental-scenes.yaml`.

## Build, Test, and Development Commands
- `bash scripts/build-color-collages-v2.sh`
  Builds the default wallpaper set from `scripts/classic-scenes.yaml`.
- `bash scripts/build-color-collages-v2.sh --scenes-file scripts/experimental-scenes.yaml`
  Builds the alternate three-scene experimental set.
- `bash scripts/build-color-collages-v2.sh --out-dir /tmp/watchmen-test --brief`
  Useful for trial renders without touching checked-in outputs.
- `bash -n scripts/build-color-collages-v2.sh`
  Shell syntax check for the main generator before committing.
- `yq -r '.scenes | length' scripts/classic-scenes.yaml`
  Quick validation that scene YAML parses and has the expected count.

## Coding Style & Naming Conventions
Use 2-space indentation in YAML and 2-space/compact style in shell continuations already present in `scripts/`. Prefer Bash plus `yq`; keep dependencies minimal. Name scene files descriptively, for example `classic-scenes.yaml`. Name generated wallpapers with stable numeric or thematic prefixes such as `1-radial-triptuch.jpg` or `exp-1-monolith.jpg`.

## Testing Guidelines
There is no formal test suite. Validate changes by:
- running `bash -n` on edited shell scripts
- parsing edited YAML with `yq`
- generating a sample render to `/tmp`
- visually checking output alignment, shadow offsets, and color treatment

When changing scene logic, confirm both `classic-scenes.yaml` and `experimental-scenes.yaml` still parse.

## Commit & Pull Request Guidelines
Current history uses short, plain commit subjects such as `Theme revamping` and `initial commit`. Keep commits brief, imperative, and scoped to one change. For pull requests, include:
- a short summary of what changed
- affected files or scene sets
- before/after screenshots for visible theme or wallpaper changes
- any non-default build command used for verification

## Configuration Notes
The wallpaper builder expects `magick` or `convert` and `yq` to be installed. Do not commit throwaway test renders from `/tmp`; only promote final outputs into `approved-color-v2/` when the composition is intentional.
