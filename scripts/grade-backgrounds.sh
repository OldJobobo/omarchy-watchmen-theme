#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src_dir="${1:-$repo_root/backgrounds-originals}"
out_dir="${2:-$repo_root/backgrounds}"
overrides_file="$repo_root/scripts/grade-backgrounds-overrides.tsv"

if [[ ! -d "$src_dir" ]]; then
  printf 'missing source directory: %s\n' "$src_dir" >&2
  exit 1
fi

mkdir -p "$out_dir"

declare -A sigmoidal_overrides
declare -A brightness_contrast_overrides
declare -A ink_colorize_overrides
declare -A mauve_colorize_overrides
declare -A blue_colorize_overrides

if [[ -f "$overrides_file" ]]; then
  while IFS=$'\t' read -r name sigmoidal brightness_contrast ink_colorize mauve_colorize blue_colorize; do
    [[ -z "${name:-}" || "${name:0:1}" == "#" ]] && continue
    sigmoidal_overrides["$name"]="$sigmoidal"
    brightness_contrast_overrides["$name"]="$brightness_contrast"
    ink_colorize_overrides["$name"]="$ink_colorize"
    mauve_colorize_overrides["$name"]="$mauve_colorize"
    blue_colorize_overrides["$name"]="$blue_colorize"
  done < "$overrides_file"
fi

clamp() {
  local value="$1"
  local min="$2"
  local max="$3"
  awk -v v="$value" -v lo="$min" -v hi="$max" 'BEGIN {
    if (v < lo) v = lo
    if (v > hi) v = hi
    print v
  }'
}

round1() {
  awk -v v="$1" 'BEGIN { printf "%.1f", v }'
}

round0() {
  awk -v v="$1" 'BEGIN { printf "%.0f", v }'
}

compute_grade_defaults() {
  local src="$1"
  local mean stddev red_mean green_mean blue_mean
  local sig_strength sig_midpoint brightness contrast_reduce
  local ink_colorize mauve_colorize blue_colorize blue_bias warm_bias

  read -r mean stddev red_mean green_mean blue_mean < <(
    magick identify -quiet -format '%[fx:mean] %[fx:standard_deviation] %[fx:mean.r] %[fx:mean.g] %[fx:mean.b]\n' "$src"
  )

  blue_bias="$(awk -v r="$red_mean" -v g="$green_mean" -v b="$blue_mean" 'BEGIN { print b - ((r + g) / 2) }')"
  warm_bias="$(awk -v r="$red_mean" -v g="$green_mean" -v b="$blue_mean" 'BEGIN { print ((r + g) / 2) - b }')"

  sig_strength="$(awk -v m="$mean" -v s="$stddev" 'BEGIN {
    print 4.0 + ((m - 0.48) * 1.4) + ((0.33 - s) * 2.1)
  }')"
  sig_strength="$(round1 "$(clamp "$sig_strength" 3.4 4.6)")"

  sig_midpoint="$(awk -v m="$mean" 'BEGIN {
    print 43.5 + ((m - 0.50) * 8.0)
  }')"
  sig_midpoint="$(round0 "$(clamp "$sig_midpoint" 41 46)")"

  brightness="$(awk -v m="$mean" 'BEGIN {
    print 3.0 + ((0.50 - m) * 24.0)
  }')"
  brightness="$(round0 "$(clamp "$brightness" 0 6)")"

  contrast_reduce="$(awk -v s="$stddev" 'BEGIN {
    print -7.0 + ((s - 0.33) * 12.0)
  }')"
  contrast_reduce="$(round0 "$(clamp "$contrast_reduce" -9 -4)")"

  ink_colorize="$(awk -v m="$mean" -v s="$stddev" 'BEGIN {
    print 4.9 + ((m - 0.48) * 3.2) + ((0.33 - s) * 3.0)
  }')"
  ink_colorize="$(round1 "$(clamp "$ink_colorize" 3.8 5.8)")"

  mauve_colorize="$(awk -v w="$warm_bias" 'BEGIN {
    print 1.9 + (w * 6.0)
  }')"
  mauve_colorize="$(round1 "$(clamp "$mauve_colorize" 1.2 2.6)")"

  blue_colorize="$(awk -v b="$blue_bias" -v w="$warm_bias" 'BEGIN {
    print 1.0 - (b * 10.0) + (w * 4.0)
  }')"
  blue_colorize="$(round1 "$(clamp "$blue_colorize" 0.6 1.4)")"

  printf '%s %s %s %s %s\n' \
    "${sig_strength}x${sig_midpoint}%" \
    "${brightness}x${contrast_reduce}" \
    "$ink_colorize" \
    "$mauve_colorize" \
    "$blue_colorize"
}

shopt -s nullglob
files=("$src_dir"/*)
if (( ${#files[@]} == 0 )); then
  printf 'no source wallpapers found in: %s\n' "$src_dir" >&2
  exit 1
fi

for src in "${files[@]}"; do
  base="$(basename "$src")"
  dest="$out_dir/$base"
  read -r sigmoidal brightness_contrast ink_colorize mauve_colorize blue_colorize < <(
    compute_grade_defaults "$src"
  )

  if [[ -n "${sigmoidal_overrides[$base]:-}" ]]; then
    sigmoidal="${sigmoidal_overrides[$base]}"
    brightness_contrast="${brightness_contrast_overrides[$base]}"
    ink_colorize="${ink_colorize_overrides[$base]}"
    mauve_colorize="${mauve_colorize_overrides[$base]}"
    blue_colorize="${blue_colorize_overrides[$base]}"
  fi

  # Subtle noir unification:
  # - compress contrast and lift shadow floor a bit
  # - gently mute saturation
  # - bias the set toward the theme's ink/mauve/blue palette without obvious recoloring
  magick "$src" \
    -auto-orient \
    +sigmoidal-contrast "$sigmoidal" \
    -brightness-contrast "$brightness_contrast" \
    -modulate 100,92,100 \
    -fill '#2c2d37' -colorize "$ink_colorize" \
    -fill '#9287b0' -colorize "$mauve_colorize" \
    -fill '#2488cb' -colorize "$blue_colorize" \
    "$dest"
done
