# P01 — user-requested movement identity pass
The user explicitly requested parkour modeled on Titanfall, Warframe and Mirror's Edge plus a
Piccolo Special Beam Cannon-style sniper wand. This authorizes the movement model change and
these traversal systems ahead of the previous rune milestone order. First-person identity remains.

Design interpretation:
- Momentum-preserving wall runs, wall jumps and timed landing jumps.
- Slides, directional slide-jump launches, brief controlled air glide, evasive dodge / Q/E rolls.
- Reachable ledge catches, deliberate Space climbs, and clearance-tested low vaults.
- 120 ms jump input buffer/coyote time; variable jump height; no automatic held hopping.
- A procedural gold/white beam with violet helical wrap and impact, no damage rebalance.
These are inspirations/tuning choices, not measured replicas of the named games' physics.

## Ownership
PlayerController alone writes actor movement and calls move_and_slide once per physics tick.
ParkourMotor computes locomotion and owns transient mode/budgets/horizontal momentum.
TraversalProbe performs bounded world queries and never teleports an actor. Vault/hang movement
returns velocity through the same collision controller. Destination and overhead clearance use a
standing capsule; the route aborts on lost clearance or timeout. No animation moves colliders.
PlayerPosture owns collider height; View owns eye/FOV/optional roll. External knockback remains
separate and interrupts hanging/mantling. Death/respawn resets all motor state.

Wall sensing follows movement direction, preserving wall-run travel while looking sideways. Mantle
exit direction is captured from the ledge route, so changing aim does not reverse the exit velocity.
Wall jump has a .3 s same-wall lockout; wall-run budget 1.25 s per airborne sequence. Glide lasts
1.2 s. Holding Shift+RMB is reserved for Block and does not glide. Q/E roll lasts .38 s, cooldown 1.0 s,
no invulnerability. Camera performs a full 360° roll for readability.

Space during a grounded slide launches along the view's horizontal direction, at least12 m/s
(max16) with bounded pitch influence on vertical launch. No arbitrary midair double jump. Locomotion
cap18 m/s; external knockback can exceed it. Slide friction2.2 m/s² versus ground braking30.
Ground acceleration65 must exceed braking for the selected model; inspector ranges preserve that.

## Beam
Damage and cooldown remain owned by CombatController. Eye ray selects aim; camera-to-muzzle and
muzzle-to-aim rays enforce cover. The cast reports last_origin and last_hit alongside the existing
shot_resolved event. WandPresentation creates at most one short-lived beam. SpiralBeam is pure
presentation: three meshes on hits (core/helix/impact), bounded240 helix segments, .24 s lifetime.
Misses omit impact and cap visible length60 m. Round end, death, respawn and scene reload clean up.
Original procedural meshes/materials only. No audio, damage charge, piercing or balance redesign.

## Technical references
Godot 4.5 physics-query API:
https://docs.godotengine.org/en/4.5/classes/class_physicsdirectspacestate3d.html
Godot 4.5 procedural ImmediateMesh API:
https://docs.godotengine.org/en/4.5/classes/class_immediatemesh.html
Game references came from the user's direction; exact game movement parameters were not supplied
or reverse-engineered. Do not claim an exact match or a completed manual feel test.
