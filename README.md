# WIZARDS! — M07 v0.7.0
PC Godot source project. Includes M01–M07: FPS movement, jump/sprint/crouch, health,
Sniper Tag, knockback, automatic respawn and timed practice rounds. Not an HTML game or exported executable.

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
| Left click | Sniper Tag when captured and alive |
| Escape / click | Release / recapture pointer (recapture does not shoot) |
| H / J | Temporary debug: 25 damage to self / dummy |

Aim at the orange dummy, then click. Tag deals **12 damage**, has a **2-second cooldown**,
uses no mana, and has no damage falloff. Arena walls and blocks stop the ray.
The physics ray is 1000 m long, covering the bounded arena; no literal infinite coordinate.
Rapid clicks during cooldown are rejected, not queued for later. Hold does not auto-fire.
The HUD shows readiness and hit damage. No tracer, wand mesh or sound added yet.
Ctrl+LMB is reserved for future Link and does not fire Tag.

Hits push the dummy in the shot direction. Horizontal push decays and collides with walls;
player input does not erase external knockback. A lethal hit can still push the target.
The dummy does not attack. Both actors have 100 HP. Nine full Tag hits kill the dummy;
the last reports only HP actually removed. Dead targets take no further damage or impulse.
At player death controls lock. Both actors respawn after **3 seconds** if their spawn is clear.
Click to resume after player respawn; the click does not shoot.

Crouch uses a 1 m capsule and .85 m eye; standing uses 1.8 m and 1.65 m. Eye height snaps
with collider to avoid clipping under roofs. Blocked standing requires retry after moving clear.
Ctrl+S reserves S from backward input while Ctrl is held. Crouch adds no speed penalty.
Walk 6 m/s; sprint 9 m/s; jump launch 7 m/s; gravity 20 m/s². These remain tunable baselines.

## Verification
Godot 4.5 stable Linux headless: editor import and 101 checks pass across M01–M07 fixtures.
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
```
Each runner should report zero failures and exit 0. Manual testing remains necessary.

## Continue
Read docs/PROJECT_STATE.md first. Next: **Gate A playtest and standalone export verification** before rune proof and broom. Runes and broom are not implemented.
Git baseline/history is included as git-baseline.bundle; reconstruct with:
`git clone git-baseline.bundle wizards-dev`. Use either that clone or extracted source as your
working copy, not two independently edited copies. Engine caches are excluded from the ZIP.

## M06 lifecycle
On death, one per-actor respawn schedule starts. After 3 seconds the full standing capsule is
checked at that actor's original spawn. If occupied, the actor remains dead, the HUD explains why,
and clearance is retried every 0.25 seconds. Move out of the dummy's spawn to let it return.
There is no alternative spawn selector yet. The current static arena supplies the spawn floor.

Respawn restores 100 HP, standing posture, original location, FPS aim and eye height, zero velocity,
zero external impulse, and a ready Tag with no queued shot. Input remains released so the game
does not steal focus. Click to resume; held inputs may then move you normally. Dead actor visuals
and collision persist during the delay; no ragdoll or spawn protection is introduced.

## M07 practice rounds
The round starts immediately and lasts 3 minutes of simulation time. Escape releases the mouse but
does not pause the timer. At 00:00, gameplay stops, pending attacks/respawns stop, and the pointer is
released. Click **Restart round** (or activate its focused button with the keyboard) for a fresh round.
The arena, actors, health, movement, camera, cooldowns and pending respawns all reset by scene reload.
No winner/team score is invented for this single-player dummy practice slice.

The first-slice feature list is now implemented, but Gate A is **not yet accepted**: a real ten-minute
playtest, target-PC graphics/input checks and a standalone PC executable run remain pending.

## Export on your PC
Linux and Windows Desktop x86_64 presets are included in export_presets.cfg. In Godot 4.5 stable,
install the matching export templates through **Editor > Manage Export Templates**, create an
`exports` folder, then use **Project > Export**, choose a preset and Export Project (release).
Keep this source ZIP as the reproducible baseline. Export presets have not produced a verified
executable here: template download failed and the Linux export attempt reported missing templates.
