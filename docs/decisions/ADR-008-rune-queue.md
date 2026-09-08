# ADR-008 — M08 rune queue and Kenaz proof
User asked to continue Godot after M07. Gate A manual/export remains pending and is not claimed done.
Unresolved M07-era questions (repeats, consumption, failed-cast, first spell) are decided here
for the smallest proof only; they are labeled so later match design can replace them.

Decisions for M08:
- Repeats allowed. Newest insert is slot 1; older runes shift right; slot 3 drops.
- Successful supported cast consumes the whole queue.
- Unsupported mix: no Tag, no damage, no cooldown, queue kept, HUD reports failure.
- Empty queue remains Sniper Tag (12 / 2 s) so M01–M07 behavior is unchanged.
- First spell is Kenaz-only permutations. Damage = 12 + 4 * copies (16 / 20 / 24).
- Kenaz is still an eye-origin hitscan on mask 3. No projectile, burn zone, or VFX yet.
- M08 loadout binds only key 1 to Kenaz; 2 and 3 are unbound no-ops.
- C clears without cooldown. Inserts allowed during cooldown. Death blocks insert;
  respawn/reset clears leftover queue.
- Queue has two presentations: HUD slots and three world cubes above the caster.

Rejected for M08: 24-rune catalog, pre-match loadout UI, burning zones, broom, cars, concentric
rings, souls. Those stay backlog.
