# Watchmen Design Language

## Core Idea

Watchmen is a graphic-novel noir theme.

Its identity comes from the tension between:

- ink-dark structure
- faded paper warmth
- bruised violet and mauve support tones
- one electric blue highlight cutting through the scene
- restrained warning colors that feel printed, not neon

This is not a superhero neon theme.
It is not a pure cyberpunk theme.
It is not a sepia retro theme either.

The theme should feel like a serious comic page under cold city light: damaged, editorial, high-contrast, and composed.

## Emotional Target

The theme should evoke:

- rain on concrete
- halftone print and aged paper
- city-night tension
- archival color reproduction
- a quiet sense of threat
- blue light as focus, not comfort

It should feel:

- graphic
- moody
- deliberate
- slightly bruised
- urban
- cool-headed
- tense rather than frantic
- cinematic without glow spam

It should not feel:

- cheerful
- glossy-futurist
- candy-colored
- pastel
- cozy
- medieval
- synthwave
- gamer-RGB
- sleek-corporate

## Visual Thesis

The desktop should feel like Watchmen translated into interface materials, not like a wallpaper pack with matching colors.

That means:

- the dark base should read like ink, shadow, and wet pavement
- the foreground should read like aged paper, skin tone, and printed highlight
- blue should act like a precise beam of focus
- red and orange should feel like blood, rust, warning ink, and urban signage
- mauve and violet should support mood and depth without replacing blue as the lead accent
- blur should exist, but the shell should still feel edged and graphic

The theme works when the UI feels printed, framed, and slightly hostile.

## Palette Roles

## Palette Source Of Truth

The first source of truth for any color choice in this theme should be [watchmen64.yaml](/home/oldjobobo/Projects/themes/omarchy-watchmen-theme/palette/watchmen64.yaml).

That file is the canonical Higgins 64 palette reference used for the Watchmen graphic novel, and this theme should treat it as the authoritative color library rather than inventing near-match colors ad hoc.

Practical rule:

- if a color already exists in `watchmen64.yaml`, prefer using that exact value
- if a UI role needs adaptation, derive it from the nearest Higgins palette value first
- only introduce a non-palette color when there is a strong implementation reason and the nearest Higgins value clearly fails

In other words, `colors.css` is the canonical UI mapping for the theme, but the underlying color provenance should try to resolve back to `palette/watchmen64.yaml` whenever possible.

### Core Neutrals

- `background`: `#2c2d37`
- `foreground`: `#ceb8b0`
- `muted border / inactive structure`: `#55595d`
- `bright foreground`: `#dfc0b0`

These colors should carry most of the interface.
If the accents start dominating large surfaces, the theme loses its editorial restraint.

### Primary Accent System

- primary focus blue: `#2488cb`
- support violet: `#9287b0`
- support mauve: `#ad93b7`
- support cyan: `#238e9e`

Semantic intent:

- blue carries selection, active borders, hover focus, and hero moments
- violet and mauve carry depth, gradients, and supporting syntax roles
- cyan is secondary information, not the main face of the theme

### Warning and Heat

- danger red: `#c13e46`
- warning amber: `#b89030`
- bright warning: `#d2833b`
- soft danger highlight: `#d8979a`

These should feel printed and weathered, not laser-bright.

### Excluded Tendencies

- yellow should not become the main accent just because Watchmen iconography can suggest it
- cyan should not displace blue as the primary focus signal
- violet should not turn the theme into fantasy or vaporwave
- red should feel fatal or urgent, not decorative
- cream should not become warm enough to make the theme cozy

## Wallpaper World

The wallpaper set should feel like one damaged urban universe.

Preferred characteristics:

- comic or graphic-novel imagery
- noir city atmosphere
- halftone, print, collage, grain, smoke, rain, or concrete texture
- Dr. Manhattan blue as an occasional high-energy light source
- restrained pinks, mauves, and reds as support mood

Allowed range:

- a few more surreal or cosmic compositions
- a few images with stronger magenta or electric blue energy

Not preferred:

- bright heroic action-poster energy
- glossy modern comic rendering
- clean minimalist abstraction
- warm nostalgic sepia
- playful pop-art

The wallpapers can be dramatic.
The shell should simplify and discipline that drama.

### Wallpaper Finishing Direction

The final wallpaper set should be slightly more disciplined than the raw source art.

That means:

- blacks should be a little lifted and compressed, not crushed
- highlights should be slightly restrained
- saturation should stay a touch muted
- the whole set should lean gently toward the theme's ink, mauve, and cold-blue world

The goal is not to make every image obviously filtered.
The goal is to make them feel like one printed universe and give black shell shadows cleaner separation against the artwork.

## Shell Language

The shell should feel like printed panels and heavy framing laid over dark glass.

### Shape

- sharp corners
- rectangular silhouettes
- no soft bubbly forms
- no pill-heavy component language

### Contrast

- medium-high contrast
- strong edge definition
- quiet fills with visible borders
- no washed-out gray soup

### Texture

- dark and dense
- slight translucency where useful
- restrained blur
- heavy black shadows
- surfaces should feel closer to lacquered print and concrete than to soft glass

### Accent Use

- blue is for focus
- red and amber are for semantic heat
- violet is for support and tonal richness
- most of the shell should stay dark, neutral, and controlled

## Surface-by-Surface Intent

### Hyprland

- thick active border with blue-to-violet movement
- muted inactive border
- zero rounding
- hard shadow language
- blur present, but not dreamy

### GTK / App Chrome

- dark page body
- paper-toned text
- blue interaction color
- support tones kept secondary
- avoid accidental teal-first or purple-first application chrome

### Launcher

- should feel like a printed frame dropped onto the wallpaper
- strong rectangular silhouette
- dark body with a blue-violet border treatment
- selection should be crisp and obvious

### Notifications and OSD

- same dark body as the shell
- blue frame for priority
- minimal ornament
- no soft or cute styling

### Waybar

- should read as a quiet structural strip, not a colorful centerpiece
- dark enough to disappear into the shell
- foreground and spacing should stay readable and disciplined

## Theme Personality

If Watchmen were described as materials, it would be:

- ink
- aged paper
- wet asphalt
- oxidized metal
- emergency paint
- electric blue light

If it were described as a place, it would be:

- a city at night after rain
- a paper archive under fluorescent light
- a comic panel lit by one impossible blue source

That is the feeling the UI should preserve.

## Design Guardrails

Before approving a wallpaper, palette tweak, or CSS change, ask:

- Does this make the theme feel more editorial and graphic?
- Is blue still the clear focus accent?
- Does this feel printed and urban, or merely colorful?
- Is this adding tension, or just adding saturation?
- Does this preserve the ink-paper-concrete relationship?
- Is the shell staying disciplined against the wallpaper drama?
- Would this still feel like Watchmen without relying on literal character imagery?

If the answer is no, the change is probably off-direction.

## One-Sentence Test

If a surface looks like ink-dark structure cut by cold blue focus and paper-warm text, it belongs to Watchmen.
