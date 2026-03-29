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
