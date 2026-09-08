# PROJECT_STATE
Milestone: P01 — Parkour movement identity + Q/E roll (on top of M10).
Engine: Godot 4.5 stable official, Compatibility, 60 Hz physics.

Implemented M01–M10 plus P01 parkour:
- Arena/player/dummy, FPS move/jump/sprint/crouch/slide, health/Tag/knockback,
  death/respawn, 3-minute practice round, Kenaz rune queue, broom hover + Warhawk chase camera.
- ParkourMotor + TraversalProbe: momentum model (accel/braking), coyote + jump buffer (120 ms),
  wall-run (1.25 s budget), wall-jump (0.3 s same-wall lockout), low vault, high ledge hang + climb,
  slide with momentum retention + slide-jump launch, RMB glide (1.2 s), Q/E directional rolls.
- Q = counter-clockwise / left roll, E = clockwise / right roll (0.38 s, camera roll 360°, lateral boost).
- First-person retained throughout. Broom mount still forces motor reset.

No boost, burning zones, horses, destruction, cars, or 24-rune catalog.
Next: PC playtest of parkour feel + M10 camera/flight, then Isa as second rune or broom boost.
Do not treat Gate A as confirmed without a PC playtest.

Ownership:
- PlayerController alone writes velocity + move_and_slide.
- ParkourMotor owns horizontal momentum, state (GROUND/AIR/SLIDE/WALL RUN/HANG/VAULT/GLIDE/ROLL/DODGE), budgets.
- TraversalProbe owns bounded ray/shape queries; never teleports.
- PlayerPosture owns collider height; View owns eye + optional roll.
- Knockback interrupts hang/vault; death/respawn resets motor.

Paths: scripts/movement/parkour_motor.gd; scripts/movement/traversal_probe.gd;
scripts/player/player_controller.gd; scripts/player/player_input.gd;
scripts/camera/player_camera.gd; scenes/player/player.tscn;
docs/decisions/ADR-008-parkour-beam.md; docs/PARKOUR_DESIGN.md.

Debt: local authority, debug H/J, placeholder meshes, hover-only broom, one bound rune,
unanimated roll/slide, no dedicated parkour course in main arena yet, teleport still unbound (Q now roll).
Decisions ADR-008 (parkour scope) + ADR-010 (Warhawk camera). Retain first-person-on-foot rule.
