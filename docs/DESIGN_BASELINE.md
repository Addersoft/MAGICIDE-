# Approved direction and scope
User supplied the WIZARDS! master specification and development plan. User authorized M01
with “Go” after a response explicitly offering that milestone. No broader implementation authorized.

Permanent invariants: true first person on foot including parkour and combat; broom smoothly
transitions to third person (~4 m behind, 2 m above, ~0.3 s), dismount returns to FPS.
Godot 4.x, typed GDScript, Blender, PC first, stylized placeholder-first assets and $0 tooling.
One state owner; small testable changes; no silent requirement changes; do not claim unrun tests.

First playable sequence: M01 movement testbed; M02 jump/sprint; M03 Ctrl+S toggle crouch
preserving momentum; M04 health/damage; M05 Tag (12 damage, 2 s cooldown, zero mana,
no intended arena range cap, knockback); M06 death/respawn; M07 3-minute round timer/dummy.
Then M08 data-driven rune queue and Kenaz; M09 broom hover / Warhawk chase camera.
Isa, boost, and remaining runes stay later. Early multiplayer feasibility is planned before
world content expansion, not implemented.

Vision retained: complete parkour suite, air control/bunny hop, teleport through walls with safe
endpoint (5 m, 5 s cooldown, 0.1 s invulnerability), melee, wand/hat/link/bind abilities, stealth,
detection, 15 m/s hover and 40 m/s boost, broom HP/destruction and momentum transfer.
24 runes: Uruz, Thurisaz, Sowilo, Algiz, Kenaz, Dagaz, Ehwaz, Raido, Fehu, Mannaz, Wunjo,
Isa, Laguz, Hagalaz, Naudiz, Othala, Jera, Tiwaz, Eihwaz, Berkana, Ingwaz, Ansuz, Perthro, Gebo.
Select three before match; newest queue rune enters slot 1, displaces older right; max 3;
order matters; C clears. Repeat, consumption, passive and unsupported-recipe policies unresolved.
Ingwaz trees with three apples; burning apples become grenades; fire/wet; horse/Pegasus;
bounded destruction first, possible later stress propagation; team best-of-three matches,
spy scoring/hidden allegiance, TTS and modular cosmetics. Full details remain in supplied master
specification; consult it before expanding a feature. None are removed by this M01 subset.

Recommended hybrid destruction and player-count caps are not permanent approved cuts.
Do not upgrade engine mid-milestone or turn camera convenience into a third-person redesign.
