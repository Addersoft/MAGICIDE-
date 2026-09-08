# WIZARDS! — M01 v0.1.0
A first-person movement testbed for PC. Godot source project, not an executable or HTML game.

## Open and play
1. Download the standard (non-.NET) Godot **4.5 stable** editor: https://godotengine.org/download/archive/4.5-stable/
2. Extract this ZIP fully to a writable folder.
3. In Godot Project Manager choose **Import**, select `project.godot`, then **Import & Edit**.
4. Press **F6** only when testing an individual scene; press **F5** to launch the whole project.
5. WASD moves; mouse looks; Escape releases the pointer; left click captures it again.
6. Stop using F8 in the editor or close the running window.

Renderer: Compatibility. Physics: 60 Hz. No add-ons, downloaded assets, .NET, or Blender required.
The project pins an established engine version for reproducibility; this is not a claim that it is the latest release.
Use a PC with keyboard and mouse. Mobile controls are outside M01.

## What is included
One 40 m graybox arena; floor, walls, blocks and low beam; one capsule player;
eye-level FPS camera; normalized WASD movement; gravity and collision; capture/focus handling;
a small headless integration test; project state, ADR, backlog and manual test plan.
Only M01 is implemented. Jump/sprint are M02; crouch is M03; combat, runes and broom follow later.

## Tuning
Select Player in `scenes/player/player.tscn`: Walk Speed defaults to 6 m/s, Gravity to 20 m/s².
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
```
Expected: PASS lines, `M01 failures: 0`, exit code 0.

## Continue development
Read `docs/PROJECT_STATE.md`, `docs/ARCHITECTURE.md` and `docs/TEST_PLAN.md`.
Return your OS, Godot version and any exact errors alongside test feedback.
The next feature task is M02 only, after M01 playtest acceptance.

## Version control
This delivery includes source and a `git-baseline.bundle`, not editor caches.
To reconstruct the recorded repository: `git clone git-baseline.bundle wizards-dev`.
Alternatively use the extracted source directly and start your own Git repository.
Do not combine two independent copies when editing. Commit each tested milestone.
