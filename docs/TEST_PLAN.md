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

## M02 manual acceptance
Run tests/m02_smoke.gd using the same command form. Then in the game:
- Space launches once, lands, and a fresh press jumps again. Hold Space through landing: no auto-hop.
- Press Space in the air: no double jump. Jump below the low beam: no ceiling penetration.
- Hold Shift while moving: faster than walking; diagonal motion does not add speed.
- Release Shift: walk speed returns. Escape/focus loss: movement and jump are blocked.
- Compare feel at render caps 30/60/144 with 60 Hz physics. Jump height/timing should be equivalent.
- Confirm all on-foot camera behavior remains FPS. No camera roll, head bob or sprint FOV shift added.

## M03 manual acceptance
- Ctrl+S once crouches; holding does not repeat; release/repress stands in clear space.
- W+Shift, then add Ctrl+S: speed should remain at sprint baseline.
- Ctrl+S alone does not move backward. S without Ctrl still moves backward normally.
- Jump/crouch and low ceilings: no camera inside roof, no standing through a roof.
- In a test scene add a roof with 1.3 m clearance: crouch fits, stand is denied; move out then retry.
- Esc or focus loss blocks crouch. Check chord after recapture for accidental toggles.
- Eye-height change currently snaps intentionally; report discomfort before adding smoothing.
Run tests/m03_smoke.gd as well as M01/M02. No future systems should mask a failed acceptance test.

## M04 manual acceptance
Run tests/m04_smoke.gd. In F5 play: H once reduces your HP by 25, J once reduces dummy HP by 25. Hold each: no repeat. Four J presses mark dummy DEAD. Four H presses mark you DEAD and release capture; movement/jump/crouch/click cannot revive you. Stop/run restores both to 100. Confirm HUD readable and prior movement checks still pass. Debug damage ignores distance/aim by design; no Sniper Tag yet.
