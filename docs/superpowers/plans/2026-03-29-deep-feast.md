# Deep Feast Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an ocean survival game where you eat fish, grow bigger, avoid bosses, and unlock new fish in a shop — as a single HTML file with zero dependencies.

**Architecture:** Single `deep-feast/index.html` file. Canvas renders a 600×600 viewport into a large scrolling world (6000×800). Camera follows the player. Fixed timestep physics at 60fps. All entities (fish, clams, meat) stored in arrays and updated/drawn each frame with camera culling. Procedural Canvas drawing for all fish. Web Audio API for all sounds.

**Tech Stack:** HTML5 Canvas 2D, Web Audio API, vanilla JavaScript, localStorage

**Spec:** `docs/superpowers/specs/2026-03-29-deep-feast-design.md`

---

## File Structure

```
deep-feast/
└── index.html    # Single file: HTML + CSS + JS
```

---

### Task 1: HTML Scaffold, Canvas, Camera System

**Files:**
- Create: `deep-feast/index.html`

**Context:** Create the HTML file with canvas, CSS (same mobile-friendly approach as Mountain Hawk), game loop with fixed timestep, and a camera that follows a test position around a large world.

- [ ] **Step 1: Create the HTML file with canvas, CSS, and game loop**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Deep Feast</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background: #0a1628;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    overflow: hidden;
  }
  canvas {
    border-radius: 4px;
    box-shadow: 0 0 40px rgba(0,0,0,0.5);
    height: 90vh;
    width: 90vh;
    image-rendering: pixelated;
    touch-action: none;
    -webkit-tap-highlight-color: transparent;
    user-select: none;
    -webkit-user-select: none;
  }
  @media (max-width: 768px), (max-height: 500px) {
    canvas { width: 100vw; height: 100vw; max-height: 100vh; border-radius: 0; box-shadow: none; }
  }
</style>
</head>
<body>
<canvas id="game" width="600" height="600"></canvas>
<script>
// ============================================================
// CONSTANTS
// ============================================================
const CANVAS_W = 600;
const CANVAS_H = 600;
const WORLD_W = 6000;
const WORLD_H = 800;
const FIXED_DT = 1 / 60;

// ============================================================
// CANVAS SETUP
// ============================================================
const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');

// ============================================================
// CAMERA
// ============================================================
let camX = 0;
let camY = 0;

function updateCamera(targetX, targetY) {
  camX = Math.max(0, Math.min(WORLD_W - CANVAS_W, targetX - CANVAS_W / 2));
  camY = Math.max(0, Math.min(WORLD_H - CANVAS_H, targetY - CANVAS_H / 2));
}

// ============================================================
// GAME STATE
// ============================================================
let lastTime = 0;
let accumulator = 0;

// Test position for camera
let testX = WORLD_W / 2;
let testY = WORLD_H / 2;

// ============================================================
// DRAWING
// ============================================================
function drawOceanBackground() {
  const grad = ctx.createLinearGradient(0, -camY, 0, WORLD_H - camY);
  grad.addColorStop(0, '#2898E0');
  grad.addColorStop(0.3, '#1E80C8');
  grad.addColorStop(0.7, '#1668A8');
  grad.addColorStop(1, '#0E5090');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  // Light rays from top
  ctx.save();
  ctx.globalAlpha = 0.06;
  for (let i = 0; i < 5; i++) {
    const rx = (i * 180 + 50 - camX * 0.05) % (CANVAS_W + 200) - 100;
    ctx.beginPath();
    ctx.moveTo(rx, -camY);
    ctx.lineTo(rx - 40, CANVAS_H);
    ctx.lineTo(rx + 40, CANVAS_H);
    ctx.closePath();
    ctx.fillStyle = '#FFFFCC';
    ctx.fill();
  }
  ctx.restore();
}

function drawOceanFloor() {
  const floorY = WORLD_H - 60 - camY;
  if (floorY > CANVAS_H) return;

  // Sand
  const sandGrad = ctx.createLinearGradient(0, floorY, 0, floorY + 60);
  sandGrad.addColorStop(0, '#C4A56B');
  sandGrad.addColorStop(1, '#A08050');
  ctx.fillStyle = sandGrad;
  ctx.fillRect(0, Math.max(0, floorY), CANVAS_W, 60);

  // Coral (draw a few per screen based on camera)
  const startTile = Math.floor(camX / 200);
  for (let t = startTile - 1; t <= startTile + 4; t++) {
    const bx = t * 200 + 100 - camX;
    const by = floorY;
    if (bx < -100 || bx > CANVAS_W + 100) continue;
    const hue = (t * 73) % 360;
    ctx.fillStyle = `hsl(${hue}, 60%, 55%)`;
    ctx.beginPath();
    ctx.ellipse(bx, by, 20 + (t % 3) * 8, 15 + (t % 4) * 5, 0, Math.PI, 0);
    ctx.fill();
    ctx.fillStyle = `hsl(${hue}, 60%, 65%)`;
    ctx.beginPath();
    ctx.ellipse(bx, by - 5, 12 + (t % 2) * 4, 10 + (t % 3) * 3, 0, Math.PI, 0);
    ctx.fill();
  }
}

// ============================================================
// GAME LOOP
// ============================================================
function gameLoop(timestamp) {
  const dt = Math.min((timestamp - lastTime) / 1000, 0.1);
  lastTime = timestamp;
  accumulator += dt;

  while (accumulator >= FIXED_DT) {
    accumulator -= FIXED_DT;
    // Test: move test position with arrow keys (will be replaced by player)
    updateCamera(testX, testY);
  }

  // Draw
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);
  drawOceanBackground();
  drawOceanFloor();

  // Draw test marker
  ctx.fillStyle = 'red';
  ctx.beginPath();
  ctx.arc(testX - camX, testY - camY, 10, 0, Math.PI * 2);
  ctx.fill();

  requestAnimationFrame(gameLoop);
}

// Temp input for camera test
const keysDown = {};
document.addEventListener('keydown', (e) => { keysDown[e.code] = true; });
document.addEventListener('keyup', (e) => { keysDown[e.code] = false; });

function updateTestInput() {
  const spd = 4;
  if (keysDown['ArrowLeft'] || keysDown['KeyA']) testX -= spd;
  if (keysDown['ArrowRight'] || keysDown['KeyD']) testX += spd;
  if (keysDown['ArrowUp'] || keysDown['KeyW']) testY -= spd;
  if (keysDown['ArrowDown'] || keysDown['KeyS']) testY += spd;
  testX = Math.max(0, Math.min(WORLD_W, testX));
  testY = Math.max(0, Math.min(WORLD_H, testY));
}

requestAnimationFrame((t) => { lastTime = t; gameLoop(t); });
</script>
</body>
</html>
```

Note: add `updateTestInput()` call inside the `while (accumulator >= FIXED_DT)` loop, before `updateCamera`.

- [ ] **Step 2: Verify in browser**

Open `deep-feast/index.html`. You should see a blue ocean gradient with coral on the floor and a red dot. Use arrow keys/WASD to scroll around the 6000×800 world. Camera clamps at edges.

- [ ] **Step 3: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: scaffold Deep Feast — canvas, camera, ocean background"
```

---

### Task 2: Player Fish — Drawing, Movement, Facing Direction

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Replace the test red dot with a procedurally drawn piranha. The fish faces left or right based on movement direction. Movement uses arrow keys/WASD with 8-directional support. The fish has a swim animation (tail wagging).

- [ ] **Step 1: Add player constants and state**

Add to CONSTANTS:

```javascript
const PLAYER_SPEED = 3;
const SPRINT_SPEED = 5.4; // 1.8x normal
const SPRINT_MAX = 13; // seconds
```

Add a PLAYER section after GAME STATE:

```javascript
// ============================================================
// PLAYER
// ============================================================
let player = {
  x: 300, y: 400,
  vx: 0, vy: 0,
  size: 1.0, // scale multiplier
  facingRight: true,
  swimTimer: 0,
  biteForce: 10,
  maxHealth: 100,
  health: 100,
  coins: parseInt(localStorage.getItem('deepFeastCoins')) || 0,
  sprinting: false,
  staminaLeft: SPRINT_MAX,
  alive: true
};
```

- [ ] **Step 2: Add drawPiranha function**

Add to a DRAWING section:

```javascript
function drawPiranha(x, y, size, facingRight, swimTimer, skin) {
  ctx.save();
  ctx.translate(x, y);
  ctx.scale(facingRight ? 1 : -1, 1);
  const s = size;

  // Tail (wags with swimTimer)
  const tailWag = Math.sin(swimTimer * 8) * 0.3;
  ctx.fillStyle = skin === 'skeleton' ? '#D0C8B8' : '#CC3300';
  ctx.beginPath();
  ctx.moveTo(-18 * s, 0);
  ctx.lineTo(-28 * s, (-10 + tailWag * 10) * s);
  ctx.lineTo(-28 * s, (10 + tailWag * 10) * s);
  ctx.closePath();
  ctx.fill();

  // Body
  ctx.fillStyle = skin === 'skeleton' ? '#E8E0D0' : '#FF4400';
  ctx.beginPath();
  ctx.ellipse(0, 0, 20 * s, 12 * s, 0, 0, Math.PI * 2);
  ctx.fill();

  // Belly
  ctx.fillStyle = skin === 'skeleton' ? '#F0E8D8' : '#FF8844';
  ctx.beginPath();
  ctx.ellipse(2 * s, 4 * s, 14 * s, 6 * s, 0, 0, Math.PI);
  ctx.fill();

  if (skin === 'skeleton') {
    // Rib lines
    ctx.strokeStyle = '#B0A898';
    ctx.lineWidth = 1;
    for (let i = -2; i <= 2; i++) {
      ctx.beginPath();
      ctx.moveTo(i * 5 * s, -6 * s);
      ctx.lineTo(i * 5 * s, 6 * s);
      ctx.stroke();
    }
  }

  // Dorsal fin
  ctx.fillStyle = skin === 'skeleton' ? '#C8C0B0' : '#CC2200';
  ctx.beginPath();
  ctx.moveTo(-4 * s, -10 * s);
  ctx.lineTo(6 * s, -14 * s);
  ctx.lineTo(8 * s, -10 * s);
  ctx.closePath();
  ctx.fill();

  // Eye
  ctx.beginPath();
  ctx.arc(10 * s, -3 * s, 3.5 * s, 0, Math.PI * 2);
  ctx.fillStyle = 'white';
  ctx.fill();
  ctx.beginPath();
  ctx.arc(11 * s, -3 * s, 1.8 * s, 0, Math.PI * 2);
  ctx.fillStyle = '#111';
  ctx.fill();
  ctx.beginPath();
  ctx.arc(11.5 * s, -3.5 * s, 0.6 * s, 0, Math.PI * 2);
  ctx.fillStyle = 'white';
  ctx.fill();

  ctx.restore();
}
```

- [ ] **Step 3: Add player input handling**

Replace the temp input section with a proper INPUT section:

```javascript
// ============================================================
// INPUT
// ============================================================
const keysDown = {};
let mouseDown = false;
let mouseHoldTime = 0;

document.addEventListener('keydown', (e) => {
  keysDown[e.code] = true;
  if (e.code === 'ShiftLeft' || e.code === 'ShiftRight') {
    player.sprinting = !player.sprinting;
  }
});
document.addEventListener('keyup', (e) => { keysDown[e.code] = false; });
canvas.addEventListener('mousedown', (e) => { e.preventDefault(); mouseDown = true; mouseHoldTime = 0; });
canvas.addEventListener('mouseup', (e) => { mouseDown = false; mouseHoldTime = 0; });
canvas.addEventListener('touchstart', (e) => { e.preventDefault(); mouseDown = true; mouseHoldTime = 0; });
canvas.addEventListener('touchend', (e) => { mouseDown = false; mouseHoldTime = 0; });

function updatePlayerInput() {
  if (!player.alive) return;
  const speed = player.sprinting && player.staminaLeft > 0 ? SPRINT_SPEED : PLAYER_SPEED;

  player.vx = 0;
  player.vy = 0;
  if (keysDown['ArrowLeft'] || keysDown['KeyA']) player.vx = -speed;
  if (keysDown['ArrowRight'] || keysDown['KeyD']) player.vx = speed;
  if (keysDown['ArrowUp'] || keysDown['KeyW']) player.vy = -speed;
  if (keysDown['ArrowDown'] || keysDown['KeyS']) player.vy = speed;

  // Diagonal normalization
  if (player.vx !== 0 && player.vy !== 0) {
    player.vx *= 0.707;
    player.vy *= 0.707;
  }

  if (player.vx > 0) player.facingRight = true;
  if (player.vx < 0) player.facingRight = false;

  // Sprint stamina
  if (player.sprinting && player.staminaLeft > 0) {
    player.staminaLeft -= FIXED_DT;
    if (player.staminaLeft <= 0) {
      player.staminaLeft = 0;
      player.sprinting = false;
    }
  } else if (!player.sprinting && player.staminaLeft < SPRINT_MAX) {
    player.staminaLeft += FIXED_DT * 0.5; // recharges at half speed
    if (player.staminaLeft > SPRINT_MAX) player.staminaLeft = SPRINT_MAX;
  }

  // Bite hold timer
  if (mouseDown) {
    mouseHoldTime += FIXED_DT;
  }
}

function updatePlayer() {
  if (!player.alive) return;
  player.x += player.vx;
  player.y += player.vy;
  player.x = Math.max(20 * player.size, Math.min(WORLD_W - 20 * player.size, player.x));
  player.y = Math.max(20 * player.size, Math.min(WORLD_H - 60 - 12 * player.size, player.y));
  player.swimTimer += FIXED_DT;
}
```

- [ ] **Step 4: Update game loop**

Replace the game loop's fixed update to use player functions, and replace drawing with the piranha:

In the `while (accumulator >= FIXED_DT)` block:
```javascript
    updatePlayerInput();
    updatePlayer();
    updateCamera(player.x, player.y);
```

In the draw section, replace the red test marker with:
```javascript
  drawPiranha(player.x - camX, player.y - camY, player.size, player.facingRight, player.swimTimer, 'normal');
```

Remove `testX`, `testY`, `updateTestInput`, and the old temp input code.

- [ ] **Step 5: Verify in browser**

Open in browser. A red piranha should appear. Arrow keys/WASD move it around. It faces the direction of movement. Tail wags as it swims. Camera follows. Shift toggles sprint (faster movement).

- [ ] **Step 6: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add piranha player with movement, sprint, and swim animation"
```

---

### Task 3: Bite Mechanic — Mouth Visual, Charge, Yellow Indicator

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Add the bite mechanic visuals to the piranha. Hold left click to open mouth with a bite-range arc. After 2 seconds, bite is charged (1.5x). Mouth and teeth turn yellow when a hittable entity is in range (will be wired to actual entities in a later task — for now just draw the visual states).

- [ ] **Step 1: Add bite constants**

Add to CONSTANTS:

```javascript
const BITE_CHARGE_TIME = 2.0; // seconds to charge
const BITE_DAMAGE_MULT = 1.5; // charged bite multiplier
const BITE_RANGE = 30; // pixels from mouth center
```

- [ ] **Step 2: Add bite state to player**

Add to the player object:

```javascript
  biting: false,
  biteCharged: false,
  canHitSomething: false, // set by collision check later
```

- [ ] **Step 3: Update input to set bite state**

In `updatePlayerInput()`, after the bite hold timer section, add:

```javascript
  player.biting = mouseDown;
  player.biteCharged = mouseHoldTime >= BITE_CHARGE_TIME;
```

- [ ] **Step 4: Add bite visuals to drawPiranha**

Add these lines inside `drawPiranha` right before `ctx.restore()`. The function needs two new parameters: `biting` and `canHit`. Update the signature to `drawPiranha(x, y, size, facingRight, swimTimer, skin, biting, biteCharged, canHit)`:

```javascript
  // Mouth and bite visuals
  if (biting) {
    const mouthColor = canHit ? '#FFD700' : '#CC3300';
    const teethColor = canHit ? '#FFD700' : '#FFFFFF';

    // Open mouth
    ctx.beginPath();
    ctx.arc(18 * s, 2 * s, 6 * s, -0.5, 0.5);
    ctx.lineTo(18 * s, 2 * s);
    ctx.closePath();
    ctx.fillStyle = '#440000';
    ctx.fill();

    // Teeth
    ctx.fillStyle = teethColor;
    for (let t = 0; t < 4; t++) {
      const angle = -0.4 + t * 0.25;
      const tx = 18 * s + Math.cos(angle) * 6 * s;
      const ty = 2 * s + Math.sin(angle) * 6 * s;
      ctx.beginPath();
      ctx.arc(tx, ty, 1.2 * s, 0, Math.PI * 2);
      ctx.fill();
    }

    // Bite range arc
    ctx.strokeStyle = biteCharged ? 'rgba(255,215,0,0.5)' : 'rgba(255,255,255,0.2)';
    ctx.lineWidth = biteCharged ? 2.5 : 1.5;
    ctx.beginPath();
    ctx.arc(20 * s, 0, BITE_RANGE * s, -0.8, 0.8);
    ctx.stroke();

    // Charged glow pulse
    if (biteCharged) {
      ctx.strokeStyle = `rgba(255,215,0,${0.2 + Math.sin(swimTimer * 10) * 0.15})`;
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(20 * s, 0, (BITE_RANGE + 5) * s, -0.8, 0.8);
      ctx.stroke();
    }
  }
```

- [ ] **Step 5: Update drawPiranha call site**

Update the draw call in the game loop:

```javascript
  drawPiranha(player.x - camX, player.y - camY, player.size, player.facingRight, player.swimTimer, 'normal', player.biting, player.biteCharged, player.canHitSomething);
```

- [ ] **Step 6: Verify in browser**

Move the fish around. Hold left click — mouth opens with a bite arc. Hold for 2 seconds — arc glows gold and pulses. Release — mouth closes. (Yellow hit indicator won't work yet since there are no other fish to detect.)

- [ ] **Step 7: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add bite mechanic — mouth visual, charge, range indicator"
```

---

### Task 4: Food Entities — Clams, Seashells, Clownfish

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Add the first edible entities. Clams and seashells sit on the ocean floor. Clownfish swim in small schools. Biting them while holding left click eats them and gives coins + stat boosts. Yellow indicator lights up when in bite range.

- [ ] **Step 1: Add entity arrays and spawn functions**

Add an ENTITIES section after PLAYER:

```javascript
// ============================================================
// ENTITIES
// ============================================================
let entities = []; // all world entities: {type, x, y, vx, vy, size, health, maxHealth, ...}

function spawnClam(x, y) {
  entities.push({ type: 'clam', x, y, vx: 0, vy: 0, size: 0.6, health: 5, maxHealth: 5, coins: 2, bfGain: 1, hpGain: 2, sizeGain: 0.002 });
}

function spawnSeashell(x, y) {
  entities.push({ type: 'seashell', x, y, vx: 0, vy: 0, size: 0.4, health: 3, maxHealth: 3, coins: 1, bfGain: 1, hpGain: 1, sizeGain: 0.001 });
}

function spawnClownfish(x, y) {
  entities.push({
    type: 'clownfish', x, y,
    vx: (Math.random() - 0.5) * 1.5, vy: (Math.random() - 0.5) * 0.5,
    size: 0.5, health: 8, maxHealth: 8,
    coins: 3, bfGain: 2, hpGain: 3, sizeGain: 0.005,
    turnTimer: Math.random() * 3
  });
}

function initEntities() {
  entities = [];
  // Scatter clams and seashells along floor
  for (let x = 50; x < WORLD_W; x += 80 + Math.random() * 120) {
    if (Math.random() > 0.5) {
      spawnClam(x, WORLD_H - 70 + Math.random() * 10);
    } else {
      spawnSeashell(x, WORLD_H - 68 + Math.random() * 8);
    }
  }
  // Clownfish schools
  for (let i = 0; i < 30; i++) {
    const sx = 200 + Math.random() * (WORLD_W - 400);
    const sy = 100 + Math.random() * (WORLD_H - 250);
    for (let j = 0; j < 3 + Math.floor(Math.random() * 3); j++) {
      spawnClownfish(sx + (Math.random() - 0.5) * 80, sy + (Math.random() - 0.5) * 40);
    }
  }
}
```

- [ ] **Step 2: Add entity drawing functions**

```javascript
function drawClam(x, y, s) {
  // Bottom shell
  ctx.fillStyle = '#8B7D6B';
  ctx.beginPath();
  ctx.ellipse(x, y, 10 * s, 6 * s, 0, 0, Math.PI);
  ctx.fill();
  // Top shell
  ctx.fillStyle = '#9B8D7B';
  ctx.beginPath();
  ctx.ellipse(x, y, 10 * s, 6 * s, 0, Math.PI, 0);
  ctx.fill();
  // Ridges
  ctx.strokeStyle = '#7B6D5B';
  ctx.lineWidth = 0.5;
  for (let i = -2; i <= 2; i++) {
    ctx.beginPath();
    ctx.arc(x, y, (4 + Math.abs(i) * 2) * s, Math.PI, 0);
    ctx.stroke();
  }
}

function drawSeashell(x, y, s) {
  ctx.fillStyle = '#F0E0C0';
  ctx.beginPath();
  ctx.ellipse(x, y, 6 * s, 4 * s, 0.3, 0, Math.PI * 2);
  ctx.fill();
  ctx.strokeStyle = '#D0C0A0';
  ctx.lineWidth = 0.5;
  ctx.beginPath();
  ctx.arc(x, y, 3 * s, 0, Math.PI * 1.5);
  ctx.stroke();
}

function drawClownfish(x, y, s, vx, swimTimer) {
  ctx.save();
  ctx.translate(x, y);
  if (vx < 0) ctx.scale(-1, 1);

  // Tail
  const tailWag = Math.sin(swimTimer * 10) * 0.2;
  ctx.fillStyle = '#FF8C00';
  ctx.beginPath();
  ctx.moveTo(-10 * s, 0);
  ctx.lineTo(-16 * s, (-5 + tailWag * 5) * s);
  ctx.lineTo(-16 * s, (5 + tailWag * 5) * s);
  ctx.closePath();
  ctx.fill();

  // Body
  ctx.fillStyle = '#FF6600';
  ctx.beginPath();
  ctx.ellipse(0, 0, 12 * s, 7 * s, 0, 0, Math.PI * 2);
  ctx.fill();

  // White stripes
  ctx.fillStyle = 'white';
  ctx.fillRect(-1 * s, -7 * s, 2.5 * s, 14 * s);
  ctx.fillRect(5 * s, -6 * s, 2 * s, 12 * s);

  // Eye
  ctx.beginPath();
  ctx.arc(7 * s, -2 * s, 2 * s, 0, Math.PI * 2);
  ctx.fillStyle = 'white';
  ctx.fill();
  ctx.beginPath();
  ctx.arc(7.5 * s, -2 * s, 1 * s, 0, Math.PI * 2);
  ctx.fillStyle = 'black';
  ctx.fill();

  ctx.restore();
}
```

- [ ] **Step 3: Add entity AI update**

```javascript
function updateEntities() {
  for (const e of entities) {
    if (e.type === 'clownfish') {
      e.turnTimer -= FIXED_DT;
      if (e.turnTimer <= 0) {
        e.vx = (Math.random() - 0.5) * 1.5;
        e.vy = (Math.random() - 0.5) * 0.5;
        e.turnTimer = 2 + Math.random() * 3;
      }
      e.x += e.vx;
      e.y += e.vy;
      // Keep in bounds
      if (e.x < 30 || e.x > WORLD_W - 30) e.vx *= -1;
      if (e.y < 30 || e.y > WORLD_H - 80) e.vy *= -1;
      e.swimTimer = (e.swimTimer || 0) + FIXED_DT;
    }
  }
}
```

- [ ] **Step 4: Add bite collision detection**

```javascript
function updateBiteCollision() {
  player.canHitSomething = false;
  if (!player.biting || !player.alive) return;

  const dir = player.facingRight ? 1 : -1;
  const mouthX = player.x + dir * 20 * player.size;
  const mouthY = player.y;
  const range = BITE_RANGE * player.size;

  for (let i = entities.length - 1; i >= 0; i--) {
    const e = entities[i];
    const dx = e.x - mouthX;
    const dy = e.y - mouthY;
    const dist = Math.sqrt(dx * dx + dy * dy);
    const hitDist = range + 10 * e.size;

    if (dist < hitDist) {
      player.canHitSomething = true;

      // Deal damage on bite (once per click, not continuous)
      if (mouseHoldTime < FIXED_DT * 2) { // just started biting
        const dmg = player.biteCharged ? player.biteForce * BITE_DAMAGE_MULT : player.biteForce;
        e.health -= dmg;

        if (e.health <= 0) {
          // Eat it — gain stats
          player.coins += e.coins;
          player.biteForce += e.bfGain;
          player.maxHealth += e.hpGain;
          player.health = Math.min(player.health + e.hpGain, player.maxHealth);
          player.size += e.sizeGain;
          localStorage.setItem('deepFeastCoins', player.coins);
          entities.splice(i, 1);
        }
      }
      break; // only hit one entity per bite
    }
  }
}
```

- [ ] **Step 5: Add entity drawing to game loop and wire updates**

In the fixed update loop, add:
```javascript
    updateEntities();
    updateBiteCollision();
```

In the draw section, after `drawOceanFloor()` and before drawing the player:
```javascript
  // Draw entities (camera culled)
  for (const e of entities) {
    const sx = e.x - camX;
    const sy = e.y - camY;
    if (sx < -60 || sx > CANVAS_W + 60 || sy < -60 || sy > CANVAS_H + 60) continue;
    if (e.type === 'clam') drawClam(sx, sy, e.size);
    else if (e.type === 'seashell') drawSeashell(sx, sy, e.size);
    else if (e.type === 'clownfish') drawClownfish(sx, sy, e.size, e.vx, e.swimTimer || 0);
  }
```

Call `initEntities()` before the first `requestAnimationFrame`.

- [ ] **Step 6: Verify in browser**

Swim around. Clams and seashells on the floor, clownfish schools swimming around. Hold left click near a clownfish — mouth opens, teeth turn yellow when in range. Bite to eat them. Coins increase (visible in console for now — HUD comes in a later task).

- [ ] **Step 7: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add clams, seashells, clownfish — eating with bite mechanic"
```

---

### Task 5: Medium Fish, Orcas, Whales + Meat Drops

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Add medium wild fish (swim around, flee or chase based on size comparison), orcas (aggressive patrols), and whales (passive, suck attack). When killed, fish drop meat pieces. Large meat can be chopped into smaller bites.

- [ ] **Step 1: Add spawn functions for medium fish, orcas, whales**

```javascript
function spawnMediumFish(x, y) {
  entities.push({
    type: 'medfish', x, y,
    vx: (Math.random() > 0.5 ? 1 : -1) * (1 + Math.random()), vy: (Math.random() - 0.5) * 0.5,
    size: 0.9 + Math.random() * 0.4, health: 30, maxHealth: 30,
    coins: 8, bfGain: 3, hpGain: 5, sizeGain: 0.01,
    turnTimer: Math.random() * 4,
    color: `hsl(${Math.floor(Math.random() * 360)}, 50%, 45%)`,
    swimTimer: 0, meatCount: 2
  });
}

function spawnOrca(x, y) {
  entities.push({
    type: 'orca', x, y,
    vx: (Math.random() > 0.5 ? 1 : -1) * 1.5, vy: 0,
    size: 2.5, health: 200, maxHealth: 200,
    coins: 30, bfGain: 5, hpGain: 8, sizeGain: 0.03,
    turnTimer: Math.random() * 5,
    swimTimer: 0, meatCount: 5,
    aggroRange: 300, damage: 20,
    respawnTime: 60, respawnX: x, respawnY: y
  });
}

function spawnWhale(x, y) {
  entities.push({
    type: 'whale', x, y,
    vx: (Math.random() > 0.5 ? 0.3 : -0.3), vy: 0,
    size: 4.0, health: 400, maxHealth: 400,
    coins: 40, bfGain: 5, hpGain: 8, sizeGain: 0.04,
    turnTimer: Math.random() * 8,
    swimTimer: 0, meatCount: 5,
    suckRange: 150, suckForce: 0.8,
    respawnTime: 90, respawnX: x, respawnY: y
  });
}
```

- [ ] **Step 2: Add meat entity**

```javascript
function spawnMeat(x, y, meatSize) {
  entities.push({
    type: 'meat', x, y,
    vx: (Math.random() - 0.5) * 2, vy: 0.5 + Math.random(),
    size: meatSize, health: meatSize * 10, maxHealth: meatSize * 10,
    coins: Math.ceil(meatSize * 5), bfGain: Math.ceil(meatSize * 2), hpGain: Math.ceil(meatSize * 3), sizeGain: meatSize * 0.005,
    lifetime: 30 // disappears after 30 seconds
  });
}

function dropMeat(x, y, count, totalSize) {
  const pieceSize = totalSize / count;
  for (let i = 0; i < count; i++) {
    spawnMeat(x + (Math.random() - 0.5) * 30, y + (Math.random() - 0.5) * 20, pieceSize);
  }
}
```

- [ ] **Step 3: Add drawing functions for medium fish, orca, whale, meat**

```javascript
function drawMediumFish(x, y, s, vx, swimTimer, color) {
  ctx.save();
  ctx.translate(x, y);
  if (vx < 0) ctx.scale(-1, 1);
  const tw = Math.sin(swimTimer * 7) * 0.2;
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.moveTo(-14 * s, 0);
  ctx.lineTo(-22 * s, (-7 + tw * 7) * s);
  ctx.lineTo(-22 * s, (7 + tw * 7) * s);
  ctx.closePath();
  ctx.fill();
  ctx.beginPath();
  ctx.ellipse(0, 0, 16 * s, 9 * s, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(8 * s, -2 * s, 2.5 * s, 0, Math.PI * 2);
  ctx.fillStyle = 'white';
  ctx.fill();
  ctx.beginPath();
  ctx.arc(8.5 * s, -2 * s, 1.2 * s, 0, Math.PI * 2);
  ctx.fillStyle = 'black';
  ctx.fill();
  ctx.restore();
}

function drawOrca(x, y, s, vx, swimTimer) {
  ctx.save();
  ctx.translate(x, y);
  if (vx < 0) ctx.scale(-1, 1);
  const sc = s * 0.5;
  const tw = Math.sin(swimTimer * 5) * 0.15;
  // Tail
  ctx.fillStyle = '#1A1A1A';
  ctx.beginPath();
  ctx.moveTo(-22 * sc, 0);
  ctx.lineTo(-34 * sc, (-10 + tw * 10) * sc);
  ctx.lineTo(-34 * sc, (10 + tw * 10) * sc);
  ctx.closePath();
  ctx.fill();
  // Body
  ctx.beginPath();
  ctx.ellipse(0, 0, 24 * sc, 12 * sc, 0, 0, Math.PI * 2);
  ctx.fill();
  // White belly
  ctx.fillStyle = '#FFFFFF';
  ctx.beginPath();
  ctx.ellipse(2 * sc, 4 * sc, 18 * sc, 6 * sc, 0, 0, Math.PI);
  ctx.fill();
  // Eye patch
  ctx.fillStyle = '#FFFFFF';
  ctx.beginPath();
  ctx.ellipse(10 * sc, -4 * sc, 5 * sc, 3 * sc, 0.2, 0, Math.PI * 2);
  ctx.fill();
  // Eye
  ctx.beginPath();
  ctx.arc(11 * sc, -4 * sc, 1.5 * sc, 0, Math.PI * 2);
  ctx.fillStyle = '#111';
  ctx.fill();
  // Dorsal fin
  ctx.fillStyle = '#1A1A1A';
  ctx.beginPath();
  ctx.moveTo(-2 * sc, -12 * sc);
  ctx.lineTo(4 * sc, -22 * sc);
  ctx.lineTo(8 * sc, -12 * sc);
  ctx.closePath();
  ctx.fill();
  ctx.restore();
}

function drawWhale(x, y, s, vx, swimTimer) {
  ctx.save();
  ctx.translate(x, y);
  if (vx < 0) ctx.scale(-1, 1);
  const sc = s * 0.4;
  const tw = Math.sin(swimTimer * 3) * 0.1;
  // Tail
  ctx.fillStyle = '#3A5A7A';
  ctx.beginPath();
  ctx.moveTo(-30 * sc, 0);
  ctx.lineTo(-45 * sc, (-12 + tw * 12) * sc);
  ctx.lineTo(-45 * sc, (12 + tw * 12) * sc);
  ctx.closePath();
  ctx.fill();
  // Body
  ctx.beginPath();
  ctx.ellipse(0, 0, 35 * sc, 16 * sc, 0, 0, Math.PI * 2);
  ctx.fillStyle = '#4A6A8A';
  ctx.fill();
  // Belly
  ctx.fillStyle = '#8AAABA';
  ctx.beginPath();
  ctx.ellipse(5 * sc, 6 * sc, 25 * sc, 8 * sc, 0, 0, Math.PI);
  ctx.fill();
  // Eye
  ctx.beginPath();
  ctx.arc(20 * sc, -4 * sc, 2 * sc, 0, Math.PI * 2);
  ctx.fillStyle = '#111';
  ctx.fill();
  // Mouth line
  ctx.strokeStyle = '#2A4A6A';
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(28 * sc, 2 * sc);
  ctx.quadraticCurveTo(32 * sc, 6 * sc, 25 * sc, 6 * sc);
  ctx.stroke();
  ctx.restore();
}

function drawMeat(x, y, s) {
  ctx.fillStyle = '#CC4444';
  ctx.beginPath();
  ctx.ellipse(x, y, 8 * s, 5 * s, 0.3, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#FFAAAA';
  ctx.beginPath();
  ctx.ellipse(x + 2 * s, y - 1 * s, 4 * s, 2 * s, 0.3, 0, Math.PI * 2);
  ctx.fill();
}
```

- [ ] **Step 4: Update entity AI for medium fish, orcas, whales**

Add cases to `updateEntities()`:

```javascript
    if (e.type === 'medfish') {
      e.swimTimer += FIXED_DT;
      e.turnTimer -= FIXED_DT;
      const dx = player.x - e.x;
      const dy = player.y - e.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < 200) {
        if (player.size > e.size * 1.3) {
          // Flee
          e.vx += (e.x - player.x) * 0.005;
          e.vy += (e.y - player.y) * 0.005;
        } else if (e.size > player.size * 1.3) {
          // Chase
          e.vx += dx * 0.003;
          e.vy += dy * 0.003;
        }
      } else if (e.turnTimer <= 0) {
        e.vx = (Math.random() - 0.5) * 2;
        e.vy = (Math.random() - 0.5) * 0.5;
        e.turnTimer = 3 + Math.random() * 4;
      }

      const maxSpd = 2;
      const spd = Math.sqrt(e.vx * e.vx + e.vy * e.vy);
      if (spd > maxSpd) { e.vx *= maxSpd / spd; e.vy *= maxSpd / spd; }
      e.x += e.vx;
      e.y += e.vy;
      if (e.x < 30 || e.x > WORLD_W - 30) e.vx *= -1;
      if (e.y < 30 || e.y > WORLD_H - 80) e.vy *= -1;
    }

    if (e.type === 'orca') {
      e.swimTimer += FIXED_DT;
      const dx = player.x - e.x;
      const dy = player.y - e.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < e.aggroRange) {
        e.vx += dx * 0.004;
        e.vy += dy * 0.004;
      } else {
        e.turnTimer -= FIXED_DT;
        if (e.turnTimer <= 0) {
          e.vx = (Math.random() - 0.5) * 3;
          e.vy = (Math.random() - 0.5) * 1;
          e.turnTimer = 4 + Math.random() * 4;
        }
      }
      const maxSpd = 2.5;
      const spd = Math.sqrt(e.vx * e.vx + e.vy * e.vy);
      if (spd > maxSpd) { e.vx *= maxSpd / spd; e.vy *= maxSpd / spd; }
      e.x += e.vx;
      e.y += e.vy;
      if (e.x < 30 || e.x > WORLD_W - 30) e.vx *= -1;
      if (e.y < 30 || e.y > WORLD_H - 80) e.vy *= -1;
    }

    if (e.type === 'whale') {
      e.swimTimer += FIXED_DT;
      e.turnTimer -= FIXED_DT;
      if (e.turnTimer <= 0) {
        e.vx = (Math.random() > 0.5 ? 0.3 : -0.3);
        e.vy = (Math.random() - 0.5) * 0.2;
        e.turnTimer = 6 + Math.random() * 8;
      }
      e.x += e.vx;
      e.y += e.vy;
      if (e.x < 60 || e.x > WORLD_W - 60) e.vx *= -1;
      if (e.y < 60 || e.y > WORLD_H - 100) e.vy *= -1;

      // Suck nearby small entities and player
      if (player.size < 1.5 && player.alive) {
        const dx = e.x + (e.vx > 0 ? 30 : -30) * e.size * 0.4 - player.x;
        const dy = e.y - player.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < e.suckRange && dist > 5) {
          player.x += dx / dist * e.suckForce;
          player.y += dy / dist * e.suckForce;
        }
      }
    }

    if (e.type === 'meat') {
      e.vy += 0.02; // slow sink
      e.vx *= 0.99; // friction
      e.x += e.vx;
      e.y += e.vy;
      if (e.y > WORLD_H - 65) { e.y = WORLD_H - 65; e.vy = 0; }
      e.lifetime -= FIXED_DT;
      if (e.lifetime <= 0) { e.health = 0; } // mark for removal
    }
```

- [ ] **Step 5: Update bite collision to handle meat chopping and drops**

In `updateBiteCollision`, when an entity's health reaches 0, check if it should drop meat:

Replace the entity death section inside `updateBiteCollision`:

```javascript
        if (e.health <= 0) {
          // Drop meat if entity has meatCount
          if (e.meatCount) {
            dropMeat(e.x, e.y, e.meatCount, e.size);
          }
          // Gain stats from eating (only if no meat drops — otherwise gain from eating the meat)
          if (!e.meatCount) {
            player.coins += e.coins;
            player.biteForce += e.bfGain;
            player.maxHealth += e.hpGain;
            player.health = Math.min(player.health + e.hpGain, player.maxHealth);
            player.size += e.sizeGain;
            localStorage.setItem('deepFeastCoins', player.coins);
          }
          entities.splice(i, 1);
        }
```

For meat that's too big to eat (meat size > player size * 0.8), biting chops it instead of eating it:

In the bite collision, before dealing damage, add a meat-chop check:

```javascript
      // Meat chopping: if meat is too big, break it down
      if (e.type === 'meat' && e.size > player.size * 0.8) {
        if (mouseHoldTime < FIXED_DT * 2) {
          // Chop: split into 2 smaller pieces
          const halfSize = e.size / 2;
          spawnMeat(e.x - 10, e.y, halfSize);
          spawnMeat(e.x + 10, e.y, halfSize);
          entities.splice(i, 1);
        }
        break;
      }
```

- [ ] **Step 6: Add medium fish, orcas, whales to initEntities**

```javascript
  // Medium fish
  for (let i = 0; i < 20; i++) {
    spawnMediumFish(200 + Math.random() * (WORLD_W - 400), 100 + Math.random() * (WORLD_H - 250));
  }
  // Orcas
  const orcaPositions = [[1000, 400], [2500, 300], [4000, 500], [5000, 350], [3000, 600]];
  for (const [ox, oy] of orcaPositions) { spawnOrca(ox, oy); }
  // Whales
  const whalePositions = [[1500, 450], [3500, 350], [5000, 500]];
  for (const [wx, wy] of whalePositions) { spawnWhale(wx, wy); }
```

- [ ] **Step 7: Add drawing cases for new entity types**

In the entity draw loop, add:

```javascript
    else if (e.type === 'medfish') drawMediumFish(sx, sy, e.size, e.vx, e.swimTimer || 0, e.color);
    else if (e.type === 'orca') drawOrca(sx, sy, e.size, e.vx, e.swimTimer || 0);
    else if (e.type === 'whale') drawWhale(sx, sy, e.size, e.vx, e.swimTimer || 0);
    else if (e.type === 'meat') drawMeat(sx, sy, e.size);
```

- [ ] **Step 8: Verify in browser**

Swim around the world. Medium fish flee if you're bigger, chase if you're smaller. Orcas chase you aggressively. Whales drift slowly and suck small things. Kill fish — they drop meat chunks. Bite big meat to chop it down. Eat small meat for stats.

- [ ] **Step 9: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add medium fish, orcas, whales, meat drops, and chopping"
```

---

### Task 6: Boss Fish — Megalodon & Mosasaurus

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Add megalodons (2-3 on map, aggressive, roam everywhere) and mosasaurus (2 on map, most dangerous). Killing one sets a localStorage flag that unlocks them in the shop. They respawn after a timer.

- [ ] **Step 1: Add spawn functions**

```javascript
function spawnMegalodon(x, y) {
  entities.push({
    type: 'megalodon', x, y,
    vx: (Math.random() > 0.5 ? 1 : -1) * 2, vy: 0,
    size: 4.0, health: 600, maxHealth: 600,
    coins: 80, bfGain: 5, hpGain: 8, sizeGain: 0.05,
    turnTimer: Math.random() * 5,
    swimTimer: 0, meatCount: 5,
    aggroRange: 500, damage: 40,
    respawnTime: 120, respawnX: x, respawnY: y
  });
}

function spawnMosasaurus(x, y) {
  entities.push({
    type: 'mosasaurus', x, y,
    vx: (Math.random() > 0.5 ? 1 : -1) * 2.5, vy: 0,
    size: 5.5, health: 1000, maxHealth: 1000,
    coins: 150, bfGain: 5, hpGain: 8, sizeGain: 0.08,
    turnTimer: Math.random() * 5,
    swimTimer: 0, meatCount: 5,
    aggroRange: 600, damage: 60,
    respawnTime: 180, respawnX: x, respawnY: y
  });
}
```

- [ ] **Step 2: Add drawing functions**

```javascript
function drawMegalodon(x, y, s, vx, swimTimer) {
  ctx.save();
  ctx.translate(x, y);
  if (vx < 0) ctx.scale(-1, 1);
  const sc = s * 0.35;
  const tw = Math.sin(swimTimer * 4) * 0.15;
  // Tail
  ctx.fillStyle = '#4A5A6A';
  ctx.beginPath();
  ctx.moveTo(-28 * sc, 0);
  ctx.lineTo(-42 * sc, (-14 + tw * 14) * sc);
  ctx.lineTo(-42 * sc, (14 + tw * 14) * sc);
  ctx.closePath();
  ctx.fill();
  // Body
  ctx.beginPath();
  ctx.ellipse(0, 0, 30 * sc, 14 * sc, 0, 0, Math.PI * 2);
  ctx.fillStyle = '#5A6A7A';
  ctx.fill();
  // Belly
  ctx.fillStyle = '#8A9AAA';
  ctx.beginPath();
  ctx.ellipse(4 * sc, 5 * sc, 22 * sc, 7 * sc, 0, 0, Math.PI);
  ctx.fill();
  // Dorsal fin
  ctx.fillStyle = '#4A5A6A';
  ctx.beginPath();
  ctx.moveTo(-4 * sc, -14 * sc);
  ctx.lineTo(6 * sc, -26 * sc);
  ctx.lineTo(12 * sc, -14 * sc);
  ctx.closePath();
  ctx.fill();
  // Jaw
  ctx.fillStyle = '#3A4A5A';
  ctx.beginPath();
  ctx.moveTo(22 * sc, 4 * sc);
  ctx.lineTo(32 * sc, 6 * sc);
  ctx.lineTo(22 * sc, 10 * sc);
  ctx.closePath();
  ctx.fill();
  // Teeth
  ctx.fillStyle = 'white';
  for (let t = 0; t < 5; t++) {
    ctx.beginPath();
    ctx.arc(24 * sc + t * 1.5 * sc, 5 * sc, 1 * sc, 0, Math.PI * 2);
    ctx.fill();
  }
  // Eye
  ctx.beginPath();
  ctx.arc(16 * sc, -3 * sc, 2.5 * sc, 0, Math.PI * 2);
  ctx.fillStyle = '#CC0000';
  ctx.fill();
  ctx.beginPath();
  ctx.arc(16.5 * sc, -3 * sc, 1.2 * sc, 0, Math.PI * 2);
  ctx.fillStyle = 'black';
  ctx.fill();
  ctx.restore();
}

function drawMosasaurus(x, y, s, vx, swimTimer) {
  ctx.save();
  ctx.translate(x, y);
  if (vx < 0) ctx.scale(-1, 1);
  const sc = s * 0.3;
  const tw = Math.sin(swimTimer * 3) * 0.12;
  // Long tail
  ctx.fillStyle = '#2A4A2A';
  ctx.beginPath();
  ctx.moveTo(-30 * sc, 0);
  ctx.quadraticCurveTo(-45 * sc, tw * 20 * sc, -55 * sc, tw * 15 * sc);
  ctx.quadraticCurveTo(-45 * sc, tw * 10 * sc + 5 * sc, -30 * sc, 4 * sc);
  ctx.closePath();
  ctx.fill();
  // Body (long, lizard-like)
  ctx.beginPath();
  ctx.ellipse(0, 0, 32 * sc, 12 * sc, 0, 0, Math.PI * 2);
  ctx.fillStyle = '#3A6A3A';
  ctx.fill();
  // Belly
  ctx.fillStyle = '#6A9A6A';
  ctx.beginPath();
  ctx.ellipse(5 * sc, 5 * sc, 24 * sc, 6 * sc, 0, 0, Math.PI);
  ctx.fill();
  // Flippers
  ctx.fillStyle = '#2A5A2A';
  ctx.beginPath();
  ctx.ellipse(-8 * sc, 10 * sc, 10 * sc, 3 * sc, 0.4, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.ellipse(8 * sc, 10 * sc, 10 * sc, 3 * sc, -0.4, 0, Math.PI * 2);
  ctx.fill();
  // Head (elongated snout)
  ctx.fillStyle = '#3A6A3A';
  ctx.beginPath();
  ctx.ellipse(26 * sc, -1 * sc, 12 * sc, 7 * sc, 0, 0, Math.PI * 2);
  ctx.fill();
  // Jaw with teeth
  ctx.fillStyle = '#2A4A2A';
  ctx.beginPath();
  ctx.moveTo(30 * sc, 2 * sc);
  ctx.lineTo(40 * sc, 3 * sc);
  ctx.lineTo(30 * sc, 6 * sc);
  ctx.closePath();
  ctx.fill();
  ctx.fillStyle = 'white';
  for (let t = 0; t < 6; t++) {
    ctx.beginPath();
    ctx.arc(31 * sc + t * 1.5 * sc, 3 * sc, 0.8 * sc, 0, Math.PI * 2);
    ctx.fill();
  }
  // Eye
  ctx.beginPath();
  ctx.arc(30 * sc, -3 * sc, 2.5 * sc, 0, Math.PI * 2);
  ctx.fillStyle = '#FFCC00';
  ctx.fill();
  ctx.beginPath();
  ctx.arc(30.5 * sc, -3 * sc, 1.2 * sc, 0, Math.PI * 2);
  ctx.fillStyle = 'black';
  ctx.fill();
  ctx.restore();
}
```

- [ ] **Step 3: Add AI for megalodon and mosasaurus**

Add to `updateEntities()`:

```javascript
    if (e.type === 'megalodon' || e.type === 'mosasaurus') {
      e.swimTimer += FIXED_DT;
      const dx = player.x - e.x;
      const dy = player.y - e.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < e.aggroRange && player.alive) {
        e.vx += dx * 0.003;
        e.vy += dy * 0.003;
      } else {
        e.turnTimer -= FIXED_DT;
        if (e.turnTimer <= 0) {
          e.vx = (Math.random() - 0.5) * 4;
          e.vy = (Math.random() - 0.5) * 1.5;
          e.turnTimer = 3 + Math.random() * 5;
        }
      }
      const maxSpd = e.type === 'mosasaurus' ? 3.0 : 2.8;
      const spd = Math.sqrt(e.vx * e.vx + e.vy * e.vy);
      if (spd > maxSpd) { e.vx *= maxSpd / spd; e.vy *= maxSpd / spd; }
      e.x += e.vx;
      e.y += e.vy;
      if (e.x < 80 || e.x > WORLD_W - 80) e.vx *= -1;
      if (e.y < 40 || e.y > WORLD_H - 100) e.vy *= -1;
    }
```

- [ ] **Step 4: Handle kill-to-unlock flags**

In `updateBiteCollision`, when a megalodon or mosasaurus dies, set localStorage flags:

After the `entities.splice(i, 1)` line, add:

```javascript
          if (e.type === 'megalodon') localStorage.setItem('deepFeastMegaKill', '1');
          if (e.type === 'mosasaurus') localStorage.setItem('deepFeastMosaKill', '1');
```

- [ ] **Step 5: Add enemy contact damage to player**

Add a new function:

```javascript
function updateEnemyDamage() {
  if (!player.alive) return;
  for (const e of entities) {
    if (!e.damage) continue; // only damaging entities
    const dx = player.x - e.x;
    const dy = player.y - e.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    const hitDist = (20 * player.size + 15 * e.size);
    if (dist < hitDist) {
      player.health -= e.damage * FIXED_DT; // damage per second on contact
      if (player.health <= 0) {
        player.health = 0;
        player.alive = false;
      }
    }
  }
}
```

Call `updateEnemyDamage()` in the fixed update loop.

- [ ] **Step 6: Add to initEntities and entity draw loop**

```javascript
  // Megalodons
  const megaPositions = [[800, 400], [3000, 300], [5200, 500]];
  for (const [mx, my] of megaPositions) { spawnMegalodon(mx, my); }
  // Mosasaurus
  const mosaPositions = [[2000, 500], [4500, 350]];
  for (const [mx, my] of mosaPositions) { spawnMosasaurus(mx, my); }
```

Drawing cases:
```javascript
    else if (e.type === 'megalodon') drawMegalodon(sx, sy, e.size, e.vx, e.swimTimer || 0);
    else if (e.type === 'mosasaurus') drawMosasaurus(sx, sy, e.size, e.vx, e.swimTimer || 0);
```

- [ ] **Step 7: Verify in browser**

Megalodons and mosasaurus roam the map and chase you. They deal damage on contact. Kill one (you need to be big/strong) — it drops 5 meat pieces. Check localStorage for kill flags.

- [ ] **Step 8: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add megalodon and mosasaurus bosses with kill-to-unlock"
```

---

### Task 7: Family System

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Player spawns with a family: 4 brothers (same size, 1.6x faster), 1 dad (slightly bigger), 1 mom (same size). Toggle follow with F key. Family members are cosmetic — they follow in loose formation but don't fight or progress.

- [ ] **Step 1: Add family state**

Add to GAME STATE:

```javascript
let family = [];
let familyActive = true;

function initFamily() {
  family = [];
  const s = player.size;
  // 4 brothers
  for (let i = 0; i < 4; i++) {
    family.push({ role: 'brother', x: player.x - 40 - i * 25, y: player.y + (i - 1.5) * 20, size: s, speedMult: 1.6, swimTimer: Math.random() * 5 });
  }
  // Dad (slightly bigger)
  family.push({ role: 'dad', x: player.x - 60, y: player.y - 30, size: s * 1.2, speedMult: 1.0, swimTimer: Math.random() * 5 });
  // Mom (same size)
  family.push({ role: 'mom', x: player.x - 60, y: player.y + 30, size: s * 1.0, speedMult: 1.0, swimTimer: Math.random() * 5 });
}
```

- [ ] **Step 2: Add F key toggle**

In the keydown handler, add:

```javascript
  if (e.code === 'KeyF') {
    familyActive = !familyActive;
  }
```

- [ ] **Step 3: Add family update**

```javascript
function updateFamily() {
  if (!player.alive) return;
  for (let i = 0; i < family.length; i++) {
    const f = family[i];
    f.swimTimer += FIXED_DT;

    if (familyActive) {
      // Follow player in a loose formation behind
      const offsetX = -30 - (i % 3) * 25;
      const offsetY = (i - family.length / 2) * 20;
      const targetX = player.x + (player.facingRight ? offsetX : -offsetX);
      const targetY = player.y + offsetY;
      const dx = targetX - f.x;
      const dy = targetY - f.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist > 5) {
        const spd = PLAYER_SPEED * f.speedMult;
        f.x += (dx / dist) * Math.min(spd, dist * 0.1);
        f.y += (dy / dist) * Math.min(spd, dist * 0.1);
      }
    } else {
      // Wander near their current position
      f.x += Math.sin(f.swimTimer * 2 + i) * 0.3;
      f.y += Math.cos(f.swimTimer * 1.5 + i) * 0.2;
    }

    f.x = Math.max(20, Math.min(WORLD_W - 20, f.x));
    f.y = Math.max(20, Math.min(WORLD_H - 80, f.y));
  }
}
```

- [ ] **Step 4: Draw family members**

In the draw section, after drawing entities and before drawing the player:

```javascript
  // Draw family
  for (const f of family) {
    const fx = f.x - camX;
    const fy = f.y - camY;
    if (fx < -60 || fx > CANVAS_W + 60 || fy < -60 || fy > CANVAS_H + 60) continue;
    const facingRight = f.x < player.x ? true : (f.x > player.x ? false : player.facingRight);
    drawPiranha(fx, fy, f.size, facingRight, f.swimTimer, 'normal', false, false, false);
  }
```

- [ ] **Step 5: Wire into game loop**

Add `updateFamily()` in the fixed update loop. Call `initFamily()` alongside `initEntities()` at startup.

- [ ] **Step 6: Verify in browser**

Start the game — 4 small brothers, a slightly bigger dad, and a same-size mom follow you. Press F to toggle them off (they wander in place). Press F again and they follow you. Brothers are noticeably faster.

- [ ] **Step 7: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add family system — 4 brothers, dad, mom, F to toggle"
```

---

### Task 8: HUD — Coins, Sprint Bar, Stats, Health

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Draw the HUD on the canvas: coins (top-left), sprint bar (top-right), stats (bottom-left with health bar).

- [ ] **Step 1: Add drawHUD function**

```javascript
function drawHUD() {
  ctx.save();

  // Coins (top-left)
  ctx.fillStyle = 'rgba(0,0,0,0.4)';
  ctx.beginPath();
  ctx.roundRect(10, 10, 100, 30, 8);
  ctx.fill();
  ctx.font = 'bold 16px sans-serif';
  ctx.fillStyle = '#FFD700';
  ctx.textAlign = 'left';
  ctx.fillText('\u{1FA99} ' + player.coins, 20, 31);

  // Sprint bar (top-right)
  ctx.fillStyle = 'rgba(0,0,0,0.4)';
  ctx.beginPath();
  ctx.roundRect(CANVAS_W - 140, 10, 130, 30, 8);
  ctx.fill();
  ctx.font = '11px sans-serif';
  ctx.fillStyle = 'rgba(255,255,255,0.7)';
  ctx.textAlign = 'left';
  ctx.fillText('Sprint', CANVAS_W - 130, 23);
  // Bar
  const barX = CANVAS_W - 130;
  const barY = 27;
  const barW = 110;
  const barH = 7;
  ctx.fillStyle = 'rgba(0,0,0,0.3)';
  ctx.beginPath();
  ctx.roundRect(barX, barY, barW, barH, 3);
  ctx.fill();
  const pct = player.staminaLeft / SPRINT_MAX;
  if (pct > 0) {
    const grad = ctx.createLinearGradient(barX, 0, barX + barW * pct, 0);
    grad.addColorStop(0, player.sprinting ? '#FF8800' : '#00BFFF');
    grad.addColorStop(1, player.sprinting ? '#FF4400' : '#00FF88');
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.roundRect(barX, barY, barW * pct, barH, 3);
    ctx.fill();
  }

  // Stats (bottom-left)
  ctx.fillStyle = 'rgba(0,0,0,0.4)';
  ctx.beginPath();
  ctx.roundRect(10, CANVAS_H - 50, 200, 40, 8);
  ctx.fill();

  ctx.font = '12px sans-serif';
  ctx.fillStyle = 'white';
  ctx.textAlign = 'left';
  ctx.fillText('Bite: ' + Math.floor(player.biteForce), 20, CANVAS_H - 32);

  // Health bar
  ctx.fillText('HP', 20, CANVAS_H - 17);
  const hpX = 42;
  const hpY = CANVAS_H - 25;
  const hpW = 100;
  const hpH = 10;
  ctx.fillStyle = 'rgba(0,0,0,0.3)';
  ctx.beginPath();
  ctx.roundRect(hpX, hpY, hpW, hpH, 3);
  ctx.fill();
  const hpPct = player.health / player.maxHealth;
  ctx.fillStyle = hpPct > 0.5 ? '#44CC44' : (hpPct > 0.25 ? '#CCAA22' : '#CC3333');
  ctx.beginPath();
  ctx.roundRect(hpX, hpY, hpW * hpPct, hpH, 3);
  ctx.fill();

  ctx.font = '10px sans-serif';
  ctx.fillStyle = '#AAAAAA';
  ctx.fillText(Math.floor(player.health) + '/' + Math.floor(player.maxHealth), hpX + hpW + 8, CANVAS_H - 16);

  // Family indicator
  if (familyActive) {
    ctx.font = '11px sans-serif';
    ctx.fillStyle = '#88CCFF';
    ctx.fillText('Family: ON', 155, CANVAS_H - 32);
  }

  ctx.restore();
}
```

- [ ] **Step 2: Call drawHUD at the end of the draw section**

After all game drawing, before `requestAnimationFrame`:

```javascript
  drawHUD();
```

- [ ] **Step 3: Verify in browser**

HUD should show coins top-left, sprint bar top-right (drains when sprinting, recharges when not), bite force and health bar bottom-left. Family status shown.

- [ ] **Step 4: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add HUD — coins, sprint bar, stats, health bar"
```

---

### Task 9: Death, Respawn, and Death Menu

**Files:**
- Modify: `deep-feast/index.html`

**Context:** When health reaches 0, show a death screen with coins earned, Retry and Shop buttons. Retry respawns the player small. Shop opens fish selection. Coins and unlocks persist.

- [ ] **Step 1: Add game states**

Add to GAME STATE:

```javascript
const STATE_PLAYING = 0;
const STATE_DEAD = 1;
const STATE_SHOP = 2;
let gameState = STATE_PLAYING;
let coinsThisRun = 0;
```

Track coins earned per run — in `updateBiteCollision`, where `player.coins += e.coins`, also add `coinsThisRun += e.coins`.

- [ ] **Step 2: Trigger death state**

When `player.alive` becomes false (in `updateEnemyDamage`), set `gameState = STATE_DEAD`.

- [ ] **Step 3: Add death menu drawing**

```javascript
function drawDeathMenu() {
  ctx.fillStyle = 'rgba(0,0,0,0.5)';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  const panelW = 260;
  const panelH = 200;
  const panelX = (CANVAS_W - panelW) / 2;
  const panelY = (CANVAS_H - panelH) / 2 - 20;

  ctx.fillStyle = 'rgba(20,30,50,0.9)';
  ctx.beginPath();
  ctx.roundRect(panelX, panelY, panelW, panelH, 12);
  ctx.fill();
  ctx.strokeStyle = 'rgba(255,255,255,0.15)';
  ctx.lineWidth = 2;
  ctx.stroke();

  ctx.save();
  ctx.textAlign = 'center';

  ctx.font = 'bold 24px sans-serif';
  ctx.fillStyle = '#CC4444';
  ctx.fillText('You Got Eaten!', CANVAS_W / 2, panelY + 35);

  ctx.font = '14px sans-serif';
  ctx.fillStyle = '#FFD700';
  ctx.fillText('Coins earned: ' + coinsThisRun, CANVAS_W / 2, panelY + 65);

  ctx.font = '13px sans-serif';
  ctx.fillStyle = '#AAAAAA';
  ctx.fillText('Total: ' + player.coins + ' coins', CANVAS_W / 2, panelY + 85);

  // Buttons
  const btnW = 180;
  const btnH = 32;
  const btnX = (CANVAS_W - btnW) / 2;

  // Retry
  ctx.fillStyle = '#44AA44';
  ctx.beginPath();
  ctx.roundRect(btnX, panelY + 105, btnW, btnH, 6);
  ctx.fill();
  ctx.font = 'bold 16px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText('Retry', CANVAS_W / 2, panelY + 127);

  // Shop
  ctx.fillStyle = '#AA8844';
  ctx.beginPath();
  ctx.roundRect(btnX, panelY + 145, btnW, btnH, 6);
  ctx.fill();
  ctx.font = 'bold 16px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText('Shop', CANVAS_W / 2, panelY + 167);

  ctx.restore();
}
```

- [ ] **Step 4: Add click handling for death menu**

Add a `getClickPos` and `hitBtn` helper (same pattern as Mountain Hawk), and update the mouse/touch handlers to check game state:

```javascript
function getClickPos(e) {
  const rect = canvas.getBoundingClientRect();
  const scaleX = CANVAS_W / rect.width;
  const scaleY = CANVAS_H / rect.height;
  if (e.touches) {
    return { x: (e.touches[0].clientX - rect.left) * scaleX, y: (e.touches[0].clientY - rect.top) * scaleY };
  }
  return { x: (e.clientX - rect.left) * scaleX, y: (e.clientY - rect.top) * scaleY };
}

function hitBtn(pos, bx, by, bw, bh) {
  return pos.x >= bx && pos.x <= bx + bw && pos.y >= by && pos.y <= by + bh;
}
```

In the mousedown/touchstart handler, before setting `mouseDown = true`, check:

```javascript
  if (gameState === STATE_DEAD) {
    const pos = getClickPos(e);
    const panelW = 260;
    const panelH = 200;
    const panelY = (CANVAS_H - panelH) / 2 - 20;
    const btnW = 180;
    const btnX = (CANVAS_W - btnW) / 2;
    if (hitBtn(pos, btnX, panelY + 105, btnW, 32)) { respawnPlayer(); return; }
    if (hitBtn(pos, btnX, panelY + 145, btnW, 32)) { gameState = STATE_SHOP; return; }
    return;
  }
```

- [ ] **Step 5: Add respawn function**

```javascript
function respawnPlayer() {
  player.x = 300;
  player.y = 400;
  player.size = 1.0;
  player.biteForce = 10;
  player.maxHealth = 100;
  player.health = 100;
  player.alive = true;
  player.sprinting = false;
  player.staminaLeft = SPRINT_MAX;
  coinsThisRun = 0;
  gameState = STATE_PLAYING;
  initEntities();
  initFamily();
}
```

- [ ] **Step 6: Wire into game loop**

Only run game updates when `gameState === STATE_PLAYING`. Draw the death menu when `gameState === STATE_DEAD`. Draw the HUD only during playing.

- [ ] **Step 7: Verify in browser**

Let a big fish kill you. Death screen shows with coins earned and total. Click Retry to restart small with coins kept. Click Shop (goes to empty shop screen for now).

- [ ] **Step 8: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add death screen with retry and shop buttons"
```

---

### Task 10: Shop — Fish Selection

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Shop screen where you can buy/select fish. Piranha is free (2 skins). Bass, Whale, Megalodon, Mosasaurus cost coins and some require kill flags. Selected fish changes your starting fish type on respawn.

- [ ] **Step 1: Add shop data and state**

```javascript
// ============================================================
// SHOP
// ============================================================
const SHOP_FISH = [
  { name: 'Piranha', cost: 0, requireKill: null, skins: ['normal', 'skeleton'] },
  { name: 'Bass', cost: 50, requireKill: null, skins: ['normal'] },
  { name: 'Whale', cost: 150, requireKill: null, skins: ['normal'], special: 'suck' },
  { name: 'Megalodon', cost: 200, requireKill: 'deepFeastMegaKill', skins: ['normal'] },
  { name: 'Mosasaurus', cost: 500, requireKill: 'deepFeastMosaKill', skins: ['normal'] }
];

let selectedFish = parseInt(localStorage.getItem('deepFeastFish')) || 0;
let selectedSkin = parseInt(localStorage.getItem('deepFeastSkin')) || 0;
let ownedFish = JSON.parse(localStorage.getItem('deepFeastOwned') || '[0]'); // array of indices
```

- [ ] **Step 2: Add shop drawing function**

```javascript
function drawShop() {
  ctx.fillStyle = 'rgba(0,0,0,0.6)';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  ctx.save();
  ctx.textAlign = 'center';
  ctx.font = 'bold 28px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText('Fish Shop', CANVAS_W / 2, 45);

  ctx.font = '14px sans-serif';
  ctx.fillStyle = '#FFD700';
  ctx.fillText('Coins: ' + player.coins, CANVAS_W / 2, 70);

  const cardW = 250;
  const cardH = 55;
  const startX = (CANVAS_W - cardW) / 2;
  const startY = 90;
  const gap = 62;

  for (let i = 0; i < SHOP_FISH.length; i++) {
    const fish = SHOP_FISH[i];
    const cy = startY + i * gap;
    const owned = ownedFish.includes(i);
    const selected = i === selectedFish;
    const canBuy = !owned && player.coins >= fish.cost && (!fish.requireKill || localStorage.getItem(fish.requireKill));
    const locked = !owned && fish.requireKill && !localStorage.getItem(fish.requireKill);

    // Card
    ctx.fillStyle = selected ? 'rgba(80,120,180,0.8)' : 'rgba(40,40,60,0.8)';
    ctx.beginPath();
    ctx.roundRect(startX, cy, cardW, cardH, 8);
    ctx.fill();
    if (selected) {
      ctx.strokeStyle = '#88BBFF';
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    // Name
    ctx.textAlign = 'left';
    ctx.font = 'bold 15px sans-serif';
    ctx.fillStyle = locked ? '#666666' : 'white';
    ctx.fillText(fish.name, startX + 15, cy + 22);

    // Status
    ctx.font = '12px sans-serif';
    if (owned && selected) {
      ctx.fillStyle = '#88FF88';
      ctx.fillText('Selected', startX + 15, cy + 40);
    } else if (owned) {
      ctx.fillStyle = '#88AACC';
      ctx.fillText('Owned — click to select', startX + 15, cy + 40);
    } else if (locked) {
      ctx.fillStyle = '#CC6666';
      ctx.fillText('Kill one to unlock', startX + 15, cy + 40);
    } else if (canBuy) {
      ctx.fillStyle = '#FFD700';
      ctx.fillText('Buy — ' + fish.cost + ' coins', startX + 15, cy + 40);
    } else {
      ctx.fillStyle = '#888888';
      ctx.fillText(fish.cost + ' coins (not enough)', startX + 15, cy + 40);
    }

    // Skin toggle for piranha
    if (i === 0 && owned) {
      ctx.textAlign = 'right';
      ctx.font = '11px sans-serif';
      ctx.fillStyle = '#AAAAAA';
      ctx.fillText('Skin: ' + SHOP_FISH[0].skins[selectedSkin], startX + cardW - 15, cy + 22);
    }
  }

  // Back button
  ctx.textAlign = 'center';
  const backW = 120;
  const backH = 32;
  const backX = (CANVAS_W - backW) / 2;
  const backY = CANVAS_H - 60;
  ctx.fillStyle = '#666677';
  ctx.beginPath();
  ctx.roundRect(backX, backY, backW, backH, 6);
  ctx.fill();
  ctx.font = 'bold 15px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText('Back', CANVAS_W / 2, backY + 22);

  ctx.restore();
}
```

- [ ] **Step 3: Add shop click handling**

```javascript
function handleShopClick(pos) {
  const cardW = 250;
  const cardH = 55;
  const startX = (CANVAS_W - cardW) / 2;
  const startY = 90;
  const gap = 62;

  for (let i = 0; i < SHOP_FISH.length; i++) {
    const cy = startY + i * gap;
    if (hitBtn(pos, startX, cy, cardW, cardH)) {
      const fish = SHOP_FISH[i];
      const owned = ownedFish.includes(i);

      if (owned) {
        selectedFish = i;
        localStorage.setItem('deepFeastFish', selectedFish);
        // Skin toggle for piranha
        if (i === 0) {
          selectedSkin = (selectedSkin + 1) % SHOP_FISH[0].skins.length;
          localStorage.setItem('deepFeastSkin', selectedSkin);
        }
      } else {
        const canBuy = player.coins >= fish.cost && (!fish.requireKill || localStorage.getItem(fish.requireKill));
        if (canBuy) {
          player.coins -= fish.cost;
          ownedFish.push(i);
          selectedFish = i;
          localStorage.setItem('deepFeastCoins', player.coins);
          localStorage.setItem('deepFeastOwned', JSON.stringify(ownedFish));
          localStorage.setItem('deepFeastFish', selectedFish);
        }
      }
      return;
    }
  }

  // Back
  const backW = 120;
  const backH = 32;
  const backX = (CANVAS_W - backW) / 2;
  const backY = CANVAS_H - 60;
  if (hitBtn(pos, backX, backY, backW, backH)) {
    gameState = STATE_DEAD;
  }
}
```

Wire into the click handler: when `gameState === STATE_SHOP`, call `handleShopClick(pos)`.

- [ ] **Step 4: Wire shop drawing into game loop**

```javascript
  if (gameState === STATE_SHOP) {
    drawShop();
  }
```

- [ ] **Step 5: Update respawn to use selected fish**

In `respawnPlayer()`, set starting size based on selected fish:

```javascript
  const fishData = SHOP_FISH[selectedFish];
  player.size = [1.0, 1.3, 2.5, 2.8, 3.5][selectedFish]; // starting sizes
  player.biteForce = [10, 15, 20, 35, 50][selectedFish];
  player.maxHealth = [100, 150, 300, 500, 800][selectedFish];
  player.health = player.maxHealth;
```

- [ ] **Step 6: Verify in browser**

Die, click Shop. See the fish list with prices. Buy Bass (if you have 50 coins). Select it. Retry — you start bigger. Piranha shows skin toggle. Megalodon/Mosasaurus locked until you kill one.

- [ ] **Step 7: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add fish shop with 5 fish, skins, kill-to-unlock"
```

---

### Task 11: Bubbles, Ambient Audio

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Add ambient bubbles floating up and procedural underwater audio: ambient underwater drone, bite crunch, coin chime, sprint whoosh, damage thud, death rumble.

- [ ] **Step 1: Add bubble particles**

```javascript
let bubbles = [];

function initBubbles() {
  bubbles = [];
  for (let i = 0; i < 30; i++) {
    bubbles.push({
      x: Math.random() * WORLD_W,
      y: Math.random() * WORLD_H,
      r: 1 + Math.random() * 3,
      speed: 0.3 + Math.random() * 0.8,
      wobble: Math.random() * Math.PI * 2
    });
  }
}

function updateBubbles() {
  for (const b of bubbles) {
    b.y -= b.speed;
    b.x += Math.sin(b.wobble) * 0.3;
    b.wobble += 0.03;
    if (b.y < -10) {
      b.y = WORLD_H + 10;
      b.x = Math.random() * WORLD_W;
    }
  }
}

function drawBubbles() {
  for (const b of bubbles) {
    const sx = b.x - camX;
    const sy = b.y - camY;
    if (sx < -10 || sx > CANVAS_W + 10 || sy < -10 || sy > CANVAS_H + 10) continue;
    ctx.beginPath();
    ctx.arc(sx, sy, b.r, 0, Math.PI * 2);
    ctx.strokeStyle = 'rgba(255,255,255,0.25)';
    ctx.lineWidth = 0.8;
    ctx.stroke();
    ctx.fillStyle = 'rgba(255,255,255,0.06)';
    ctx.fill();
  }
}
```

- [ ] **Step 2: Add audio system**

```javascript
// ============================================================
// AUDIO
// ============================================================
let audioCtx = null;

function initAudio() {
  if (audioCtx) return;
  audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  startUnderwaterAmbient();
}

function startUnderwaterAmbient() {
  const bufSize = audioCtx.sampleRate * 2;
  const buf = audioCtx.createBuffer(1, bufSize, audioCtx.sampleRate);
  const data = buf.getChannelData(0);
  for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;
  const src = audioCtx.createBufferSource();
  src.buffer = buf;
  src.loop = true;
  const filter = audioCtx.createBiquadFilter();
  filter.type = 'lowpass';
  filter.frequency.value = 300;
  const gain = audioCtx.createGain();
  gain.gain.value = 0.06;
  src.connect(filter);
  filter.connect(gain);
  gain.connect(audioCtx.destination);
  src.start();
}

function playBite() {
  if (!audioCtx) return;
  const bufSize = audioCtx.sampleRate * 0.08;
  const buf = audioCtx.createBuffer(1, bufSize, audioCtx.sampleRate);
  const data = buf.getChannelData(0);
  for (let i = 0; i < bufSize; i++) data[i] = (Math.random() * 2 - 1) * (1 - i / bufSize);
  const src = audioCtx.createBufferSource();
  src.buffer = buf;
  const filter = audioCtx.createBiquadFilter();
  filter.type = 'bandpass';
  filter.frequency.value = 600;
  const gain = audioCtx.createGain();
  gain.gain.value = 0.2;
  src.connect(filter);
  filter.connect(gain);
  gain.connect(audioCtx.destination);
  src.start();
}

function playCoin() {
  if (!audioCtx) return;
  const osc = audioCtx.createOscillator();
  osc.type = 'sine';
  osc.frequency.value = 1000;
  const gain = audioCtx.createGain();
  gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.2);
  osc.connect(gain);
  gain.connect(audioCtx.destination);
  osc.start();
  osc.stop(audioCtx.currentTime + 0.2);
}

function playDamage() {
  if (!audioCtx) return;
  const bufSize = audioCtx.sampleRate * 0.1;
  const buf = audioCtx.createBuffer(1, bufSize, audioCtx.sampleRate);
  const data = buf.getChannelData(0);
  for (let i = 0; i < bufSize; i++) data[i] = (Math.random() * 2 - 1) * (1 - i / bufSize);
  const src = audioCtx.createBufferSource();
  src.buffer = buf;
  const filter = audioCtx.createBiquadFilter();
  filter.type = 'lowpass';
  filter.frequency.value = 200;
  const gain = audioCtx.createGain();
  gain.gain.value = 0.25;
  src.connect(filter);
  filter.connect(gain);
  gain.connect(audioCtx.destination);
  src.start();
}
```

- [ ] **Step 3: Wire audio into game actions**

- Call `initAudio()` on first click/keydown
- Call `playBite()` when a bite lands in `updateBiteCollision`
- Call `playCoin()` when coins are gained
- Call `playDamage()` when player takes damage in `updateEnemyDamage`

- [ ] **Step 4: Wire bubbles into game loop**

Call `initBubbles()` at startup. `updateBubbles()` in the fixed update loop. `drawBubbles()` after entities, before HUD.

- [ ] **Step 5: Verify in browser**

Bubbles float up gently. Underwater ambient plays. Bite makes a crunch sound. Coins chime. Taking damage thuds.

- [ ] **Step 6: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add bubbles and procedural underwater audio"
```

---

### Task 12: Entity Respawning + Polish

**Files:**
- Modify: `deep-feast/index.html`

**Context:** Add respawn timers for orcas, whales, megalodons, mosasaurus. Add entity health bars for big fish. Add a title screen. General polish.

- [ ] **Step 1: Add respawn system**

```javascript
let respawnQueue = []; // {type, x, y, timer}

function queueRespawn(entity) {
  if (entity.respawnTime) {
    respawnQueue.push({
      type: entity.type,
      x: entity.respawnX,
      y: entity.respawnY,
      timer: entity.respawnTime
    });
  }
}

function updateRespawns() {
  for (let i = respawnQueue.length - 1; i >= 0; i--) {
    respawnQueue[i].timer -= FIXED_DT;
    if (respawnQueue[i].timer <= 0) {
      const r = respawnQueue[i];
      if (r.type === 'orca') spawnOrca(r.x, r.y);
      else if (r.type === 'whale') spawnWhale(r.x, r.y);
      else if (r.type === 'megalodon') spawnMegalodon(r.x, r.y);
      else if (r.type === 'mosasaurus') spawnMosasaurus(r.x, r.y);
      respawnQueue.splice(i, 1);
    }
  }
}
```

In `updateBiteCollision`, when killing an entity with `respawnTime`, call `queueRespawn(e)` before splicing.

Call `updateRespawns()` in the fixed update loop.

- [ ] **Step 2: Add health bars for large entities**

After drawing each entity, if it has health < maxHealth and is an orca/whale/megalodon/mosasaurus, draw a small health bar above it:

```javascript
function drawEntityHealthBar(sx, sy, entity) {
  if (entity.health >= entity.maxHealth) return;
  if (!['orca', 'whale', 'megalodon', 'mosasaurus'].includes(entity.type)) return;
  const barW = 30 * entity.size * 0.3;
  const barH = 3;
  const bx = sx - barW / 2;
  const by = sy - 18 * entity.size * 0.4;
  ctx.fillStyle = 'rgba(0,0,0,0.5)';
  ctx.fillRect(bx, by, barW, barH);
  const pct = entity.health / entity.maxHealth;
  ctx.fillStyle = pct > 0.5 ? '#44CC44' : (pct > 0.25 ? '#CCAA22' : '#CC3333');
  ctx.fillRect(bx, by, barW * pct, barH);
}
```

Call it after drawing each entity in the draw loop.

- [ ] **Step 3: Add title screen**

```javascript
let gameStarted = false;

function drawTitleScreen() {
  drawOceanBackground();
  drawOceanFloor();
  drawBubbles();

  ctx.fillStyle = 'rgba(0,0,0,0.3)';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  ctx.save();
  ctx.textAlign = 'center';

  ctx.font = 'bold 42px sans-serif';
  ctx.fillStyle = '#22AAFF';
  ctx.shadowColor = 'rgba(0,0,0,0.5)';
  ctx.shadowBlur = 8;
  ctx.fillText('Deep Feast', CANVAS_W / 2, CANVAS_H / 2 - 40);

  ctx.shadowBlur = 0;
  ctx.font = '16px sans-serif';
  ctx.fillStyle = '#CCDDEE';
  ctx.fillText('Eat. Grow. Survive.', CANVAS_W / 2, CANVAS_H / 2);

  ctx.font = '14px sans-serif';
  ctx.fillStyle = '#8899AA';
  ctx.fillText('Click or press any key to start', CANVAS_W / 2, CANVAS_H / 2 + 40);

  ctx.font = '11px sans-serif';
  ctx.fillStyle = '#556677';
  ctx.fillText('WASD to swim \u00B7 Shift to sprint \u00B7 Click to bite \u00B7 F for family', CANVAS_W / 2, CANVAS_H / 2 + 70);

  ctx.restore();
}
```

Show title screen before game starts. First click/key starts the game.

- [ ] **Step 4: Add clam/seashell/clownfish respawning**

In `updateEntities`, periodically check if food entities are running low and spawn more:

```javascript
function replenishFood() {
  let clamCount = 0, clownCount = 0;
  for (const e of entities) {
    if (e.type === 'clam' || e.type === 'seashell') clamCount++;
    if (e.type === 'clownfish') clownCount++;
  }
  if (clamCount < 30) {
    const x = Math.random() * WORLD_W;
    if (Math.random() > 0.5) spawnClam(x, WORLD_H - 70 + Math.random() * 10);
    else spawnSeashell(x, WORLD_H - 68 + Math.random() * 8);
  }
  if (clownCount < 40) {
    spawnClownfish(Math.random() * WORLD_W, 100 + Math.random() * (WORLD_H - 250));
  }
}
```

Call `replenishFood()` once every 60 frames (add a counter).

- [ ] **Step 5: Verify full game flow**

1. Title screen — "Deep Feast", click to start
2. Swimming with piranha, family follows
3. Eat clams, seashells, clownfish — coins and stats grow
4. Medium fish flee or chase depending on size
5. Orcas chase aggressively
6. Whales suck small fish
7. Megalodons and mosasaurus roam and attack
8. Bite mechanic: hold click, yellow when in range, 2s charge
9. Sprint toggle with Shift
10. Kill fish → meat drops → chop if too big → eat
11. Die → death menu → retry or shop
12. Shop: buy fish, select fish, skin toggle for piranha
13. Respawns: big fish come back after timers
14. Food replenishes

- [ ] **Step 6: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add respawning, health bars, title screen, food replenishment"
```

---

## Summary

| Task | Description | Key Output |
|------|-------------|------------|
| 1 | Scaffold + camera | Canvas, ocean background, camera system |
| 2 | Player fish | Piranha with movement, sprint, swim animation |
| 3 | Bite mechanic | Hold click, charge, yellow indicator, range arc |
| 4 | Food entities | Clams, seashells, clownfish, eating for stats/coins |
| 5 | Medium fish + orcas + whales | AI behaviors, meat drops, chopping |
| 6 | Boss fish | Megalodon, mosasaurus, kill-to-unlock |
| 7 | Family system | 4 brothers, dad, mom, F toggle |
| 8 | HUD | Coins, sprint bar, bite force, health bar |
| 9 | Death + respawn | Death menu, retry, coins persist |
| 10 | Shop | 5 fish, skins, buy/select, kill requirements |
| 11 | Bubbles + audio | Ambient particles, procedural sounds |
| 12 | Polish | Respawning, health bars, title, food replenish |

Each task produces a progressively more complete game. After Task 4 you can eat things. After Task 6 there are real threats. After Task 10 there's full progression.

---

### Task 13: Bite Latch Mechanic

**Files:**
- Modify: `deep-feast/index.html`

**Context:** When the player's bite lands on an enemy, the fish latches on and deals continuous damage. The player moves with the enemy while latched. Click again or wait ~2s to release. Taking damage from another source forces release.

- [ ] **Step 1: Add latch state to player**

```javascript
  latchTarget: null, // reference to entity being latched onto
  latchTimer: 0,     // time spent latched
  latchMaxTime: 2.0, // auto-release after 2 seconds
  latchOffsetX: 0,
  latchOffsetY: 0,
```

- [ ] **Step 2: Modify bite collision to trigger latch**

In `updateBiteCollision`, when a bite lands on an entity that isn't a clam/seashell/meat (i.e., a living fish), instead of just dealing damage once, set `player.latchTarget = e` and record the offset. Don't deal the initial damage — the latch deals continuous damage instead.

```javascript
      // Latch onto living fish (not clams/seashells/meat)
      if (!['clam', 'seashell', 'meat'].includes(e.type) && mouseHoldTime < FIXED_DT * 2 && !player.latchTarget) {
        player.latchTarget = e;
        player.latchTimer = 0;
        player.latchOffsetX = player.x - e.x;
        player.latchOffsetY = player.y - e.y;
        playBite();
        break;
      }
```

- [ ] **Step 3: Add latch update function**

```javascript
function updateLatch() {
  if (!player.latchTarget || !player.alive) return;
  const e = player.latchTarget;

  // Check if target is still alive and in entities
  if (!entities.includes(e) || e.health <= 0) {
    player.latchTarget = null;
    return;
  }

  // Move with target
  player.x = e.x + player.latchOffsetX;
  player.y = e.y + player.latchOffsetY;

  // Deal continuous damage
  const dps = player.biteCharged ? player.biteForce * BITE_DAMAGE_MULT : player.biteForce;
  e.health -= dps * FIXED_DT;

  player.latchTimer += FIXED_DT;

  // Auto-release after max time
  if (player.latchTimer >= player.latchMaxTime) {
    player.latchTarget = null;
  }

  // Release on second click
  if (!mouseDown && player.latchTimer > 0.2) {
    player.latchTarget = null;
  }

  // Kill target if health depleted
  if (e.health <= 0) {
    if (e.meatCount) dropMeat(e.x, e.y, e.meatCount, e.size);
    if (!e.meatCount) {
      player.coins += e.coins;
      player.biteForce += e.bfGain;
      player.maxHealth += e.hpGain;
      player.health = Math.min(player.health + e.hpGain, player.maxHealth);
      player.size += e.sizeGain;
      localStorage.setItem('deepFeastCoins', player.coins);
    }
    if (e.type === 'megalodon') localStorage.setItem('deepFeastMegaKill', '1');
    if (e.type === 'mosasaurus') localStorage.setItem('deepFeastMosaKill', '1');
    if (e.respawnTime) queueRespawn(e);
    entities.splice(entities.indexOf(e), 1);
    player.latchTarget = null;
  }
}
```

- [ ] **Step 4: Force release when player takes damage**

In `updateEnemyDamage`, when the player takes damage, add:

```javascript
      player.latchTarget = null; // force release on taking damage
```

- [ ] **Step 5: Call updateLatch in game loop**

Add `updateLatch()` after `updateBiteCollision()` in the fixed update.

- [ ] **Step 6: Verify in browser**

Bite a medium fish — you latch on and ride it while dealing damage. After 2 seconds or clicking again, you release. Getting hit by another fish forces release. Latching onto a boss gradually wears it down.

- [ ] **Step 7: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add bite latch — attach to enemies and deal continuous damage"
```

---

### Task 14: Fish-vs-Fish AI Combat

**Files:**
- Modify: `deep-feast/index.html`

**Context:** AI fish fight each other. Bigger fish attack smaller ones nearby. When a fish kills another, it drops meat. Winners may eat the meat or move on — leaving it for the player to steal.

- [ ] **Step 1: Add fish-vs-fish combat function**

```javascript
function updateFishCombat() {
  for (let i = entities.length - 1; i >= 0; i--) {
    const a = entities[i];
    if (!a || !['medfish', 'orca', 'megalodon', 'mosasaurus'].includes(a.type)) continue;

    for (let j = entities.length - 1; j >= 0; j--) {
      if (i === j) continue;
      const b = entities[j];
      if (!b || b.type === 'meat' || b.type === 'clam' || b.type === 'seashell') continue;

      const dx = a.x - b.x;
      const dy = a.y - b.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      const contactDist = 15 * a.size + 15 * b.size;

      if (dist < contactDist && a.size > b.size * 1.3) {
        // a eats b — deal damage per frame
        b.health -= a.size * 2 * FIXED_DT;

        if (b.health <= 0) {
          // b dies — drop meat
          if (b.meatCount) {
            dropMeat(b.x, b.y, b.meatCount, b.size);
          } else {
            // Small fish drop 1 small meat
            spawnMeat(b.x, b.y, b.size * 0.5);
          }
          entities.splice(j, 1);
          if (j < i) i--; // adjust index
          break;
        }
      }
    }
  }
}
```

- [ ] **Step 2: Call in game loop**

Add `updateFishCombat()` in the fixed update, after `updateEntities()`.

- [ ] **Step 3: Verify in browser**

Watch the ocean — bigger fish chase and eat smaller ones. Meat drops from kills. Swim over to steal unclaimed meat. The world feels alive with predator-prey dynamics.

- [ ] **Step 4: Commit**

```bash
git add deep-feast/index.html
git commit -m "feat: add fish-vs-fish AI combat — predators eat prey, drop meat"
```

---

## Updated Summary

| Task | Description | Key Output |
|------|-------------|------------|
| 1 | Scaffold + camera | Canvas, ocean background, camera system |
| 2 | Player fish | Piranha with movement, sprint, swim animation |
| 3 | Bite mechanic | Hold click, charge, yellow indicator, range arc |
| 4 | Food entities | Clams, seashells, clownfish, eating for stats/coins |
| 5 | Medium fish + orcas + whales | AI behaviors, meat drops, chopping |
| 6 | Boss fish | Megalodon, mosasaurus, kill-to-unlock |
| 7 | Family system | 4 brothers, dad, mom, F toggle |
| 8 | HUD | Coins, sprint bar, bite force, health bar |
| 9 | Death + respawn | Death menu, retry, coins persist |
| 10 | Shop | 5 fish, skins, buy/select, kill requirements |
| 11 | Bubbles + audio | Ambient particles, procedural sounds |
| 12 | Polish | Respawning, health bars, title, food replenish |
| 13 | Bite latch | Latch onto enemies, continuous damage, auto-release |
| 14 | Fish-vs-fish combat | AI predator-prey fights, stealable meat drops |
