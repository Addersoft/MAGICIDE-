# Technical debt
- Direct input velocity remains a simple M01 tuning model. M05 resolves external-impulse overwrite
  with separate horizontal impulse state; advanced acceleration, slides and bunny-hop remain deferred.
- Input and combat are local. Introduce tick-tagged requests/server validation during network spike;
  do not claim prediction readiness.
- Ray origin is FPS eye; no wand/muzzle exists. If a muzzle is later added, resolve near-cover aim
  and obstruction before allowing muzzle presentation to diverge from gameplay origin.
- 1000 m ray covers 40 m arena. When bounds expand, update query coverage; no range falloff intended.
- H/J direct damage remains an explicit debug fixture; remove before public playtests as appropriate.
- Dead actors remain collidable during the three-second respawn delay. M06 uses one clearance-checked
  original spawn; add alternate/team spawns only when match rules need them. No dynamic-floor validation
  yet because arena terrain is static. A blocked spawn can wait indefinitely until cleared.
- No persistent sensitivity settings; inspector only. Eye crouch snaps for clearance safety.
- No actual PC graphical/comfort/focus validation. Manual acceptance remains pending.
- No audio/tracer/wand art for Tag; text feedback is the M05 presentation placeholder.

- M07 export not verified: matching templates unavailable in runtime; Linux/Windows presets supplied.
- Practice rounds have a timer only. Team scoring/best-of-three remain later match work, not implied
  by the round-end overlay. Full current-scene reload is the bounded M07 restart implementation.
- Gate A ten-minute real playtest not yet reported; headless checks cannot establish feel or rendering.

- M08 Kenaz is a colored hitscan, not a fire volume or projectile. Burning zones remain later.
- Only key 1 is bound. Pre-match three-rune loadout UI is not started.
- World cubes are placeholder meshes, not stylized runes.
