# WIZARDS! — M04 v0.4.0
A first-person movement testbed for PC. Godot source project, not an executable or HTML game.

## Open and play
1. Download the standard (non-.NET) Godot **4.5 stable** editor: https://godotengine.org/download/archive/4.5-stable/
2. Extract this ZIP fully to a writable folder.
3. In Godot Project Manager choose **Import**, select `project.godot`, then **Import & Edit**.
4. Press **F6** only when testing an individual scene; press **F5** to launch the whole project.
5. WASD moves; Space jumps; Ctrl+S toggles crouch; hold Shift to sprint; mouse looks; Escape releases the pointer; left click captures it again.
6. Stop using F8 in the editor or close the running window.

Renderer: Compatibility. Physics: 60 Hz. No add-ons, downloaded assets, .NET, or Blender required.
The project pins an established engine version for reproducibility; this is not a claim that it is the latest release.
Use a PC with keyboard and mouse. Mobile controls are outside M01.

## What is included
One 40 m graybox arena; floor, walls, blocks and low beam; one capsule player;
eye-level FPS camera; normalized WASD movement; gravity and collision; capture/focus handling;
a small headless integration test; project state, ADR, backlog and manual test plan.
M01–M04 are implemented; combat, runes and broom follow later.

## Tuning
Select Player in `scenes/player/player.tscn`: Walk Speed defaults to 6 m/s, Sprint Speed to 9 m/s, Jump Speed to 7 m/s, Gravity to 20 m/s².
Select View: mouse sensitivity defaults to 0.12 degrees/pixel; Invert Y is available.
Camera3D: FOV 80 degrees. Baseline intentionally has immediate acceleration and stopping.
This is temporary M01 movement, not the future momentum/crouch model.

## Verification
See `docs/TEST_RESULTS.md`. Engine import and headless physics checks were run in Linux.
Interactive camera feel, GPU rendering, focus behavior on your OS and the five-minute playtest
remain unverified. M01 awaits those checks; no exported executable was tested.

## Run automated test
Replace `godot` with your Godot executable path if it is not on PATH:
```
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/m01_smoke.gd
godot --headless --path . --script res://tests/m02_smoke.gd
godot --headless --path . --script res://tests/m03_smoke.gd
godot --headless --path . --script res://tests/m04_smoke.gd
```
Expected: PASS lines, `M01 failures: 0` and `M02 failures: 0`, exit code 0.

## Continue development
Read `docs/PROJECT_STATE.md`, `docs/ARCHITECTURE.md` and `docs/TEST_PLAN.md`.
Return your OS, Godot version and any exact errors alongside test feedback.
Next is M05 Sniper Tag and knockback after playtest feedback.

## Version control
This delivery includes source and a `git-baseline.bundle`, not editor caches.
To reconstruct the recorded repository: `git clone git-baseline.bundle wizards-dev`.
Alternatively use the extracted source directly and start your own Git repository.
Do not combine two independent copies when editing. Commit each tested milestone.

## M03 crouch
Ctrl+S toggles once per chord press. Holding the chord does not repeat. S is reserved for crouch
while Ctrl is held; ordinary S still moves backward. Collider height drops from 1.8 to 1.0 m,
eye from 1.65 to 0.85 m. Eye snaps with collider to avoid clipping under an obstruction.
Standing is rejected under a low ceiling; press the chord again after moving clear.
Crouch itself does not change velocity or apply a speed penalty; standard movement/braking still
operates. This is not the later slide/bunny-hop momentum system.

## M04 health/damage testbed
Player and orange dummy start at 100 HP. **H** damages the player by 25; **J** damages the dummy
by 25, regardless of aim/range. These are temporary debug controls, not weapons. Holding a key
should not repeatedly damage. HUD and overhead dummy text show HP/death. At zero HP the player
loses controls. Stop and run again to reset. Respawn is M06; Sniper Tag/knockback is M05.
Dead dummy remains collidable for now. No healing, scoring or death animation is implemented.
