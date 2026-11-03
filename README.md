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

## ⚡ Power-ups System

Survival Mode features a dynamic power-up capsule drop system. Capsules fall from destroyed tiles or the ceiling and activate upon touching the paddle:

### 🎁 Rewarding
* **MultiBall**: Spawns 1–3 additional balls with randomized boosted damage (2–5 HP) and divergent upward trajectories.
* **Fireball**: Spawns a high-heat blazing ball that destroys any tile in one hit, including indestructible metal bricks.
* **Expanded**: Widens the paddle by 1.5x (12s) or 2.0x (8s) for easier catches and wider coverage.
* **Revival**: Restores one lost heart. Guaranteed to spawn after completing every 5th stage if hearts are not full.
* **Guardian**: Deploys an emergency laser barrier across the bottom deadzone that saves a ball from dropping.

### ⚠️ Punishing
* **Shrinked**: Contracts paddle width to 40%–60% of normal size for 8–16 seconds.
* **Lazy**: Slows paddle movement speed to 40%–60% for 8–16 seconds.
* **Immortal**: Renders all destructible tiles temporarily immune to damage for 8–16 seconds.
* **Imposter**: Weakens the ball's striking power, causing it to deal reduced or zero damage for 8 seconds.

### 🎲 Situational & Chaos
* **Oiled**: Turbocharges paddle speed by 1.5x–2.0x for 8–16 seconds.
* **Phase Shifter**: Sets all destructible tiles on the board to the exact same uniform health tier (1–6 HP).
* **Reforged**: Scrambles and randomizes the health of every destructible tile on the board independently (1–6 HP).
* **Mystery**: Surprises the player by rolling a completely random power-up effect.

### ⏱️ Spawning & Pacing Rules
* **Combo Drops**: Chaining hits to every 3rd combo multiplier (`combo % 3 == 0`) spawns a power-up.
* **Pity Guarantee**: If no power-up has dropped from combos, hitting the 8th tile guarantees a power-up spawn.
* **Periodic Drops**: A random power-up capsule descends from the ceiling every 24 seconds.
* **Clean State Reset**: Active power-up timers, paddle size/speed modifiers, and falling capsules automatically reset to default when a ball is lost or when advancing to the next stage.

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

The project supports multi-platform exports (**Itch.io Web**, **YouTube Playables Web**, and **Android APK**) and includes a `Makefile` to streamline builds, packaging, and local testing:

```bash
# Build and package both web platforms (Itch.io & YouTube Playables)
make build-all

# --- Android APK Targets ---
# Export Android APK to build/android/breakout.apk (default: release)
make export-android

# Export and package into versioned APK (build/Breakout-vX.Y.Z.apk)
make build-android

# Build in debug mode (uses debug keystore)
make build-android RELEASE=false

# Clean only Android build artifacts
make clean-android

# --- Itch.io Targets ---
# Export Web build to build/itch/
make export-itch

# Export and package into versioned zip (build/Breakout-Itch-vX.Y.Z.zip)
make build-itch

# Run local HTTP server for Itch build (http://localhost:8000)
make server-itch

# --- YouTube Playables Targets ---
# Export Web build with YouTube SDK connector to build/youtube/
make export-yt

# Export and package for YouTube Playables (build/Breakout-YouTube-vX.Y.Z.zip)
make build-yt

# Run local gzip-compressed HTTP server for YouTube Playables Test Suite
make server-yt

# --- Cleanup ---
# Remove entire build/ directory
make clean
```

### 📺 YouTube Playables Integration
- **SDK Bridge**: Fully integrated with the official YouTube Playables SDK (`vendor/youtube/yt_playable_sdk.gd` and `yt_game_sdk.js`).
- **Platform Lifecycle**: Automatically handles platform `onPause`, `onResume`, and `onAudioEnabledChange` events.
- **Whole-Game Pausing**: Freezes gameplay, physics, and countdown animations during YouTube pauses.
- **Cloud Progress**: Automatically syncs level unlocks, star ratings, and survival high scores via YouTube cloud storage (`saveData` / `loadData`).
- **GZIP Compression**: Built-in development server (`scripts/server.py`) with GZIP compression to meet YouTube's < 30 MiB initial bundle size requirement.
