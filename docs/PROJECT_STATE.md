# PROJECT_STATE
Milestone: M10 — Warhawk camera (roll + mouse lag), dime-turn hover, Ctrl slide.
Engine: Godot 4.5 stable official, Compatibility, 60 Hz physics.
Implemented M01–M10: arena/player/dummy, FPS move/jump/sprint/crouch/slide, health/Tag/knockback,
death/respawn, 3-minute practice round, Kenaz rune queue, broom hover + Warhawk chase camera.
No boost, parkour suite, burning zones, horses, destruction, cars, or 24-rune catalog.
Next: PC playtest of M10 camera/flight/slide, then Isa as second rune or broom boost.
Do not treat Gate A as confirmed without a PC playtest.

BroomController owns mounted flag, hover integrate, visual roll. ChaseRig owns the third-person
camera: lagged aim basis including roll, boom in that space. On foot: View/Camera3D current.
Mounted: ChaseRig/Camera3D current. Hover 15 m/s, climb 8 m/s, damp 22, velocity yaws with look.
F toggles mount. Death/respawn force dismount. Combat still aims from View.
On foot Ctrl while walking/running slides; stationary Ctrl+S crouches; mounted Ctrl descends.

Paths: scripts/broom/broom_controller.gd; scripts/camera/broom_camera.gd;
scripts/player/player_controller.gd; scripts/player/player_input.gd;
scripts/player/player_posture.gd; tests/m10_smoke.gd;
docs/decisions/ADR-010-warhawk-camera.md.
Debt: local authority, debug H/J, placeholder broom mesh, hover-only, one bound rune, unanimated slide.
Decisions ADR-010. Checkpoint docs/checkpoints/M10.md. Retain first-person-on-foot rule.
