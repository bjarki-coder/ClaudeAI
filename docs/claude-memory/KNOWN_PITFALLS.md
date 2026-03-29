# Known Pitfalls

- ~~Physics is frame-based~~ FIXED: Now uses fixed timestep accumulator (1/60s steps). Consistent on all refresh rates.
- `roundRect` API requires Chrome 99+, Firefox 112+, Safari 16+. Older browsers will crash on Game Over.
- Rainbow skin computes HSL colors every frame from timestamp — works fine but is the most expensive skin to render.
- When switching worlds, must call `initParticles()` to reset particle directions (Moon particles go up, others down).
