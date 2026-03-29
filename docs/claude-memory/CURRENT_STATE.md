# Current State

## Project: Mountain Hawk
A realistic Flappy Bird clone — a hawk soaring through themed worlds. Built as a single HTML file (`mountain-hawk/index.html`) with zero dependencies.

## Tech Stack
- HTML5 Canvas 2D (600x600 square, CSS-scaled to 90vh)
- Web Audio API (all sounds procedural, no external files)
- Vanilla JavaScript
- localStorage for persistence

## What's Built
- **Core game**: Gravity, flap physics, rotation, collision detection
- **Parallax background**: 5-layer scrolling (sky, far mountains, near mountains, trees, ground)
- **Hawk**: Round Flappy-Bird-style body with realistic hawk details (hooked beak, eyebrow stripe, tail feathers)
- **Obstacles**: Rock pillars with shrinking gap (starts 130px, -1.5px per score, min 70px)
- **Particles**: Ambient particles per world (snow/leaves/dust/moon dust)
- **Death effects**: Feather burst, screen flash, hawk tumble
- **Audio**: Wind loop, flap whoosh, score chime, hawk cry (random 8-15s), collision thud
- **Scroll speed**: 3px per frame

## Menu System
- **Game Over menu**: 3 buttons — Retry, Skins, Worlds
- **6 Skins** (all unlocked): Hawk, Fire Bird, Ice Bird, Robo Bird, Rainbow (color-shifting), Ghost (transparent)
- **4 Worlds** (all unlocked): Snowy Mountains, Forest, Desert, Moon
- Selections persisted to localStorage

## World Details
- **Snowy Mountains**: Blue sky, snow-capped mountains, pine trees, white ground, snowflakes
- **Forest**: Blue-green sky, green hills, round trees, grass ground, leaf particles
- **Desert**: Orange sky, sand dunes, cacti, sandy ground, dust particles
- **Moon**: Black starry sky, sun (top-left with glow), Earth (top-right), no mountains, craters in ground, upward-floating dust

## Architecture
Single file `mountain-hawk/index.html` (~1300 lines). Organized into sections:
CONSTANTS → SKINS → WORLDS → CANVAS SETUP → GAME STATE → AUDIO → INPUT → PHYSICS → DRAWING FUNCTIONS → GAME LOOP

## Pillar caps removed (flat edges)

## Specs & Plans
- `docs/superpowers/specs/2026-03-29-mountain-hawk-design.md` — original game spec
- `docs/superpowers/specs/2026-03-29-menu-skins-worlds-design.md` — menu/skins/worlds spec
- `docs/superpowers/plans/2026-03-29-mountain-hawk.md` — original 10-task build plan
- `docs/superpowers/plans/2026-03-29-menu-skins-worlds.md` — 6-task menu plan

## Next likely tasks
- More skins or worlds
- Power-ups or collectibles
- More game modes
- Another 2D browser game
