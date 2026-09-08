# Test evidence — 2026-09-08
Environment: Linux x86_64 container, Godot 4.5.stable.official.876b29033, headless.
Project configured Compatibility, physics 60 Hz. GPU output not assessed.

Executed: headless editor import --quit. Exit 0; no parser errors reported.
Executed: --headless --script res://tests/m01_smoke.gd. Exit 0, M01 failures: 0.
Passed: floor settling; one player; current FPS camera; 6 m forward over 60 physics ticks;
release stops horizontal movement; diagonal speed 6 m/s with pitched view; no pitch-induced lift;
obstacle blocks motion; pitch clamp; capture release disables movement.

Not executed: interactive graphical playtest, OS pointer/focus scenarios, 30/60/144 render-rate
comparison, five-minute soak or exported desktop executable. These are pending acceptance.
Status: generated, reviewed, tested headlessly. Confirmed only for the listed checks/environment.

## M02 v0.2.0
Same Linux headless Godot 4.5 stable environment. Editor import exit 0, no parser errors.
M01 regression fixture: all 10 checks pass, exit 0.
M02 fixture: all 10 checks pass, exit 0: physical Space/Shift mappings; 9 m sprint over 60 ticks;
normalized diagonal sprint; releasing Shift restores 6 m/s; ground jump launch; no air double
jump; held jump does not repeat on landing; released capture blocks actions; low beam blocks jump.
Manual visual/feel checks and render-cap comparison remain pending. User explicitly requested
continuation to M02; that instruction does not establish that M01 manual tests passed.

## M03 v0.3.0
Headless editor import: exit 0. M01 and M02 regression fixtures: 10 checks each pass, exit 0.
M03 fixture: 11 checks pass, exit 0. Covers Control mapping, chord toggle and no repeat, forward
sprint speed through toggle, eye/collider dimensions, open-space stand, obstructed stand rejection,
eye stays low, clearance recovery, posture does not mutate velocity, released capture blocks toggle.
Environment unchanged: Godot 4.5 stable Linux headless. Manual graphics/feel/capture and render-rate
comparison remain pending. Test evidence does not establish full parkour momentum functionality.

## M04 v0.4.0
Godot 4.5 stable Linux headless import exit 0. All prior 31 checks pass. M04 12 checks pass: actor initial/independent HP, invalid values, subtraction, dummy clamp/death label, actual overkill damage, reentrant single death, dead damage rejection, blocked recapture/movement/jump, death HUD. All runners exit 0. Total 43. Interactive key handling, rendering, camera comfort and frame-cap comparisons remain unverified.

## M05 v0.5.0
Godot 4.5 stable official 876b29033, Linux headless. Import exit 0, no parser errors.
M01/M02/M03/M04: all 43 prior checks pass, all exit 0.
M05: 19 checks pass, exit 0: LMB 12 damage, caster excluded, 2 s cooldown start, rapid requests
rejected, dummy displacement/decay, cooldown persistence/expiry, wall occlusion/blocked-shot cooldown,
recapture no-fire, Ctrl+LMB no-fire, capture-loss cancel, repeat damage, player horizontal/vertical
impulse retention, crouch impulse retention, death cancel, boundary collision and blocked-impulse cleanup.
Total: 62 assertions. M05 rerun after adding boundary fixture; both runs exited 0.
Not tested: GPU output, manual camera/aim feel, target-PC focus handling, render-cap comparison,
network behavior or executable export. The shot test dispatches mouse events to the input handler;
it does not simulate a physical OS pointer or establish interactive graphics correctness.

## M06 v0.6.0
Linux headless Godot 4.5 stable official 876b29033: editor import exit 0, no parser errors.
All 62 earlier checks pass; M06 adds 22 passing checks, total 84, all runners exit 0.
M06 covers one death/schedule, delay/no early return, health/location/velocity/posture/aim/eye reset,
ready combat, explicit recapture, fast cooldown/impulse reset, repeated cycles/node count, blocked
spawn UI/clearance recovery, standing shape after crouched death, dummy reset and clean scene reload.
Initial M06 run had two assertion failures due to exact float comparisons of engine-stored 1.8/1.65
values; tests changed to approximate comparison without changing production reset behavior. Rerun
passed; extra fast-cooldown/impulse assertions also passed in final M06 run.
No graphical/comfort, OS focus/capture, frame-cap comparison or executable export verified.
