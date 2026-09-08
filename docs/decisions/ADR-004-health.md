# ADR-004 — M04 health
Use a per-actor Node with 100 default HP. A positive finite damage amount subtracts HP, clamps
at zero and returns actual damage. Commit lethal state before emitting notifications. This makes
reentrant damage harmless on lethal callbacks. Death emits once. No revive/reset API yet.
H/J are explicitly temporary test fixture actions, not attacks, and require an alive captured player.
Dead player controls blocked; corpse gravity continues, dummy collision remains. Later M06 owns
respawn and lifecycle cleanup. No full DamageSystem manager until a second use requires it.
