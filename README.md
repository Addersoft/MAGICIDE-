


# WIZARDS! — M10
PC Godot source project. Includes M01–M10: FPS movement, jump/sprint/crouch/slide, health,
Sniper Tag, knockback, automatic respawn, timed practice rounds, Kenaz rune queue,
and broom hover with a Warhawk (2007) third-person chase camera.
Not an HTML game or exported executable.

## Run
1. Download the standard Godot **4.5 stable** editor:
   https://godotengine.org/download/archive/4.5-stable/
2. Extract this archive fully into a new writable folder. This is a complete project; do not overlay an older copy.
3. Import `project.godot` in Godot Project Manager; choose Import & Edit.
4. Press **F5**. Mouse and keyboard required. F8 stops the running scene.

Renderer Compatibility; 60 Hz physics; no .NET, add-ons or external assets required.
Godot 4.5 is pinned for reproducibility, not claimed to be the latest version.

## Controls
| Input | Behavior |
|---|---|
| WASD / mouse | On foot: move / aim FPS. On broom: look-relative strafe/forward/back |
| Space | Ground jump on foot. Climb while mounted (held). |
| Hold Shift | Sprint on foot. Unbound on broom (boost is later). |
| Ctrl (walk/run) | Slide on foot. |
| Ctrl+S (still) | Toggle crouch on foot. |
| Ctrl (mounted) | Descend. S still reverses. |
| F | Mount / dismount broom |
| 1 | Insert Kenaz at slot 1 (newest). 2 and 3 are unbound. |
| C | Clear the rune queue (does not shoot) |
| Left click | Sniper Tag if queue empty; Kenaz cast if queue is Kenaz-only |
| Escape / click | Release / recapture pointer (recapture does not shoot) |
| H / J | Temporary debug: 25 damage to self / dummy |

Empty-queue Tag is unchanged: **12 damage**, **2-second cooldown**, no mana, no falloff.
Kenaz-only queues deal **16 / 20 / 24** for 1 / 2 / 3 copies, same cooldown and hitscan.
Unsupported mixes do not fire Tag, do not start cooldown, and keep the queue.
Successful Kenaz consumes the whole queue. Arena walls still stop the ray.

Aim at the orange dummy, then click. The HUD shows queue slots, readiness and hit damage.
Three colored cubes above the caster mirror the queue in world space.
Ctrl+LMB is reserved for future Link and does not fire Tag.

Hits push the dummy in the shot direction. Horizontal push decays and collides with walls;
player input does not erase external knockback. A lethal hit can still push the target.
The dummy does not attack. Both actors have 100 HP. Dead targets take no further damage or impulse.
At player death controls lock. Both actors respawn after **3 seconds** if their spawn is clear.
Click to resume after player respawn; the click does not shoot. Respawn clears leftover runes.

Crouch uses a 1 m capsule and .85 m eye; standing uses 1.8 m and 1.65 m. Eye height snaps
with collider to avoid clipping under roofs. Blocked standing requires retry after moving clear.
Ctrl while walking or running is a short slide (low capsule, extra speed). Stationary Ctrl+S
still toggles crouch and still reserves S from backward input. Crouch adds no speed penalty.
Walk 6 m/s; sprint 9 m/s; jump launch 7 m/s; gravity 20 m/s². These remain tunable baselines.

## M09/M10 broom — Warhawk camera
Press **F** to mount. The camera blends in **0.3 s** to a chase cam about **4 m behind**.
You are the subject. This is Incognito's Warhawk (2007) chase, not a world-up look-at:

- Mouse aim is instant on the wand/eye.
- The chase camera **lags ~133 ms** catching up to wherever the mouse points.
- The camera **banks with the broom** (strafe + turn-rate roll). Horizon is not locked.
- Flick look 180 while moving: travel **redirects on a dime** with the nose.
- **S** is reverse. Release WASD: stop on a dime.
- Space up, Ctrl down; altitude holds when you let go.
- Boost, broom HP and jet mode are not in this slice.

Arena walls are 16 m with a ceiling so hover cannot leave the graybox. Interior blocks are unchanged.
Tag still fires from the eye, not from the chase camera. Death and respawn force a dismount.

## Verification
Godot 4.5 stable Linux headless: editor import and checks across M01–M10 fixtures.
No GPU rendering, camera comfort, target-PC mouse/focus, exported executable, or render-cap
comparison is confirmed. See docs/TEST_RESULTS.md and docs/TEST_PLAN.md.

Run from this project folder, replacing `godot` with your executable path:
```
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/m01_smoke.gd
godot --headless --path . --script res://tests/m02_smoke.gd
godot --headless --path . --script res://tests/m03_smoke.gd
godot --headless --path . --script res://tests/m04_smoke.gd
godot --headless --path . --script res://tests/m05_smoke.gd
godot --headless --path . --script res://tests/m06_smoke.gd
godot --headless --path . --script res://tests/m07_smoke.gd
godot --headless --path . --script res://tests/m08_smoke.gd
godot --headless --path . --script res://tests/m09_smoke.gd
godot --headless --path . --script res://tests/m10_smoke.gd
```
Each runner should report zero failures and exit 0. Manual testing remains necessary.

## Continue
Read docs/PROJECT_STATE.md first. Next after M10 camera/flight feel is accepted: **Isa as second rune** or
**broom boost**. Gate A playtest and standalone export remain open.
Runes beyond Kenaz, boost, cars, concentric rings and souls are not implemented.
Use this working copy, not two independently edited copies. Engine caches are excluded.

## M06 lifecycle
On death, one per-actor respawn schedule starts. After 3 seconds the full standing capsule is
checked at that actor's original spawn. If occupied, the actor remains dead, the HUD explains why,
and clearance is retried every 0.25 seconds. Move out of the dummy's spawn to let it return.
There is no alternative spawn selector yet. The current static arena supplies the spawn floor.

Respawn restores 100 HP, standing posture, original location, FPS aim and eye height, zero velocity,
zero external impulse, a ready Tag with no queued shot, and an empty rune queue. Input remains
released so the game does not steal focus. Click to resume; held inputs may then move you normally.

## M07 practice rounds
The round starts immediately and lasts 3 minutes of simulation time. Escape releases the mouse but
does not pause the timer. At 00:00, gameplay stops, pending attacks/respawns stop, and the pointer is
released. Click **Restart round** (or activate its focused button with the keyboard) for a fresh round.
The arena, actors, health, movement, camera, cooldowns, rune queue and pending respawns all reset
by scene reload. No winner/team score is invented for this single-player dummy practice slice.

## M08 rune queue
Press **1** to push Kenaz. Newest rune is the left slot. A fourth insert drops the oldest.
**C** clears. Left click with an empty queue is still Tag. Left click with one to three Kenaz
casts the fire hitscan (16/20/24). Mixed/unknown recipes are rejected and keep the queue.
Kenaz does not yet create burning zones or projectiles.

The first-slice plus Kenaz proof is implemented, but Gate A is **not yet accepted**.

## Export on your PC
Linux and Windows Desktop x86_64 presets are included in export_presets.cfg. In Godot 4.5 stable,
install the matching export templates through **Editor > Manage Export Templates**, create an
`exports` folder, then use **Project > Export**, choose a preset and Export Project (release).
Export presets have not produced a verified executable here.


WIZARDS! — MASTER DEVELOPMENT PLANNER PROMPTYou are the lead technical director, gameplay programmer, systems architect, and production planner for the game described below.Your job at this stage is NOT to immediately build the entire game.Your job is to create the most realistic, technically robust, AI-friendly development plan possible, while accounting for:• Your available context window• Token/output limitations• Context degradation over long conversations• The possibility of losing earlier implementation details• Code-generation errors• Integration conflicts• AI hallucinations• Scope creep• The difficulty of debugging large generated codebases• Performance constraints• Multiplayer/networking complexity• Physics/destruction complexity• Asset-generation limitations• The developer's potentially limited programming experienceThe project must remain achievable by one person using AI assistance and free/low-cost software.
───
1. GAMETitle: WIZARDS!Genre: First-person wizard brawler / arena shooter with parkour, rune-based spell construction, stealth, destructible environments, and third-person broom flight.Primary platforms: PC first. Console compatibility should be considered architecturally but NOT prioritized until the PC prototype is working.Engine: Godot 4.x unless you identify a compelling technical reason that another free engine is substantially better.3D software: Blender.Development philosophy: AI-assisted, incremental, test-driven development.Budget: $0 upfront whenever reasonably possible.
───
2. CORE CAMERA RULEThis is extremely important.WIZARDS! is primarily FIRST PERSON.While:• walking• sprinting• crouching• parkouring• fighting on foot• casting spells on footthe player uses a true first-person camera.When the player mounts and flies the broom:FIRST PERSON → smooth transition → THIRD PERSON.When dismounting:THIRD PERSON → FIRST PERSON.Do not reinterpret the game as primarily third person.
───
3. CORE GAMEPLAYThe player is a wizard fighting in a destructible arena.Core gameplay loop:MOVE → AIM → BUILD RUNES → CAST → REACT → PARKOUR → FLY → COUNTER → DESTROY ENVIRONMENT → WINThe game should reward:• aiming skill• movement skill• timing• spell construction• positioning• environmental awareness• counterplay
───
4. MOVEMENTOn-foot movement is first person.Required systems eventually include:• WASD movement• mouse look• jumping• sprinting• toggle crouch• sliding• wall running• wall jumping• ledge grabbing• vaulting• dodge roll• goomba stomp• coyote time• jump buffering• short hop• variable jump height• bunny-hop momentum• air controlCrouch:CTRL + SThis toggles crouch/duck on and off.It must not destroy momentum.
───
5. BROOMThe broom is a major gameplay system.On foot: FIRST PERSON.While airborne on broom: THIRD PERSON.Broom eventually supports:HOVER:• 15 m/s max• inertial dampening• spring-locked vertical movement• strafe turning• boost charging• instant retrograde• stop-on-dime• roll driftBOOST:• 40 m/s max• stronger inertia• pitch controls altitude• banked turns• blue boost flamesCamera: approximately 4m behind and 2m above player.Mount transition: approximately 0.3 seconds.Dismount: return to first person.Eventually:• broom HP• broom destruction• respawn• network synchronization• momentum transfer
───
6. COMBATDefault left click:If rune queue is empty: SNIPER TAG.If rune queue contains runes: CAST SPELL.Sniper Tag:• 2 second cooldown• 12 base damage• infinite range• hitscan or extremely fast projectile• moderate knockback• zero mana cost• rune effects can modify the hitMelee:• punch• kick• uppercut• wand interactionsOther eventual abilities:Q = Teleport V = Invisibility R = Detection Pulse Shift + RMB = Block Middle Mouse = Wand Throw Ctrl + Space = Hat Attack F = Harness / Finisher depending on context Ctrl + LMB = Link Ctrl + RMB = Bind / Tether Pull
───
7. TELEPORTQ:• 5 second cooldown• moves approximately 5m in movement direction• phases through walls• 0.1 sec invulnerability• destination must be unoccupied• ghost trail through geometryRune interactions may modify it.
───
8. RUNE SYSTEMThere are 24 runes.Players select 3 runes before the match.They bind them to:1 2 3Pressing a rune key pushes it into a queue.Example:Press 1:[Uruz]Press 2:[Kenaz][Uruz]Press 3:[Isa][Kenaz][Uruz]New runes enter Slot 1 and push older runes right.Slot 3 is discarded when necessary.Order matters.Left click casts the current permutation.C clears the queue.The queue exists in two representations:1. World-space queue above the player's head.2. Screen-space mirror in the FPS HUD.Enemies can see the world-space queue under appropriate visibility conditions.The rune system MUST be data-driven.Do NOT hard-code 24 runes into one giant script.Prefer:• Resources• data objects• dictionaries• configuration files• modular effect componentswhere appropriate for Godot.
───
9. RUNESThe eventual 24-rune set:Uruz Thurisaz Sowilo Algiz Kenaz Dagaz Ehwaz Raido Fehu Mannaz Wunjo Isa Laguz Hagalaz Naudiz Othala Jera Tiwaz Eihwaz Berkana Ingwaz Ansuz Perthro GeboImportant examples:Uruz: Blink becomes charging dash.Kenaz: Fire/burning zones.Uruz + Kenaz: Dash leaves fire trail.Algiz: Shield.Algiz + Sowilo: Shield can reflect lightning.Dagaz: True free flight.Ehwaz: Summons horse.Raido: Allows horse riding.Dagaz + Ehwaz: Pegasus.Mannaz: Improved punching.Isa: Slow.Laguz: Water/wet interactions and improved air control.Hagalaz: Tornado.Naudiz: Improved bind.Othala: General stat improvement.Jera: Time slow.Tiwaz: Heavy wand thrust / improved wand throw.Eihwaz: Platform-center snap / defensive effect.Berkana: Passive healing.Ingwaz: Plant tree.Ansuz: Rune disruption.Perthro: Mana gain while hidden.Gebo: Linked damage healing.
───
10. ENVIRONMENTEventually support:• destructible terrain• pre-fractured geometry• chunk health• explosions• stress propagation• cascading destruction• fire propagation• burning zones• trees• apples• horses• wet/burning interactionsHowever:DO NOT attempt full destruction simulation in the first prototype.Use a deliberately simplified destruction system initially.The architecture should allow a more advanced system to replace it later.
───
11. TREES / APPLESIngwaz:Crouch/duck interaction plants a tree.Tree:• grows rapidly• temporary lifetime• collision• three applesApples:• can fall• heal players• can interact with fire• burning apple becomes grenadeLaguz can affect tree/apple behavior.
───
12. HORSESEhwaz summons horse.Raido enables mounting.Horse eventually has:• HP• collision• rider• movement• double jump• damage buffering• death• special rune interactionsDagaz + Ehwaz:Pegasus.Do NOT implement this until the basic player and broom systems are stable.
───
13. DESTRUCTIONLong-term:Terrain is divided into destructible chunks.Explosions damage chunks.Destroyed chunks fracture into physical pieces.Damage/stress can propagate into nearby chunks.Teleport can shatter severely damaged geometry.World streaming may eventually be used.However, prioritize gameplay over simulation accuracy.If full physical destruction is too expensive or unstable, design a convincing hybrid destruction system.
───
14. GAME MODESEventually:Team Deathmatch.Supports: 1v1 2v2 and scalable XvX.Best of 3 rounds.Default: 3 minutes per round.Team points.Spy mechanics eventually include:• hidden allegiance• team kills• special scoring• kill-feed obfuscation• stealth bonusesThese should NOT block the first playable prototype.
───
15. ACCESSIBILITYEventually:Toggleable text-to-speech for:• UI• chat• tooltips• tutorials• important gameplay promptsDo not prioritize this over core gameplay.
───
16. CHARACTER CUSTOMIZATIONEventually:• body• face• clothing• accessories• colors• voice pitch• other cosmetic customizationThis should be modular and data-driven.Do not spend early development time on detailed customization.
───
17. GRAPHICAL STYLEUse a stylized 3D fantasy aesthetic.Do NOT target photorealism.Prioritize:• readable silhouettes• strong spell colors• exaggerated magical VFX• readable characters• clean environments• strong destruction feedback• high visual clarity during combatGraphics should be achievable by one developer using Blender and free resources.
───
18. DEVELOPMENT PRIORITYUse this rough priority:TIER 0: 3Cs• character controller• camera• input• basic healthTIER 1: Combat• Sniper Tag• melee• damage• knockback• death• round systemTIER 2: Movement identity• parkour• crouch• dodge• broom• FPS/third-person camera transitionTIER 3: Rune system• rune data• queue• casting• initial runes• synergy systemTIER 4: World systems• trees• apples• fire• horses• destructionTIER 5: Polish• TTS• customization• cinematics• advanced VFX• networking improvements
───
19. CRITICAL AI DEVELOPMENT RULESYou MUST follow these rules when helping implement the game.Rule 1 — Never generate the entire game at once.Break implementation into small milestones.Each milestone should produce something testable.Rule 2 — Prefer modular architecture.Avoid giant scripts.Prefer small systems such as:PlayerController PlayerCamera MovementController CombatController HealthComponent RuneController RuneQueue SpellSystem AbilityController BroomController BroomCamera DamageSystem TargetingSystem GameManager RoundManager etc.Choose the actual architecture intelligently.Rule 3 — Minimize dependencies.If a system does not need another system, do not couple them.Rule 4 — Do not rewrite working systems unnecessarily.When fixing a bug, modify the smallest possible amount of code.Rule 5 — Never silently change design requirements.If you think a requirement should change:1. Explain why.2. Identify the affected systems.3. Offer the change as a recommendation.4. Wait for approval before changing architecture.Rule 6 — Track technical debt.Maintain a concise TECH_DEBT list.Rule 7 — Track unfinished systems.Maintain a TODO list.Rule 8 — Track architectural decisions.Maintain an ADR-style decision log.Rule 9 — Never pretend code was tested if it wasn't.Explicitly distinguish:• designed• generated• reviewed• tested• confirmed workingRule 10 — Assume generated code can contain bugs.Before producing complex code, reason about:• null references• race conditions• physics edge cases• networking• input conflicts• frame-rate dependence• scene ownership• resource lifetime• multiplayer authority
───
20. TOKEN / CONTEXT MANAGEMENTThis is extremely important.You must optimize for long-term AI-assisted development.Do NOT waste output repeating the entire game design every turn.Create a compact project memory structure.Maintain:PROJECT_STATE.mdcontaining only the information necessary to continue development.Suggested structure:PROJECT_STATE ├── Current milestone ├── Current implementation ├── Working systems ├── Broken systems ├── Next task ├── Known bugs ├── Architecture ├── Important file paths ├── Input mappings ├── Data structures ├── Technical debt └── DecisionsWhenever the project changes significantly, update this compact state.When the conversation becomes long, prioritize the project state over historical conversation.
───
21. CONTEXT CHECKPOINTSAt the end of every major milestone, generate a compact checkpoint.Format:CHECKPOINTMilestone: Status: Implemented: Files changed: Important architecture: Known bugs: Tests performed: Next task: Do not change: Technical debt:The checkpoint should be concise enough to paste into a new AI session.
───
22. ENTROPY / FAILURE CONTROLTreat every generated change as potentially introducing entropy into the codebase.Define "entropy" as:• duplicated logic• inconsistent naming• undocumented assumptions• dead code• conflicting systems• accidental rewrites• unclear ownership• excessive dependencies• generated code that nobody understandsYour goal is to continuously REDUCE entropy.Prefer:small changes > giant changesexplicit interfaces > implicit couplingdata-driven systems > hard-coded systemstested modules > speculative systemssimple solutions > clever solutions
───
23. IMPLEMENTATION LOOPFor each milestone use this cycle:1. Explain the goal.2. Define acceptance criteria.3. Define files/systems affected.4. Implement the smallest viable version.5. Explain how to install/integrate it.6. Explain how to test it.7. Identify likely failure points.8. Wait for test feedback.9. Fix bugs.10. Update PROJECT_STATE.11. Move to the next milestone.Do NOT jump several milestones ahead unless explicitly requested.
───
24. PROTOTYPE-FIRST RULEUse placeholder assets whenever possible.For example:Player: capsule.Broom: simple cylinder/mesh.Wand: simple stick.Rune: simple glowing square.Enemy: colored capsule.Arena: simple boxes.Only replace placeholders with final art after the gameplay works.
───
25. FIRST VERTICAL SLICEYour first playable build should contain ONLY:• one arena• one player• FPS camera• WASD• mouse look• jump• sprint• crouch• Sniper Tag• health• damage• knockback• death• respawn• simple round timer• one dummy enemyThen add:• first rune• rune queue• one spellThen:• broom• mount• third-person transition• basic flight• dismountOnly after these work should we significantly expand the game.
───
26. YOUR FIRST RESPONSEDO NOT WRITE GAME CODE YET.First produce:A. Technical feasibility assessmentTell me which parts of WIZARDS! are:GREEN = straightforwardYELLOW = difficult but achievableRED = extremely difficult / likely to require compromisesExplain why.B. Recommended Godot architectureGive me the proposed project structure.C. Development roadmapBreak the project into milestones small enough for reliable AI-assisted development.Each milestone should have:• goal• systems• dependencies• acceptance criteria• estimated complexity• major risksD. AI workflowExplain exactly how you recommend I work with you/Astra across multiple sessions without losing project context.E. $0 software/assets strategyRecommend free tools and sources.F. First milestoneDefine exactly what should be built FIRST.Do not implement it yet.G. Risk registerIdentify the 10 biggest technical risks in WIZARDS!.H. Scope-control rulesGive me rules that prevent this project from becoming impossible for a solo AI-assisted developer.Be honest.Do not tell me the game is easy.Do not artificially simplify the game unless you clearly label the simplification.The objective is not to produce the largest amount of code.The objective is to produce the highest probability of eventually having a functioning, fun game.END PROMPT
Todo:+cars. | able to shoot your wand , your arm changes depending on which side of the car youre on | tires can be shot out |windows can be broken |cars can explode on collision or engine failure Cars can get stuck on terrain shifts | linking the ground or walls you can shift them, changes cocentric rings to 1 is a cone 2 is a square 3 is a cylindar |combat cocentric rings 1 changes to dot sight sniper 2 changes to shotgun cone spread 50% dmg for 50% of cones side length, 100% dmg for 75% of cone, 2x dmg for 25% of cone (tip) 3 regular burst medium paced projectile 1.5x dmg and knockback | {2nd ring shows negative / counter rune in black and white |3rd ring shows either isa tiwas or uruz for sniper burst and shotgun }-when crosshair is over opponent Rings spin clockwise counter clockwise and clockwise |repeat runes in queue strengthen the damage and effect of that rune on everytjing it collides with|kenouz kaunaz kainaz shoots a larger fireball or thicker beam or larger shotgun spread than just 1 kaunaz Kaunaz isa kaunaz shoots a medium size fire spellIsa kaunaz isa shoots a larger size ice spell If rune > 1 in triune : spellsize++ ; spellsize init-> rune[s,m,l]I killimg enemies gathers their soul, throw it in your teams circle to gain a kill, 








