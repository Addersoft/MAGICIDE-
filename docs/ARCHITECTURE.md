# Architecture — M01
Main instances ArenaGraybox and exactly one Player. HUD is display-only.
Player is CharacterBody3D with origin at feet, 1.8 m capsule height and radius 0.35 m.
View is at local Y=1.65 m, contains the only current Camera3D.

- player_input.gd owns raw input, capture and look signals. Emits pixel delta; polls action vector.
- player_camera.gd owns View yaw/pitch, clamp and horizontal movement basis. Never moves the body.
- player_controller.gd owns velocity and the only move_and_slide call in _physics_process.

MovementController extraction is deferred until it has a meaningful second responsibility.
No unused manager skeletons, autoloads or network framework. Input-to-movement seam is local only;
this is not prediction-ready multiplayer. State ownership must survive future extraction.

Collision layer 1: solid world. Layer 2: player. Player mask 1, world mask 2.
Arena dimensions: 40 x 40 m. M01–M08 walls were 4 m; M09 raised boundary walls to 16 m with a
ceiling so hover cannot leave the box. Interior obstacles are unchanged. Units are metres.
Definitions/resources contain authored values; no mutable actor state in shared Resources.
Physics uses 60 ticks/s; velocities are metres/s, gravity metres/s². Mouse uses screen-relative
pixel displacement without multiplying by frame delta. No third-person mode exists in M01.

Relevant API references (Godot 4.5):
https://docs.godotengine.org/en/4.5/classes/class_characterbody3d.html
https://docs.godotengine.org/en/4.5/classes/class_inputeventmousemotion.html

M03: PlayerPosture owns collider shape/offset and requests eye height through PlayerCamera.
Collider shape is duplicated per instance before editing. A full standing capsule shape query
excludes self and uses the player's collision mask. Failed stand leaves posture unchanged.
Eye snaps with collider; movement/camera orientation owners remain unchanged. Queries and posture
changes occur in the physics callback. No animation or separate movement state machine added.
M10: Posture also owns sliding (same low capsule as crouch). Slide velocity stays in PlayerController.

M04 HealthComponent owns current HP and is_dead; apply_damage returns actual HP removed. Invalid/nonpositive inputs rejected. Lethal state commits before signals to prevent reentrant duplicate death. Per-node state, no shared resource HP. PlayerController disables input on died and blocks movement/actions while dead, retaining gravity. DamageTestbed is scene-local debug input/HUD glue; remove debug hotkeys when production controls replace them. Dummy StaticBody retains collision on death until lifecycle milestone.

M05: CombatController receives primary_requested and resolves a pending request in physics. Cooldown
is simulation seconds. Eye-origin ray excludes caster RID, checks layers 1|2, and stops at first body.
No muzzle exists yet, so camera origin is the actual cast origin. Range 1000 m covers this arena;
revisit range when map bounds expand to preserve no gameplay-range limit. No mana dependency.
Accepted hit calls Health.apply_damage, then target.apply_knockback only if HP was actually removed.
Shot feedback signal is presentation only. No timers/particles determine damage.

KnockbackComponent owns horizontal external velocity and bounded linear decay; it never moves a body.
PlayerController and DummyController remain their respective sole movement owners. They combine
input/external velocity, integrate vertical impulses/gravity and call move_and_slide once per tick.
Collision normals remove blocked external velocity after motion. Dead bodies can retain hit impulse.
Dummy changed from StaticBody3D to CharacterBody3D because it now receives physical movement.
Layer 1 = world; layer 2 = actors; actors use mask 3; attack ray uses mask 3 and excludes caster.
PlayerPosture standing queries automatically inherit the actor mask and therefore include the dummy.

M06: each actor contains RespawnController, which stores its initial transform and a duplicate of
the original standing collider. It owns a single waiting/countdown state, not a SceneTree timer.
At expiry it checks that shape against actor mask 3, excluding the actor's RID. Retry every .25 s
if blocked. Successful reset calls actor.reset_for_respawn(spawn) in physics; the actor remains the
same node, so scene-local HUD references and health subscriptions stay valid. No duplicate actors.

The actor resets transform/velocity/external impulse, player posture/view/input/combat, then calls
Health.reset_full last. Health owns the actual HP/dead mutation. Combat reset clears cooldown and
pending shot and emits presentation reset. Respawn emits respawned after reset. Physics interpolation
history resets on teleport. Dead colliders remain until the in-place reset. Ready state does not
recapture the mouse; a deliberate click does, without an attack. Scene destruction owns all lifetime.

M07 RoundManager owns 180 s remaining time, ended latch and one deferred restart request. Physics
priority -100 resolves expiry before actor priority 0, so a final-tick queued shot/respawn cannot run
after expiry. End disables gameplay capture and damage and disables processing on both actor subtrees.
HUD/root continue processing; the SceneTree is not globally paused. Collision bodies remain in place.

RoundHUD owns clock/overlay/button presentation and invokes manager.restart_round; no gameplay
arithmetic in UI. Restart reloads the complete current scene (not a patchwork of actor resets), restoring
arena/actors/subscriptions/timers from source. Repeated restart requests are coalesced until reload.
Health has a damage_enabled gate for ended-round direct calls; new scene resets it to true.
PlayerInput gameplay_enabled gate prevents recapture of controls after time expires.

M08: RuneDefinition resources are authored data only. RuneQueue owns bound loadout and the live
three-slot array (index 0 = newest). SpellCatalog.resolve is a pure function. CombatController still
owns cooldown, pending shot and the physics ray. Empty queue uses Tag damage; Kenaz-only uses scaled
damage then consume(); unsupported emits cast_failed and does not touch cooldown or the ray.
PlayerInput emits rune_insert_requested(0..2) and rune_clear_requested. RuneHud and RuneBillboard are
presentation. No autoload. No 24-rune script.

M09: BroomController owns mounted state, hover integrate and the placeholder subject mesh.
PlayerController remains the only move_and_slide caller and switches between _foot_physics and
_broom_physics. Mounted motion_mode is FLOATING with gravity omitted; dismount restores GROUNDED.
View/Camera3D stays the FPS camera and the combat aim origin.
WASD on broom is look-relative; S is reverse; Space/Ctrl are climb/descend. F toggles mount.
Death and respawn call force_dismount. Boost is not present.

M10: ChaseRig copies View yaw/pitch plus broom roll with an exponential look lag (~133 ms) instead of
look_at(..., WORLD_UP). Boom position is in that lagged basis. Hover planar velocity is rotated by
look-yaw delta so a 180 flick reverses travel. On-foot Ctrl while moving starts a posture slide;
stationary Ctrl+S remains crouch. Mounted Ctrl is still descend.
