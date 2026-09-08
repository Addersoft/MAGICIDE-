# PROJECT_STATE
Current milestone: M01 v0.1.0 generated/reviewed; headless tests passed; manual acceptance pending.
Engine: Godot 4.5.stable.official.876b29033; standard GDScript; Compatibility; 60 Hz physics.
Implementation: one 40 m graybox arena, one FPS capsule, WASD, mouse look, gravity/collision,
mouse release/recapture, static instructions/crosshair. No later milestone features implemented.

Confirmed in headless Linux: editor import and 10 integration checks; see TEST_RESULTS.md.
Broken systems: none observed in executed checks; graphical behavior unknown.
Next task: developer imports project.godot and runs TEST_PLAN.md; fix M01 failures first.
After acceptance: M02 jump/sprint only. Do not advance automatically without test feedback.

Ownership: PlayerInput reads input; PlayerCamera script owns View yaw/pitch; PlayerController
is the only velocity/body movement owner. Main instances arena/player. No global manager.
Paths: scenes/boot/main.tscn, scenes/arenas/arena_graybox.tscn, scenes/player/player.tscn,
scripts/player/player_input.gd, scripts/player/player_controller.gd,
scripts/camera/player_camera.gd, tests/m01_smoke.gd.
Inputs: WASD, mouse; Escape release; click recapture. Physical keys in project.godot.
Capsule 1.8 m tall/radius .35 m, origin feet; eye 1.65 m; speed 6 m/s; pitch ±85°.
Layers: 1 world, 2 player. No runtime rune data structures yet.

Do not change: FPS on foot, future smooth third-person broom; data-driven runes newest-first;
CTRL+S future toggle preserves momentum; incremental tested milestones; honest verification.
Debt: baseline horizontal velocity assignment must change before external knockback/momentum;
no networking prediction, no saved preferences. See TECH_DEBT.md.
Decisions: ADR-001 records engine/renderer and minimal ownership. Target PC unknown.
Unresolved later: crouch chord/backward input, rune repeats/consumption/fallback/passives,
broom mount key. Full game baseline remains the user-provided master specification.
Checkpoint: docs/checkpoints/M01.md. Repository baseline is supplied as git-baseline.bundle.
