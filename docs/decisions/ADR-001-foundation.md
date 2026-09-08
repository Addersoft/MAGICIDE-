# ADR-001 — M01 foundation
Date: 2026-09-08. Status: implementation choice within authorized M01.
Use Godot 4.5 stable official 876b29033, standard GDScript, Compatibility renderer and 60 Hz physics.
Rationale: reproducible available binary; conservative desktop renderer while target hardware is
unknown. Not a latest-version claim. No dependency plugins. Revisit on a separate branch if hardware
requires it. One player script owns body movement, one input script, one view script. Do not extract
empty MovementController or networking classes. FPS eye stays at Y=1.65 m.
