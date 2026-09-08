# ADR-006 — M06 actor lifecycle
User authorized M06 with Go. Default 3 s delay, original spawn per actor. Retry blocked spawn .25 s;
no unsafe fallback. Full original standing capsule (not crouched shape) checks world/actors excluding
self. Fixed arena floor retained; no streaming/destruction. Dead actor remains collidable/visible.

Reset existing actors in place to preserve scene-local references and avoid duplicate actors/timers.
RespawnController owns scheduling/clearance; actor owns its own reset; Health owns restored HP/dead.
Reset movement/impulse/posture/view/input/cooldown before Health.reset_full. Reset interpolation.
Cooldown resets to ready and pending attacks cancel; this is the documented M06 cooldown policy.
Leave mouse released on respawn so focus is never stolen; conscious click recaptures without attack.
No spawn protection, alternate spawn list, networking, round reset or new game rules introduced.
