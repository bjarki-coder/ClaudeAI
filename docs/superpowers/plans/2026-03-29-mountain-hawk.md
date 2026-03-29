# Mountain Hawk Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a realistic Flappy Bird clone — a hawk soaring through snowy mountain passes — as a single HTML file with zero dependencies.

**Architecture:** Single `index.html` file containing all HTML, CSS, and JavaScript. The game uses HTML5 Canvas for rendering, Web Audio API for procedural sound generation, and localStorage for score persistence. The game loop runs via `requestAnimationFrame` at 60fps.

**Tech Stack:** HTML5 Canvas 2D, Web Audio API, vanilla JavaScript, localStorage

**Spec:** `docs/superpowers/specs/2026-03-29-mountain-hawk-design.md`

---

## File Structure

```
mountain-hawk/
└── index.html    # Single file: HTML + CSS + JS (all game code)
```

Everything lives in one file. The JavaScript is organized into clearly separated sections via comments: constants, state, drawing functions, physics, audio, game loop.

---

### Task 1: HTML Scaffold + Game Loop

**Files:**
- Create: `mountain-hawk/index.html`

**Context:** Set up the HTML page with a centered canvas and a working `requestAnimationFrame` game loop. This is the skeleton everything else builds on.

- [ ] **Step 1: Create the HTML file with canvas and basic CSS**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mountain Hawk</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background: #1a1a2e;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    overflow: hidden;
  }
  canvas {
    border-radius: 4px;
    box-shadow: 0 0 40px rgba(0,0,0,0.5);
  }
</style>
</head>
<body>
<canvas id="game" width="400" height="600"></canvas>
<script>
// ============================================================
// CONSTANTS
// ============================================================
const CANVAS_W = 400;
const CANVAS_H = 600;

// ============================================================
// CANVAS SETUP
// ============================================================
const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');

// ============================================================
// GAME STATE
// ============================================================
let lastTime = 0;

// ============================================================
// GAME LOOP
// ============================================================
function gameLoop(timestamp) {
  const dt = (timestamp - lastTime) / 1000; // delta in seconds
  lastTime = timestamp;

  // Clear
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);

  // Temp: draw a blue sky to prove it works
  ctx.fillStyle = '#87CEEB';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  requestAnimationFrame(gameLoop);
}

requestAnimationFrame((t) => { lastTime = t; gameLoop(t); });
</script>
</body>
</html>
```

- [ ] **Step 2: Verify in browser**

Open `mountain-hawk/index.html` in a browser. You should see a blue rectangle (400x600) centered on a dark background.

- [ ] **Step 3: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: scaffold HTML canvas and game loop"
```

---

### Task 2: Sky Gradient + Parallax Background Layers

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Draw the 5-layer parallax background. Each layer is a repeating pattern drawn at a different scroll speed. The layers from back to front: sky gradient (static), far mountains (0.2x), near mountains (0.5x), pine trees (0.8x), snowy ground (1.0x). Each layer tiles horizontally and wraps seamlessly.

- [ ] **Step 1: Add background constants and scroll state**

Add to the CONSTANTS section:

```javascript
const SCROLL_SPEED = 2; // pixels per frame at 60fps
const GROUND_H = 60;
```

Add to the GAME STATE section:

```javascript
let scrollX = 0; // master scroll position
```

- [ ] **Step 2: Add the sky gradient drawing function**

Add a DRAWING FUNCTIONS section after GAME STATE:

```javascript
// ============================================================
// DRAWING FUNCTIONS
// ============================================================
function drawSky() {
  const grad = ctx.createLinearGradient(0, 0, 0, CANVAS_H);
  grad.addColorStop(0, '#5B86B8');
  grad.addColorStop(0.4, '#8BACC8');
  grad.addColorStop(0.7, '#B8C8D8');
  grad.addColorStop(1, '#D8DDE4');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
}
```

- [ ] **Step 3: Add the mountain layer drawing function**

This function draws a procedural mountain range that tiles seamlessly. It takes parameters to vary each layer.

```javascript
function drawMountainLayer(scrollFactor, baseY, height, peakCount, color, snowColor) {
  const offset = (scrollX * scrollFactor) % CANVAS_W;
  ctx.save();

  for (let copy = -1; copy <= 1; copy++) {
    const shiftX = copy * CANVAS_W - offset;
    ctx.beginPath();
    ctx.moveTo(shiftX, CANVAS_H);

    for (let i = 0; i <= peakCount; i++) {
      const x = shiftX + (i / peakCount) * CANVAS_W;
      const peakY = baseY - Math.sin(i * 2.7 + peakCount) * height * 0.6 - height * 0.3;
      if (i === 0) {
        ctx.lineTo(x, peakY);
      } else {
        const prevX = shiftX + ((i - 1) / peakCount) * CANVAS_W;
        const cpX = (prevX + x) / 2;
        ctx.quadraticCurveTo(cpX, peakY - height * 0.2, x, peakY);
      }
    }

    ctx.lineTo(shiftX + CANVAS_W, CANVAS_H);
    ctx.closePath();
    ctx.fillStyle = color;
    ctx.fill();

    // Snow caps
    if (snowColor) {
      for (let i = 0; i <= peakCount; i++) {
        const x = shiftX + (i / peakCount) * CANVAS_W;
        const peakY = baseY - Math.sin(i * 2.7 + peakCount) * height * 0.6 - height * 0.3;
        ctx.beginPath();
        ctx.moveTo(x - 12, peakY + 10);
        ctx.lineTo(x, peakY);
        ctx.lineTo(x + 12, peakY + 10);
        ctx.closePath();
        ctx.fillStyle = snowColor;
        ctx.fill();
      }
    }
  }

  ctx.restore();
}
```

- [ ] **Step 4: Add pine trees drawing function**

```javascript
function drawPineTrees(scrollFactor) {
  const offset = (scrollX * scrollFactor) % CANVAS_W;
  const treeBaseY = CANVAS_H - GROUND_H;

  for (let copy = -1; copy <= 1; copy++) {
    const shiftX = copy * CANVAS_W - offset;
    for (let i = 0; i < 12; i++) {
      const x = shiftX + (i / 12) * CANVAS_W + 20;
      const h = 25 + Math.sin(i * 3.1) * 15;
      ctx.beginPath();
      ctx.moveTo(x - 6, treeBaseY);
      ctx.lineTo(x, treeBaseY - h);
      ctx.lineTo(x + 6, treeBaseY);
      ctx.closePath();
      ctx.fillStyle = i % 2 === 0 ? '#1A3A0A' : '#2D5016';
      ctx.fill();
    }
  }
}
```

- [ ] **Step 5: Add ground drawing function**

```javascript
function drawGround() {
  const grad = ctx.createLinearGradient(0, CANVAS_H - GROUND_H, 0, CANVAS_H);
  grad.addColorStop(0, '#C8C8C8');
  grad.addColorStop(1, '#FFFFFF');
  ctx.fillStyle = grad;
  ctx.fillRect(0, CANVAS_H - GROUND_H, CANVAS_W, GROUND_H);
}
```

- [ ] **Step 6: Add drawBackground function that composes all layers**

```javascript
function drawBackground() {
  drawSky();
  drawMountainLayer(0.2, CANVAS_H - 100, 140, 8, 'rgba(160,170,185,0.7)', 'rgba(255,255,255,0.6)');
  drawMountainLayer(0.5, CANVAS_H - 70, 120, 10, 'rgba(120,130,145,0.85)', 'rgba(255,255,255,0.8)');
  drawPineTrees(0.8);
  drawGround();
}
```

- [ ] **Step 7: Update game loop to use background and advance scroll**

Replace the game loop body (the clear + temp blue sky) with:

```javascript
function gameLoop(timestamp) {
  const dt = (timestamp - lastTime) / 1000;
  lastTime = timestamp;

  // Advance scroll
  scrollX += SCROLL_SPEED;

  // Draw
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);
  drawBackground();

  requestAnimationFrame(gameLoop);
}
```

- [ ] **Step 8: Verify in browser**

Open in browser. You should see layered snowy mountains scrolling at different speeds with pine trees in front and a snowy ground strip. The parallax depth effect should be clearly visible.

- [ ] **Step 9: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add 5-layer parallax mountain background"
```

---

### Task 3: Hawk Rendering + Wing Animation

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Draw the hawk procedurally on canvas with 3 wing animation frames (up/level/down). The hawk is drawn at a fixed X position — the world scrolls past it. The wing state will later be driven by physics; for now we cycle through frames for testing.

- [ ] **Step 1: Add hawk constants and state**

Add to CONSTANTS:

```javascript
const HAWK_X = 80; // fixed horizontal position
const HAWK_W = 50;
const HAWK_H = 30;
```

Add to GAME STATE:

```javascript
let hawkY = CANVAS_H / 2;
let hawkVel = 0;
let hawkRotation = 0;
let wingState = 0; // 0=up, 1=level, 2=down
let wingTimer = 0;
```

- [ ] **Step 2: Add the drawHawk function**

```javascript
function drawHawk(x, y, rotation, wing) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(rotation);

  // Body
  ctx.beginPath();
  ctx.ellipse(0, 0, 18, 8, 0, 0, Math.PI * 2);
  ctx.fillStyle = '#5C3A1E';
  ctx.fill();

  // Wings based on state
  ctx.fillStyle = '#7A4E2A';
  ctx.beginPath();
  if (wing === 0) {
    // Wings up
    ctx.moveTo(-8, -3);
    ctx.quadraticCurveTo(-18, -18, -24, -14);
    ctx.quadraticCurveTo(-16, -6, -8, -3);
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(8, -3);
    ctx.quadraticCurveTo(18, -18, 24, -14);
    ctx.quadraticCurveTo(16, -6, 8, -3);
  } else if (wing === 1) {
    // Wings level
    ctx.moveTo(-8, 0);
    ctx.quadraticCurveTo(-18, -4, -26, -1);
    ctx.quadraticCurveTo(-18, 2, -8, 0);
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(8, 0);
    ctx.quadraticCurveTo(18, -4, 26, -1);
    ctx.quadraticCurveTo(18, 2, 8, 0);
  } else {
    // Wings down
    ctx.moveTo(-8, 3);
    ctx.quadraticCurveTo(-18, 14, -22, 16);
    ctx.quadraticCurveTo(-16, 8, -8, 3);
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(8, 3);
    ctx.quadraticCurveTo(18, 14, 22, 16);
    ctx.quadraticCurveTo(16, 8, 8, 3);
  }
  ctx.fill();

  // Head
  ctx.beginPath();
  ctx.ellipse(14, -2, 7, 6, 0, 0, Math.PI * 2);
  ctx.fillStyle = '#4A2E14';
  ctx.fill();

  // Beak
  ctx.beginPath();
  ctx.moveTo(20, -3);
  ctx.lineTo(27, -1);
  ctx.lineTo(20, 1);
  ctx.closePath();
  ctx.fillStyle = '#DAA520';
  ctx.fill();

  // Eye
  ctx.beginPath();
  ctx.arc(16, -4, 1.8, 0, Math.PI * 2);
  ctx.fillStyle = '#FFD700';
  ctx.fill();
  ctx.beginPath();
  ctx.arc(16, -4, 0.8, 0, Math.PI * 2);
  ctx.fillStyle = 'black';
  ctx.fill();

  ctx.restore();
}
```

- [ ] **Step 3: Draw the hawk in the game loop**

Add after `drawBackground()` in the game loop:

```javascript
  // Animate wings for testing (will be driven by physics later)
  wingTimer += dt;
  if (wingTimer > 0.15) {
    wingTimer = 0;
    wingState = (wingState + 1) % 3;
  }

  drawHawk(HAWK_X, hawkY, hawkRotation, wingState);
```

- [ ] **Step 4: Verify in browser**

Open in browser. You should see the hawk in the center-left of the screen with its wings cycling through up/level/down animation frames against the scrolling mountain background.

- [ ] **Step 5: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add hawk with 3-frame wing animation"
```

---

### Task 4: Physics, Controls + Hawk Flight

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Add gravity, flap mechanics, and rotation. The hawk falls under gravity, flapping gives an instant upward velocity boost. Rotation smoothly follows vertical velocity. Inputs: click, spacebar, tap.

- [ ] **Step 1: Add physics constants**

Add to CONSTANTS:

```javascript
const GRAVITY = 0.5;      // pixels per frame downward acceleration
const FLAP_STRENGTH = -8;  // instant upward velocity on flap
const MAX_FALL_SPEED = 10;
const MAX_ROTATION = Math.PI / 4;      // 45 degrees nose down
const MIN_ROTATION = -Math.PI / 6;     // 30 degrees nose up
```

- [ ] **Step 2: Add game state enum and flap tracking**

Add to GAME STATE:

```javascript
const STATE_TITLE = 0;
const STATE_PLAYING = 1;
const STATE_GAMEOVER = 2;
let gameState = STATE_TITLE;
let flapHoldTimer = 0; // time since last flap (for wing animation)
```

- [ ] **Step 3: Add input handlers**

Add an INPUT section after GAME STATE:

```javascript
// ============================================================
// INPUT
// ============================================================
function handleFlap() {
  if (gameState === STATE_TITLE) {
    gameState = STATE_PLAYING;
    hawkY = CANVAS_H / 2;
    hawkVel = 0;
  }

  if (gameState === STATE_PLAYING) {
    hawkVel = FLAP_STRENGTH;
    flapHoldTimer = 0;
  }

  if (gameState === STATE_GAMEOVER) {
    resetGame();
  }
}

function resetGame() {
  hawkY = CANVAS_H / 2;
  hawkVel = 0;
  hawkRotation = 0;
  scrollX = 0;
  gameState = STATE_TITLE;
}

canvas.addEventListener('mousedown', (e) => { e.preventDefault(); handleFlap(); });
canvas.addEventListener('touchstart', (e) => { e.preventDefault(); handleFlap(); });
document.addEventListener('keydown', (e) => {
  if (e.code === 'Space') { e.preventDefault(); handleFlap(); }
});
```

- [ ] **Step 4: Add physics update function**

Add a PHYSICS section:

```javascript
// ============================================================
// PHYSICS
// ============================================================
function updatePhysics() {
  if (gameState !== STATE_PLAYING) return;

  // Gravity
  hawkVel += GRAVITY;
  if (hawkVel > MAX_FALL_SPEED) hawkVel = MAX_FALL_SPEED;
  hawkY += hawkVel;

  // Rotation follows velocity
  const targetRotation = (hawkVel / MAX_FALL_SPEED) * MAX_ROTATION;
  hawkRotation += (targetRotation - hawkRotation) * 0.15;
  hawkRotation = Math.max(MIN_ROTATION, Math.min(MAX_ROTATION, hawkRotation));

  // Wing animation driven by physics
  flapHoldTimer += 1 / 60;
  if (flapHoldTimer < 0.1) {
    wingState = 0; // wings up right after flap
  } else if (hawkVel < 0) {
    wingState = 1; // level while rising
  } else {
    wingState = 2; // down while falling
  }

  // Ground collision
  if (hawkY > CANVAS_H - GROUND_H - HAWK_H / 2) {
    hawkY = CANVAS_H - GROUND_H - HAWK_H / 2;
    gameState = STATE_GAMEOVER;
  }

  // Ceiling collision
  if (hawkY < HAWK_H / 2) {
    hawkY = HAWK_H / 2;
    hawkVel = 0;
  }
}
```

- [ ] **Step 5: Update game loop**

Replace the game loop with:

```javascript
function gameLoop(timestamp) {
  const dt = (timestamp - lastTime) / 1000;
  lastTime = timestamp;

  // Update
  if (gameState === STATE_PLAYING) {
    scrollX += SCROLL_SPEED;
  }
  updatePhysics();

  // Draw
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);
  drawBackground();
  drawHawk(HAWK_X, hawkY, hawkRotation, wingState);

  requestAnimationFrame(gameLoop);
}
```

Remove the old wing cycling test code (wingTimer increment and wingState cycling).

- [ ] **Step 6: Add title screen bobbing**

Add to the game loop, before `drawHawk`:

```javascript
  // Title screen: hawk bobs gently
  if (gameState === STATE_TITLE) {
    hawkY = CANVAS_H / 2 + Math.sin(timestamp / 300) * 15;
    wingTimer += dt;
    if (wingTimer > 0.3) { wingTimer = 0; wingState = (wingState + 1) % 3; }
  }
```

- [ ] **Step 7: Verify in browser**

Open in browser. The hawk should bob on the title screen. Clicking/pressing space makes the hawk fly — gravity pulls it down, clicking flaps it up. The hawk should tilt based on velocity. Hitting the ground should stop the game.

- [ ] **Step 8: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add gravity, flap physics, and input controls"
```

---

### Task 5: Rock Pillar Obstacles

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Add the obstacles — pairs of rock pillars extending from top and bottom of the screen with a gap between them. Pillars scroll left and are recycled when they go off-screen. They have snow caps for the realistic mountain look.

- [ ] **Step 1: Add obstacle constants and state**

Add to CONSTANTS:

```javascript
const PILLAR_W = 60;
const GAP_SIZE = 130;
const PILLAR_SPACING = 220; // horizontal distance between pillar pairs
const PILLAR_MIN_TOP = 80;  // minimum height of top pillar
const PILLAR_MAX_TOP = CANVAS_H - GROUND_H - GAP_SIZE - 80; // max top pillar height
```

Add to GAME STATE:

```javascript
let pillars = []; // array of { x, topH } — topH is height of top pillar
```

- [ ] **Step 2: Add pillar spawning to resetGame and game start**

Update `resetGame`:

```javascript
function resetGame() {
  hawkY = CANVAS_H / 2;
  hawkVel = 0;
  hawkRotation = 0;
  scrollX = 0;
  pillars = [];
  gameState = STATE_TITLE;
}
```

Update `handleFlap` — when transitioning from TITLE to PLAYING, seed the first pillars:

```javascript
function handleFlap() {
  if (gameState === STATE_TITLE) {
    gameState = STATE_PLAYING;
    hawkY = CANVAS_H / 2;
    hawkVel = 0;
    pillars = [];
    // Seed pillars starting off-screen right
    for (let i = 0; i < 4; i++) {
      pillars.push({
        x: CANVAS_W + i * PILLAR_SPACING,
        topH: PILLAR_MIN_TOP + Math.random() * (PILLAR_MAX_TOP - PILLAR_MIN_TOP),
        scored: false
      });
    }
  }

  if (gameState === STATE_PLAYING) {
    hawkVel = FLAP_STRENGTH;
    flapHoldTimer = 0;
  }

  if (gameState === STATE_GAMEOVER) {
    resetGame();
  }
}
```

- [ ] **Step 3: Add pillar update logic**

Add to the PHYSICS section:

```javascript
function updatePillars() {
  if (gameState !== STATE_PLAYING) return;

  for (let i = 0; i < pillars.length; i++) {
    pillars[i].x -= SCROLL_SPEED;
  }

  // Remove off-screen pillars and add new ones
  if (pillars.length > 0 && pillars[0].x < -PILLAR_W) {
    pillars.shift();
    const lastX = pillars[pillars.length - 1].x;
    pillars.push({
      x: lastX + PILLAR_SPACING,
      topH: PILLAR_MIN_TOP + Math.random() * (PILLAR_MAX_TOP - PILLAR_MIN_TOP),
      scored: false
    });
  }
}
```

- [ ] **Step 4: Add pillar drawing function**

Add to DRAWING FUNCTIONS:

```javascript
function drawPillar(x, topH) {
  const bottomY = topH + GAP_SIZE;
  const bottomH = CANVAS_H - GROUND_H - bottomY;

  // Top pillar (hangs from ceiling)
  const topGrad = ctx.createLinearGradient(x, 0, x + PILLAR_W, 0);
  topGrad.addColorStop(0, '#5A5A5A');
  topGrad.addColorStop(0.5, '#7A7A7A');
  topGrad.addColorStop(1, '#5A5A5A');
  ctx.fillStyle = topGrad;
  ctx.fillRect(x, 0, PILLAR_W, topH);

  // Top pillar snow (on the bottom edge, hanging down)
  ctx.fillStyle = 'rgba(255,255,255,0.85)';
  ctx.beginPath();
  ctx.ellipse(x + PILLAR_W / 2, topH, PILLAR_W / 2 + 4, 8, 0, 0, Math.PI);
  ctx.fill();

  // Bottom pillar (rises from ground)
  const botGrad = ctx.createLinearGradient(x, bottomY, x + PILLAR_W, bottomY);
  botGrad.addColorStop(0, '#5A5A5A');
  botGrad.addColorStop(0.5, '#7A7A7A');
  botGrad.addColorStop(1, '#5A5A5A');
  ctx.fillStyle = botGrad;
  ctx.fillRect(x, bottomY, PILLAR_W, bottomH);

  // Bottom pillar snow cap (on top edge)
  ctx.fillStyle = 'rgba(255,255,255,0.85)';
  ctx.beginPath();
  ctx.ellipse(x + PILLAR_W / 2, bottomY, PILLAR_W / 2 + 4, 8, 0, Math.PI, Math.PI * 2);
  ctx.fill();

  // Subtle shadow on left side of both pillars
  ctx.fillStyle = 'rgba(0,0,0,0.1)';
  ctx.fillRect(x, 0, 6, topH);
  ctx.fillRect(x, bottomY, 6, bottomH);
}

function drawPillars() {
  for (const p of pillars) {
    drawPillar(p.x, p.topH);
  }
}
```

- [ ] **Step 5: Wire into game loop**

Add `updatePillars()` call after `updatePhysics()` in the game loop.

Add `drawPillars()` call after `drawBackground()` and before `drawHawk()`:

```javascript
  // Draw
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);
  drawBackground();
  drawPillars();
  drawHawk(HAWK_X, hawkY, hawkRotation, wingState);
```

- [ ] **Step 6: Verify in browser**

Open in browser, click to start. Rock pillars with snow caps should scroll from right to left. The hawk can fly through gaps. Pillars recycle as they go off-screen. No collision yet — the hawk passes through them.

- [ ] **Step 7: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add scrolling rock pillar obstacles with snow caps"
```

---

### Task 6: Collision Detection + Scoring

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Add bounding-box collision between the hawk and pillars. Add score tracking — +1 for each pillar pair passed. Display current score during play, and both final and best score on game over. Best score persisted to localStorage.

- [ ] **Step 1: Add score state**

Add to GAME STATE:

```javascript
let score = 0;
let bestScore = parseInt(localStorage.getItem('mountainHawkBest')) || 0;
```

- [ ] **Step 2: Add collision detection to updatePhysics**

Add at the end of `updatePhysics()`, before the ground/ceiling checks:

```javascript
  // Pillar collision (bounding box, slightly forgiving)
  const hx = HAWK_X - 14; // left edge of hawk hitbox (narrower than visual)
  const hy = hawkY - 6;   // top edge
  const hw = 32;           // hitbox width
  const hh = 14;           // hitbox height

  for (const p of pillars) {
    // Check overlap with top pillar
    if (hx + hw > p.x && hx < p.x + PILLAR_W) {
      if (hy < p.topH || hy + hh > p.topH + GAP_SIZE) {
        gameState = STATE_GAMEOVER;
        if (score > bestScore) {
          bestScore = score;
          localStorage.setItem('mountainHawkBest', bestScore);
        }
        return;
      }
    }

    // Score: hawk passed the pillar's right edge
    if (!p.scored && p.x + PILLAR_W < HAWK_X) {
      p.scored = true;
      score++;
    }
  }
```

- [ ] **Step 3: Reset score on game start**

In `handleFlap`, inside the `STATE_TITLE` block, add:

```javascript
    score = 0;
```

- [ ] **Step 4: Add score drawing functions**

Add to DRAWING FUNCTIONS:

```javascript
function drawScore() {
  ctx.save();
  ctx.font = 'bold 48px sans-serif';
  ctx.textAlign = 'center';
  ctx.fillStyle = 'white';
  ctx.shadowColor = 'rgba(0,0,0,0.5)';
  ctx.shadowBlur = 6;
  ctx.shadowOffsetX = 2;
  ctx.shadowOffsetY = 2;
  ctx.fillText(score, CANVAS_W / 2, 60);
  ctx.restore();
}

function drawGameOver() {
  // Dim overlay
  ctx.fillStyle = 'rgba(0,0,0,0.4)';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  // Score panel
  const panelW = 220;
  const panelH = 160;
  const panelX = (CANVAS_W - panelW) / 2;
  const panelY = (CANVAS_H - panelH) / 2 - 30;

  ctx.fillStyle = 'rgba(30,30,50,0.9)';
  ctx.beginPath();
  ctx.roundRect(panelX, panelY, panelW, panelH, 12);
  ctx.fill();
  ctx.strokeStyle = 'rgba(255,255,255,0.2)';
  ctx.lineWidth = 2;
  ctx.stroke();

  ctx.save();
  ctx.textAlign = 'center';

  ctx.font = 'bold 24px sans-serif';
  ctx.fillStyle = '#CC4444';
  ctx.fillText('Game Over', CANVAS_W / 2, panelY + 35);

  ctx.font = '16px sans-serif';
  ctx.fillStyle = '#AAAAAA';
  ctx.fillText('Score', CANVAS_W / 2, panelY + 65);

  ctx.font = 'bold 36px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText(score, CANVAS_W / 2, panelY + 100);

  ctx.font = '14px sans-serif';
  ctx.fillStyle = '#88AACC';
  ctx.fillText('Best: ' + bestScore, CANVAS_W / 2, panelY + 125);

  ctx.font = '14px sans-serif';
  ctx.fillStyle = '#888888';
  ctx.fillText('Click to Retry', CANVAS_W / 2, panelY + panelH + 30);

  ctx.restore();
}

function drawTitle() {
  ctx.save();
  ctx.textAlign = 'center';

  ctx.font = 'bold 36px sans-serif';
  ctx.fillStyle = 'white';
  ctx.shadowColor = 'rgba(0,0,0,0.5)';
  ctx.shadowBlur = 6;
  ctx.fillText('Mountain Hawk', CANVAS_W / 2, 120);

  ctx.shadowBlur = 0;
  ctx.font = '16px sans-serif';
  ctx.fillStyle = '#CCCCCC';
  ctx.fillText('Click or press Space to start', CANVAS_W / 2, CANVAS_H - 100);

  if (bestScore > 0) {
    ctx.font = '14px sans-serif';
    ctx.fillStyle = '#88AACC';
    ctx.fillText('Best: ' + bestScore, CANVAS_W / 2, CANVAS_H - 70);
  }

  ctx.restore();
}
```

- [ ] **Step 5: Wire UI into game loop**

Add to the end of the game loop (after `drawHawk`):

```javascript
  // UI overlays
  if (gameState === STATE_TITLE) {
    drawTitle();
  } else if (gameState === STATE_PLAYING) {
    drawScore();
  } else if (gameState === STATE_GAMEOVER) {
    drawScore();
    drawGameOver();
  }
```

- [ ] **Step 6: Verify in browser**

Open in browser. Title screen shows "Mountain Hawk" and best score. Click to play — score appears top-center and increments when passing pillars. Hitting a pillar ends the game. Game Over panel shows score and best score. Click to retry. Best score persists across page reloads.

- [ ] **Step 7: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add collision detection, scoring, and game state UI"
```

---

### Task 7: Snowfall Particles

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Add ambient snowfall — white particles drifting diagonally, varying sizes and opacity for depth. Always active across all game states.

- [ ] **Step 1: Add snow particle state and init function**

Add to GAME STATE:

```javascript
let snowflakes = [];
```

Add to DRAWING FUNCTIONS:

```javascript
function initSnowflakes() {
  snowflakes = [];
  for (let i = 0; i < 40; i++) {
    snowflakes.push({
      x: Math.random() * CANVAS_W,
      y: Math.random() * CANVAS_H,
      r: 1 + Math.random() * 2,
      speed: 0.3 + Math.random() * 1,
      drift: -0.3 - Math.random() * 0.5,
      opacity: 0.3 + Math.random() * 0.5
    });
  }
}
```

- [ ] **Step 2: Add snow update and draw functions**

```javascript
function updateSnowflakes() {
  for (const s of snowflakes) {
    s.y += s.speed;
    s.x += s.drift;
    if (s.y > CANVAS_H) {
      s.y = -5;
      s.x = Math.random() * CANVAS_W;
    }
    if (s.x < -5) {
      s.x = CANVAS_W + 5;
    }
  }
}

function drawSnowflakes() {
  for (const s of snowflakes) {
    ctx.beginPath();
    ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(255,255,255,${s.opacity})`;
    ctx.fill();
  }
}
```

- [ ] **Step 3: Wire into game loop**

Call `initSnowflakes()` right before the first `requestAnimationFrame` call (at the bottom of the script).

In the game loop, add `updateSnowflakes()` before the draw section, and `drawSnowflakes()` after `drawPillars()` and before `drawHawk()`:

```javascript
  updateSnowflakes();

  // Draw
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);
  drawBackground();
  drawPillars();
  drawSnowflakes();
  drawHawk(HAWK_X, hawkY, hawkRotation, wingState);
```

- [ ] **Step 4: Verify in browser**

Open in browser. Snowflakes should drift gently across the screen at all times — on the title screen, during play, and on game over. They should vary in size, speed, and opacity.

- [ ] **Step 5: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add ambient snowfall particles"
```

---

### Task 8: Death Effects (Feathers, Flash, Tumble)

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** When the hawk hits a pillar or the ground, trigger: (1) a burst of feather particles, (2) a brief white screen flash, (3) the hawk tumbling/spiraling downward.

- [ ] **Step 1: Add death effect state**

Add to GAME STATE:

```javascript
let feathers = [];
let screenFlash = 0; // opacity, fades to 0
let deathAnimTimer = 0;
let deathHawkVel = 0;
```

- [ ] **Step 2: Add death trigger function**

Add to PHYSICS section:

```javascript
function triggerDeath() {
  gameState = STATE_GAMEOVER;
  screenFlash = 0.6;
  deathAnimTimer = 0;
  deathHawkVel = -3;

  if (score > bestScore) {
    bestScore = score;
    localStorage.setItem('mountainHawkBest', bestScore);
  }

  // Spawn feathers
  feathers = [];
  for (let i = 0; i < 10; i++) {
    feathers.push({
      x: HAWK_X,
      y: hawkY,
      vx: (Math.random() - 0.5) * 6,
      vy: -Math.random() * 5,
      r: 1.5 + Math.random() * 2,
      color: Math.random() > 0.5 ? '#7A4E2A' : '#DDDDDD',
      life: 1.0
    });
  }
}
```

- [ ] **Step 3: Replace inline game over triggers with triggerDeath()**

In `updatePhysics`, replace the pillar collision game over code:

```javascript
        gameState = STATE_GAMEOVER;
        if (score > bestScore) {
          bestScore = score;
          localStorage.setItem('mountainHawkBest', bestScore);
        }
        return;
```

With:

```javascript
        triggerDeath();
        return;
```

And replace the ground collision:

```javascript
    gameState = STATE_GAMEOVER;
```

With:

```javascript
    triggerDeath();
```

- [ ] **Step 4: Add death effects update and draw**

```javascript
function updateDeathEffects(dt) {
  if (gameState !== STATE_GAMEOVER) return;

  // Screen flash fade
  if (screenFlash > 0) {
    screenFlash -= dt * 4;
    if (screenFlash < 0) screenFlash = 0;
  }

  // Feather particles
  for (const f of feathers) {
    f.x += f.vx;
    f.y += f.vy;
    f.vy += 0.2; // gravity on feathers
    f.life -= dt * 1.2;
  }
  feathers = feathers.filter(f => f.life > 0);

  // Hawk tumble animation
  deathAnimTimer += dt;
  deathHawkVel += 0.3;
  hawkY += deathHawkVel;
  hawkRotation += 0.1; // spin
  if (hawkY > CANVAS_H - GROUND_H - HAWK_H / 2) {
    hawkY = CANVAS_H - GROUND_H - HAWK_H / 2;
    deathHawkVel = 0;
  }
}

function drawFeathers() {
  for (const f of feathers) {
    ctx.beginPath();
    ctx.arc(f.x, f.y, f.r, 0, Math.PI * 2);
    ctx.fillStyle = f.color;
    ctx.globalAlpha = Math.max(0, f.life);
    ctx.fill();
    ctx.globalAlpha = 1;
  }
}

function drawScreenFlash() {
  if (screenFlash > 0) {
    ctx.fillStyle = `rgba(255,255,255,${screenFlash})`;
    ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
  }
}
```

- [ ] **Step 5: Wire into game loop**

In the game loop, add `updateDeathEffects(dt)` after `updatePhysics()`.

In the draw section, add `drawFeathers()` after `drawHawk()`, and `drawScreenFlash()` before the UI overlays:

```javascript
  drawHawk(HAWK_X, hawkY, hawkRotation, wingState);
  drawFeathers();
  drawScreenFlash();

  // UI overlays
```

Also: only draw `drawGameOver()` after the death animation settles (delay ~1 second):

```javascript
  } else if (gameState === STATE_GAMEOVER) {
    drawScore();
    if (deathAnimTimer > 1.0) {
      drawGameOver();
    }
  }
```

- [ ] **Step 6: Verify in browser**

Open in browser, play the game. When the hawk hits a pillar: feather particles burst outward, screen flashes white briefly, hawk tumbles and spins downward. After ~1 second the Game Over panel appears.

- [ ] **Step 7: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add death effects — feathers, screen flash, hawk tumble"
```

---

### Task 9: Procedural Audio (Web Audio API)

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Add all 5 sounds using the Web Audio API — all procedurally generated, no external files. Sounds: ambient wind (continuous), wing flap, score chime, hawk cry (random interval), collision thud. Audio context must be created on first user interaction (browser autoplay policy).

- [ ] **Step 1: Add audio state and initialization**

Add an AUDIO section after INPUT:

```javascript
// ============================================================
// AUDIO
// ============================================================
let audioCtx = null;
let windNode = null;
let windGain = null;

function initAudio() {
  if (audioCtx) return;
  audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  startWind();
}
```

- [ ] **Step 2: Add ambient wind function**

```javascript
function startWind() {
  const bufferSize = audioCtx.sampleRate * 2;
  const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < bufferSize; i++) {
    data[i] = Math.random() * 2 - 1;
  }

  windNode = audioCtx.createBufferSource();
  windNode.buffer = buffer;
  windNode.loop = true;

  const filter = audioCtx.createBiquadFilter();
  filter.type = 'lowpass';
  filter.frequency.value = 400;

  windGain = audioCtx.createGain();
  windGain.gain.value = 0.08;

  windNode.connect(filter);
  filter.connect(windGain);
  windGain.connect(audioCtx.destination);
  windNode.start();
}
```

- [ ] **Step 3: Add wing flap sound**

```javascript
function playFlap() {
  if (!audioCtx) return;
  const bufferSize = audioCtx.sampleRate * 0.1;
  const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < bufferSize; i++) {
    data[i] = (Math.random() * 2 - 1) * (1 - i / bufferSize);
  }

  const source = audioCtx.createBufferSource();
  source.buffer = buffer;

  const filter = audioCtx.createBiquadFilter();
  filter.type = 'bandpass';
  filter.frequency.value = 800;
  filter.Q.value = 0.5;

  const gain = audioCtx.createGain();
  gain.gain.value = 0.15;

  source.connect(filter);
  filter.connect(gain);
  gain.connect(audioCtx.destination);
  source.start();
}
```

- [ ] **Step 4: Add score chime sound**

```javascript
function playChime() {
  if (!audioCtx) return;
  const osc = audioCtx.createOscillator();
  osc.type = 'sine';
  osc.frequency.value = 800;

  const gain = audioCtx.createGain();
  gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.25);

  osc.connect(gain);
  gain.connect(audioCtx.destination);
  osc.start();
  osc.stop(audioCtx.currentTime + 0.25);
}
```

- [ ] **Step 5: Add hawk cry sound**

```javascript
function playHawkCry() {
  if (!audioCtx) return;
  const osc = audioCtx.createOscillator();
  osc.type = 'sawtooth';
  osc.frequency.setValueAtTime(1200, audioCtx.currentTime);
  osc.frequency.exponentialRampToValueAtTime(400, audioCtx.currentTime + 0.6);

  const vibrato = audioCtx.createOscillator();
  vibrato.frequency.value = 8;
  const vibratoGain = audioCtx.createGain();
  vibratoGain.gain.value = 30;
  vibrato.connect(vibratoGain);
  vibratoGain.connect(osc.frequency);
  vibrato.start();

  const gain = audioCtx.createGain();
  gain.gain.setValueAtTime(0.04, audioCtx.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.6);

  const filter = audioCtx.createBiquadFilter();
  filter.type = 'bandpass';
  filter.frequency.value = 800;
  filter.Q.value = 2;

  osc.connect(filter);
  filter.connect(gain);
  gain.connect(audioCtx.destination);
  osc.start();
  osc.stop(audioCtx.currentTime + 0.6);
  vibrato.stop(audioCtx.currentTime + 0.6);
}
```

- [ ] **Step 6: Add collision thud sound**

```javascript
function playThud() {
  if (!audioCtx) return;
  const bufferSize = audioCtx.sampleRate * 0.08;
  const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < bufferSize; i++) {
    data[i] = (Math.random() * 2 - 1) * (1 - i / bufferSize);
  }

  const source = audioCtx.createBufferSource();
  source.buffer = buffer;

  const filter = audioCtx.createBiquadFilter();
  filter.type = 'lowpass';
  filter.frequency.value = 200;

  const gain = audioCtx.createGain();
  gain.gain.value = 0.3;

  source.connect(filter);
  filter.connect(gain);
  gain.connect(audioCtx.destination);
  source.start();
}
```

- [ ] **Step 7: Add random hawk cry timer**

Add to GAME STATE:

```javascript
let hawkCryTimer = 8 + Math.random() * 7; // 8-15 seconds
```

Add to the game loop update section:

```javascript
  // Random hawk cry
  if (gameState === STATE_PLAYING) {
    hawkCryTimer -= dt;
    if (hawkCryTimer <= 0) {
      playHawkCry();
      hawkCryTimer = 8 + Math.random() * 7;
    }
  }
```

- [ ] **Step 8: Wire audio into existing game actions**

In `handleFlap`, add `initAudio()` at the very top (before any state checks). Add `playFlap()` inside the `STATE_PLAYING` block:

```javascript
function handleFlap() {
  initAudio();

  if (gameState === STATE_TITLE) {
    // ... existing code ...
  }

  if (gameState === STATE_PLAYING) {
    hawkVel = FLAP_STRENGTH;
    flapHoldTimer = 0;
    playFlap();
  }

  // ... rest unchanged ...
}
```

In pillar scoring (inside `updatePhysics`, where `p.scored = true`), add:

```javascript
      playChime();
```

In `triggerDeath()`, add:

```javascript
  playThud();
```

- [ ] **Step 9: Verify in browser**

Open in browser, click to start. You should hear:
- Wind ambience playing continuously
- Whoosh on each flap
- Chime when passing a pillar
- Occasional distant hawk screech (~every 8-15 seconds)
- Thud on death

- [ ] **Step 10: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add procedural audio — wind, flap, chime, hawk cry, collision"
```

---

### Task 10: Polish + Final Tuning

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Final polish pass — ensure game feel is right, add any missing small details, and do a final play-test. This task covers: preventing double-flap on game over → title transition, ensuring the background still scrolls slowly on the title screen, and adding a game over delay before click-to-retry is active.

- [ ] **Step 1: Add game over click delay**

Add to GAME STATE:

```javascript
let gameOverClickDelay = 0;
```

In `triggerDeath()`, add:

```javascript
  gameOverClickDelay = 1.5; // seconds before click-to-retry is active
```

Update `handleFlap` game over block:

```javascript
  if (gameState === STATE_GAMEOVER && gameOverClickDelay <= 0) {
    resetGame();
  }
```

In the game loop update section, add:

```javascript
  if (gameState === STATE_GAMEOVER) {
    gameOverClickDelay -= dt;
  }
```

- [ ] **Step 2: Add slow background scroll on title screen**

In the game loop, change the scroll update:

```javascript
  // Update
  if (gameState === STATE_PLAYING) {
    scrollX += SCROLL_SPEED;
  } else {
    scrollX += SCROLL_SPEED * 0.3; // slow scroll on title/game over
  }
```

- [ ] **Step 3: Reset hawk cry timer on game start**

In `handleFlap`, inside the `STATE_TITLE` block, add:

```javascript
    hawkCryTimer = 8 + Math.random() * 7;
```

- [ ] **Step 4: Verify full game flow in browser**

Play through the complete game flow multiple times:
1. Title screen — hawk bobs, wind plays, background scrolls slowly, "Click or press Space to start" shown
2. Playing — hawk responds to input, pillars scroll, score increments, audio works, snowflakes drift
3. Death — feather burst, flash, tumble, thud sound, ~1s delay then Game Over panel
4. Game Over — score and best score shown, click-to-retry has delay, best score persists on reload
5. Retry — click returns to title, can start fresh

- [ ] **Step 5: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: polish — click delay, title scroll, final tuning"
```

---

## Summary

| Task | Description | Key Output |
|------|-------------|------------|
| 1 | HTML scaffold + game loop | Canvas renders, loop runs |
| 2 | Parallax background | 5-layer scrolling mountains |
| 3 | Hawk rendering | Animated hawk with 3 wing states |
| 4 | Physics + controls | Gravity, flap, rotation, input |
| 5 | Rock pillars | Scrolling obstacles with snow caps |
| 6 | Collision + scoring | Death on hit, score tracking, localStorage |
| 7 | Snowfall particles | Ambient snow effect |
| 8 | Death effects | Feathers, flash, tumble |
| 9 | Procedural audio | Wind, flap, chime, hawk cry, thud |
| 10 | Polish + tuning | Click delay, title scroll, final QA |

Each task produces a playable game — starting from a blue rectangle and progressively adding layers until the full Mountain Hawk experience is complete.
