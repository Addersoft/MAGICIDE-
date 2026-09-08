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
