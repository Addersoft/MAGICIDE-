# Technical debt
- Direct input velocity remains a simple M01 tuning model. M05 resolves external-impulse overwrite
  with separate horizontal impulse state; advanced acceleration, slides and bunny-hop remain deferred.
- Input and combat are local. Introduce tick-tagged requests/server validation during network spike;
  do not claim prediction readiness.
- Ray origin is FPS eye; no wand/muzzle exists. If a muzzle is later added, resolve near-cover aim
  and obstruction before allowing muzzle presentation to diverge from gameplay origin.
- 1000 m ray covers 40 m arena. When bounds expand, update query coverage; no range falloff intended.
- H/J direct damage remains an explicit debug fixture; remove before public playtests as appropriate.
- Dead dummy remains collidable. M06 will define corpse/respawn lifecycle and safe spawns.
- No persistent sensitivity settings; inspector only. Eye crouch snaps for clearance safety.
- No actual PC graphical/comfort/focus validation. Manual acceptance remains pending.
- No audio/tracer/wand art for Tag; text feedback is the M05 presentation placeholder.
