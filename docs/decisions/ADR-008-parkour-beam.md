# ADR-008 — explicit parkour/beam scope expansion + Q/E roll
User requested Titanfall/Warframe/Mirror's Edge-inspired parkour and Piccolo-style Special Beam
Cannon for the sniper wand. This explicitly changes priority from rune queue to movement identity.
Implement modular momentum/traversal without rewriting health/round/respawn ownership. First person
remains invariant. Expose main tuning numbers; use original procedural course/wand/beam assets.

Q = counter-clockwise (left) roll, E = clockwise (right) roll. Short duration with lateral boost
and full camera roll for readability. E is no longer a pure dodge; the roll is the primary
evasive/momentum tool. Plain RMB glide excludes Shift+RMB Block. Ctrl while moving remains slide;
Ctrl+S remains the required crouch toggle. No unapproved Tag damage/cooldown change.

Old acceleration tests updated to match the requested momentum behavior, not removed. New physical
fixtures cover wall running while aiming, jump timing, vault clearance, glide/roll budgets, stomp,
beam lifetime and muzzle occlusion. Manual feel/render remains pending and must not be inferred.
