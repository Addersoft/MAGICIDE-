# PROJECT_STATE
Milestone: M07 v0.7.0 implemented/reviewed/headless tested; Gate A manual/export acceptance pending.
Engine: Godot 4.5 stable official 876b29033, Compatibility, 60 Hz physics.
Implemented M01–M07: one arena/player/dummy, FPS movement/jump/sprint/crouch, health/Tag/knockback,
death/respawn, 3-minute practice timer/end overlay/restart. No winner scoring, teams, runes or broom.
Tests: import +101 checks (10+10+11+12+19+22+17) pass in Linux headless. Full-length manual round,
ten-minute playtest, graphics/input comfort and standalone executable run remain unverified.
Template download failed; export presets included. Gate A is not accepted by headless tests alone.
Next: Gate A feedback/fixes and PC export, then M08 rune queue after unresolved rune semantics are
resolved. Do not silently treat implementation as confirmed fun/working graphically.

RoundManager owns timer, ended latch and coalesced deferred current-scene reload. Priority -100
processes expiry before actors. End releases capture, disables Health damage and actor processing;
HUD remains active. Root is not paused. RoundHUD owns clock, end overlay, Restart button.
Restart reconstructs whole arena/actors/timers from current scene. Escape does not pause clock.
Health.damage_enabled and input.gameplay_enabled prevent ended-round actions/direct damage.

Prior lifecycle: 3 s respawn at original standing-clear spawn, .25 s retry if blocked, in-place actor
reset, pointer remains released after individual respawn. Round restart uses normal startup capture.
Tag 12 damage/2 s/no mana/no falloff; eye ray1000 m covers arena. Horizontal impulse separate from
input. Layers1 world,2 actors; masks3. H/J debug damage. Crouch Ctrl+S suppresses backward S.
Paths: scripts/match/round_manager.gd; scripts/ui/round_hud.gd; main.tscn; input/health gates;
export_presets.cfg; tests/m01_smoke.gd through m07_smoke.gd. Full history git-baseline.bundle.
Known bugs: none in executed checks; manual/export gates remain pending. No templates obtainable here.
Debt: local authority, debug controls, fixed respawn/no dynamic floor, eye-origin shot, no final art.
Decisions ADR-007. Checkpoint docs/checkpoints/M07.md. Retain permanent first-person-on-foot rule.
