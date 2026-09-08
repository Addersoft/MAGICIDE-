# M01 acceptance
Automated fixture covers floor settling, exactly one player, camera activation, 6 m/s forward
travel, release stop, normalized diagonal motion, pitch-independent walking, obstacle collision,
pitch clamp and disabling movement on release. Run commands in README.

Manual checks still required on developer PC:
1. Fresh extract: import in Godot 4.5 stable, F5. No parser or recurring runtime errors.
2. Move/look five minutes: eye-level FPS, free yaw, clamped pitch, no upward walking when looking up.
3. Walk into all four boundary walls and blocks, slide along corners; no penetration or falling through.
4. Release movement: no drift. Diagonal speed feels equivalent to straight walking.
5. Escape: visible cursor and no walking. Click: recapture without a large camera jump.
6. Alt-tab out/back: capture stays released until click; held/released keys do not produce stuck movement.
7. Resize window: readable instructions/crosshair, constant mouse sensitivity.
8. Render caps 30/60/144 with physics fixed at 60: compare timed travel in clear space.
   The 40 m arena is too short for 10 seconds at 6 m/s. For the original 10-second criterion,
   temporarily extend the fixture floor and move boundary walls beyond 65 m on a test-only copy,
   then measure 60 m ±0.2 m at each cap. Do not ship that fixture modification in main scene.
9. Record OS, CPU/GPU/RAM, renderer, observed FPS, engine version, test outcomes.

Likely failures: OS-specific mouse capture/warp, graphics driver behavior, frame pacing, editor
embedded-game pointer handling. If embedded play misbehaves, use a separate game window and
report both results. Headless tests cannot prove comfort or visual correctness.
Stop if a check fails; give exact reproduction and debugger text. Do not add M02 over a blocker.
