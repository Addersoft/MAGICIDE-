# PROJECT_STATE
Milestone: M03 v0.3.0 implemented/reviewed, headless tested; manual acceptance pending.
Engine: Godot 4.5 stable official 876b29033; Compatibility; 60 Hz physics.
Implemented: FPS graybox movement, jump/sprint, Ctrl+S crouch toggle and headroom check.
Verified: import and 31 checks (M01 10, M02 10, M03 11) pass in Linux headless.
Unverified: graphical playtest, pointer/focus on target PC, render cap comparison, comfort.
Next: manual feedback/bug fixes, then M04 health/damage. No combat/runes/broom yet.

Input policy: Ctrl+S reserved for crouch; S suppressed as backward input while Ctrl held.
Chord rising edge, one toggle; failed stand requires fresh press after moving clear.
Posture: standing collider 1.8 m / eye 1.65; crouched collider 1 m / eye .85; eye snaps safely.
PlayerPosture changes shape/offset, never velocity; PlayerCamera owns eye and view transform.
PlayerController still sole velocity/move_and_slide owner. PlayerInput owns chord detection.
Paths: scripts/player/player_posture.gd; player_controller.gd; player_input.gd;
scripts/camera/player_camera.gd; scenes/player/player.tscn; tests/m01–m03_smoke.gd.
Known bugs: none observed in executed checks. Manual acceptance remains outstanding despite Go.
Debt: baseline immediate movement still needs external impulse/acceleration design for knockback;
no full momentum system, saved settings or networking. Normal braking still applies while crouched.
Do not change: FPS on foot, future third-person broom, newest-first data-driven runes, small patches.
Decisions: ADR-001/002/003. Checkpoint: docs/checkpoints/M03.md. History in git-baseline.bundle.
