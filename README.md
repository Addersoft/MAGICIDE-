# WIZARDS! — M10
PC Godot source project. Includes M01–M10: FPS movement, jump/sprint/crouch/slide, health,
Sniper Tag, knockback, automatic respawn, timed practice rounds, Kenaz rune queue,
and broom hover with a Warhawk (2007) third-person chase camera.
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
| WASD / mouse | On foot: move / aim FPS. On broom: look-relative strafe/forward/back |
| Space | Ground jump on foot. Climb while mounted (held). |
| Hold Shift | Sprint on foot. Unbound on broom (boost is later). |
| Ctrl (walk/run) | Slide on foot. |
| Ctrl+S (still) | Toggle crouch on foot. |
| Ctrl (mounted) | Descend. S still reverses. |
| F | Mount / dismount broom |
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
Ctrl while walking or running is a short slide (low capsule, extra speed). Stationary Ctrl+S
still toggles crouch and still reserves S from backward input. Crouch adds no speed penalty.
Walk 6 m/s; sprint 9 m/s; jump launch 7 m/s; gravity 20 m/s². These remain tunable baselines.

## M09/M10 broom — Warhawk camera
Press **F** to mount. The camera blends in **0.3 s** to a chase cam about **4 m behind**.
You are the subject. This is Incognito's Warhawk (2007) chase, not a world-up look-at:

- Mouse aim is instant on the wand/eye.
- The chase camera **lags ~133 ms** catching up to wherever the mouse points.
- The camera **banks with the broom** (strafe + turn-rate roll). Horizon is not locked.
- Flick look 180 while moving: travel **redirects on a dime** with the nose.
- **S** is reverse. Release WASD: stop on a dime.
- Space up, Ctrl down; altitude holds when you let go.
- Boost, broom HP and jet mode are not in this slice.

Arena walls are 16 m with a ceiling so hover cannot leave the graybox. Interior blocks are unchanged.
Tag still fires from the eye, not from the chase camera. Death and respawn force a dismount.

## Verification
Godot 4.5 stable Linux headless: editor import and checks across M01–M10 fixtures.
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
godot --headless --path . --script res://tests/m09_smoke.gd
godot --headless --path . --script res://tests/m10_smoke.gd
```
Each runner should report zero failures and exit 0. Manual testing remains necessary.

## Continue
Read docs/PROJECT_STATE.md first. Next after M10 camera/flight feel is accepted: **Isa as second rune** or
**broom boost**. Gate A playtest and standalone export remain open.
Runes beyond Kenaz, boost, cars, concentric rings and souls are not implemented.
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
