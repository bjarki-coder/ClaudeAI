# Decisions

## 2026-03-28
- Decision: Use Claude Code project setup pattern from battle-tested guide.
- Why: Provides structured memory, hooks, and knowledge management from day one.
- Consequence: All project knowledge lives in docs/claude-memory/ (git-tracked), not auto-memory.

## 2026-03-29
- Decision: Plain HTML5 Canvas with zero dependencies for game development.
- Why: Father-and-son project — educational value of understanding every line. Also loads instantly, no build tools needed.

- Decision: Single index.html file for the entire game.
- Why: Simple to share, open, and deploy. No server needed.

- Decision: All audio procedurally generated via Web Audio API.
- Why: No external files to manage, instant loading, everything self-contained.

- Decision: All skins and worlds unlocked from the start.
- Why: Bjarki wanted fun and easy access, no progression gates.

- Decision: Same physics across all worlds (visual-only theming).
- Why: Keeps gameplay consistent and predictable.

- Decision: Ceiling doesn't kill (clamps hawk position instead).
- Why: Matches classic Flappy Bird behavior.

- Decision: Frame-based physics (not delta-time-based).
- Why: Simpler for a learning project. Game assumes 60fps. dt is only used for death effects, particles, and timers.

- Decision: Pillar caps removed (flat edges on pillars).
- Why: Bjarki's preference for cleaner look.

### Deep Feast Decisions

- Decision: Started as 2D Canvas, then rebuilt as full 3D with Three.js (CDN).
- Why: Bjarki requested progressively more immersive views — side view → behind-the-fish → full 3D.

- Decision: Three.js loaded from CDN (r128), still single HTML file.
- Why: Keeps the single-file simplicity while enabling real 3D.

- Decision: Enemies have short aggro ranges (120-180px), not long-range.
- Why: Bjarki wanted to explore safely and choose when to engage, not get rushed.

- Decision: Family is piranha-exclusive.
- Why: Bjarki's request — other fish (Bass, Whale, Megalodon, Mosasaurus) don't get family.

- Decision: Mosasaurus needs air every 2 minutes (surfaces to breathe).
- Why: Bjarki's idea for realistic behavior and surface encounter opportunities.

- Decision: Bite teeth are on the range outline/arc, not on the fish body.
- Why: Bjarki's preference — 5 big teeth on the bite indicator ring.

- Decision: Mouse look with pointer lock for camera control.
- Why: Bjarki wanted FPS-style free look in 3D.

- Decision: Player can jump out of water, sees beach/sun/sky above.
- Why: Bjarki's idea for a surface world with land visible.
