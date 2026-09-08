# PROJECT_STATE
Milestone: M05 v0.5.0 generated/reviewed/headless tested; manual acceptance pending.
Engine: Godot 4.5 stable official 876b29033; Compatibility; physics 60 Hz.
Implemented M01–M05: FPS movement, jump/sprint/crouch, actor health, Tag and knockback.
Tests: headless import and 62 checks pass (10+10+11+12+19); all exit 0 in Linux.
Not verified: GPU/comfort, target OS pointer behavior, render cap comparison or exports.
Next: feedback/fixes then M06 death/respawn lifecycle. Timer M07, then runes, then broom.

Tag: LMB; 12 base damage; 2 s simulation cooldown; no mana; no falloff. Physics ray 1000 m
covers bounded arena, origin FPS eye, mask 3, excludes caster. First collider occludes all behind.
No rune queue yet; primary dispatch will route spells in rune milestone. Requests during cooldown
rejected; single pending click per tick. Recapture click never fires. Ctrl+LMB reserved for Link.
Capture loss and death cancel pending shots. Text-only hit/cooldown feedback; no wand/tracer/audio.
Knockback: hit direction *5 m/s velocity impulse; horizontal decay 12 m/s², vertical through gravity.
Component owns horizontal external state; each actor controller alone calls move_and_slide. Input
cannot overwrite external velocity. Wall collision discards blocked component. Lethal hit still pushes;
dead target rejects damage and new impulses from Tag. Dummy now CharacterBody3D, no AI.
Layers 1 world, 2 actors, actor masks 3. Health still sole HP/death owner. Dead input blocked.

Paths: scripts/combat/combat_controller.gd, knockback_component.gd, health_component.gd;
scripts/actors/dummy_controller.gd; scripts/ui/combat_status.gd; player_controller/input;
scenes/player/player.tscn, scenes/actors/dummy.tscn; tests/m01_smoke.gd through m05_smoke.gd.
Controls unchanged plus LMB Tag; H/J remain debug damage. Restart scene resets dead actors.
Known bugs: none observed in executed tests; pending manual acceptance is not evidence of success.
Debt: eye-origin/muzzle future policy, local authority, full movement momentum deferred, 1000 m
coverage assumes current arena, dead dummy collision until M06. See TECH_DEBT.md.
Invariants: FPS on foot, future third-person broom; data-driven newest-first runes; small milestones.
Decisions ADR-005 documents new impulse state and movable dummy. History in git-baseline.bundle.
Checkpoint docs/checkpoints/M05.md.
