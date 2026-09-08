# ADR-010 — Warhawk camera, dime-turn hover, on-foot Ctrl slide
User asked to mirror Warhawk (2007) camera feel exactly: bank with the craft,
slight delay catching the mouse, turn around on a dime. On foot, Ctrl while
walking or running is the slide / special locomotion.

Research (Incognito / Warhawk 2007):
- Pro chase cam is airframe-relative, including roll — "nausea-inducing" bank
  is the point; world-up look_at was the opposite of that.
- Right-stick / mouse is look. Camera orientation lags that look (~120–150 ms)
  so a flick shows the side of the craft, then settles behind it.
- Hover is arcade, not a sim: stop and pirouette on a dime; velocity lives in
  the look frame, so a 180 look redirects travel instead of coasting the old way.
- Coordinated bank from turn rate plus strafe, camera copies that roll.

Decisions:
- ChaseRig no longer look_at(subject, WORLD_UP). It slerps its basis toward
  View yaw/pitch plus broom roll (look_lag 7.5, ~133 ms). Boom is in that lagged
  space (1.55 m along camera up, 4 m along camera +Z).
- Broom visual copies View pitch/yaw and banks from A/D plus yaw-rate.
- Hover planar velocity is rotated by look-yaw delta each tick, then damped
  toward WASD (damp 22, retrograde 2.2). Altitude bubble unchanged.
- Combat still aims from View (instant mouse), never from the lagged chase cam.
- On foot: Ctrl tap while grounded and moving starts a 0.7 s low-capsule slide.
  Stationary Ctrl+S remains crouch. Mounted Ctrl remains descend.
- Ctrl+Space / Ctrl+LMB stay reserved.

Rejected: world-up chase, Newtonian coast on look-flick, replacing crouch entirely,
boost/jet mode, Q/E manual roll (auto-bank covers Warhawk coordinated roll).
