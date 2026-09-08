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

## M05 acceptance
Run tests/m05_smoke.gd and the earlier fixtures. Manual PC checks:
- Aim at orange capsule: click removes 12 HP and visibly pushes it; subsequent shot ready after 2 s.
- Rapid clicks/holding do not bypass cooldown. Hit HUD tracks actual damage; last lethal hit clamps.
- Aim at wall/block: no dummy damage through it. Shot still starts cooldown. Shooting empty sky misses.
- Escape then click: recapture only. Ctrl+click does not fire Tag. Dead player cannot fire.
- Push dummy against boundary walls; no penetration, vibration or delayed push after collision.
- Walk/jump/crouch/sprint while aiming: camera stays FPS and movement tests still pass.
- Restart scene after death. No respawn or dummy AI is claimed in M05.
- At 30/60/144 render caps with physics fixed at 60 Hz, compare cooldown and push distance.
Likely failure points: eye-origin aiming near cover, narrow collider hit regions, controller/impulse
mixing, OS mouse capture. Report exact reproduction, engine version, hardware and debugger output.

## M06 current acceptance (supersedes older stop/run-to-reset instructions)
Run m06_smoke.gd plus prior fixtures. In F5 play:
- H four times: player dies, controls release; countdown reaches respawn at about 3 s.
- Player returns to initial spawn at 100 HP, standing with original aim and no drift; click resumes
  without firing. Tag is ready. Repeat while crouched, jumping and moving.
- Kill dummy with Tag or J; it returns at 100 HP to its starting point after 3 s.
- Stand at dummy's starting point after killing it: it should wait with a blocked message.
  Move aside: the next clearance retry lets it respawn.
- Repeat deaths and restart while a respawn is pending; no duplicate actors, stale HUD or errors.
- Check pointer focus and camera reset visually. No camera transition to third person is permitted.
Automated tests include a shortened .05 s fixture for rapid cycles/unexpired cooldown reset;
the normal 3 s default is tested separately. The delay is an inspector-tunable prototype choice.

## M07 / Gate A acceptance
Run m07_smoke.gd and earlier fixtures. On PC:
- Play a full 3-minute round: clock reaches 00:00 once; movement/shooting/debug damage stop.
- End overlay is readable; pointer releases. Restart button works with mouse/keyboard.
- Restart restores arena, 100 HP actors at original spawns, posture/aim, ready Tag and no old respawns.
- Repeat restart during the test session; no duplicate actors or stale HUD.
- Ten-minute manual playtest with movement, crouch, jump, shooting, deaths/respawns and multiple
  rounds. Record OS/hardware/FPS/engine/debugger results. Headless fixtures do not replace this.
- Export with matching 4.5 stable templates and included Linux/Windows presets; run standalone.
- Gate A remains pending until visual/comfort checks, clean import and standalone execution pass.
The M07 automated fixture tests real scene reload plus near-expiry timing; it does not wait the full
three-minute wall-clock duration. Manual full-round timing remains explicitly pending.

## M08 acceptance
Run tests/m08_smoke.gd plus prior fixtures. In F5 play:
- Empty queue LMB still deals 12 Tag damage and starts the 2 s cooldown.
- Press 1: Kenaz appears in HUD slot 1 and as an orange cube over the caster.
- Press 1 three more times: still three Kenaz; oldest drops.
- Keys 2 and 3 do nothing. C clears cubes and HUD without shooting.
- One Kenaz then LMB: 16 damage, queue empties, 2 s cooldown.
- Three Kenaz then LMB: 24 damage.
- Camera stays first person. Round end still blocks insert/cast.

## M09 acceptance
Run tests/m09_smoke.gd plus prior fixtures. In F5 play:
- On foot the camera is FPS. Press F: 0.3 s blend to third person, broom/body visible.
- Hover: release WASD and the broom stops in about a quarter-second. S goes backward without turning.
- Flick look 180 then hold W: you travel the new forward. The chase camera swings behind the broom
  so the broom stays the subject (Warhawk-style), not a locked cockpit cam.
- Space climbs, Ctrl descends, altitude holds when those are released (no gravity).
- A/D strafe in the look frame. Camera stays upright; broom may roll slightly on strafe.
- F dismounts to FPS. Dismount in air falls. Death/respawn force dismount.
- Tag still aims from the eye, not from 4 m behind. Round end still blocks mount.
Headless checks cannot prove camera comfort. Record that as Gate A.

