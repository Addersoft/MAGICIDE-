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
Arena dimensions: 40 x 40 m, boundary wall height 4 m. Units are metres.
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
