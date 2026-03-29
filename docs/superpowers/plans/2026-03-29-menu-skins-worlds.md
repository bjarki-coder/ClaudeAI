# Menu, Skins & Worlds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a death menu with skin selection (6 fun skins) and world selection (4 themed worlds) to Mountain Hawk.

**Architecture:** All changes go into the existing single `mountain-hawk/index.html` file. Skin palettes and world themes are defined as constant objects. Drawing functions are refactored to read from the active skin/world. New game states (STATE_SKINS, STATE_WORLDS) handle menu navigation. Click handling uses coordinate-based hit testing on canvas.

**Tech Stack:** HTML5 Canvas 2D, vanilla JavaScript, localStorage

**Spec:** `docs/superpowers/specs/2026-03-29-menu-skins-worlds-design.md`

---

## File Structure

```
mountain-hawk/
└── index.html    # Modified — same single file
```

---

### Task 1: Skin Palette Data + Refactor drawHawk

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Define 6 skin palette objects and refactor `drawHawk()` to use palette colors instead of hardcoded values. The bird shape stays identical — only colors change. This task does NOT add the selection UI yet — just the data and the drawing refactor.

- [ ] **Step 1: Add skin palette definitions after the CONSTANTS section**

Add a new SKINS section right after the existing constants (after line 47, before CANVAS SETUP):

```javascript
// ============================================================
// SKINS
// ============================================================
const SKINS = [
  {
    name: 'Hawk', body: '#6B3D1F', chest: '#8B5A2B', belly: '#D4A96A',
    wing: '#5C3A1E', wingStroke: '#4A2E14', tail: '#4A2E14',
    eyePatch: '#F5F0E0', eyeColor: '#E8A000', pupil: '#111',
    beak: '#E8901A', beakTip: '#C07010', eyebrow: '#2A1A0A'
  },
  {
    name: 'Fire Bird', body: '#CC2200', chest: '#FF4400', belly: '#FF8800',
    wing: '#AA0000', wingStroke: '#880000', tail: '#880000',
    eyePatch: '#FFE0A0', eyeColor: '#FFFF00', pupil: '#111',
    beak: '#FF6600', beakTip: '#CC4400', eyebrow: '#660000'
  },
  {
    name: 'Ice Bird', body: '#88CCEE', chest: '#AADDFF', belly: '#DDEEFF',
    wing: '#66AACC', wingStroke: '#4488AA', tail: '#4488AA',
    eyePatch: '#FFFFFF', eyeColor: '#FFFFFF', pupil: '#336688',
    beak: '#99DDFF', beakTip: '#77BBDD', eyebrow: '#446688'
  },
  {
    name: 'Robo Bird', body: '#777788', chest: '#8888AA', belly: '#AAAACC',
    wing: '#555566', wingStroke: '#444455', tail: '#444455',
    eyePatch: '#AAAABB', eyeColor: '#00FF00', pupil: '#003300',
    beak: '#999999', beakTip: '#777777', eyebrow: '#333344'
  },
  {
    name: 'Rainbow', body: null, chest: null, belly: null,
    wing: null, wingStroke: null, tail: null,
    eyePatch: '#FFFFFF', eyeColor: '#FF00FF', pupil: '#111',
    beak: '#FF8800', beakTip: '#CC6600', eyebrow: '#333333',
    rainbow: true
  },
  {
    name: 'Ghost', body: 'rgba(200,200,220,0.6)', chest: 'rgba(180,180,200,0.5)',
    belly: 'rgba(220,220,240,0.4)', wing: 'rgba(160,160,180,0.5)',
    wingStroke: 'rgba(130,130,150,0.4)', tail: 'rgba(130,130,150,0.4)',
    eyePatch: 'rgba(220,220,240,0.5)', eyeColor: '#AACCFF', pupil: '#334455',
    beak: 'rgba(200,200,220,0.7)', beakTip: 'rgba(170,170,190,0.6)',
    eyebrow: 'rgba(100,100,120,0.5)'
  }
];
```

- [ ] **Step 2: Add skin selection state to GAME STATE**

Add after `let gameOverClickDelay = 0;`:

```javascript
let currentSkin = parseInt(localStorage.getItem('mountainHawkSkin')) || 0;
```

- [ ] **Step 3: Add a helper function to get resolved skin colors**

Add right after the SKINS array:

```javascript
function getSkinColors(skinIndex, timestamp) {
  const skin = SKINS[skinIndex];
  if (!skin.rainbow) return skin;
  const hue = (timestamp / 10) % 360;
  return {
    name: skin.name,
    body: `hsl(${hue},80%,45%)`,
    chest: `hsl(${(hue + 40) % 360},80%,55%)`,
    belly: `hsl(${(hue + 80) % 360},80%,65%)`,
    wing: `hsl(${(hue - 30 + 360) % 360},80%,40%)`,
    wingStroke: `hsl(${(hue - 30 + 360) % 360},80%,30%)`,
    tail: `hsl(${(hue + 180) % 360},80%,35%)`,
    eyePatch: skin.eyePatch, eyeColor: skin.eyeColor, pupil: skin.pupil,
    beak: skin.beak, beakTip: skin.beakTip, eyebrow: skin.eyebrow,
    rainbow: true
  };
}
```

- [ ] **Step 4: Refactor drawHawk to accept a skin parameter**

Change the function signature from `drawHawk(x, y, rotation, wing)` to `drawHawk(x, y, rotation, wing, skin)`.

Replace every hardcoded color in drawHawk with the skin property:

```javascript
function drawHawk(x, y, rotation, wing, skin) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(rotation);

  // Tail feathers
  ctx.fillStyle = skin.tail;
  ctx.beginPath();
  ctx.moveTo(-14, -2);
  ctx.lineTo(-24, -6);
  ctx.lineTo(-22, 0);
  ctx.lineTo(-26, 4);
  ctx.lineTo(-14, 2);
  ctx.closePath();
  ctx.fill();

  // Body
  ctx.beginPath();
  ctx.ellipse(0, 0, 16, 14, 0, 0, Math.PI * 2);
  ctx.fillStyle = skin.body;
  ctx.fill();

  // Belly
  ctx.beginPath();
  ctx.ellipse(3, 5, 10, 8, 0, Math.PI, Math.PI * 2);
  ctx.fillStyle = skin.belly;
  ctx.fill();

  // Chest
  ctx.beginPath();
  ctx.ellipse(6, 0, 8, 10, 0, 0, Math.PI * 2);
  ctx.fillStyle = skin.chest;
  ctx.fill();

  // Wing
  ctx.fillStyle = skin.wing;
  ctx.beginPath();
  if (wing === 0) {
    ctx.moveTo(-4, -4);
    ctx.quadraticCurveTo(-14, -22, -8, -24);
    ctx.quadraticCurveTo(-2, -18, 2, -10);
    ctx.quadraticCurveTo(0, -6, -4, -4);
  } else if (wing === 1) {
    ctx.moveTo(-4, -2);
    ctx.quadraticCurveTo(-18, -6, -20, -2);
    ctx.quadraticCurveTo(-18, 2, -4, 2);
    ctx.quadraticCurveTo(-2, 0, -4, -2);
  } else {
    ctx.moveTo(-4, 2);
    ctx.quadraticCurveTo(-14, 16, -6, 20);
    ctx.quadraticCurveTo(0, 14, 2, 8);
    ctx.quadraticCurveTo(0, 4, -4, 2);
  }
  ctx.fill();
  ctx.strokeStyle = skin.wingStroke;
  ctx.lineWidth = 0.5;
  ctx.stroke();

  // Eye patch
  ctx.beginPath();
  ctx.ellipse(10, -4, 6, 5.5, 0, 0, Math.PI * 2);
  ctx.fillStyle = skin.eyePatch;
  ctx.fill();

  // Eye
  ctx.beginPath();
  ctx.arc(11, -4, 4, 0, Math.PI * 2);
  ctx.fillStyle = skin.eyeColor;
  ctx.fill();
  ctx.beginPath();
  ctx.arc(12, -4, 2, 0, Math.PI * 2);
  ctx.fillStyle = skin.pupil;
  ctx.fill();
  ctx.beginPath();
  ctx.arc(12.8, -5.2, 0.8, 0, Math.PI * 2);
  ctx.fillStyle = 'white';
  ctx.fill();

  // Eyebrow
  ctx.beginPath();
  ctx.moveTo(6, -8);
  ctx.quadraticCurveTo(10, -10, 15, -8);
  ctx.lineWidth = 1.5;
  ctx.strokeStyle = skin.eyebrow;
  ctx.stroke();

  // Beak
  ctx.beginPath();
  ctx.moveTo(15, -3);
  ctx.quadraticCurveTo(22, -2, 21, 1);
  ctx.quadraticCurveTo(19, 3, 16, 1);
  ctx.closePath();
  ctx.fillStyle = skin.beak;
  ctx.fill();
  ctx.beginPath();
  ctx.moveTo(21, 1);
  ctx.quadraticCurveTo(22, 2, 20, 3);
  ctx.quadraticCurveTo(19, 3, 19, 2);
  ctx.fillStyle = skin.beakTip;
  ctx.fill();

  ctx.restore();
}
```

- [ ] **Step 5: Update all drawHawk call sites to pass skin**

In the game loop, the call `drawHawk(HAWK_X, hawkY, hawkRotation, wingState)` becomes:

```javascript
  const skin = getSkinColors(currentSkin, timestamp);
  drawHawk(HAWK_X, hawkY, hawkRotation, wingState, skin);
```

The `timestamp` variable is already available in `gameLoop(timestamp)`.

- [ ] **Step 6: Update feather colors to use current skin**

In `triggerDeath()`, replace the feather color line:

```javascript
      color: Math.random() > 0.5 ? '#7A4E2A' : '#DDDDDD',
```

With:

```javascript
      color: Math.random() > 0.5 ? SKINS[currentSkin].wing || '#7A4E2A' : '#DDDDDD',
```

- [ ] **Step 7: Verify in browser**

Open the game. It should look and play exactly the same as before (Hawk skin is index 0, the default). To test other skins, temporarily change `currentSkin` to 1-5 in the code and reload.

- [ ] **Step 8: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add 6 skin palettes and refactor drawHawk to use them"
```

---

### Task 2: World Theme Data + Refactor Drawing Functions

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Define 4 world theme objects and refactor all drawing functions to use theme colors instead of hardcoded values. Each world swaps: sky gradient, mountain colors, tree shapes, ground colors, pillar colors, and particle properties.

- [ ] **Step 1: Add world theme definitions after the SKINS section**

```javascript
// ============================================================
// WORLDS
// ============================================================
const WORLDS = [
  {
    name: 'Snowy Mountains',
    sky: [{stop:0,color:'#5B86B8'},{stop:0.4,color:'#8BACC8'},{stop:0.7,color:'#B8C8D8'},{stop:1,color:'#D8DDE4'}],
    farMtn: {color:'rgba(160,170,185,0.7)', snow:'rgba(255,255,255,0.6)'},
    nearMtn: {color:'rgba(120,130,145,0.85)', snow:'rgba(255,255,255,0.8)'},
    tree1: '#1A3A0A', tree2: '#2D5016', treeShape: 'triangle',
    groundTop: '#C8C8C8', groundBot: '#FFFFFF',
    pillarDark: '#5A5A5A', pillarLight: '#7A7A7A', pillarCap: 'rgba(255,255,255,0.85)',
    particleColor: '255,255,255', particleMinO: 0.3, particleMaxO: 0.8,
    particleDir: 1, // 1 = down, -1 = up
    special: null
  },
  {
    name: 'Forest',
    sky: [{stop:0,color:'#70B8E8'},{stop:0.5,color:'#A0D8A0'},{stop:1,color:'#E8F0E8'}],
    farMtn: {color:'rgba(80,140,80,0.5)', snow:null},
    nearMtn: {color:'rgba(50,110,50,0.7)', snow:null},
    tree1: '#1B7A1B', tree2: '#2D9B2D', treeShape: 'round',
    groundTop: '#4A8B3A', groundBot: '#7BC86C',
    pillarDark: '#4A3520', pillarLight: '#6B5035', pillarCap: 'rgba(80,160,80,0.7)',
    particleColor: '120,180,60', particleMinO: 0.3, particleMaxO: 0.7,
    particleDir: 1,
    special: null
  },
  {
    name: 'Desert',
    sky: [{stop:0,color:'#E8A030'},{stop:0.5,color:'#F0D080'},{stop:1,color:'#F0E0B0'}],
    farMtn: {color:'rgba(180,140,90,0.5)', snow:null},
    nearMtn: {color:'rgba(160,120,70,0.7)', snow:null},
    tree1: '#2A6B2A', tree2: '#3A8B3A', treeShape: 'cactus',
    groundTop: '#D4A960', groundBot: '#E8D4A0',
    pillarDark: '#8B7040', pillarLight: '#A89060', pillarCap: 'rgba(210,180,130,0.7)',
    particleColor: '200,170,120', particleMinO: 0.2, particleMaxO: 0.5,
    particleDir: 1,
    special: null
  },
  {
    name: 'Moon',
    sky: [{stop:0,color:'#0A0A1A'},{stop:0.5,color:'#101028'},{stop:1,color:'#1A1A3A'}],
    farMtn: {color:'rgba(60,60,70,0.7)', snow:null},
    nearMtn: {color:'rgba(80,80,90,0.8)', snow:null},
    tree1: '#555566', tree2: '#666677', treeShape: 'rock',
    groundTop: '#3A3A3A', groundBot: '#555555',
    pillarDark: '#3A3A4A', pillarLight: '#5A5A6A', pillarCap: 'rgba(100,100,110,0.6)',
    particleColor: '200,200,210', particleMinO: 0.2, particleMaxO: 0.5,
    particleDir: -1,
    special: 'moon'
  }
];
```

- [ ] **Step 2: Add world selection state to GAME STATE**

Add after `let currentSkin = ...`:

```javascript
let currentWorld = parseInt(localStorage.getItem('mountainHawkWorld')) || 0;
```

- [ ] **Step 3: Refactor drawSky to use world theme**

Replace the entire `drawSky()` function:

```javascript
function drawSky() {
  const world = WORLDS[currentWorld];
  const grad = ctx.createLinearGradient(0, 0, 0, CANVAS_H);
  for (const s of world.sky) {
    grad.addColorStop(s.stop, s.color);
  }
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  // Moon special: draw stars and Earth
  if (world.special === 'moon') {
    // Static stars (seeded by position so they don't flicker)
    for (let i = 0; i < 60; i++) {
      const sx = (i * 137.5) % CANVAS_W;
      const sy = (i * 97.3) % (CANVAS_H - 150);
      const sr = 0.5 + (i % 3) * 0.5;
      ctx.beginPath();
      ctx.arc(sx, sy, sr, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(255,255,255,${0.4 + (i % 5) * 0.12})`;
      ctx.fill();
    }
    // Earth in top-right
    ctx.beginPath();
    ctx.arc(340, 60, 20, 0, Math.PI * 2);
    ctx.fillStyle = '#2244AA';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(335, 55, 8, 0, Math.PI * 2);
    ctx.fillStyle = '#33AA55';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(348, 65, 5, 0, Math.PI * 2);
    ctx.fillStyle = '#33AA55';
    ctx.fill();
  }
}
```

- [ ] **Step 4: Refactor drawBackground to use world theme**

Replace `drawBackground()`:

```javascript
function drawBackground() {
  const world = WORLDS[currentWorld];
  drawSky();
  drawMountainLayer(0.2, CANVAS_H - 100, 140, 8, world.farMtn.color, world.farMtn.snow);
  drawMountainLayer(0.5, CANVAS_H - 70, 120, 10, world.nearMtn.color, world.nearMtn.snow);
  drawWorldTrees(0.8);
  drawGround();
}
```

- [ ] **Step 5: Refactor drawGround to use world theme**

Replace `drawGround()`:

```javascript
function drawGround() {
  const world = WORLDS[currentWorld];
  const grad = ctx.createLinearGradient(0, CANVAS_H - GROUND_H, 0, CANVAS_H);
  grad.addColorStop(0, world.groundTop);
  grad.addColorStop(1, world.groundBot);
  ctx.fillStyle = grad;
  ctx.fillRect(0, CANVAS_H - GROUND_H, CANVAS_W, GROUND_H);
}
```

- [ ] **Step 6: Replace drawPineTrees with drawWorldTrees**

Replace the entire `drawPineTrees()` function with `drawWorldTrees()`:

```javascript
function drawWorldTrees(scrollFactor) {
  const world = WORLDS[currentWorld];
  const treeBaseY = CANVAS_H - GROUND_H;
  const offset = (scrollX * scrollFactor) % CANVAS_W;
  const treeCount = 12;
  const treeSpacing = CANVAS_W / treeCount;

  for (let copy = -1; copy <= 1; copy++) {
    const shiftX = copy * CANVAS_W - offset;

    for (let i = 0; i < treeCount; i++) {
      const tx = shiftX + i * treeSpacing + treeSpacing / 2;
      const treeH = 25 + Math.sin(i * 3.1) * 15;
      const color = i % 2 === 0 ? world.tree1 : world.tree2;

      ctx.fillStyle = color;
      if (world.treeShape === 'triangle') {
        // Pine tree
        const w = treeH * 0.5;
        ctx.beginPath();
        ctx.moveTo(tx, treeBaseY - treeH);
        ctx.lineTo(tx - w, treeBaseY);
        ctx.lineTo(tx + w, treeBaseY);
        ctx.closePath();
        ctx.fill();
      } else if (world.treeShape === 'round') {
        // Deciduous tree
        ctx.fillRect(tx - 2, treeBaseY - treeH * 0.4, 4, treeH * 0.4);
        ctx.beginPath();
        ctx.arc(tx, treeBaseY - treeH * 0.5, treeH * 0.35, 0, Math.PI * 2);
        ctx.fill();
      } else if (world.treeShape === 'cactus') {
        // Cactus
        const w = 6;
        ctx.fillRect(tx - w / 2, treeBaseY - treeH, w, treeH);
        if (i % 3 === 0) {
          ctx.fillRect(tx + w / 2, treeBaseY - treeH * 0.7, treeH * 0.25, 4);
          ctx.fillRect(tx + w / 2 + treeH * 0.25 - 2, treeBaseY - treeH * 0.7 - 8, 4, 12);
        }
        if (i % 3 === 1) {
          ctx.fillRect(tx - w / 2 - treeH * 0.25, treeBaseY - treeH * 0.5, treeH * 0.25, 4);
          ctx.fillRect(tx - w / 2 - treeH * 0.25, treeBaseY - treeH * 0.5 - 8, 4, 12);
        }
      } else if (world.treeShape === 'rock') {
        // Jagged moon rocks
        const w = treeH * 0.4;
        ctx.beginPath();
        ctx.moveTo(tx - w, treeBaseY);
        ctx.lineTo(tx - w * 0.3, treeBaseY - treeH * 0.8);
        ctx.lineTo(tx + w * 0.1, treeBaseY - treeH);
        ctx.lineTo(tx + w * 0.5, treeBaseY - treeH * 0.6);
        ctx.lineTo(tx + w, treeBaseY);
        ctx.closePath();
        ctx.fill();
      }
    }
  }
}
```

- [ ] **Step 7: Refactor drawPillar to use world theme**

Replace `drawPillar()`:

```javascript
function drawPillar(x, topH, gap) {
  const world = WORLDS[currentWorld];
  const bottomY = topH + gap;
  const bottomH = CANVAS_H - GROUND_H - bottomY;

  // Top pillar
  const topGrad = ctx.createLinearGradient(x, 0, x + PILLAR_W, 0);
  topGrad.addColorStop(0, world.pillarDark);
  topGrad.addColorStop(0.5, world.pillarLight);
  topGrad.addColorStop(1, world.pillarDark);
  ctx.fillStyle = topGrad;
  ctx.fillRect(x, 0, PILLAR_W, topH);

  // Top pillar cap
  ctx.fillStyle = world.pillarCap;
  ctx.beginPath();
  ctx.ellipse(x + PILLAR_W / 2, topH, PILLAR_W / 2 + 4, 8, 0, 0, Math.PI);
  ctx.fill();

  // Bottom pillar
  const botGrad = ctx.createLinearGradient(x, bottomY, x + PILLAR_W, bottomY);
  botGrad.addColorStop(0, world.pillarDark);
  botGrad.addColorStop(0.5, world.pillarLight);
  botGrad.addColorStop(1, world.pillarDark);
  ctx.fillStyle = botGrad;
  ctx.fillRect(x, bottomY, PILLAR_W, bottomH);

  // Bottom pillar cap
  ctx.fillStyle = world.pillarCap;
  ctx.beginPath();
  ctx.ellipse(x + PILLAR_W / 2, bottomY, PILLAR_W / 2 + 4, 8, 0, Math.PI, Math.PI * 2);
  ctx.fill();

  // Shadow
  ctx.fillStyle = 'rgba(0,0,0,0.1)';
  ctx.fillRect(x, 0, 6, topH);
  ctx.fillRect(x, bottomY, 6, bottomH);
}
```

- [ ] **Step 8: Refactor particles to use world theme**

Replace `initSnowflakes()`, `updateSnowflakes()`, and `drawSnowflakes()`:

```javascript
function initParticles() {
  snowflakes = [];
  const world = WORLDS[currentWorld];
  for (let i = 0; i < 40; i++) {
    snowflakes.push({
      x: Math.random() * CANVAS_W,
      y: Math.random() * CANVAS_H,
      r: 1 + Math.random() * 2,
      speed: (0.3 + Math.random() * 1) * world.particleDir,
      drift: -0.3 - Math.random() * 0.5,
      opacity: world.particleMinO + Math.random() * (world.particleMaxO - world.particleMinO)
    });
  }
}

function updateParticles() {
  const world = WORLDS[currentWorld];
  for (const s of snowflakes) {
    s.y += s.speed;
    s.x += s.drift;
    if (world.particleDir > 0 && s.y > CANVAS_H) {
      s.y = -5;
      s.x = Math.random() * CANVAS_W;
    } else if (world.particleDir < 0 && s.y < -5) {
      s.y = CANVAS_H + 5;
      s.x = Math.random() * CANVAS_W;
    }
    if (s.x < -5) s.x = CANVAS_W + 5;
  }
}

function drawParticles() {
  const world = WORLDS[currentWorld];
  for (const s of snowflakes) {
    ctx.beginPath();
    ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(${world.particleColor},${s.opacity})`;
    ctx.fill();
  }
}
```

- [ ] **Step 9: Update all call sites**

In the game loop, replace:
- `updateSnowflakes()` → `updateParticles()`
- `drawSnowflakes()` → `drawParticles()`

At the bottom of the script, replace:
- `initSnowflakes()` → `initParticles()`

In `drawBackground()`, the call to `drawPineTrees(0.8)` was already changed to `drawWorldTrees(0.8)` in Step 4.

- [ ] **Step 10: Verify in browser**

Open the game. It should look identical (Snowy Mountains is world 0). To test other worlds, temporarily set `currentWorld` to 1, 2, or 3 and reload.

- [ ] **Step 11: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add 4 world themes and refactor drawing to use them"
```

---

### Task 3: Game Over Menu With Buttons

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Replace the current Game Over panel with an expanded menu that has three buttons: Retry, Skins, Worlds. Replace the simple click-to-retry with coordinate-based button click detection.

- [ ] **Step 1: Add new game states**

In the GAME STATE section, after `const STATE_GAMEOVER = 2;` add:

```javascript
const STATE_SKINS = 3;
const STATE_WORLDS = 4;
```

- [ ] **Step 2: Replace drawGameOver with the new menu version**

Replace the entire `drawGameOver()` function:

```javascript
function drawGameOver() {
  ctx.fillStyle = 'rgba(0,0,0,0.4)';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  const panelW = 260;
  const panelH = 250;
  const panelX = (CANVAS_W - panelW) / 2;
  const panelY = (CANVAS_H - panelH) / 2 - 20;

  // Panel background
  ctx.fillStyle = 'rgba(30,30,50,0.9)';
  ctx.beginPath();
  ctx.roundRect(panelX, panelY, panelW, panelH, 12);
  ctx.fill();
  ctx.strokeStyle = 'rgba(255,255,255,0.2)';
  ctx.lineWidth = 2;
  ctx.stroke();

  ctx.save();
  ctx.textAlign = 'center';

  // Title
  ctx.font = 'bold 24px sans-serif';
  ctx.fillStyle = '#CC4444';
  ctx.fillText('Game Over', CANVAS_W / 2, panelY + 35);

  // Score
  ctx.font = '14px sans-serif';
  ctx.fillStyle = '#AAAAAA';
  ctx.fillText('Score', CANVAS_W / 2, panelY + 60);
  ctx.font = 'bold 32px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText(score, CANVAS_W / 2, panelY + 92);
  ctx.font = '13px sans-serif';
  ctx.fillStyle = '#88AACC';
  ctx.fillText('Best: ' + bestScore, CANVAS_W / 2, panelY + 112);

  // Buttons
  const btnW = 180;
  const btnH = 32;
  const btnX = (CANVAS_W - btnW) / 2;
  const btnStartY = panelY + 130;
  const btnGap = 38;

  const buttons = [
    {label: 'Retry', color: '#44AA44'},
    {label: 'Skins', color: '#AA8844'},
    {label: 'Worlds', color: '#4488CC'}
  ];

  for (let i = 0; i < buttons.length; i++) {
    const by = btnStartY + i * btnGap;
    ctx.fillStyle = buttons[i].color;
    ctx.beginPath();
    ctx.roundRect(btnX, by, btnW, btnH, 6);
    ctx.fill();
    ctx.font = 'bold 16px sans-serif';
    ctx.fillStyle = 'white';
    ctx.fillText(buttons[i].label, CANVAS_W / 2, by + 22);
  }

  ctx.restore();
}
```

- [ ] **Step 3: Add click position helper**

Add to the INPUT section (before `handleFlap`):

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

- [ ] **Step 4: Replace handleFlap and input handlers with new click handling**

Replace the entire INPUT section (from `handleFlap` through the event listeners):

```javascript
function handleClick(e) {
  e.preventDefault();
  initAudio();
  const pos = getClickPos(e);

  if (gameState === STATE_TITLE) {
    gameState = STATE_PLAYING;
    hawkY = CANVAS_H / 2;
    hawkVel = 0;
    score = 0;
    currentGap = GAP_SIZE;
    pillars = [];
    hawkCryTimer = 8 + Math.random() * 7;
    for (let i = 0; i < 4; i++) {
      const gap = currentGap;
      const maxTop = CANVAS_H - GROUND_H - gap - 80;
      pillars.push({
        x: CANVAS_W + i * PILLAR_SPACING,
        topH: PILLAR_MIN_TOP + Math.random() * (maxTop - PILLAR_MIN_TOP),
        gap: gap,
        scored: false
      });
    }
    hawkVel = FLAP_STRENGTH;
    flapHoldTimer = 0;
    playFlap();
    return;
  }

  if (gameState === STATE_PLAYING) {
    hawkVel = FLAP_STRENGTH;
    flapHoldTimer = 0;
    playFlap();
    return;
  }

  if (gameState === STATE_GAMEOVER && deathAnimTimer > 1.0 && gameOverClickDelay <= 0) {
    // Check menu buttons
    const panelW = 260;
    const panelH = 250;
    const panelY = (CANVAS_H - panelH) / 2 - 20;
    const btnW = 180;
    const btnH = 32;
    const btnX = (CANVAS_W - btnW) / 2;
    const btnStartY = panelY + 130;
    const btnGap = 38;

    if (hitBtn(pos, btnX, btnStartY, btnW, btnH)) {
      // Retry
      resetGame();
    } else if (hitBtn(pos, btnX, btnStartY + btnGap, btnW, btnH)) {
      // Skins
      gameState = STATE_SKINS;
    } else if (hitBtn(pos, btnX, btnStartY + btnGap * 2, btnW, btnH)) {
      // Worlds
      gameState = STATE_WORLDS;
    }
    return;
  }

  if (gameState === STATE_SKINS) {
    handleSkinsClick(pos);
    return;
  }

  if (gameState === STATE_WORLDS) {
    handleWorldsClick(pos);
    return;
  }
}

function resetGame() {
  hawkY = CANVAS_H / 2;
  hawkVel = 0;
  hawkRotation = 0;
  scrollX = 0;
  pillars = [];
  initParticles();
  gameState = STATE_TITLE;
}

canvas.addEventListener('mousedown', handleClick);
canvas.addEventListener('touchstart', handleClick);
document.addEventListener('keydown', (e) => {
  if (e.code === 'Space') {
    e.preventDefault();
    if (gameState === STATE_PLAYING) {
      initAudio();
      hawkVel = FLAP_STRENGTH;
      flapHoldTimer = 0;
      playFlap();
    } else if (gameState === STATE_TITLE) {
      handleClick({preventDefault:()=>{}, clientX:0, clientY:0, target:canvas});
    }
  }
});
```

Note: `handleSkinsClick` and `handleWorldsClick` are stub references — they will be implemented in Tasks 4 and 5. For now, add placeholder functions right before `resetGame`:

```javascript
function handleSkinsClick(pos) { /* Task 4 */ }
function handleWorldsClick(pos) { /* Task 5 */ }
```

- [ ] **Step 5: Update game loop for new states**

The game loop's scroll section should also scroll slowly during SKINS/WORLDS. Change:

```javascript
  } else {
    scrollX += SCROLL_SPEED * 0.3;
  }
```

To:

```javascript
  } else {
    scrollX += SCROLL_SPEED * 0.3;
  }
```

(No change needed — the `else` already covers all non-PLAYING states.)

Also update the UI overlay section at the bottom of the game loop:

```javascript
  // UI overlays
  if (gameState === STATE_TITLE) {
    drawTitle();
  } else if (gameState === STATE_PLAYING) {
    drawScore();
  } else if (gameState === STATE_GAMEOVER) {
    drawScore();
    if (deathAnimTimer > 1.0) {
      drawGameOver();
    }
  } else if (gameState === STATE_SKINS) {
    drawSkinsScreen();
  } else if (gameState === STATE_WORLDS) {
    drawWorldsScreen();
  }
```

Add placeholder draw functions in the DRAWING FUNCTIONS section:

```javascript
function drawSkinsScreen() { /* Task 4 */ }
function drawWorldsScreen() { /* Task 5 */ }
```

- [ ] **Step 6: Verify in browser**

Play and die. The Game Over panel should now show three buttons: Retry, Skins, Worlds. Clicking Retry should restart. Clicking Skins/Worlds won't show anything yet (empty screens — Tasks 4 & 5).

- [ ] **Step 7: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add game over menu with Retry, Skins, Worlds buttons"
```

---

### Task 4: Skins Selection Screen

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Implement the skin selection screen — a 2x3 grid of skin cards drawn on canvas. Each card shows a small hawk preview in that skin's colors and the skin name. Clicking a card selects that skin. A Back button returns to the Game Over menu.

- [ ] **Step 1: Replace the drawSkinsScreen placeholder**

Replace `function drawSkinsScreen() { /* Task 4 */ }` with:

```javascript
function drawSkinsScreen() {
  ctx.fillStyle = 'rgba(0,0,0,0.6)';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  ctx.save();
  ctx.textAlign = 'center';

  // Title
  ctx.font = 'bold 28px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText('Choose Skin', CANVAS_W / 2, 50);

  // Grid: 2 columns, 3 rows
  const cols = 2;
  const cardW = 150;
  const cardH = 120;
  const gapX = 20;
  const gapY = 15;
  const startX = (CANVAS_W - (cols * cardW + (cols - 1) * gapX)) / 2;
  const startY = 75;

  for (let i = 0; i < SKINS.length; i++) {
    const col = i % cols;
    const row = Math.floor(i / cols);
    const cx = startX + col * (cardW + gapX);
    const cy = startY + row * (cardH + gapY);
    const skin = getSkinColors(i, performance.now());

    // Card background
    ctx.fillStyle = i === currentSkin ? 'rgba(80,120,180,0.8)' : 'rgba(40,40,60,0.8)';
    ctx.beginPath();
    ctx.roundRect(cx, cy, cardW, cardH, 8);
    ctx.fill();
    if (i === currentSkin) {
      ctx.strokeStyle = '#88BBFF';
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    // Bird preview (small, centered in card)
    drawHawk(cx + cardW / 2, cy + 45, 0, 1, skin);

    // Skin name
    ctx.font = '13px sans-serif';
    ctx.fillStyle = i === currentSkin ? '#FFFFFF' : '#AAAAAA';
    ctx.fillText(SKINS[i].name, cx + cardW / 2, cy + cardH - 10);
  }

  // Back button
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

- [ ] **Step 2: Replace the handleSkinsClick placeholder**

Replace `function handleSkinsClick(pos) { /* Task 4 */ }` with:

```javascript
function handleSkinsClick(pos) {
  const cols = 2;
  const cardW = 150;
  const cardH = 120;
  const gapX = 20;
  const gapY = 15;
  const startX = (CANVAS_W - (cols * cardW + (cols - 1) * gapX)) / 2;
  const startY = 75;

  for (let i = 0; i < SKINS.length; i++) {
    const col = i % cols;
    const row = Math.floor(i / cols);
    const cx = startX + col * (cardW + gapX);
    const cy = startY + row * (cardH + gapY);
    if (hitBtn(pos, cx, cy, cardW, cardH)) {
      currentSkin = i;
      localStorage.setItem('mountainHawkSkin', currentSkin);
      return;
    }
  }

  // Back button
  const backW = 120;
  const backH = 32;
  const backX = (CANVAS_W - backW) / 2;
  const backY = CANVAS_H - 60;
  if (hitBtn(pos, backX, backY, backW, backH)) {
    gameState = STATE_GAMEOVER;
  }
}
```

- [ ] **Step 3: Verify in browser**

Die in the game, click "Skins". A 2x3 grid of bird previews should appear. Click different skins to select them (highlight changes). Click Back to return to Game Over. Click Retry, start playing — the hawk should use the selected skin's colors.

- [ ] **Step 4: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add skin selection screen with 6 skins"
```

---

### Task 5: Worlds Selection Screen

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Implement the world selection screen — a 2x2 grid of world cards with sky gradient previews and names. Clicking selects a world. Back button returns to Game Over. When changing world, re-init particles.

- [ ] **Step 1: Replace the drawWorldsScreen placeholder**

Replace `function drawWorldsScreen() { /* Task 5 */ }` with:

```javascript
function drawWorldsScreen() {
  ctx.fillStyle = 'rgba(0,0,0,0.6)';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  ctx.save();
  ctx.textAlign = 'center';

  // Title
  ctx.font = 'bold 28px sans-serif';
  ctx.fillStyle = 'white';
  ctx.fillText('Choose World', CANVAS_W / 2, 50);

  // Grid: 2 columns, 2 rows
  const cols = 2;
  const cardW = 160;
  const cardH = 180;
  const gapX = 20;
  const gapY = 20;
  const startX = (CANVAS_W - (cols * cardW + (cols - 1) * gapX)) / 2;
  const startY = 80;

  for (let i = 0; i < WORLDS.length; i++) {
    const col = i % cols;
    const row = Math.floor(i / cols);
    const cx = startX + col * (cardW + gapX);
    const cy = startY + row * (cardH + gapY);
    const world = WORLDS[i];

    // Card background
    ctx.fillStyle = i === currentWorld ? 'rgba(80,120,180,0.8)' : 'rgba(40,40,60,0.8)';
    ctx.beginPath();
    ctx.roundRect(cx, cy, cardW, cardH, 8);
    ctx.fill();
    if (i === currentWorld) {
      ctx.strokeStyle = '#88BBFF';
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    // Sky preview
    const prevX = cx + 10;
    const prevY = cy + 10;
    const prevW = cardW - 20;
    const prevH = 110;
    const grad = ctx.createLinearGradient(prevX, prevY, prevX, prevY + prevH);
    for (const s of world.sky) {
      grad.addColorStop(s.stop, s.color);
    }
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.roundRect(prevX, prevY, prevW, prevH, 4);
    ctx.fill();

    // Ground preview strip at bottom of preview
    const gndH = 15;
    ctx.fillStyle = world.groundTop;
    ctx.fillRect(prevX, prevY + prevH - gndH, prevW, gndH);

    // Mini mountain silhouette
    ctx.fillStyle = world.nearMtn.color;
    ctx.beginPath();
    ctx.moveTo(prevX, prevY + prevH - gndH);
    ctx.lineTo(prevX + prevW * 0.2, prevY + prevH - gndH - 30);
    ctx.lineTo(prevX + prevW * 0.4, prevY + prevH - gndH - 15);
    ctx.lineTo(prevX + prevW * 0.6, prevY + prevH - gndH - 35);
    ctx.lineTo(prevX + prevW * 0.8, prevY + prevH - gndH - 20);
    ctx.lineTo(prevX + prevW, prevY + prevH - gndH);
    ctx.closePath();
    ctx.fill();

    // Moon special: stars in preview
    if (world.special === 'moon') {
      for (let s = 0; s < 15; s++) {
        const sx = prevX + (s * 9.7) % prevW;
        const sy = prevY + (s * 7.3) % (prevH * 0.5);
        ctx.beginPath();
        ctx.arc(sx, sy, 0.8, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(255,255,255,0.6)';
        ctx.fill();
      }
    }

    // World name
    ctx.font = 'bold 14px sans-serif';
    ctx.fillStyle = i === currentWorld ? '#FFFFFF' : '#AAAAAA';
    ctx.fillText(world.name, cx + cardW / 2, cy + cardH - 15);
  }

  // Back button
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

- [ ] **Step 2: Replace the handleWorldsClick placeholder**

Replace `function handleWorldsClick(pos) { /* Task 5 */ }` with:

```javascript
function handleWorldsClick(pos) {
  const cols = 2;
  const cardW = 160;
  const cardH = 180;
  const gapX = 20;
  const gapY = 20;
  const startX = (CANVAS_W - (cols * cardW + (cols - 1) * gapX)) / 2;
  const startY = 80;

  for (let i = 0; i < WORLDS.length; i++) {
    const col = i % cols;
    const row = Math.floor(i / cols);
    const cx = startX + col * (cardW + gapX);
    const cy = startY + row * (cardH + gapY);
    if (hitBtn(pos, cx, cy, cardW, cardH)) {
      currentWorld = i;
      localStorage.setItem('mountainHawkWorld', currentWorld);
      initParticles();
      return;
    }
  }

  // Back button
  const backW = 120;
  const backH = 32;
  const backX = (CANVAS_W - backW) / 2;
  const backY = CANVAS_H - 60;
  if (hitBtn(pos, backX, backY, backW, backH)) {
    gameState = STATE_GAMEOVER;
  }
}
```

- [ ] **Step 3: Verify in browser**

Die in the game, click "Worlds". A 2x2 grid of world previews should appear (sky gradients, ground strips, mini mountains). Click to select a world. Click Back. Click Retry — the game should now use the selected world's theme (different sky, ground, trees, pillars, particles). Moon world should show stars and Earth in the sky, with particles floating upward.

- [ ] **Step 4: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: add world selection screen with 4 worlds"
```

---

### Task 6: Polish + Integration Testing

**Files:**
- Modify: `mountain-hawk/index.html`

**Context:** Final integration pass. Ensure all combinations of skins and worlds work, death animation still plays properly before menu shows, and background continues scrolling on menu screens.

- [ ] **Step 1: Ensure death effects update during SKINS/WORLDS screens**

In `updateDeathEffects(dt)`, the guard currently checks `if (gameState !== STATE_GAMEOVER) return;`. Change to also allow during SKINS/WORLDS so the background keeps animating:

```javascript
function updateDeathEffects(dt) {
  if (gameState !== STATE_GAMEOVER && gameState !== STATE_SKINS && gameState !== STATE_WORLDS) return;
```

- [ ] **Step 2: Ensure particles update during menu screens**

The game loop already calls `updateParticles()` unconditionally, so particles animate on all screens. Verify this is the case — no change needed if already unconditional.

- [ ] **Step 3: Update drawTitle to show current world name and skin name**

In `drawTitle()`, after the "Best" score text, add:

```javascript
  ctx.font = '12px sans-serif';
  ctx.fillStyle = '#777777';
  ctx.fillText(SKINS[currentSkin].name + ' · ' + WORLDS[currentWorld].name, CANVAS_W / 2, CANVAS_H - 45);
```

- [ ] **Step 4: Verify full flow in browser**

Test the complete flow:
1. Title screen shows current skin/world names
2. Play and die — death animation plays, then menu appears with Retry/Skins/Worlds
3. Click Skins — grid of 6 skins with hawk previews, click to select, Back returns to menu
4. Click Worlds — grid of 4 worlds with sky previews, click to select, Back returns to menu
5. Click Retry — game starts with selected skin and world
6. Test all 4 worlds: Snowy Mountains (snow, pines), Forest (green, round trees, leaf particles), Desert (orange, cacti, dust), Moon (dark, stars, Earth, rocks, upward dust)
7. Test all 6 skins: Hawk, Fire Bird, Ice Bird, Robo Bird, Rainbow (color shifts), Ghost (transparent)
8. Selections persist across page reloads (localStorage)

- [ ] **Step 5: Commit**

```bash
git add mountain-hawk/index.html
git commit -m "feat: polish menu integration — death effects on menu, title info"
```

---

## Summary

| Task | Description | Key Output |
|------|-------------|------------|
| 1 | Skin palettes + drawHawk refactor | 6 skins, hawk uses palette colors |
| 2 | World themes + drawing refactor | 4 worlds, all drawing functions themed |
| 3 | Game Over menu buttons | Retry/Skins/Worlds buttons, click detection |
| 4 | Skins selection screen | 2x3 grid with previews, click to select |
| 5 | Worlds selection screen | 2x2 grid with previews, click to select |
| 6 | Polish + integration | Death effects on menu, title info, full QA |
