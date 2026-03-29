# Menu, Skins & Worlds — Design Spec

Adds a death menu with skin selection and world selection to Mountain Hawk. All skins and worlds are unlocked from the start. Same physics across all worlds — purely visual theming.

## Game Over Menu

The current Game Over panel is replaced with an expanded menu. After the death animation settles (~1s), the menu appears with:

- **Score** and **Best Score** (as before)
- Three buttons stacked vertically:
  - **Retry** — restarts the game with current skin/world
  - **Skins** — opens skin selection screen
  - **Worlds** — opens world selection screen

Clicking Retry goes to title screen. Clicking Skins/Worlds replaces the canvas with that selection screen.

## Menu Screens

### Skins Screen

Full-canvas overlay drawn on the canvas (not HTML elements). Shows:

- Title: "Choose Skin"
- 2x3 grid of skin cards, each showing:
  - A small preview of the bird drawn with that skin's colors
  - The skin name below
  - Currently selected skin has a highlight border
- Click a card to select that skin (immediate visual feedback)
- **Back** button at bottom returns to Game Over menu

Selection is stored in a `currentSkin` variable and persisted to localStorage.

### Worlds Screen

Full-canvas overlay. Shows:

- Title: "Choose World"
- 2x2 grid of world cards, each showing:
  - A small preview rectangle with the world's sky gradient and ground color
  - The world name below
  - Currently selected world has a highlight border
- Click a card to select that world
- **Back** button at bottom returns to Game Over menu

Selection is stored in a `currentWorld` variable and persisted to localStorage.

## Game State Changes

New game states added:

- `STATE_SKINS` — skin selection screen
- `STATE_WORLDS` — world selection screen

State flow:
```
TITLE → PLAYING → GAMEOVER → RETRY (back to TITLE)
                            → SKINS → GAMEOVER
                            → WORLDS → GAMEOVER
```

## Skins

6 skins total. Each skin is a color palette object used by `drawHawk()`. The bird shape stays the same — only colors change.

### Skin Definitions

Each skin defines these color properties:
- `body` — main body fill
- `chest` — chest/breast area
- `belly` — belly patch
- `wing` — wing fill
- `wingStroke` — wing feather detail
- `head` — head (used for tail feathers too)
- `eyePatch` — white area around eye
- `eyeColor` — iris color
- `pupil` — pupil color
- `beak` — beak fill
- `beakTip` — beak hook
- `eyebrow` — eyebrow stripe
- `name` — display name

| Skin | Body | Chest | Belly | Wing | Eye | Beak | Special |
|------|------|-------|-------|------|-----|------|---------|
| Hawk | #6B3D1F | #8B5A2B | #D4A96A | #5C3A1E | #E8A000 | #E8901A | Default |
| Fire Bird | #CC2200 | #FF4400 | #FF8800 | #AA0000 | #FFFF00 | #FF6600 | Red/orange |
| Ice Bird | #88CCEE | #AADDFF | #DDEEFF | #66AACC | #FFFFFF | #99DDFF | Blue/white |
| Robo Bird | #777788 | #8888AA | #AAAACC | #555566 | #00FF00 | #999999 | Metallic/LED |
| Rainbow | Cycles HSL | Cycles HSL | Cycles HSL | Cycles HSL | #FF00FF | #FF8800 | Color shifts based on timestamp |
| Ghost Bird | rgba(200,200,220,0.6) | rgba(180,180,200,0.5) | rgba(220,220,240,0.4) | rgba(160,160,180,0.5) | #AACCFF | rgba(200,200,220,0.7) | Semi-transparent, all colors have alpha |

### Rainbow Skin Implementation

The Rainbow skin uses `hsl()` colors where the hue shifts based on `timestamp / 10 % 360`. Each body part offsets the hue by a fixed amount (body=0, chest=+40, belly=+80, wing=-30) creating a shifting rainbow effect.

### Ghost Skin Implementation

All colors use rgba with low alpha values (0.4-0.7). The eye has a brighter opacity to stand out. The overall effect is a see-through bird.

### drawHawk Changes

`drawHawk()` receives the skin palette and uses it for all color values instead of hardcoded colors. The existing color references become `skin.body`, `skin.chest`, etc.

For the Rainbow skin, colors are computed fresh each frame from the timestamp. The function accepts an optional `timestamp` parameter for this.

## Worlds

4 worlds total. Each world is a theme object that defines colors and shapes for all visual layers.

### World Theme Properties

Each world defines:
- `skyGradient` — array of `{stop, color}` for the sky
- `farMountain` — `{color, snowColor}` (snowColor can be null)
- `nearMountain` — `{color, snowColor}`
- `treeColor1`, `treeColor2` — alternating tree/obstacle colors
- `treeShape` — 'triangle' (pine), 'round' (deciduous), 'cactus', 'rock'
- `groundGradient` — `{top, bottom}` colors
- `pillarColor` — `{dark, light}` for the gradient
- `pillarCapColor` — snow cap color (or sand, dust, etc.)
- `particleColor` — snowflake/leaf/dust color
- `particleOpacityRange` — `{min, max}`
- `name` — display name

### World Definitions

#### Snowy Mountains (Default)
- Sky: blue (#5B86B8) → light gray (#D8DDE4)
- Far mountains: rgba(160,170,185,0.7), white snow caps
- Near mountains: rgba(120,130,145,0.85), white snow caps
- Trees: dark green pines (#1A3A0A, #2D5016)
- Ground: gray (#C8C8C8) → white (#FFFFFF)
- Pillars: gray (#5A5A5A/#7A7A7A), white snow caps
- Particles: white snowflakes

#### Forest
- Sky: light blue (#70B8E8) → soft white (#E8F0E8)
- Far mountains: rgba(80,140,80,0.5), no snow caps
- Near mountains: rgba(50,110,50,0.7), no snow caps
- Trees: round/deciduous shapes, bright greens (#1B7A1B, #2D9B2D)
- Ground: green (#4A8B3A) → light green (#7BC86C)
- Pillars: brown bark (#4A3520/#6B5035), green moss caps
- Particles: green/yellow leaves, drifting and slowly rotating

#### Desert
- Sky: hot orange (#E8A030) → pale yellow (#F0E0B0)
- Far mountains: rgba(180,140,90,0.5), no snow caps
- Near mountains: rgba(160,120,70,0.7), no snow caps
- Trees: cactus shapes (tall rectangles with arms), green (#2A6B2A, #3A8B3A)
- Ground: tan (#D4A960) → light sand (#E8D4A0)
- Pillars: sandstone (#8B7040/#A89060), sand-colored caps
- Particles: small tan dust specks, drifting horizontally

#### Moon
- Sky: deep black (#0A0A1A) → dark blue (#1A1A3A)
- Stars: random small white dots drawn in the sky (static, part of sky layer)
- Far mountains: rgba(60,60,70,0.7), no snow caps (crater-like shapes)
- Near mountains: rgba(80,80,90,0.8), no snow caps
- Trees: jagged rock formations (irregular triangles), gray (#555566, #666677)
- Ground: dark gray (#3A3A3A) → gray (#555555)
- Pillars: dark rock (#3A3A4A/#5A5A6A), gray dust caps
- Particles: tiny white/gray dust specks, floating slowly upward
- Special: Earth visible in sky (small blue-green circle at top-right, drawn once in sky layer)

### Drawing Function Changes

All drawing functions (`drawSky`, `drawMountainLayer`, `drawPineTrees`, `drawGround`, `drawPillar`, `drawSnowflakes`) read from the current world theme instead of hardcoded colors.

`drawPineTrees` becomes `drawWorldTrees` and checks `world.treeShape` to draw different shapes:
- `'triangle'` — current pine tree triangles
- `'round'` — circles on short trunks
- `'cactus'` — tall rectangles with 1-2 arm branches
- `'rock'` — irregular jagged shapes

Moon world adds a `drawStars()` call in `drawSky` and a `drawEarth()` call for the background Earth.

Snowflake update/draw uses `world.particleColor` and `world.particleOpacityRange`. Moon particles drift upward instead of downward.

## localStorage Persistence

- `mountainHawkSkin` — stores selected skin name (string)
- `mountainHawkWorld` — stores selected world name (string)
- `mountainHawkBest` — best score (already exists)

On load, read these values and set `currentSkin` and `currentWorld` accordingly. Default to 'hawk' and 'snow' if not set.

## Click Handling Changes

The canvas click handler needs to know what screen is showing and handle button/card clicks based on position. Each menu screen defines clickable regions as rectangles. On click, check which region was hit.

The existing `handleFlap()` function is updated:
- During `STATE_GAMEOVER`: check if click hits Retry/Skins/Worlds buttons
- During `STATE_SKINS`: check if click hits a skin card or Back button
- During `STATE_WORLDS`: check if click hits a world card or Back button
- During other states: existing behavior unchanged

## File Structure

Still a single `mountain-hawk/index.html` file. The world themes and skin palettes are defined as constant objects near the top of the script.
