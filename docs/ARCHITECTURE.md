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
