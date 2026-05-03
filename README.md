# Watchmen Omarchy Theme

An Omarchy theme built from ink-dark panels, paper-warm text, cold blue focus, and a restrained graphic-novel palette. It ships as a normal Omarchy theme directory: colors, shell styling, app overrides, and finished wallpapers are all kept at the repo root where Omarchy expects them.

## Preview

![Watchmen Omarchy theme preview](preview.png)

## Install

```bash
omarchy-theme-install https://github.com/OldJobobo/omarchy-watchmen-theme
```

Then select `watchmen` from the Omarchy theme picker, or run:

```bash
omarchy-theme-set watchmen
```

## What's Included

- Omarchy theme colors in `colors.css` and `colors.toml`
- Hyprland, Hyprlock, Waybar, Walker, Mako, SwayOSD, and GTK styling
- Terminal themes for Foot, Ghostty, Kitty, Alacritty, and Warp
- App themes for btop, Chromium, Vencord, Zed, Neovim, and cliamp
- A 17-wallpaper set in `backgrounds/`
- Palette references in `palette/`

## Wallpapers

All shipped wallpapers are 4K except `show-4-rorschach-radial.jpg`, which is 3440x1440.

<table>
  <tr>
    <td><img src="backgrounds/1-radial-triptuch.jpg" alt="Radial triptuch wallpaper"></td>
    <td><img src="backgrounds/2-pyramid.jpg" alt="Pyramid wallpaper"></td>
    <td><img src="backgrounds/3-vertical-left-col.jpg" alt="Vertical left column wallpaper"></td>
  </tr>
  <tr>
    <td><img src="backgrounds/4-radial-pyramid.jpg" alt="Radial pyramid wallpaper"></td>
    <td><img src="backgrounds/5-radial-bottom-strip.jpg" alt="Radial bottom strip wallpaper"></td>
    <td><img src="backgrounds/6-rorschach.jpg" alt="Rorschach wallpaper"></td>
  </tr>
</table>

## Notes

This repository is intended to be the release theme only. Wallpaper-generation scripts, scene YAMLs, source images, probe renders, and other build-workspace files belong in the separate generator project, not in the published theme.

Keep final wallpapers in `backgrounds/`. Keep temporary renders in `/tmp` or another ignored workspace.
