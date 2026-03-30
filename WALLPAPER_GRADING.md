# Watchmen Wallpaper Grading

The shipped wallpapers in `backgrounds/` are generated derivatives.

Source of truth:

- archived originals live in `backgrounds-originals/`
- graded outputs live in `backgrounds/`

Regenerate the active set with:

```bash
./scripts/grade-backgrounds.sh
```

The grading target is intentionally subtle:

- reduce contrast enough to keep black window shadows legible
- slightly lift/compress the black floor
- mute saturation a bit
- apply a very light Watchmen palette bias so the set reads as one world

Implementation notes:

- `scripts/grade-backgrounds.sh` probes each image and computes default grading values from image metrics
- `scripts/grade-backgrounds-overrides.tsv` owns per-file tuning overrides
- the TSV is a last-mile exception layer, not the primary grading model
- if a wallpaper needs different treatment, add or adjust a row in the TSV instead of hard-coding another filename branch in the script

Do not hand-edit `backgrounds/` directly unless you also update the archived original or change the grading recipe.
