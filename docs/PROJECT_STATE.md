# PROJECT_STATE
Milestone: M09 v0.9.0 implemented/reviewed; Gate A manual/export still pending.
Engine: Godot 4.5 stable official, Compatibility, 60 Hz physics.
Implemented M01–M09: arena/player/dummy, FPS move/jump/sprint/crouch, health/Tag/knockback,
death/respawn, 3-minute practice round, Kenaz rune queue, broom hover + Warhawk chase camera.
No boost, parkour suite, burning zones, horses, destruction, cars, or 24-rune catalog.
Next: verify M09 hover/camera in editor, then Isa as second rune or broom boost.
Do not treat Gate A or broom “feel” as confirmed without a PC playtest.

BroomController owns mounted flag and hover integrate. ChaseRig owns the third-person camera.
On foot: View/Camera3D current. Mounted: ChaseRig/Camera3D current, 4 m back 2 m up, spring follow.
Hover 15 m/s, climb 8 m/s, damp 14, retrograde 1.6. F toggles mount. Death/respawn force dismount.
Combat still aims from View. Empty queue Tag 12. Kenaz 16/20/24 unchanged.

Paths: scripts/broom/broom_controller.gd; scripts/camera/broom_camera.gd;
scripts/player/player_controller.gd; scripts/player/player_input.gd;
scenes/player/player.tscn; scenes/arenas/arena_graybox.tscn; tests/m09_smoke.gd;
docs/decisions/ADR-009-broom.md.
Known bugs: none claimed beyond pending Gate A/export. Boost is not in this slice.
Debt: local authority, debug H/J, placeholder broom mesh, hover-only, one bound rune.
Decisions ADR-009. Checkpoint docs/checkpoints/M09.md. Retain first-person-on-foot rule.
