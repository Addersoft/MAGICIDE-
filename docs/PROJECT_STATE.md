# PROJECT_STATE
Milestone: M06 v0.6.0 generated/reviewed/headless tested; manual acceptance pending.
Engine: Godot 4.5 stable official 876b29033, Compatibility, physics 60 Hz.
Implemented M01–M06: FPS movement, jump/sprint/crouch, health/damage, Tag/knockback, respawn.
Verification: headless import +84 checks (10+10+11+12+19+22), all pass in Linux; no graphical or
OS input/comfort validation. Explicit Go allowed progression, not evidence of passed manual tests.
Next: manual feedback/fixes then M07 three-minute round timer and first-slice integration. No runes,
broom, scoring or round system yet. Existing startup arena remains fixed/static.

RespawnController per actor: remembers original transform and standing shape; on death starts one
3 s countdown. At expiry query mask 3 excluding self; if occupied wait/retry every .25 s with HUD
reason. Does not find alternative spawns or remove dead-body collisions. In-place reset preserves
node identity/references. Original floor is assumed present; no destruction yet.
Actor.reset_for_respawn owns transform/velocity/impulse reset; player additionally resets posture,
view aim, input, Tag cooldown/pending shot. Health.reset_full restores max HP last. Respawned signal.
Pointer remains released after respawn; click resumes and does not shoot. Reset interpolation history.

Tag unchanged: 12 base damage,2 s cooldown,no mana,no falloff,1000 m eye-origin ray covers arena.
Knockback: direction*5 m/s, horizontal decay12; body remains sole motion owner. Crouch no penalty.
Layers:1 world,2 actors; actor masks3. H/J debug damage; dead targets immune until respawn.
Paths: scripts/actors/respawn_controller.gd; player_controller/input/posture; health/combat;
dummy_controller.gd; ui/combat_status.gd; debug/damage_testbed.gd; actor/player scenes;
tests/m01_smoke.gd through m06_smoke.gd. Prior ownership contracts unchanged.
Known bugs: none in executed checks; manual acceptance remains pending.
Debt: fixed spawn/no alternate selection or dynamic-floor validation, local authority, placeholder
corpse/feedback, no advanced acceleration/momentum or saved preferences. See TECH_DEBT.md.
Invariants: FPS on foot, eventual third-person broom, data-driven newest-first runes, small patches.
ADR-006 documents respawn choices. Checkpoint docs/checkpoints/M06.md; history git-baseline.bundle.
