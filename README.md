# Breakout

A classic 2D retro arcade brick-breaker built with **Godot Engine 4**. Bounce the ball, direct your shots, and break through challenging brick formations across campaign levels and endless survival waves.

---

## Game Modes

### Level Mode (Campaign)
- **16 Handcrafted Levels**: Progress through **Easy** (Levels 1–5), **Medium** (Levels 6–10), and **Hard** (Levels 11–16) difficulty tiers.
- **Objective**: Destroy all destructible bricks to complete the level. Indestructible metal bricks serve as obstacles you must navigate around.
- **Star Rating**: Earn up to 3 stars per level based on the number of lives remaining upon victory.
- **Persistent Progress**: Your best time, star rating, and completion status are automatically saved, unlocking new levels as you progress.

### Survival Mode (Endless)
- **Procedural Stages**: Face endless waves of dynamically generated brick formations with varying layouts, patterns, and obstacles.
- **Stage Progression**: Clearing all destructible bricks in a stage plays a victory fanfare and advances you to the next, with no health reset between stages.
- **Combo Multiplier System**:
  - Each consecutive brick hit increases your active combo multiplier by `+1`.
  - Points earned: $\text{Effective Damage} \times \text{Combo}$.
  - **Paddle Reset**: Hitting the paddle resets the combo multiplier back to `1`. Keeping the ball ricocheting among bricks yields massive scores!
- **High Score Tracking**: Your personal best score is saved persistently, with the in-game score counter highlighting in gold when you beat your high score.

---

## Key Features

- **Brick Health Tiers**: Bricks feature varying durability with color-coded visual health (1 to 6 hits), plus indestructible metal bricks:
  - **1 HP**: Mauve (Purple)
  - **2 HP**: Blue
  - **3 HP**: Green
  - **4 HP**: Yellow
  - **5 HP**: Peach (Orange)
  - **6 HP**: Red
  - **Indestructible**: Metal
- **Dynamic Paddle Deflection**: Ball bounce angles dynamically adjust based on where the ball strikes the paddle, allowing skillful angle control and aiming.
- **Particle Effects**: Hits produce dynamic particle bursts matching each brick's color palette.
- **Lives & Countdown**: Start each run with 3 hearts. Losing a ball pauses briefly and restarts with an animated 3-2-1-GO! countdown.
- **Retro Audio**: Authentic 8-bit sound effects for paddle bounces, wall bounces, brick hits, life loss, countdowns, stage clears, and game outcomes.

---

## Controls

| Action | Input |
| :--- | :--- |
| **Move Paddle** | `A` / `D` or `Left` / `Right` Arrow keys |
| **Pause / Resume** | `Space` / `Enter` or in-game Pause button |
| **Menu Navigation** | Mouse Click or Keyboard (`Tab` / Arrow keys to focus, `Space` / `Enter` to select) |
