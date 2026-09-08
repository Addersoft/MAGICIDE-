# ADR-005 — M05 Tag and knockback
User authorized M05 with Go. Tag implemented as eye-origin hitscan: 12 damage, 2 s cooldown,
zero mana dependency, no falloff. Finite 1000 m query covers the bounded arena. No muzzle exists;
add explicit muzzle obstruction policy if wand art gains a distinct gameplay origin later.
One pending click is consumed in physics; no cooldown buffering or held auto-fire. No network/runes yet.
Ctrl+LMB reserved for future Link. Recapture consumes its click; loss of capture/death cancels pending.

Dummy must move under knockback, so change its body from static to character. Add horizontal external
velocity state shared as a component, without another movement owner. Each controller integrates its
own vertical impulse/gravity. Tune impulse to 5 m/s, horizontal decay 12 m/s². Wall normals discard
blocked impulse. Existing direct input speeds unchanged and crouch does not touch external state.
Actor layer 2/mask 3, world layer 1. All prior acceptance fixtures rerun after mask/body changes.
This is necessary M05 integration, not a new parkour controller or multiplayer authority framework.
