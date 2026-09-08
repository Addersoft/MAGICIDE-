# Technical debt
- Immediate horizontal velocity assignment: intentionally simple M01. It will overwrite external
  impulses; replace with an approved acceleration/impulse model before crouch momentum/knockback.
- Input is local, no tick command records. Revisit at multiplayer spike; do not claim prediction readiness.
- Capture response has no live HUD status. Static instructions are sufficient for M01; review if confusing.
- No graphical/OS playtest here. M01 acceptance remains pending until developer checks pass.
- No persisted sensitivity preferences: inspector tuning only; add settings with later UI work.
