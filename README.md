# WIZARDS! — M08 v0.8.0
PC Godot source project. Includes M01–M08: FPS movement, jump/sprint/crouch, health,
Sniper Tag, knockback, automatic respawn, timed practice rounds, Kenaz rune queue and first spell.
Not an HTML game or exported executable.

## Run
1. Download the standard Godot **4.5 stable** editor:
   https://godotengine.org/download/archive/4.5-stable/
2. Extract this archive fully into a new writable folder. This is a complete project; do not overlay an older copy.
3. Import `project.godot` in Godot Project Manager; choose Import & Edit.
4. Press **F5**. Mouse and keyboard required. F8 stops the running scene.

Renderer Compatibility; 60 Hz physics; no .NET, add-ons or external assets required.
Godot 4.5 is pinned for reproducibility, not claimed to be the latest version.

## Controls
| Input | Behavior |
|---|---|
| WASD / mouse | Move / aim in first person |
| Space | Ground jump, fresh press |
| Hold Shift | Sprint |
| Ctrl+S | Toggle crouch, one toggle per press |
| 1 | Insert Kenaz at slot 1 (newest). 2 and 3 are unbound. |
| C | Clear the rune queue (does not shoot) |
| Left click | Sniper Tag if queue empty; Kenaz cast if queue is Kenaz-only |
| Escape / click | Release / recapture pointer (recapture does not shoot) |
| H / J | Temporary debug: 25 damage to self / dummy |

Empty-queue Tag is unchanged: **12 damage**, **2-second cooldown**, no mana, no falloff.
Kenaz-only queues deal **16 / 20 / 24** for 1 / 2 / 3 copies, same cooldown and hitscan.
Unsupported mixes do not fire Tag, do not start cooldown, and keep the queue.
Successful Kenaz consumes the whole queue. Arena walls still stop the ray.

Aim at the orange dummy, then click. The HUD shows queue slots, readiness and hit damage.
Three colored cubes above the caster mirror the queue in world space.
Ctrl+LMB is reserved for future Link and does not fire Tag.

Hits push the dummy in the shot direction. Horizontal push decays and collides with walls;
player input does not erase external knockback. A lethal hit can still push the target.
The dummy does not attack. Both actors have 100 HP. Dead targets take no further damage or impulse.
At player death controls lock. Both actors respawn after **3 seconds** if their spawn is clear.
Click to resume after player respawn; the click does not shoot. Respawn clears leftover runes.

Crouch uses a 1 m capsule and .85 m eye; standing uses 1.8 m and 1.65 m. Eye height snaps
with collider to avoid clipping under roofs. Blocked standing requires retry after moving clear.
Ctrl+S reserves S from backward input while Ctrl is held. Crouch adds no speed penalty.
Walk 6 m/s; sprint 9 m/s; jump launch 7 m/s; gravity 20 m/s². These remain tunable baselines.

## Verification
Godot 4.5 stable Linux headless: editor import and checks across M01–M08 fixtures.
No GPU rendering, camera comfort, target-PC mouse/focus, exported executable, or render-cap
comparison is confirmed. See docs/TEST_RESULTS.md and docs/TEST_PLAN.md.

Run from this project folder, replacing `godot` with your executable path:
```
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/m01_smoke.gd
godot --headless --path . --script res://tests/m02_smoke.gd
godot --headless --path . --script res://tests/m03_smoke.gd
godot --headless --path . --script res://tests/m04_smoke.gd
godot --headless --path . --script res://tests/m05_smoke.gd
godot --headless --path . --script res://tests/m06_smoke.gd
godot --headless --path . --script res://tests/m07_smoke.gd
godot --headless --path . --script res://tests/m08_smoke.gd
```
Each runner should report zero failures and exit 0. Manual testing remains necessary.

## Continue
Read docs/PROJECT_STATE.md first. Next after M08 feel is accepted: **Isa as second rune** or
**broom mount / third-person camera**. Gate A playtest and standalone export remain open.
Runes beyond Kenaz, broom, cars, concentric rings and souls are not implemented.
Use this working copy, not two independently edited copies. Engine caches are excluded.

## M06 lifecycle
On death, one per-actor respawn schedule starts. After 3 seconds the full standing capsule is
checked at that actor's original spawn. If occupied, the actor remains dead, the HUD explains why,
and clearance is retried every 0.25 seconds. Move out of the dummy's spawn to let it return.
There is no alternative spawn selector yet. The current static arena supplies the spawn floor.

Respawn restores 100 HP, standing posture, original location, FPS aim and eye height, zero velocity,
zero external impulse, a ready Tag with no queued shot, and an empty rune queue. Input remains
released so the game does not steal focus. Click to resume; held inputs may then move you normally.

## M07 practice rounds
The round starts immediately and lasts 3 minutes of simulation time. Escape releases the mouse but
does not pause the timer. At 00:00, gameplay stops, pending attacks/respawns stop, and the pointer is
released. Click **Restart round** (or activate its focused button with the keyboard) for a fresh round.
The arena, actors, health, movement, camera, cooldowns, rune queue and pending respawns all reset
by scene reload. No winner/team score is invented for this single-player dummy practice slice.

## M08 rune queue
Press **1** to push Kenaz. Newest rune is the left slot. A fourth insert drops the oldest.
**C** clears. Left click with an empty queue is still Tag. Left click with one to three Kenaz
casts the fire hitscan (16/20/24). Mixed/unknown recipes are rejected and keep the queue.
Kenaz does not yet create burning zones or projectiles.

The first-slice plus Kenaz proof is implemented, but Gate A is **not yet accepted**.

## Export on your PC
Linux and Windows Desktop x86_64 presets are included in export_presets.cfg. In Godot 4.5 stable,
install the matching export templates through **Editor > Manage Export Templates**, create an
`exports` folder, then use **Project > Export**, choose a preset and Export Project (release).
Export presets have not produced a verified executable here.
