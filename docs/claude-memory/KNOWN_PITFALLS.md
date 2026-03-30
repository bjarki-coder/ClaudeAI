# Known Pitfalls

## Mountain Hawk
- ~~Physics is frame-based~~ FIXED: Now uses fixed timestep accumulator (1/60s steps). Consistent on all refresh rates.
- `roundRect` API requires Chrome 99+, Firefox 112+, Safari 16+. Older browsers will crash on Game Over.
- Rainbow skin computes HSL colors every frame from timestamp — works fine but is the most expensive skin to render.
- When switching worlds, must call `initParticles()` to reset particle directions (Moon particles go up, others down).

## Deep Feast
- Three.js loaded from CDN — requires internet connection to play. No offline mode.
- Deep Feast file is large (~2500+ lines). Future features should be careful about complexity.
- Pointer lock requires user gesture (click) to activate — can't auto-lock.
- Mosasaurus air timer resets on respawn — if killed near surface it respawns with full air.
- Entity count is high on the larger map (~200+ entities). Performance may drop on low-end devices.
- Above-water gravity is simple — no proper physics for jumping out of water, just downward pull.
