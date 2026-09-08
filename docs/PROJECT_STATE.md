# PROJECT_STATE
Milestone: M08 v0.8.0 implemented/reviewed; Gate A manual/export still pending.
Engine: Godot 4.5 stable official, Compatibility, 60 Hz physics.
Implemented M01–M08: arena/player/dummy, FPS move/jump/sprint/crouch, health/Tag/knockback,
death/respawn, 3-minute practice round, Kenaz rune queue and Kenaz-only hitscan spell.
No broom, parkour suite, burning zones, horses, destruction, cars, or 24-rune catalog.
Next: verify M08 in editor, then either Isa as second rune or broom FPS→third-person proof.
Do not treat Gate A or Kenaz “feel” as confirmed without a PC playtest.

RuneQueue owns three slots, newest at index 0. Loadout[0] = kenaz; 2 and 3 unbound.
SpellCatalog.resolve is side-effect free. CombatController still owns the physics ray and cooldown.
Empty queue → Tag 12. Kenaz copies 1/2/3 → 16/20/24. Unsupported mix rejects without cooldown.
Successful Kenaz consume()s the queue. C clears. Respawn clears. Dead/uncaptured cannot insert.

Paths: scripts/runes/*; data/runes/kenaz.tres; scripts/combat/combat_controller.gd;
scripts/player/player_input.gd; scripts/ui/rune_hud.gd; scenes/player/player.tscn;
tests/m08_smoke.gd; docs/decisions/ADR-008-rune-queue.md.
Known bugs: none claimed beyond pending Gate A/export. Kenaz is hitscan, not fire volumes.
Debt: local authority, debug H/J, fixed spawns, eye-origin shot, one bound rune, no final art.
Decisions ADR-008. Checkpoint docs/checkpoints/M08.md. Retain first-person-on-foot rule.
