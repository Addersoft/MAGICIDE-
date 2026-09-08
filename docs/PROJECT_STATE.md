# PROJECT_STATE
Current milestone: M02 v0.2.0 generated/reviewed; headless tests passed; manual acceptance pending.
Engine: Godot 4.5.stable.official.876b29033, Compatibility, 60 Hz physics, typed GDScript.
Implementation: M01 FPS graybox movement plus M02 Space jump and held Shift sprint.
Tests: engine import passes; M01 10/10 and M02 10/10 integration checks pass in Linux headless.
No visual/comfort, OS pointer or render-cap checks confirmed. User requested continuation with Go;
this authorized M02 but is not evidence of M01 manual acceptance.

Next: PC playtest and bug feedback; then M03 Ctrl+S crouch. Before M03 resolve S/backward chord
policy. Do not implement later features without instruction. No crouch, combat, runes or broom yet.
Ownership unchanged: PlayerInput polls actions; PlayerCamera owns View; PlayerController alone
writes velocity and calls move_and_slide. Input jump is a fresh press accepted only on the floor.
Speed: walk 6, sprint 9 m/s; jump 7 m/s upward, gravity 20 m/s². Sprint is omnidirectional and can
be held in air for this tunable baseline. No momentum model, buffering, variable jump or stamina yet.

Paths: project.godot; scenes/boot/main.tscn; scenes/player/player.tscn;
scripts/player/player_input.gd and player_controller.gd; scripts/camera/player_camera.gd;
tests/m01_smoke.gd, tests/m02_smoke.gd. Layers 1 world, 2 player.
Known bugs: none in executed checks; untested graphical behavior unknown.
Debt: immediate velocity assignment incompatible with eventual preserved momentum/impulses;
no saved settings; local input only. See TECH_DEBT.md.
Decisions: ADR-001 foundation, ADR-002 M02 tuning. Full baseline in user master specification.
Invariants: first person on foot; eventual third-person broom; data-driven newest-first runes;
Ctrl+S crouch must preserve momentum; no silent scope changes or claims of unrun tests.
Repository history: included git-baseline.bundle. Current checkpoint docs/checkpoints/M02.md.
