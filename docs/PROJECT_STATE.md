# PROJECT_STATE
Milestone: M04 v0.4.0 implemented/reviewed/headless tested; manual acceptance pending.
Engine: Godot 4.5 stable official 876b29033, Compatibility, 60 Hz.
Implemented: M01 FPS arena/controller, M02 jump/sprint, M03 crouch, M04 player/dummy health.
Tests: headless import and 43 checks pass (10+10+11+12), each runner exit 0, Linux.
No visual/comfort/OS input or render-rate validation confirmed.
Next: playtest/bug fixes, then M05 Tag/knockback. Respawn M06; timer M07. No runes/broom yet.

HealthComponent owns HP/dead, apply_damage(amount) returns actual removed HP, health_changed(current,
maximum) and died signals. Max/default 100. Nonfinite/negative/zero rejected, dead immune, death
committed before notifications. PlayerController gates dead movement and releases capture; PlayerInput
refuses dead recapture. Gravity remains active. Dummy remains collidable after death.
DamageTestbed debug-only H/J applies 25 direct damage and updates HUD/overhead text. Not a weapon.
Restart the running scene to reset. No respawn, healing, scoring or knockback implemented.

Paths: scripts/combat/health_component.gd; scripts/debug/damage_testbed.gd;
scenes/actors/dummy.tscn; player_controller.gd and player_input.gd; main.tscn;
tests/m01_smoke.gd through m04_smoke.gd. Prior body/input/camera/posture ownership unchanged.
Inputs: WASD, mouse, Space, Shift, Ctrl+S; Esc release, click capture if alive; H/J debug damage.
Ctrl+S suppresses backward S; crouch toggles once, preserves velocity in posture, queries stand space.
Known bugs: none observed in executed checks; interactive validation pending.
Debt: immediate movement model before impulses, debug hotkeys, persistent dead dummy collision,
no settings/networking. See TECH_DEBT.md.
Invariants: FPS on foot, future third-person broom; newest-first data-driven runes; small milestones.
Checkpoint docs/checkpoints/M04.md. Git history included as git-baseline.bundle.
