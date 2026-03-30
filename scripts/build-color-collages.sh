#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src_dir="${1:-$repo_root/backgrounds-originals-graded}"
out_dir="${2:-$repo_root/approved-color}"

mkdir -p "$out_dir"

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
frame="#dfc0b0"
shadow="#000000b0"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

make_panel() {
  local src="$1"
  local size="$2"
  local rotate="${3:-0}"
  local out="$4"

  local max_w="${size%x*}"
  local max_h="${size#*x}"

  "${IM[@]}" "$src" \
    -resize "${max_w}x${max_h}" \
    -bordercolor "$frame" \
    -border 18 \
    "(" +clone -background "$shadow" -shadow 75x18+0+12 ")" \
    +swap -background none -layers merge +repage \
    -distort SRT "$rotate" \
    "$out"
}

make_filler_panel() {
  local src="$1"
  local size="$2"
  local rotate="${3:-0}"
  local out="$4"

  local max_w="${size%x*}"
  local max_h="${size#*x}"

  "${IM[@]}" "$src" \
    -resize "${max_w}x${max_h}" \
    -modulate 92,85,100 \
    -bordercolor "$frame" \
    -border 14 \
    "(" +clone -background "#00000070" -shadow 55x14+0+8 ")" \
    +swap -background none -layers merge +repage \
    -distort SRT "$rotate" \
    "$out"
}

make_bg() {
  local style="$1"
  local a="$2"
  local b="${3:-$2}"
  local out="$4"

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
      "${IM[@]}" -size "${canvas_w}x${canvas_h}" xc:none \
        -sparse-color bilinear "0,0 $b ${canvas_w},0 $b $((canvas_w / 2)),$((canvas_h / 2)) $a 0,${canvas_h} $b ${canvas_w},${canvas_h} $b" \
        "$out"
      ;;
    *)
      echo "unknown background style: $style" >&2
      exit 1
      ;;
  esac
}

place_panels() {
  local canvas="$1"
  shift
  local cmd=("${IM[@]}" "$canvas")

  while (($#)); do
    local panel="$1"
    local x="$2"
    local y="$3"
    shift 3
    cmd+=("$panel" -gravity northwest -geometry "+${x}+${y}" -composite)
  done

  cmd+=("$canvas")
  "${cmd[@]}"
}

src() {
  printf '%s/%s' "$src_dir" "$1"
}

build_01() {
  local canvas="$tmp_dir/build-01.png"
  make_bg radial "#242949" "#4e6aa0" "$canvas"

  make_filler_panel "$(src wallhaven-gjqyrq_LE_upscale_gentle_x2.jpg)" 620x350 -12 "$tmp_dir/f1.png"
  make_filler_panel "$(src wp7238492-watchmen-comic-wallpapers.jpg)" 580x330 11 "$tmp_dir/f2.png"
  make_filler_panel "$(src wallhaven-8xkqz1_LE_upscale_gentle_x2.jpg)" 600x340 -9 "$tmp_dir/f3.png"
  make_filler_panel "$(src wallhaven-1jd56v_LE_upscale_gentle_x2.jpg)" 580x330 10 "$tmp_dir/f4.png"
  make_filler_panel "$(src wp7238442.jpg)" 620x350 -7 "$tmp_dir/f5.png"
  make_panel "$(src wallhaven-nev8o4_LE_upscale_gentle_x2.jpg)" 1050x620 -7 "$tmp_dir/p1.png"
  make_panel "$(src wallhaven-j81g2w_LE_upscale_gentle_x2.jpg)" 1020x580 5 "$tmp_dir/p2.png"
  make_panel "$(src watchmen-dr-manhattan-wallpaper-820112d01dc61ebbca5872f5c0e82932.jpg)" 1180x650 2 "$tmp_dir/p3.png"
  make_panel "$(src wp7238489-watchmen-comic-wallpapers.jpg)" 1040x610 -4 "$tmp_dir/p4.png"
  make_panel "$(src wallhaven-x17rq3_LE_upscale_gentle_x2.jpg)" 980x570 6 "$tmp_dir/p5.png"

  place_panels "$canvas" \
    "$tmp_dir/f1.png" 250 700 \
    "$tmp_dir/f2.png" 1350 860 \
    "$tmp_dir/f3.png" 2100 760 \
    "$tmp_dir/f4.png" 2920 980 \
    "$tmp_dir/f5.png" 1660 1220 \
    "$tmp_dir/p1.png" 120 210 \
    "$tmp_dir/p2.png" 1420 205 \
    "$tmp_dir/p3.png" 2500 210 \
    "$tmp_dir/p4.png" 300 1260 \
    "$tmp_dir/p5.png" 2520 1260

  "${IM[@]}" "$canvas" -quality 92 "$out_dir/watchmen-color-collage-01.jpg"
}

build_02() {
  local canvas="$tmp_dir/build-02.png"
  make_bg diagonal "#512345" "#ad93b7" "$canvas"

  make_filler_panel "$(src wallhaven-x17rq3_LE_upscale_gentle_x2.jpg)" 580x330 -10 "$tmp_dir/f1.png"
  make_filler_panel "$(src wp7238489-watchmen-comic-wallpapers.jpg)" 620x350 8 "$tmp_dir/f2.png"
  make_filler_panel "$(src wallhaven-1jd56v_LE_upscale_gentle_x2.jpg)" 580x330 -11 "$tmp_dir/f3.png"
  make_filler_panel "$(src wp7238442.jpg)" 600x340 9 "$tmp_dir/f4.png"
  make_filler_panel "$(src watchmen-wallpaper-4960188d115a9d7bd61748cf70e1064d.jpg)" 620x350 -8 "$tmp_dir/f5.png"
  make_panel "$(src watchmen-dr-manhattan-hd-pink-comics-page-wallpaper-12f1c2d02d066e7baad8526510181932.jpg)" 1260x720 3 "$tmp_dir/p1.png"
  make_panel "$(src wp7238479-watchmen-comic-wallpapers.jpg)" 940x560 -6 "$tmp_dir/p2.png"
  make_panel "$(src wallhaven-gjqyrq_LE_upscale_gentle_x2.jpg)" 1040x610 2 "$tmp_dir/p3.png"
  make_panel "$(src wallhaven-nev8o4_LE_upscale_gentle_x2.jpg)" 930x560 5 "$tmp_dir/p4.png"
  make_panel "$(src wp7238480-watchmen-comic-wallpapers.jpg)" 1040x610 -4 "$tmp_dir/p5.png"

  place_panels "$canvas" \
    "$tmp_dir/f1.png" 420 780 \
    "$tmp_dir/f2.png" 1190 1020 \
    "$tmp_dir/f3.png" 2980 760 \
    "$tmp_dir/f4.png" 2050 1190 \
    "$tmp_dir/f5.png" 520 1120 \
    "$tmp_dir/p1.png" 1260 180 \
    "$tmp_dir/p2.png" 2480 260 \
    "$tmp_dir/p3.png" 250 1280 \
    "$tmp_dir/p4.png" 2330 1260 \
    "$tmp_dir/p5.png" 320 250

  "${IM[@]}" "$canvas" -quality 92 "$out_dir/watchmen-color-collage-02.jpg"
}

build_03() {
  local canvas="$tmp_dir/build-03.png"
  make_bg vertical "#79383f" "#2c2d37" "$canvas"

  make_filler_panel "$(src wallhaven-nev8o4_LE_upscale_gentle_x2.jpg)" 580x330 9 "$tmp_dir/f1.png"
  make_filler_panel "$(src wp7238489-watchmen-comic-wallpapers.jpg)" 620x350 -8 "$tmp_dir/f2.png"
  make_filler_panel "$(src wallhaven-gjqyrq_LE_upscale_gentle_x2.jpg)" 580x330 11 "$tmp_dir/f3.png"
  make_filler_panel "$(src watchmen-wallpaper-4960188d115a9d7bd61748cf70e1064d.jpg)" 620x350 -7 "$tmp_dir/f4.png"
  make_filler_panel "$(src wallhaven-1jd56v_LE_upscale_gentle_x2.jpg)" 600x340 8 "$tmp_dir/f5.png"
  make_panel "$(src 'wallhaven-zxqwkj_LE_upscale_gentle (1).jpg')" 1120x650 -6 "$tmp_dir/p1.png"
  make_panel "$(src wallhaven-j81g2w_LE_upscale_gentle_x2.jpg)" 1060x610 4 "$tmp_dir/p2.png"
  make_panel "$(src wp7238492-watchmen-comic-wallpapers.jpg)" 980x610 1 "$tmp_dir/p3.png"
  make_panel "$(src watchmen-dr-manhattan-wallpaper-820112d01dc61ebbca5872f5c0e82932.jpg)" 980x560 -3 "$tmp_dir/p4.png"
  make_panel "$(src wallhaven-x17rq3_LE_upscale_gentle_x2.jpg)" 1020x580 5 "$tmp_dir/p5.png"

  place_panels "$canvas" \
    "$tmp_dir/f1.png" 360 760 \
    "$tmp_dir/f2.png" 1370 860 \
    "$tmp_dir/f3.png" 2780 800 \
    "$tmp_dir/f4.png" 1730 1250 \
    "$tmp_dir/f5.png" 640 1290 \
    "$tmp_dir/p1.png" 140 1020 \
    "$tmp_dir/p2.png" 260 250 \
    "$tmp_dir/p3.png" 2700 260 \
    "$tmp_dir/p4.png" 1450 300 \
    "$tmp_dir/p5.png" 2390 1190

  "${IM[@]}" "$canvas" -quality 92 "$out_dir/watchmen-color-collage-03.jpg"
}

build_04() {
  local canvas="$tmp_dir/build-04.png"
  make_bg diagonal "#2488cb" "#1f1d3c" "$canvas"

  make_filler_panel "$(src wallhaven-j81g2w_LE_upscale_gentle_x2.jpg)" 580x330 -9 "$tmp_dir/f1.png"
  make_filler_panel "$(src wp7238492-watchmen-comic-wallpapers.jpg)" 620x350 10 "$tmp_dir/f2.png"
  make_filler_panel "$(src wallhaven-gjqyrq_LE_upscale_gentle_x2.jpg)" 600x340 -8 "$tmp_dir/f3.png"
  make_filler_panel "$(src watchmen-wallpaper-4960188d115a9d7bd61748cf70e1064d.jpg)" 580x330 9 "$tmp_dir/f4.png"
  make_filler_panel "$(src wallhaven-8xkqz1_LE_upscale_gentle_x2.jpg)" 620x350 -10 "$tmp_dir/f5.png"
  make_panel "$(src watchmen-dr-manhattan-wallpaper-820112d01dc61ebbca5872f5c0e82932.jpg)" 1240x700 -2 "$tmp_dir/p1.png"
  make_panel "$(src wallhaven-nev8o4_LE_upscale_gentle_x2.jpg)" 980x560 4 "$tmp_dir/p2.png"
  make_panel "$(src wp7238489-watchmen-comic-wallpapers.jpg)" 980x580 -5 "$tmp_dir/p3.png"
  make_panel "$(src wallhaven-j81g2w_LE_upscale_gentle_x2.jpg)" 1020x560 6 "$tmp_dir/p4.png"
  make_panel "$(src wallhaven-gjqyrq_LE_upscale_gentle_x2.jpg)" 980x580 -4 "$tmp_dir/p5.png"

  place_panels "$canvas" \
    "$tmp_dir/f1.png" 410 860 \
    "$tmp_dir/f2.png" 1450 520 \
    "$tmp_dir/f3.png" 2850 860 \
    "$tmp_dir/f4.png" 660 1190 \
    "$tmp_dir/f5.png" 2190 1190 \
    "$tmp_dir/p1.png" 1290 760 \
    "$tmp_dir/p2.png" 220 230 \
    "$tmp_dir/p3.png" 2520 240 \
    "$tmp_dir/p4.png" 250 1350 \
    "$tmp_dir/p5.png" 2530 1320

  "${IM[@]}" "$canvas" -quality 92 "$out_dir/watchmen-color-collage-04.jpg"
}

build_05() {
  local canvas="$tmp_dir/build-05.png"
  make_bg radial "#582444" "#d2833b" "$canvas"

  make_filler_panel "$(src wallhaven-nev8o4_LE_upscale_gentle_x2.jpg)" 580x330 -10 "$tmp_dir/f1.png"
  make_filler_panel "$(src wallhaven-j81g2w_LE_upscale_gentle_x2.jpg)" 620x350 8 "$tmp_dir/f2.png"
  make_filler_panel "$(src watchmen-wallpaper-4960188d115a9d7bd61748cf70e1064d.jpg)" 600x340 -8 "$tmp_dir/f3.png"
  make_filler_panel "$(src wp7238480-watchmen-comic-wallpapers.jpg)" 580x330 10 "$tmp_dir/f4.png"
  make_filler_panel "$(src wallhaven-1jd56v_LE_upscale_gentle_x2.jpg)" 620x350 -9 "$tmp_dir/f5.png"
  make_panel "$(src wp7238442.jpg)" 1160x660 0 "$tmp_dir/p1.png"
  make_panel "$(src watchmen-wallpaper-4960188d115a9d7bd61748cf70e1064d.jpg)" 1080x620 -5 "$tmp_dir/p2.png"
  make_panel "$(src wp7238479-watchmen-comic-wallpapers.jpg)" 1020x600 4 "$tmp_dir/p3.png"
  make_panel "$(src wallhaven-nev8o4_LE_upscale_gentle_x2.jpg)" 920x540 -4 "$tmp_dir/p4.png"
  make_panel "$(src wp7238489-watchmen-comic-wallpapers.jpg)" 980x580 5 "$tmp_dir/p5.png"

  place_panels "$canvas" \
    "$tmp_dir/f1.png" 390 820 \
    "$tmp_dir/f2.png" 1260 900 \
    "$tmp_dir/f3.png" 2990 840 \
    "$tmp_dir/f4.png" 1830 1240 \
    "$tmp_dir/f5.png" 620 1250 \
    "$tmp_dir/p1.png" 160 1220 \
    "$tmp_dir/p2.png" 1380 220 \
    "$tmp_dir/p3.png" 2660 1210 \
    "$tmp_dir/p4.png" 270 250 \
    "$tmp_dir/p5.png" 2460 260

  "${IM[@]}" "$canvas" -quality 92 "$out_dir/watchmen-color-collage-05.jpg"
}

build_06() {
  local canvas="$tmp_dir/build-06.png"
  make_bg vertical "#ceb8b0" "#846b75" "$canvas"

  make_filler_panel "$(src wp7238492-watchmen-comic-wallpapers.jpg)" 580x330 -9 "$tmp_dir/f1.png"
  make_filler_panel "$(src wallhaven-nev8o4_LE_upscale_gentle_x2.jpg)" 620x350 8 "$tmp_dir/f2.png"
  make_filler_panel "$(src watchmen-wallpaper-4960188d115a9d7bd61748cf70e1064d.jpg)" 580x330 -10 "$tmp_dir/f3.png"
  make_filler_panel "$(src wp7238489-watchmen-comic-wallpapers.jpg)" 620x350 9 "$tmp_dir/f4.png"
  make_filler_panel "$(src wallhaven-x17rq3_LE_upscale_gentle_x2.jpg)" 600x340 -8 "$tmp_dir/f5.png"
  make_panel "$(src wallhaven-gjqyrq_LE_upscale_gentle_x2.jpg)" 1080x620 -4 "$tmp_dir/p1.png"
  make_panel "$(src wallhaven-8xkqz1_LE_upscale_gentle_x2.jpg)" 1020x610 5 "$tmp_dir/p2.png"
  make_panel "$(src wallhaven-1jd56v_LE_upscale_gentle_x2.jpg)" 1080x620 -3 "$tmp_dir/p3.png"
  make_panel "$(src wp7238480-watchmen-comic-wallpapers.jpg)" 980x560 4 "$tmp_dir/p4.png"
  make_panel "$(src wallhaven-j81g2w_LE_upscale_gentle_x2.jpg)" 1020x580 -5 "$tmp_dir/p5.png"

  place_panels "$canvas" \
    "$tmp_dir/f1.png" 420 820 \
    "$tmp_dir/f2.png" 1400 880 \
    "$tmp_dir/f3.png" 2920 840 \
    "$tmp_dir/f4.png" 1710 1230 \
    "$tmp_dir/f5.png" 690 1240 \
    "$tmp_dir/p1.png" 180 250 \
    "$tmp_dir/p2.png" 1470 230 \
    "$tmp_dir/p3.png" 2550 250 \
    "$tmp_dir/p4.png" 310 1320 \
    "$tmp_dir/p5.png" 2190 1280

  "${IM[@]}" "$canvas" -quality 92 "$out_dir/watchmen-color-collage-06.jpg"
}

build_01
build_02
build_03
build_04
build_05
build_06

printf 'Wrote %s\n' "$out_dir"/watchmen-color-collage-*.jpg
