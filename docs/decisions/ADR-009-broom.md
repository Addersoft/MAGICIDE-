# ADR-009 — M09 broom hover and Warhawk chase camera
User asked for the broom next, with a Warhawk (2007) subject/camera relationship
and anti-gravity hover: stop on a dime, 180 turn on a dime, S is reverse.

Decisions for M09:
- F (Harness) mounts and dismounts. Binding was unresolved; this is the M09 choice.
- On foot remains true FPS. Mount blends 0.3 s into a world-space chase camera
  4 m behind and 2 m above. Dismount restores FPS. Camera stays world-upright
  and springs behind the subject so the broom is always the framed object.
- Hover only. No boost, broom HP, flames, or network sync.
- Anti-gravity bubble: MOTION_MODE_FLOATING, no gravity, altitude holds when
  vertical input is released. Desired velocity is input * 15 m/s (8 m/s climb).
  Exponential damp 14 (×1.6 when reversing). This is stop-on-a-dime with a
  little inertial dampening, not Newtonian flight.
- WASD is look-relative strafe/forward/back. S is reverse, not a brake-then-turn.
  Mouse yaws the subject immediately; 180 look + W is a new forward.
  Space climbs, Ctrl descends. Ctrl+S crouch is ignored while mounted.
- Aim rays still originate from View (the eye), not the chase camera.
- Placeholder capsule + stick is the visible subject; hidden in FPS.
- Arena walls raised to 16 m with a ceiling so hover cannot leave the box.
  Ground obstacles are unchanged.

Rejected for M09: boost 40 m/s, banked-turn flight model, broom destruction,
Isa, cars, rings, souls, 24-rune dump.
