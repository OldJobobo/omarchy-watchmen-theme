# Repository Guidelines

## Project Structure & Module Organization
This repository is an Omarchy theme bundle plus a wallpaper-generation workspace. Root-level theme files such as `hyprland.conf`, `waybar.css`, `foot.ini`, `ghostty.conf`, and `colors.css` define app- and shell-specific styling. Wallpaper inputs live in `backgrounds-originals/`, graded sources live in `backgrounds-originals-graded/`, and generated outputs are written to `approved-color-v2/`. Scene presets and build scripts live in `scripts/`, especially `scripts/build-collages.sh`, `scripts/classic-scenes.yaml`, and `scripts/experimental-scenes.yaml`.

## Build, Test, and Development Commands
- `bash scripts/build-collages.sh`
  Builds the default wallpaper set from `scripts/classic-scenes.yaml`.
- `bash scripts/build-collages.sh --scenes-file scripts/experimental-scenes.yaml`
  Builds the alternate three-scene experimental set.
- `bash scripts/build-collages.sh --scenes-file scripts/classic-scenes.yaml --validate-only --brief`
  Fast scene-file validation pass: parses YAML, resolves sources, assigns images, and runs geometry sanity checks without rendering JPGs.
- `bash scripts/build-collages.sh --scenes-file scripts/classic-scenes.yaml --probe-render --out-dir /tmp/watchmen-probe --brief`
  Low-res probe render for quick composition checks without paying for a full 4K pass.
- `bash scripts/build-collages.sh --scenes-file scripts/classic-scenes.yaml --probe-render --preview-contact-sheet --out-dir /tmp/watchmen-probe --brief`
  Probe render plus a thumbnail contact sheet for scanning the whole scene set at once.
- `bash scripts/build-collages.sh --out-dir /tmp/watchmen-test --brief`
  Useful for trial renders without touching checked-in outputs.
- `bash -n scripts/build-collages.sh`
  Shell syntax check for the main generator before committing.
- `yq -r '.scenes | length' scripts/classic-scenes.yaml`
  Quick validation that scene YAML parses and has the expected count.

## Coding Style & Naming Conventions
Use 2-space indentation in YAML and 2-space/compact style in shell continuations already present in `scripts/`. Prefer Bash plus `yq`; keep dependencies minimal. Name scene files descriptively, for example `classic-scenes.yaml`. Name generated wallpapers with stable numeric or thematic prefixes such as `1-radial-triptuch.jpg` or `exp-1-monolith.jpg`.

For the full scene-file YAML reference, including `bg_image`, top-level globals, slot syntax, and supported enums/defaults, see `SCENE_YAML_REFERENCE.md`.

## Testing Guidelines
There is no formal test suite. Validate changes by:
- running `bash -n` on edited shell scripts
- parsing edited YAML with `yq`
- running `bash scripts/build-collages.sh --scenes-file path/to/scenes.yaml --validate-only --brief` for fast scene validation
- running `bash scripts/build-collages.sh --scenes-file path/to/scenes.yaml --probe-render --out-dir /tmp/watchmen-probe --brief` for a cheap visual pass
- generating a sample render to `/tmp`
- visually checking output alignment, shadow offsets, and color treatment

`--validate-only` catches scene-file structure, treatment references, source existence, assignment constraints, and obvious off-canvas slot placement before render time. Use a real `/tmp` render only for final composition and aesthetic review.

`--probe-render` defaults to `hd` unless you explicitly pass `--output-resolution`, and `--preview-contact-sheet` writes `watchmen-preview-contact-sheet.jpg` alongside the rendered JPGs.

When changing scene logic, confirm both `classic-scenes.yaml` and `experimental-scenes.yaml` still validate.

## Commit & Pull Request Guidelines
Current history uses short, plain commit subjects such as `Theme revamping` and `initial commit`. Keep commits brief, imperative, and scoped to one change. For pull requests, include:
- a short summary of what changed
- affected files or scene sets
- before/after screenshots for visible theme or wallpaper changes
- any non-default build command used for verification

## Configuration Notes
The wallpaper builder expects `magick` or `convert` and `yq` to be installed. Do not commit throwaway test renders from `/tmp`; only promote final outputs into `approved-color-v2/` when the composition is intentional.
