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
