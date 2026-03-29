# Deep Feast — Game Design Spec

A side-view ocean survival game. Eat clams, fish, and meat to grow. Avoid or fight megalodons and mosasaurus. Buy new fish in the shop. Single HTML file, zero dependencies.

## Tech Stack

- **Rendering:** HTML5 Canvas 2D
- **Audio:** Web Audio API (procedural)
- **Storage:** localStorage (coins, unlocks, selected fish)
- **Build:** Single `deep-feast/index.html` — no dependencies
- **Input:** Arrow keys/WASD for movement, Shift to sprint, Left click to bite, F to toggle family

## Map

Wide scrolling ocean. The map is much wider than tall — roughly 6000px wide × 800px tall (the screen is 600×600, camera follows the player). Water color is a gentle gradient but doesn't get very dark — medium blue throughout with a slightly lighter top.

The entire map is one continuous zone. There is no strict depth layering — everything can appear everywhere. However:

- **Clams, seashells, small food** — scattered along the ocean floor everywhere
- **Clownfish** — free food, swim around in small schools everywhere
- **Medium fish** — swim around mid-areas
- **Orcas** — 5 total, patrol around the map
- **Whales** — a few around the map, suck in small things
- **Megalodons** — 2-3 roaming the entire map, dangerous
- **Mosasaurus** — 2 roaming the entire map, most dangerous

The ocean floor has coral, sand, seashells, and clams. Bubbles float up as ambient particles.

## Player Fish

### Starter: Piranha
- 2 skins: Normal (orange/red) and Skeleton (bone-white with visible ribs)
- Small starting size
- Fast, aggressive-looking

### Controls
- **Arrow keys / WASD** — swim in 4 directions (8-directional with diagonals)
- **Shift** — press to toggle sprint on/off (not hold)
- **Left click (hold)** — open mouth to bite. Mouth outline appears at front of fish while held
- **Left click (hold 2s)** — charged bite, 1.5x damage
- **F key** — toggle family following on/off

### Mouth & Bite Visual
- **Not clicking:** Mouth closed, no outline — clean fish look
- **Holding left click:** Mouth opens, a bite-range outline/arc appears at the front of the fish
- **In range of a hittable fish:** Mouth and teeth turn yellow to signal you can land the hit
- **Charged (2s hold):** Bite outline pulses/glows to show 1.5x damage is ready

### Sprint
- Press Shift to toggle sprint on/off
- 13-second stamina bar displayed on screen
- Drains while sprinting, recharges while not sprinting
- Sprint speed: 1.8x normal speed

## Eating & Growth

### What You Eat
- **Clams/seashells** — on ocean floor, stationary. Small XP + coins
- **Clownfish** — free food, swim in small schools. Easy to catch
- **Small wild fish** — swim around, slightly evasive
- **Medium fish** — harder to catch, more XP + coins
- **Meat drops** — when you kill a fish, it drops meat pieces

### Meat Drops
When you kill a fish, it drops meat based on its size:
- Small fish: 1 piece of meat (you can eat it directly)
- Medium fish: 2-3 pieces
- Large fish (orcas, whales): 5 pieces
- Boss fish (megalodon, mosasaurus): 5 large pieces

If a meat piece is bigger than what you can eat in one bite, you can **chop it down** by biting it repeatedly — each bite breaks off a smaller piece you can eat.

### Auto-Stats (from eating)
Every time you eat something, your stats increase gradually:

- **Size** — grows visually, determines what you can eat and what threatens you
- **Bite Force (Jaw)** — increases in small increments (e.g., 50 → 55, not 50 → 100). Determines damage dealt when biting
- **Max Health** — increases in small increments. Determines how many hits you can take

The increment size depends on what you ate:
- Clam/seashell: +1 bite force, +2 max health, tiny size increase
- Clownfish: +2 bite force, +3 max health, small size increase
- Medium fish meat: +3 bite force, +5 max health, moderate size increase
- Boss meat: +5 bite force, +8 max health, notable size increase

### Suck Ability
Once your fish grows large enough (or if playing as Whale), you gain a suck ability: small nearby fish and food get pulled toward your mouth automatically. Range depends on your size.

## Family System

You spawn with a family:
- **4 brothers** — same fish type as you, same size, 1.6x faster than you
- **1 dad** — slightly bigger than you
- **1 mom** — same size as you

Family members:
- Follow you in a loose formation when toggled on (F key)
- Do NOT progress/grow — they stay the same size the whole game
- Swim around you, mostly cosmetic/companionship
- If you die, family disappears and respawns with you

## Shop

Accessible from the death screen (like Mountain Hawk's menu). Coins persist between deaths. Unlocked fish persist.

| Fish | Cost | Requirement | Starting Size | Special |
|------|------|-------------|---------------|---------|
| Piranha | Free | None (starter) | Small | 2 skins (normal + skeleton) |
| Bass | 50 coins | None | Medium | Slightly stronger jaw |
| Whale | 150 coins | None | Large | Suck attack (pulls in food), no bite |
| Megalodon | 200 coins | Must kill one first | Large | Powerful bite |
| Mosasaurus | 500 coins | Must kill one first | Very large | Most powerful bite |

### Kill-to-Unlock
- Megalodon: killing any megalodon on the map flags `megalodonKilled = true` in localStorage. This makes it available for purchase in the shop.
- Mosasaurus: same — kill one to unlock the purchase option.
- The flag persists across deaths.

## Enemy AI

### Clownfish
- Swim in small schools (3-5 fish)
- Slow, don't flee aggressively
- Pure food — no threat

### Small Wild Fish
- Swim in random patterns
- Flee when player gets close (if player is bigger)
- Attack if player is smaller

### Medium Fish
- Faster, more evasive
- Will chase and bite the player if player is smaller
- Flee if player is significantly bigger

### Orcas (5 on map)
- Patrol set routes
- Aggressive — chase player if in range
- Tough to kill, high health
- Drop 5 meat pieces on death
- Respawn after 60 seconds

### Whales (few on map)
- Passive — don't attack
- Suck in small fish and food near their mouth
- Can accidentally suck in the player if player is small enough
- Very high health
- Drop 5 large meat pieces on death
- Respawn after 90 seconds

### Megalodon (2-3 on map)
- Roam the entire map
- Very aggressive — chase player from far range
- High damage, high health
- Player must be large + strong to fight them
- Drop 5 large meat pieces on death
- Respawn after 120 seconds
- Killing one unlocks shop purchase

### Mosasaurus (2 on map)
- Roam the entire map
- Most aggressive and dangerous
- Highest damage and health
- Drop 5 large meat pieces on death
- Respawn after 180 seconds
- Killing one unlocks shop purchase

## Camera

Camera follows the player, centered on screen. The camera is clamped to map boundaries (can't scroll past edges).

## UI (HUD)

Drawn on canvas, always visible:
- **Coins** — top-left (🪙 count)
- **Sprint bar** — top-right (13-second bar, fills/drains)
- **Stats** — bottom-left (Size, Bite Force, Health bar)
- **Bite charge indicator** — near the fish, subtle glow when charged

## Death

When health reaches 0 (eaten by a bigger fish):
- Death animation (fish fades, meat drops from your body)
- Death menu appears:
  - Score summary (coins earned this run)
  - **Retry** — restart with current fish
  - **Shop** — buy/select fish
- You keep: coins, shop unlocks, kill flags
- You lose: size, stats, current growth

## Visual Style

- **Ocean:** Gentle blue gradient, not very dark. Coral and sand floor.
- **Fish:** Procedurally drawn on canvas (like Mountain Hawk's hawk). Each fish type has distinct shape and colors.
- **Bubbles:** Ambient particles floating upward.
- **Coral:** Colorful shapes along the ocean floor.
- **Light rays:** Subtle light beams from the top of the water.

## Audio (Procedural Web Audio API)

- **Ambient underwater** — low filtered noise loop
- **Bite sound** — short crunch on bite
- **Charged bite** — deeper, punchier crunch
- **Coin collect** — soft chime
- **Sprint activate** — whoosh
- **Damage taken** — thud
- **Death** — low rumble
- **Suck** — wind/vacuum sound for whale/large fish

## File Structure

```
deep-feast/
└── index.html    # Single file: HTML + CSS + JS
```

## Performance

- 60fps via requestAnimationFrame with fixed timestep (like Mountain Hawk)
- Camera culling — only draw entities visible on screen
- Mobile-friendly CSS (same approach as Mountain Hawk)
- Touch controls for mobile: virtual joystick left side, bite button right side
