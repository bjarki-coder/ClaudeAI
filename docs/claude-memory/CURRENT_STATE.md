# Current State

## Two Games Built

---

## Game 1: Mountain Hawk
A realistic Flappy Bird clone — a hawk soaring through themed worlds.

**File:** `mountain-hawk/index.html` (~1400 lines)
**Tech:** HTML5 Canvas 2D, Web Audio API, vanilla JS, localStorage
**Status:** Complete and polished

### Features
- Core flappy bird mechanics with realistic hawk
- 5-layer parallax scrolling background
- 6 skins: Hawk, Fire Bird, Ice Bird, Robo Bird, Rainbow, Ghost
- 4 worlds: Snowy Mountains (with clouds), Forest, Desert, Moon (with sun, craters)
- Shrinking gap difficulty (130px → 70px)
- Procedural audio, death effects, mobile-friendly
- Game Over menu with Retry/Skins/Worlds

### Specs & Plans
- `docs/superpowers/specs/2026-03-29-mountain-hawk-design.md`
- `docs/superpowers/specs/2026-03-29-menu-skins-worlds-design.md`
- `docs/superpowers/plans/2026-03-29-mountain-hawk.md`
- `docs/superpowers/plans/2026-03-29-menu-skins-worlds.md`

---

## Game 2: Deep Feast
A 3D ocean survival game — eat fish, grow bigger, avoid bosses, buy new fish.

**File:** `deep-feast/index.html` (~2500+ lines)
**Tech:** Three.js (CDN r128), Web Audio API, vanilla JS, localStorage
**Status:** Complete with major features, actively being expanded

### Core Gameplay
- 3D underwater world (15000 x 1200) with Three.js rendering
- Mouse look (pointer lock) — FPS-style camera control
- WASD movement relative to look direction
- Sprint toggle (Shift), 13s stamina bar

### Bite & Combat
- Hold left click to bite — teeth appear on bite range outline (5 teeth, yellow when in range)
- 2-second charge for 1.5x damage
- Bite latch — attach to living fish, deal continuous damage, auto-release after 2s
- Fish-vs-fish AI combat — predators eat prey, drop stealable meat

### Entities & AI
- Clams, seashells (ocean floor food)
- Clownfish (schools, free food)
- Medium fish (flee or chase based on size comparison)
- Orcas (aggressive patrol, short aggro range ~120px)
- Whales (passive, suck attack)
- Megalodons (3→7 on map, aggro range ~150px, kill to unlock in shop)
- Mosasaurus (2→5 on map, aggro range ~180px, kill to unlock, NEEDS AIR every 2 min — surfaces to breathe)

### Meat System
- Killed fish drop meat pieces based on size
- Big meat can be chopped down by biting it
- Eating gives coins + auto-stat increases (bite force, health, size — gradual increments)

### Family System
- Piranha only: 4 brothers (1.6x faster), 1 dad (bigger), 1 mom (same size)
- Toggle with F key
- Other fish have no family

### Shop (5 fish)
- Piranha: free, 2 skins (normal + skeleton)
- Bass: 50 coins
- Whale: 150 coins (suck attack)
- Megalodon: 200 coins + must kill one
- Mosasaurus: 500 coins + must kill one
- Death keeps coins + unlocks, lose size/stats

### Surface World
- Can jump out of water — gravity pulls back down
- Above water: sky, bright sun with glow, beach with sand/vegetation/trees
- Splash particles when crossing water surface
- Mosasaurus surfaces every 2 minutes to breathe

### 3D Environment
- Procedural 3D fish meshes (piranha, clownfish, orca, whale, megalodon, mosasaurus)
- Coral reef on ocean floor (spheres, cylinders, cones in bright colors)
- Underwater fog, light rays, bubbles floating up
- Beach/land along one edge with trees
- Health bars on large enemies

### Audio
- Underwater ambient drone
- Bite crunch, coin chime, damage thud
- All procedural Web Audio API

### Specs & Plans
- `docs/superpowers/specs/2026-03-29-deep-feast-design.md`
- `docs/superpowers/plans/2026-03-29-deep-feast.md`

---

## GitHub Pages
Both games available at:
- `https://bjarki-coder.github.io/ClaudeAI/mountain-hawk/`
- `https://bjarki-coder.github.io/ClaudeAI/deep-feast/`

## Next likely tasks
- More Deep Feast features (new fish, biomes, abilities)
- New game ideas
- Shared game launcher page
