# Movement / flight fix staging

Porting the movement-input fixes from the supplied WIZARDS-Flight v1.0 archive into the current MAGICIDE- controller architecture.

Targets:
- Sprint + jump must coexist.
- Jumping out of crouch must stand when clearance allows.
- LMB must remain independent of sprint/crouch/jump/flight input.
- Q/E must be flight-only aileron controls; they must not trigger an on-foot player barrel roll.
- Player/camera must never be rolled by the parkour motor.
- Flight Q/E should visibly bank the broom and add lateral flight authority.
