# Mountain Hawk — Game Design Spec

A realistic Flappy Bird clone featuring a hawk soaring through snowy mountain passes. Built with plain HTML5 Canvas and Web Audio API — zero dependencies.

## Core Concept

The player controls a hawk flying through narrow gaps between snow-capped rock pillars in a snowy mountain environment. Classic Flappy Bird difficulty with immersive realistic visuals and nature audio.

## Tech Stack

- **Rendering:** HTML5 Canvas 2D context
- **Audio:** Web Audio API (all sounds procedurally generated, no external files)
- **Storage:** localStorage for best score persistence
- **Build:** Single HTML file with embedded JS and CSS — no build tools, no dependencies
- **Browser support:** Modern browsers (Chrome, Firefox, Edge, Safari)

## Game States

### 1. Title Screen
- Game title "Mountain Hawk" displayed
- Hawk gently bobbing up and down in center
- "Click to Start" prompt below hawk
- Background scrolling slowly with snowfall
- Ambient wind audio playing

### 2. Playing
- Hawk flies, obstacles scroll left at constant speed
- Score increments by 1 for each pillar passed
- Current score displayed top-center with drop shadow
- Full audio: wind, flaps, score chimes, occasional hawk cry

### 3. Game Over
- Hawk tumbles/spirals downward on collision
- Brief white screen flash
- Feather particle burst at collision point
- Score panel shows: final score and best score
- "Click to Retry" prompt
- Best score saved to localStorage

## Physics & Controls

### Input
- **Mouse click** — triggers flap
- **Spacebar** — triggers flap
- **Touch/tap** — triggers flap (mobile support)

### Flight Physics
- Constant downward gravity applied each frame
- Flap applies an instant upward velocity (overrides current vertical velocity)
- Hawk rotation tied to vertical velocity:
  - Positive velocity (falling) → hawk tilts nose-down (max ~45°)
  - Negative velocity (rising after flap) → hawk tilts nose-up (max ~-30°)
  - Rotation smoothly interpolates between states

### Collision
- Bounding box collision detection (hawk hitbox vs rock pillars, ground, and ceiling)
- Collision = instant death → Game Over state
- Hitbox slightly smaller than visual hawk for fairness

## Scoring & Difficulty

- **+1 point** each time the hawk's x-position passes a pillar pair's trailing edge
- **Gap size:** Fixed, tuned to classic Flappy Bird difficulty (~130px on a 600px canvas)
- **Scroll speed:** Constant throughout the game (~3px per frame at 60fps)
- **Pillar spacing:** Fixed horizontal distance between pillar pairs
- **Best score:** Persisted in localStorage, shown on Game Over screen

## Visual Design

### Canvas Size
- 400px wide × 600px tall (portrait orientation, like original Flappy Bird)
- Centered on page with a subtle background behind the canvas

### Parallax Background (5 layers, back to front)

| Layer | Content | Scroll Speed | Description |
|-------|---------|-------------|-------------|
| 1 | Sky | Static | Vertical gradient: blue at top → light gray/white at bottom |
| 2 | Far mountains | 0.2x | Distant mountain silhouettes with snow-capped peaks, muted colors |
| 3 | Near mountains | 0.5x | Closer mountain range, darker, more defined snow caps |
| 4 | Pine trees | 0.8x | Small pine tree silhouettes on slopes |
| 5 | Ground | 1.0x | Snowy ground strip at canvas bottom |

Each layer tiles horizontally and loops seamlessly.

### Hawk Sprite (drawn procedurally on canvas)
- Brown body ellipse with darker brown head
- Golden beak and yellow eye with black pupil
- 3 wing animation frames based on state:
  - **Wings up:** Triggered on flap, held briefly
  - **Wings level:** Gliding state
  - **Wings down:** Falling state
- Smooth rotation based on vertical velocity

### Obstacles (Rock Pillars)
- Vertical rock pillars extending from top and bottom of screen
- Gap between top and bottom pillar for the hawk to fly through
- Rock texture: gray gradient with slight irregularity
- Snow caps on top of bottom pillars and bottom of top pillars
- Pillar width: ~60px
- Slight shadow for depth

### Particle Effects

**Snowfall (always active):**
- White circular particles, varying sizes (1-3px radius)
- Drift diagonally (slight horizontal + downward movement)
- Random spawn across top of screen
- Varying opacity (0.3-0.8) for depth
- ~30-50 particles on screen at a time

**Death feathers (on collision):**
- Burst of 8-12 small brown/white particles from collision point
- Particles spread outward with gravity, fade out over ~1 second

**Screen flash (on collision):**
- Canvas briefly flashes white (opacity 0.5 → 0, over ~200ms)

## Audio Design

All audio is procedurally generated using the Web Audio API — no external audio files required.

### Ambient Wind (continuous loop)
- Low-frequency filtered white noise
- Subtle volume oscillation for natural feel
- Plays on all game states (quieter on title/game over)

### Wing Flap (on each input)
- Short (~100ms) noise burst with bandpass filter
- Quick attack, fast decay
- Gives a soft "whoosh" effect

### Score Chime (on passing a pillar)
- Short sine wave tone (~800Hz)
- Quick envelope (50ms attack, 200ms decay)
- Pleasant, non-intrusive ding

### Hawk Cry (random, ambient)
- Plays at random intervals (every 8-15 seconds)
- Frequency sweep (high to low) with slight vibrato
- Low volume, distant feel
- Only during Playing state

### Collision Impact (on death)
- Short burst of low-frequency noise (~80ms)
- Gives a dull thud sound

## File Structure

```
mountain-hawk/
├── index.html          # Single file containing everything
└── README.md           # How to play, controls
```

The entire game lives in a single `index.html` file. All rendering, physics, audio, and game logic are embedded. Open in any browser to play — no server needed.

## Controls Summary

| Input | Action |
|-------|--------|
| Click | Flap |
| Spacebar | Flap |
| Tap (mobile) | Flap |

## Performance Targets

- 60 FPS on modern browsers
- requestAnimationFrame for the game loop
- No external asset loading — instant start
