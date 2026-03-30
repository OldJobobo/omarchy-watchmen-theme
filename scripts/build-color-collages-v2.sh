#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

src_dir_default="$repo_root/backgrounds-originals-graded"
out_dir_default="$repo_root/approved-color-v2"
scenes_file_default="$repo_root/scripts/classic-scenes.yaml"

if command -v magick >/dev/null 2>&1; then
  IM=(magick)
elif command -v convert >/dev/null 2>&1; then
  IM=(convert)
else
  echo "ImageMagick is required (magick or convert)." >&2
  exit 1
fi

canvas_w=3840
canvas_h=2160
margin=84
frame="#dfc0b0"
hero_shadow="#000000c4"
mid_shadow="#00000096"
src_dir="$src_dir_default"
out_dir="$out_dir_default"
scenes_file="$scenes_file_default"
bg_mode="default"
bg_style_override="default"
bg_brightness="0.82"
bg_saturation="75"
mid_brightness="0.82"
mid_saturation="75"
fg_brightness="1.00"
fg_saturation="100"
shadow_style="soft"
verbosity="verbose"
tmp_dir="$(mktemp -d)"
manifest="$out_dir/watchmen-color-collage-v2-manifest.txt"
trap 'rm -rf "$tmp_dir"' EXIT

declare -a wallpaper_names=()
declare -a scene_layouts=()
declare -a scene_backgrounds=()
declare -a scene_bg_treatment_keys=()
declare -a scene_mid_treatment_keys=()
declare -a scene_fg_treatment_keys=()
declare -a scene_shadow_styles=()
declare -a scene_declared_hero_counts=()
declare -a scene_declared_mid_counts=()
declare -A treatment_brightness=()
declare -A treatment_saturation=()

src() {
  printf '%s/%s' "$src_dir" "$1"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --src-dir PATH           Source image directory
  --out-dir PATH           Output directory
  --scenes-file PATH       Scene definition YAML file
  --bg-mode MODE           Background mode: default or random
  --bg-style STYLE         Background style override: default, solid, vertical, diagonal, radial, or random
  --bg-brightness VALUE    Background brightness multiplier
  --bg-saturation VALUE    Background saturation percentage
  --mid-brightness VALUE   Midground brightness multiplier
  --mid-saturation VALUE   Midground saturation percentage
  --fg-brightness VALUE    Foreground brightness multiplier
  --fg-saturation VALUE    Foreground saturation percentage
  --shadow-style STYLE     Panel drop shadow style: soft or hard
  --brief                  Brief status output
  --silent                 No status output
  --help                   Show this help text

Env vars still work as fallback:
  SCENES_FILE BG_MODE BG_STYLE BG_BRIGHTNESS BG_SATURATION
  MID_BRIGHTNESS MID_SATURATION
  FG_BRIGHTNESS FG_SATURATION SHADOW_STYLE VERBOSITY
EOF
}

apply_env_fallbacks() {
  src_dir="${SRC_DIR:-$src_dir}"
  out_dir="${OUT_DIR:-$out_dir}"
  scenes_file="${SCENES_FILE:-$scenes_file}"
  bg_mode="${BG_MODE:-$bg_mode}"
  bg_style_override="${BG_STYLE:-$bg_style_override}"
  bg_brightness="${BG_BRIGHTNESS:-$bg_brightness}"
  bg_saturation="${BG_SATURATION:-$bg_saturation}"
  mid_brightness="${MID_BRIGHTNESS:-$mid_brightness}"
  mid_saturation="${MID_SATURATION:-$mid_saturation}"
  fg_brightness="${FG_BRIGHTNESS:-$fg_brightness}"
  fg_saturation="${FG_SATURATION:-$fg_saturation}"
  shadow_style="${SHADOW_STYLE:-$shadow_style}"
  verbosity="${VERBOSITY:-$verbosity}"
}

require_value() {
  local flag="$1"
  local value="${2:-}"
  if [[ -z "$value" || "$value" == --* ]]; then
    echo "missing value for $flag" >&2
    usage >&2
    exit 1
  fi
}

parse_args() {
  while (($#)); do
    case "$1" in
      --src-dir)
        require_value "$1" "${2:-}"
        src_dir="$2"
        shift 2
        ;;
      --out-dir)
        require_value "$1" "${2:-}"
        out_dir="$2"
        shift 2
        ;;
      --scenes-file)
        require_value "$1" "${2:-}"
        scenes_file="$2"
        shift 2
        ;;
      --bg-mode)
        require_value "$1" "${2:-}"
        bg_mode="$2"
        shift 2
        ;;
      --bg-style)
        require_value "$1" "${2:-}"
        bg_style_override="$2"
        shift 2
        ;;
      --bg-brightness)
        require_value "$1" "${2:-}"
        bg_brightness="$2"
        shift 2
        ;;
      --bg-saturation)
        require_value "$1" "${2:-}"
        bg_saturation="$2"
        shift 2
        ;;
      --mid-brightness)
        require_value "$1" "${2:-}"
        mid_brightness="$2"
        shift 2
        ;;
      --mid-saturation)
        require_value "$1" "${2:-}"
        mid_saturation="$2"
        shift 2
        ;;
      --fg-brightness)
        require_value "$1" "${2:-}"
        fg_brightness="$2"
        shift 2
        ;;
      --fg-saturation)
        require_value "$1" "${2:-}"
        fg_saturation="$2"
        shift 2
        ;;
      --shadow-style)
        require_value "$1" "${2:-}"
        shadow_style="$2"
        shift 2
        ;;
      --brief)
        verbosity="brief"
        shift
        ;;
      --silent)
        verbosity="silent"
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        echo "unknown option: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done
}

load_scenes() {
  if [[ ! -f "$scenes_file" ]]; then
    echo "missing scenes file: $scenes_file" >&2
    exit 1
  fi

  if ! command -v yq >/dev/null 2>&1; then
    echo "yq is required to read scenes from $scenes_file" >&2
    exit 1
  fi

  mapfile -t wallpaper_names < <(yq -r '.scenes[].name' "$scenes_file")
  mapfile -t scene_layouts < <(yq -r '.scenes[].layout' "$scenes_file")
  mapfile -t scene_backgrounds < <(yq -r '.scenes[] | "\(.background[0])|\(.background[1])|\(.background[2])"' "$scenes_file")
  mapfile -t scene_bg_treatment_keys < <(yq -r '.scenes[] | (.treatment.bg // "")' "$scenes_file")
  mapfile -t scene_mid_treatment_keys < <(yq -r '.scenes[] | (.treatment.mid // "")' "$scenes_file")
  mapfile -t scene_fg_treatment_keys < <(yq -r '.scenes[] | (.treatment.fg // "")' "$scenes_file")
  mapfile -t scene_shadow_styles < <(yq -r '.scenes[] | (.shadow // "")' "$scenes_file")

  treatment_brightness=()
  treatment_saturation=()
  while IFS=$'\t' read -r name brightness saturation; do
    [[ -z "$name" ]] && continue
    treatment_brightness["$name"]="$brightness"
    treatment_saturation["$name"]="$saturation"
  done < <(yq -r '.treatments // {} | to_entries[] | "\(.key)\t\(.value.brightness // "")\t\(.value.saturation // "")"' "$scenes_file")

  if ((${#wallpaper_names[@]} == 0)); then
    echo "no scenes defined in $scenes_file" >&2
    exit 1
  fi

  local scene_shadow
  for scene_shadow in "${scene_shadow_styles[@]}"; do
    case "$scene_shadow" in
      ""|soft|hard) ;;
      *)
        echo "invalid scene shadow style in $scenes_file: $scene_shadow" >&2
        exit 1
        ;;
    esac
  done

  log_verbose "Loaded ${#wallpaper_names[@]} scenes from $scenes_file"
}

slot_lines() {
  local scene_idx="$1"
  local layer="$2"
  local key
  case "$layer" in
    hero) key="hero_slots" ;;
    mid) key="mid_slots" ;;
    *)
      echo "unknown slot layer: $layer" >&2
      exit 1
      ;;
  esac

  yq -r --argjson idx "$scene_idx" --arg key "$key" \
    '.scenes[$idx][$key][] | if length >= 6 then "\(. [0])|\(.[1])|\(.[2])|\(.[3])|\(.[4])|\(.[5])" else "\(. [0])|\(.[1])|\(.[2])|\(.[3])|\(.[4])|" end' \
    "$scenes_file"
}

validate_settings() {
  case "$bg_mode" in
    default|random) ;;
    *)
      echo "invalid --bg-mode: $bg_mode" >&2
      exit 1
      ;;
  esac

  case "$bg_style_override" in
    default|solid|vertical|diagonal|radial|random) ;;
    *)
      echo "invalid --bg-style: $bg_style_override" >&2
      exit 1
      ;;
  esac

  case "$verbosity" in
    verbose|brief|silent) ;;
    *)
      echo "invalid verbosity: $verbosity" >&2
      exit 1
      ;;
  esac

  case "$shadow_style" in
    soft|hard) ;;
    *)
      echo "invalid --shadow-style: $shadow_style" >&2
      exit 1
      ;;
  esac
}

log_verbose() {
  if [[ "$verbosity" == "verbose" ]]; then
    printf '%s\n' "$*"
  fi
}

log_status() {
  if [[ "$verbosity" != "silent" ]]; then
    printf '%s\n' "$*"
  fi
}

first_nonempty() {
  local value
  for value in "$@"; do
    if [[ -n "$value" ]]; then
      printf '%s\n' "$value"
      return 0
    fi
  done
  printf '\n'
}

treatment_value() {
  local key="$1"
  local field="$2"
  if [[ -z "$key" ]]; then
    printf '\n'
    return 0
  fi

  case "$field" in
    brightness)
      printf '%s\n' "${treatment_brightness[$key]:-}"
      ;;
    saturation)
      printf '%s\n' "${treatment_saturation[$key]:-}"
      ;;
    *)
      echo "unknown treatment field: $field" >&2
      exit 1
      ;;
  esac
}

apply_treatment() {
  local input="$1"
  local output="$2"
  local brightness="$3"
  local saturation="$4"

  "${IM[@]}" "$input" \
    -channel RGB -evaluate multiply "$brightness" +channel \
    -modulate 100,"$saturation",100 \
    "$output"
}

resolve_background() {
  local scene_idx="$1"
  local style="$2"
  local a="$3"
  local b="$4"

  if [[ "$bg_style_override" != "default" ]]; then
    if [[ "$bg_style_override" == "random" ]]; then
      local styles=(solid vertical diagonal radial)
      style="${styles[$((RANDOM % ${#styles[@]}))]}"
    else
      style="$bg_style_override"
    fi
  elif [[ "$bg_mode" == "random" ]]; then
    local styles=(solid vertical diagonal radial)
    style="${styles[$((RANDOM % ${#styles[@]}))]}"
  fi

  printf '%s|%s|%s\n' "$style" "$a" "$b"
}

declare -a resolved_backgrounds=()
declare -A source_use_count=()
declare -A source_hero_use_count=()
declare -A source_last_scene=()

prepare_backgrounds() {
  local i background bg_style bg_a bg_b
  for ((i=0; i<${#wallpaper_names[@]}; i++)); do
    background="${scene_backgrounds[$i]}"
    IFS='|' read -r bg_style bg_a bg_b <<< "$background"
    resolved_backgrounds[$i]="$(resolve_background "$i" "$bg_style" "$bg_a" "$bg_b")"
    log_verbose "Resolved background for ${wallpaper_names[$i]}: ${resolved_backgrounds[$i]}"
  done
}

panel_dims() {
  local file="$1"
  identify -format '%w %h' "$file"
}

build_bg() {
  local style="$1"
  local a="$2"
  local b="${3:-$2}"
  local out="$4"
  local brightness="$5"
  local saturation="$6"

  case "$style" in
    solid)
      "${IM[@]}" -size "${canvas_w}x${canvas_h}" "xc:$a" "$out"
      ;;
    vertical)
      "${IM[@]}" -size "${canvas_w}x${canvas_h}" xc:none \
        -sparse-color bilinear "0,0 $a 0,${canvas_h} $b" \
        "$out"
      ;;
    diagonal)
      "${IM[@]}" -size "${canvas_w}x${canvas_h}" xc:none \
        -sparse-color bilinear "0,0 $a ${canvas_w},${canvas_h} $b" \
        "$out"
      ;;
    radial)
      "${IM[@]}" -size "${canvas_w}x${canvas_h}" "radial-gradient:${a}-${b}" "$out"
      ;;
    *)
      echo "unknown background style: $style" >&2
      exit 1
      ;;
  esac

  apply_treatment "$out" "$out" "$brightness" "$saturation"
}

safe_xy() {
  local panel="$1"
  local wanted_x="$2"
  local wanted_y="$3"
  local w h
  read -r w h <<< "$(panel_dims "$panel")"

  local max_x=$((canvas_w - margin - w))
  local max_y=$((canvas_h - margin - h))
  local x="$wanted_x"
  local y="$wanted_y"

  if (( x < margin )); then x=$margin; fi
  if (( y < margin )); then y=$margin; fi
  if (( x > max_x )); then x=$max_x; fi
  if (( y > max_y )); then y=$max_y; fi

  printf '%s %s\n' "$x" "$y"
}

place_panel() {
  local canvas="$1"
  local panel="$2"
  local x="$3"
  local y="$4"
  local layer="${5:-}"
  local panel_shadow_style="${6:-soft}"
  local shadow_color=""
  local shadow_opacity=""
  local shadow_dx=6
  local shadow_dy=6

  read -r x y <<< "$(safe_xy "$panel" "$x" "$y")"

  if [[ "$panel_shadow_style" == "hard" ]]; then
    case "$layer" in
      mid)
        shadow_color="#000000"
        shadow_opacity="0.46"
        ;;
      hero)
        shadow_color="#000000"
        shadow_opacity="0.62"
        ;;
      *)
        echo "unknown hard shadow layer: $layer" >&2
        exit 1
        ;;
    esac

    "${IM[@]}" "$canvas" \
      "(" "$panel" -fill "$shadow_color" -colorize 100 -channel A -evaluate multiply "$shadow_opacity" +channel ")" \
      -gravity northwest -geometry "+$((x + shadow_dx))+$((y + shadow_dy))" -composite \
      "$canvas"
  fi

  "${IM[@]}" "$canvas" "$panel" -gravity northwest -geometry "+${x}+${y}" -composite "$canvas"
}

make_panel() {
  local layer="$1"
  local source="$2"
  local max_w="$3"
  local max_h="$4"
  local rotate="$5"
  local out="$6"
  local brightness="$7"
  local saturation="$8"
  local panel_shadow_style="$9"
  local shadow_color shadow_spec

  if [[ "$layer" == "mid" ]]; then
    if [[ "$panel_shadow_style" == "hard" ]]; then
      "${IM[@]}" "$source" \
        -resize "${max_w}x${max_h}^" \
        -gravity center \
        -extent "${max_w}x${max_h}" \
        -bordercolor "$frame" \
        -border 12 \
        -background none -rotate "$rotate" \
        "$out"
    else
      shadow_color="$mid_shadow"
      shadow_spec="28x6+0+5"
      "${IM[@]}" "$source" \
        -resize "${max_w}x${max_h}^" \
        -gravity center \
        -extent "${max_w}x${max_h}" \
        -bordercolor "$frame" \
        -border 12 \
        "(" +clone -background "$shadow_color" -shadow "$shadow_spec" ")" \
        +swap -background none -layers merge +repage \
        -background none -rotate "$rotate" \
        "$out"
    fi
    apply_treatment "$out" "$out" "$brightness" "$saturation"
  else
    if [[ "$panel_shadow_style" == "hard" ]]; then
      "${IM[@]}" "$source" \
        -resize "${max_w}x${max_h}" \
        -bordercolor "$frame" \
        -border 18 \
        -background none -rotate "$rotate" \
        "$out"
    else
      shadow_color="$hero_shadow"
      shadow_spec="72x16+0+10"
      "${IM[@]}" "$source" \
        -resize "${max_w}x${max_h}" \
        -bordercolor "$frame" \
        -border 18 \
        "(" +clone -background "$shadow_color" -shadow "$shadow_spec" ")" \
        +swap -background none -layers merge +repage \
        -background none -rotate "$rotate" \
        "$out"
    fi
    apply_treatment "$out" "$out" "$brightness" "$saturation"
  fi
}

load_sources() {
  mapfile -t all_sources < <(find "$src_dir" -maxdepth 1 -type f -printf '%f\n' | sort)
  if ((${#all_sources[@]} < 12)); then
    echo "need at least 12 source images in $src_dir" >&2
    exit 1
  fi
  log_verbose "Loaded ${#all_sources[@]} source images from $src_dir"
}

join_by() {
  local sep="$1"
  shift || true
  local first=1
  local item
  for item in "$@"; do
    if (( first )); then
      printf '%s' "$item"
      first=0
    else
      printf '%s%s' "$sep" "$item"
    fi
  done
}

contains_in_array() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

init_source_usage() {
  local source
  source_use_count=()
  source_hero_use_count=()
  source_last_scene=()
  for source in "${all_sources[@]}"; do
    source_use_count["$source"]=0
    source_hero_use_count["$source"]=0
    source_last_scene["$source"]=-1
  done
}

eligible_for_refs() {
  local candidate="$1"
  shift
  local ref_name
  for ref_name in "$@"; do
    [[ -z "$ref_name" ]] && continue
    if contains_in_ref "$ref_name" "$candidate"; then
      return 1
    fi
  done
  return 0
}

select_preferred_source() {
  local layer="$1"
  local scene_idx="$2"
  local start_idx="$3"
  shift 3
  local total="${#all_sources[@]}"
  local best_candidate=""
  local best_hero_count=-1
  local best_total_count=-1
  local best_last_scene=999999
  local offset idx candidate hero_count total_count last_scene

  for ((offset=0; offset<total; offset++)); do
    idx=$(( (start_idx + offset) % total ))
    candidate="${all_sources[$idx]}"
    if ! eligible_for_refs "$candidate" "$@"; then
      continue
    fi

    hero_count="${source_hero_use_count[$candidate]:-0}"
    total_count="${source_use_count[$candidate]:-0}"
    last_scene="${source_last_scene[$candidate]:--1}"
    if [[ -z "$best_candidate" \
      || hero_count -lt best_hero_count \
      || ( hero_count -eq best_hero_count && total_count -lt best_total_count ) \
      || ( hero_count -eq best_hero_count && total_count -eq best_total_count && last_scene -lt best_last_scene ) ]]; then
      best_candidate="$candidate"
      best_hero_count="$hero_count"
      best_total_count="$total_count"
      best_last_scene="$last_scene"
      if (( hero_count == 0 && total_count == 0 )); then
        break
      fi
    fi
  done

  if [[ -z "$best_candidate" ]]; then
    return 1
  fi

  printf '%s\n' "$best_candidate"
}

record_source_use() {
  local source="$1"
  local layer="$2"
  local scene_idx="$3"
  source_use_count["$source"]=$(( ${source_use_count["$source"]:-0} + 1 ))
  source_last_scene["$source"]="$scene_idx"
  if [[ "$layer" == "hero" ]]; then
    source_hero_use_count["$source"]=$(( ${source_hero_use_count["$source"]:-0} + 1 ))
  fi
}

init_scene_refs() {
  local i
  for ((i=0; i<${#wallpaper_names[@]}; i++)); do
    unset "hero_lists_$i" "mid_lists_$i" "hero_declared_lists_$i" "mid_declared_lists_$i"
    declare -g -a "hero_lists_$i=()"
    declare -g -a "mid_lists_$i=()"
    declare -g -a "hero_declared_lists_$i=()"
    declare -g -a "mid_declared_lists_$i=()"
  done
}

hero_list_ref() {
  printf 'hero_lists_%s\n' "$1"
}

mid_list_ref() {
  printf 'mid_lists_%s\n' "$1"
}

hero_declared_ref() {
  printf 'hero_declared_lists_%s\n' "$1"
}

mid_declared_ref() {
  printf 'mid_declared_lists_%s\n' "$1"
}

append_ref() {
  local ref_name="$1"
  local value="$2"
  declare -n ref="$ref_name"
  ref+=("$value")
}

get_ref_items() {
  local ref_name="$1"
  declare -n ref="$ref_name"
  if ((${#ref[@]} == 0)); then
    return 0
  fi
  printf '%s\n' "${ref[@]}"
}

ref_len() {
  local ref_name="$1"
  declare -n ref="$ref_name"
  printf '%s\n' "${#ref[@]}"
}

contains_in_ref() {
  local ref_name="$1"
  local needle="$2"
  declare -n ref="$ref_name"
  local item
  for item in "${ref[@]}"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

ref_join() {
  local ref_name="$1"
  local sep="$2"
  declare -n ref="$ref_name"
  join_by "$sep" "${ref[@]}"
}

ref_tail_join() {
  local ref_name="$1"
  local offset="$2"
  local sep="$3"
  declare -n ref="$ref_name"
  if (( offset >= ${#ref[@]} )); then
    printf '\n'
    return 0
  fi
  join_by "$sep" "${ref[@]:$offset}"
}

ref_head_join() {
  local ref_name="$1"
  local count="$2"
  local sep="$3"
  declare -n ref="$ref_name"
  if (( count <= 0 || ${#ref[@]} == 0 )); then
    printf '\n'
    return 0
  fi
  if (( count > ${#ref[@]} )); then
    count="${#ref[@]}"
  fi
  join_by "$sep" "${ref[@]:0:$count}"
}

load_declared_images() {
  local i hero_ref mid_ref
  local -a declared_items=()

  scene_declared_hero_counts=()
  scene_declared_mid_counts=()

  for ((i=0; i<${#wallpaper_names[@]}; i++)); do
    hero_ref="$(hero_declared_ref "$i")"
    mid_ref="$(mid_declared_ref "$i")"

    mapfile -t declared_items < <(yq -r --argjson idx "$i" '.scenes[$idx].hero_images // [] | .[]' "$scenes_file")
    declare -n hero_declared="$hero_ref"
    hero_declared=("${declared_items[@]}")
    scene_declared_hero_counts[$i]="${#declared_items[@]}"

    mapfile -t declared_items < <(yq -r --argjson idx "$i" '.scenes[$idx].mid_images // [] | .[]' "$scenes_file")
    declare -n mid_declared="$mid_ref"
    mid_declared=("${declared_items[@]}")
    scene_declared_mid_counts[$i]="${#declared_items[@]}"
  done
}

validate_declared_images() {
  local i expected_hero_count expected_mid_count hero_ref mid_ref item
  local -a hero_items=() mid_items=()
  local -A seen=()

  for ((i=0; i<${#wallpaper_names[@]}; i++)); do
    expected_hero_count="$(slot_lines "$i" hero | wc -l)"
    expected_mid_count="$(slot_lines "$i" mid | wc -l)"
    hero_ref="$(hero_declared_ref "$i")"
    mid_ref="$(mid_declared_ref "$i")"
    mapfile -t hero_items < <(get_ref_items "$hero_ref")
    mapfile -t mid_items < <(get_ref_items "$mid_ref")

    if ((${#hero_items[@]} > expected_hero_count)); then
      echo "declared hero_images exceed hero slots for ${wallpaper_names[$i]}" >&2
      exit 1
    fi

    if ((${#mid_items[@]} > expected_mid_count)); then
      echo "declared mid_images exceed mid slots for ${wallpaper_names[$i]}" >&2
      exit 1
    fi

    seen=()
    for item in "${hero_items[@]}"; do
      if ! contains_in_array "$item" "${all_sources[@]}"; then
        echo "declared hero image not found for ${wallpaper_names[$i]}: $item" >&2
        exit 1
      fi
      if [[ -n "${seen[$item]:-}" ]]; then
        echo "duplicate declared hero image in ${wallpaper_names[$i]}: $item" >&2
        exit 1
      fi
      seen["$item"]=1
    done

    seen=()
    for item in "${mid_items[@]}"; do
      if ! contains_in_array "$item" "${all_sources[@]}"; then
        echo "declared mid image not found for ${wallpaper_names[$i]}: $item" >&2
        exit 1
      fi
      if [[ -n "${seen[$item]:-}" ]]; then
        echo "duplicate declared mid image in ${wallpaper_names[$i]}: $item" >&2
        exit 1
      fi
      seen["$item"]=1
    done

    for item in "${hero_items[@]}"; do
      if contains_in_array "$item" "${mid_items[@]}"; then
        echo "declared mid_images overlap declared hero_images in ${wallpaper_names[$i]}: $item" >&2
        exit 1
      fi
    done
  done
}

seed_declared_images() {
  local scene_idx="$1"
  local layer="$2"
  local declared_ref target_ref item

  case "$layer" in
    hero)
      declared_ref="$(hero_declared_ref "$scene_idx")"
      target_ref="$(hero_list_ref "$scene_idx")"
      ;;
    mid)
      declared_ref="$(mid_declared_ref "$scene_idx")"
      target_ref="$(mid_list_ref "$scene_idx")"
      ;;
    *)
      echo "unknown declared image layer: $layer" >&2
      exit 1
      ;;
  esac

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    append_ref "$target_ref" "$item"
    record_source_use "$item" "$layer" "$scene_idx"
  done < <(get_ref_items "$declared_ref")
}

assign_scene_heroes() {
  local scene_idx="$1"
  local total="${#all_sources[@]}"
  local ref_name mid_declared_ref target_count slot start_idx candidate
  ref_name="$(hero_list_ref "$scene_idx")"
  mid_declared_ref="$(mid_declared_ref "$scene_idx")"
  target_count="$(slot_lines "$scene_idx" hero | wc -l)"
  seed_declared_images "$scene_idx" hero

  for ((slot=$(ref_len "$ref_name"); slot<target_count; slot++)); do
    start_idx=$(( (slot * 7 + scene_idx * 4 + scene_idx / 2) % total ))
    if ! candidate="$(select_preferred_source "hero" "$scene_idx" "$start_idx" "$ref_name" "$mid_declared_ref")"; then
      echo "unable to assign hero source within wallpaper ${wallpaper_names[$scene_idx]}" >&2
      exit 1
    fi
    append_ref "$ref_name" "$candidate"
    record_source_use "$candidate" "hero" "$scene_idx"
  done

  log_verbose "Assigned hero image set for ${wallpaper_names[$scene_idx]}"
}

assign_scene_midgrounds() {
  local scene_idx="$1"
  local target_count idx candidate ref_name hero_ref slot

  ref_name="$(mid_list_ref "$scene_idx")"
  hero_ref="$(hero_list_ref "$scene_idx")"
  target_count="$(slot_lines "$scene_idx" mid | wc -l)"
  idx=$(( scene_idx * 3 ))
  seed_declared_images "$scene_idx" mid

  for ((slot=$(ref_len "$ref_name"); slot<target_count; slot++)); do
    if ! candidate="$(select_preferred_source "mid" "$scene_idx" "$(( idx % ${#all_sources[@]} ))" "$hero_ref" "$ref_name")"; then
      echo "unable to assign midground set for ${wallpaper_names[$scene_idx]}" >&2
      exit 1
    fi
    append_ref "$ref_name" "$candidate"
    record_source_use "$candidate" "mid" "$scene_idx"
    idx=$((idx + 2))
  done

  log_verbose "Assigned midground image set for ${wallpaper_names[$scene_idx]}"
}

assign_sources_by_scene() {
  local scene_idx
  for ((scene_idx=0; scene_idx<${#wallpaper_names[@]}; scene_idx++)); do
    assign_scene_heroes "$scene_idx"
    assign_scene_midgrounds "$scene_idx"
  done
}

validate_assignments() {
  local i j hero_ref mid_ref hero_sig expected_hero_count expected_mid_count
  local -A seen_sig=()

  for ((i=0; i<${#wallpaper_names[@]}; i++)); do
    hero_ref="$(hero_list_ref "$i")"
    mid_ref="$(mid_list_ref "$i")"
    mapfile -t hero_items < <(get_ref_items "$hero_ref")
    mapfile -t mid_items < <(get_ref_items "$mid_ref")

    expected_hero_count="$(slot_lines "$i" hero | wc -l)"
    if ((${#hero_items[@]} != expected_hero_count)); then
      echo "expected $expected_hero_count heroes for ${wallpaper_names[$i]}, found ${#hero_items[@]}" >&2
      exit 1
    fi

    expected_mid_count="$(slot_lines "$i" mid | wc -l)"
    if ((${#mid_items[@]} != expected_mid_count)); then
      echo "expected $expected_mid_count midgrounds for ${wallpaper_names[$i]}, found ${#mid_items[@]}" >&2
      exit 1
    fi

    hero_sig="$(join_by '|' "${hero_items[@]}")"
    if [[ -n "${seen_sig[$hero_sig]:-}" ]]; then
      echo "duplicate hero set between ${wallpaper_names[$i]} and ${seen_sig[$hero_sig]}" >&2
      exit 1
    fi
    seen_sig["$hero_sig"]="${wallpaper_names[$i]}"

    for j in "${hero_items[@]}"; do
      if contains_in_array "$j" "${mid_items[@]}"; then
        echo "midground uses hero source $j in ${wallpaper_names[$i]}" >&2
        exit 1
      fi
    done
  done
}

write_manifest() {
  : > "$manifest"
  {
    printf 'Source dir: %s\n' "$src_dir"
    printf 'Output dir: %s\n' "$out_dir"
    printf 'Available sources: %s\n' "${#all_sources[@]}"
    printf 'BG mode: %s\n' "$bg_mode"
    printf 'BG style override: %s\n' "$bg_style_override"
    printf 'BG treatment: brightness=%s saturation=%s\n' "$bg_brightness" "$bg_saturation"
    printf 'MID treatment: brightness=%s saturation=%s\n' "$mid_brightness" "$mid_saturation"
    printf 'FG treatment: brightness=%s saturation=%s\n' "$fg_brightness" "$fg_saturation"
    printf 'Shadow style: %s\n' "$shadow_style"
    printf 'Note: This build guarantees unique hero sets per wallpaper and no hero/midground overlap within a wallpaper. Sources are assigned scene-by-scene; hero reuse is deferred until eligible hero candidates are exhausted, and post-hero reuse is deprioritized until lower-use alternatives are spent.\n'
  } >> "$manifest"

  local i hero_ref mid_ref hero_declared_count mid_declared_count
  for ((i=0; i<${#wallpaper_names[@]}; i++)); do
    hero_ref="$(hero_list_ref "$i")"
    mid_ref="$(mid_list_ref "$i")"
    hero_declared_count="${scene_declared_hero_counts[$i]:-0}"
    mid_declared_count="${scene_declared_mid_counts[$i]:-0}"
    {
      printf '\n[%s]\n' "${wallpaper_names[$i]}"
      printf 'layout=%s\n' "${scene_layouts[$i]}"
      printf 'background=%s\n' "${resolved_backgrounds[$i]}"
      printf 'heroes=%s\n' "$(ref_join "$hero_ref" ', ')"
      printf 'heroes_declared=%s\n' "$(ref_head_join "$hero_ref" "$hero_declared_count" ', ')"
      printf 'heroes_selected=%s\n' "$(ref_tail_join "$hero_ref" "$hero_declared_count" ', ')"
      printf 'midground=%s\n' "$(ref_join "$mid_ref" ', ')"
      printf 'midground_declared=%s\n' "$(ref_head_join "$mid_ref" "$mid_declared_count" ', ')"
      printf 'midground_selected=%s\n' "$(ref_tail_join "$mid_ref" "$mid_declared_count" ', ')"
    } >> "$manifest"
  done

  log_verbose "Wrote manifest to $manifest"
}

render_scene() {
  local scene_idx="$1"
  local name="${wallpaper_names[$scene_idx]}"
  local background="${resolved_backgrounds[$scene_idx]}"
  local bg_style bg_a bg_b
  local bg_scene_treatment_key mid_scene_treatment_key fg_scene_treatment_key
  local bg_scene_brightness bg_scene_saturation
  local mid_scene_brightness mid_scene_saturation
  local fg_scene_brightness fg_scene_saturation
  local scene_shadow_style effective_shadow_style
  local effective_bg_brightness effective_bg_saturation
  IFS='|' read -r bg_style bg_a bg_b <<< "$background"
  bg_scene_treatment_key="${scene_bg_treatment_keys[$scene_idx]}"
  mid_scene_treatment_key="${scene_mid_treatment_keys[$scene_idx]}"
  fg_scene_treatment_key="${scene_fg_treatment_keys[$scene_idx]}"
  scene_shadow_style="${scene_shadow_styles[$scene_idx]}"
  bg_scene_brightness="$(treatment_value "$bg_scene_treatment_key" brightness)"
  bg_scene_saturation="$(treatment_value "$bg_scene_treatment_key" saturation)"
  mid_scene_brightness="$(treatment_value "$mid_scene_treatment_key" brightness)"
  mid_scene_saturation="$(treatment_value "$mid_scene_treatment_key" saturation)"
  fg_scene_brightness="$(treatment_value "$fg_scene_treatment_key" brightness)"
  fg_scene_saturation="$(treatment_value "$fg_scene_treatment_key" saturation)"
  effective_bg_brightness="$(first_nonempty "$bg_scene_brightness" "$bg_brightness")"
  effective_bg_saturation="$(first_nonempty "$bg_scene_saturation" "$bg_saturation")"
  effective_shadow_style="$(first_nonempty "$scene_shadow_style" "$shadow_style")"

  local canvas="$tmp_dir/${name}.png"
  log_status "Rendering ${name} ($((scene_idx + 1))/${#wallpaper_names[@]})"
  log_verbose "  background: ${resolved_backgrounds[$scene_idx]}"
  log_verbose "  bg treatment: brightness=${effective_bg_brightness} saturation=${effective_bg_saturation}"
  log_verbose "  shadow style: ${effective_shadow_style}"
  build_bg "$bg_style" "$bg_a" "$bg_b" "$canvas" "$effective_bg_brightness" "$effective_bg_saturation"

  local hero_ref mid_ref
  hero_ref="$(hero_list_ref "$scene_idx")"
  mid_ref="$(mid_list_ref "$scene_idx")"
  mapfile -t hero_items < <(get_ref_items "$hero_ref")
  mapfile -t mid_items < <(get_ref_items "$mid_ref")

  local spec index=0 max_w max_h rotate x y slot_treatment_key source panel
  local effective_mid_brightness effective_mid_saturation
  local slot_brightness slot_saturation
  while IFS='|' read -r max_w max_h rotate x y slot_treatment_key; do
    source="$(src "${mid_items[$index]}")"
    if [[ ! -f "$source" ]]; then
      echo "missing assigned midground source: $source" >&2
      exit 1
    fi
    slot_brightness="$(treatment_value "$slot_treatment_key" brightness)"
    slot_saturation="$(treatment_value "$slot_treatment_key" saturation)"
    effective_mid_brightness="$(first_nonempty "$slot_brightness" "$mid_scene_brightness" "$mid_brightness")"
    effective_mid_saturation="$(first_nonempty "$slot_saturation" "$mid_scene_saturation" "$mid_saturation")"
    panel="$tmp_dir/${name}-mid-${index}.png"
    make_panel "mid" "$source" "$max_w" "$max_h" "$rotate" "$panel" "$effective_mid_brightness" "$effective_mid_saturation" "$effective_shadow_style"
    place_panel "$canvas" "$panel" "$x" "$y" "mid" "$effective_shadow_style"
    log_verbose "  mid[$index]: ${mid_items[$index]} @ ${x},${y} ${max_w}x${max_h} rot=${rotate} brightness=${effective_mid_brightness} saturation=${effective_mid_saturation} shadow=${effective_shadow_style}"
    index=$((index + 1))
  done < <(slot_lines "$scene_idx" mid)

  index=0
  local effective_fg_brightness effective_fg_saturation
  while IFS='|' read -r max_w max_h rotate x y slot_treatment_key; do
    source="$(src "${hero_items[$index]}")"
    if [[ ! -f "$source" ]]; then
      echo "missing assigned hero source: $source" >&2
      exit 1
    fi
    slot_brightness="$(treatment_value "$slot_treatment_key" brightness)"
    slot_saturation="$(treatment_value "$slot_treatment_key" saturation)"
    effective_fg_brightness="$(first_nonempty "$slot_brightness" "$fg_scene_brightness" "$fg_brightness")"
    effective_fg_saturation="$(first_nonempty "$slot_saturation" "$fg_scene_saturation" "$fg_saturation")"
    panel="$tmp_dir/${name}-hero-${index}.png"
    make_panel "hero" "$source" "$max_w" "$max_h" "$rotate" "$panel" "$effective_fg_brightness" "$effective_fg_saturation" "$effective_shadow_style"
    place_panel "$canvas" "$panel" "$x" "$y" "hero" "$effective_shadow_style"
    log_verbose "  hero[$index]: ${hero_items[$index]} @ ${x},${y} ${max_w}x${max_h} rot=${rotate} brightness=${effective_fg_brightness} saturation=${effective_fg_saturation} shadow=${effective_shadow_style}"
    index=$((index + 1))
  done < <(slot_lines "$scene_idx" hero)

  "${IM[@]}" "$canvas" \
    -quality 93 "$out_dir/${name}.jpg"
  log_status "Wrote $out_dir/${name}.jpg"
}

apply_env_fallbacks
parse_args "$@"
validate_settings

mkdir -p "$out_dir"
manifest="$out_dir/watchmen-color-collage-v2-manifest.txt"

log_status "Starting wallpaper build"
log_verbose "  scenes: $scenes_file"
log_verbose "  output: $out_dir"
log_verbose "  bg mode/style: $bg_mode / $bg_style_override"
log_verbose "  bg treatment: brightness=$bg_brightness saturation=$bg_saturation"
log_verbose "  mid treatment: brightness=$mid_brightness saturation=$mid_saturation"
log_verbose "  fg treatment: brightness=$fg_brightness saturation=$fg_saturation"
log_verbose "  shadow style: $shadow_style"

load_scenes
init_scene_refs
load_declared_images
load_sources
validate_declared_images
init_source_usage
assign_sources_by_scene
validate_assignments
prepare_backgrounds
write_manifest

for i in "${!wallpaper_names[@]}"; do
  render_scene "$i"
done

log_status "Wrote $manifest"
log_status "Build complete"
