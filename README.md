# Breakout

A modern, pastel-infused 2D arcade brick-breaker built with **Godot Engine 4**. Bounce the ball, direct your shots, and break through challenging brick formations across 48 handcrafted campaign levels, endless survival waves, and instant quick play.

---

## 🎮 Game Modes

### Campaign Mode (Level Selection)
- **48 Handcrafted Levels**: Progress across 3 themed chapters, each containing 16 levels:
  - **Chapter 1: The Fundamentals (Levels 1–16)**: Introduction to angles, geometric formations, and early multi-hit bricks.
  - **Chapter 2: The Crucible (Levels 17–32)**: Denser multi-hit brick formations, defensive barriers, and tactical infiltration points.
  - **Chapter 3: The Iron Frontier (Levels 33–48)**: High-challenge gauntlets featuring metal wall mazes, pinball bumper studs, and precision choke points.
- **Difficulty Tiers**: Levels span four designated difficulty ratings: **Easy**, **Medium**, **Hard**, and **Special**.
- **Objective**: Destroy all destructible bricks to complete each level. Indestructible metal bricks serve as permanent obstacles you must navigate around.
- **Star Rating & Best Times**: Earn up to 3 stars per level based on remaining lives. Your best completion time, star rating, and unlock progress are automatically saved.

### Survival Mode (Endless)
- **Dynamic Wave Generation**: Face endless, procedurally generated brick formations scaling through 6 distinct difficulty phases.
- **Continuous Progression**: Clearing all destructible bricks in a wave triggers a victory fanfare and immediately transitions to the next wave, retaining your active lives.
- **Combo Multiplier System**:
  - Each consecutive brick hit increases your active combo multiplier by `+1`.
  - Points earned: $\text{Effective Damage} \times \text{Combo Multiplier}$.
  - **Paddle Reset**: Hitting the paddle resets the multiplier back to `1`. Keeping the ball ricocheting within clusters yields massive scores!
- **Persistent High Scores**: Track and save your highest survival record.

### Quick Play Mode
- Jump straight into instant arcade action with randomized board formations without navigating campaign level select.

---

## ✨ Key Features

- **Brick Health Tiers (1–6 HP + Metal)**: Bricks feature varying durability color-coded in a clean pastel palette:
  - **1 HP**: Mauve (Purple)
  - **2 HP**: Blue
  - **3 HP**: Green
  - **4 HP**: Yellow
  - **5 HP**: Peach (Orange)
  - **6 HP**: Red
  - **Indestructible**: Silver Metal
- **Dynamic Paddle Deflection**: Ball bounce angles dynamically adjust based on where the ball strikes the paddle (center bounces upward, edges bounce at steep outward angles) for skillful aiming.
- **Screen Shake & Particle Bursts**: Satisfying visual impact with color-matched debris bursts and subtle screen shake.
- **Lives & Animated Countdown**: Start each run with 3 hearts. Losing a ball resets the paddle with an animated 3-2-1-GO! countdown sequence.
- **Soundtrack & Retro SFX**: Original *Lavender Chillwave* ambient music alongside crisp retro-modern sound effects for impacts, clears, and UI interactions.
- **Full Keyboard, Mouse & Touch Support**: Playable smoothly in web browsers, desktop PCs, and touchscreens.

---

## 🕹️ Controls

| Action | Primary Input | Alternate / Mouse |
| :--- | :--- | :--- |
| **Move Paddle** | `A` / `D` | `Left` / `Right` Arrow keys, Mouse |
| **Pause / Resume** | `Space` | UI Button |
| **Menu Navigation** | Arrow Keys / `Tab` | Mouse Hover & Click |
| **Confirm Selection** | `Enter` | Left Click |

---

## 🛠️ Development & Export

The project includes a `Makefile` to streamline web builds and local testing:

```bash
# Export the game to Web (HTML5/WebAssembly) in build/web/
make export-web

# Export to Web and bundle into a versioned zip (e.g. build/Breakout-Web-v1.0.0.zip)
make build-web

# Launch a local HTTP server to play and test the web build in your browser
make server-web

# Clean build artifacts
make clean-web
make clean-build
```
