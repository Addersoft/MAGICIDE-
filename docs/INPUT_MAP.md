# Input map
| Action | Physical default | Implemented |
|---|---|---|
| move_forward | W | Yes |
| move_backward | S | Yes |
| move_left | A | Yes |
| move_right | D | Yes |
| release_mouse | Escape | Yes |
| Capture | Left mouse, when released | Yes |
| Look | Mouse motion | Yes |
| Crouch toggle | CTRL+S | Yes, rising chord edge |
| jump | Space | Yes, ground only, fresh press |
| sprint | Shift | Yes, hold |

Movement is disabled while capture is released; gravity continues. Focus loss releases capture.
First motion after recapture is discarded to avoid a warp delta. View pitch limits ±85 degrees.

Reserved future design: Space jump; Shift sprint; CTRL+S crouch toggle; LMB empty-queue Tag /
nonempty-queue cast; 1/2/3 rune insertion; C clear; Q teleport; V invisibility; R detection;
Shift+RMB block; MMB wand throw; Ctrl+Space hat; F harness/finisher; Ctrl+LMB link;
Ctrl+RMB bind/pull. Broom mount binding unresolved.
M03: Ctrl+S is reserved for crouch, so S does not command backward motion while Ctrl is held. Crouch itself must not reset
momentum. Modifier precedence must be centralized before adding overlapping actions.

M02 tuning: sprint is 9 m/s in any input direction, including airborne; no stamina, acceleration,
FOV change or buffered jump yet. Jump launch speed 7 m/s, gravity 20 m/s². These are tunable
baseline choices, not finalized movement balance.

M04 debug-only: H = 25 self damage; J = 25 dummy damage. Requires captured controls and living player. No weapon raycast. Death prevents recapture.

M05: primary_fire = left mouse. Central input owns firing; first click after release only captures.
Ctrl+LMB is reserved for Link and suppressed. Combat rejects clicks during cooldown; does not buffer
them or auto-fire while held. Death/focus/capture loss cancel pending shots before physics execution.

M06: player respawns after 3 s when spawn is clear; click to resume after respawn, not to shoot.
No reset key added. H/J test damage remains available while alive. Original spawn is used for each
actor. Blocked spawn waits; standing reset never recaptures focus automatically.

M07: RoundEnd Restart button is clickable/focused and uses standard Godot UI activation. No new
combat key assigned. At round end pointer releases and gameplay cannot be recaptured. Restart
reloads scene and uses normal initial capture. Escape during play does not pause the round clock.

M08: rune_1 / rune_2 / rune_3 = physical 1/2/3. rune_clear = C. Only bind 1 is Kenaz in this
slice; 2 and 3 no-op. Inserts require captured living controls. C does not shoot. Empty LMB is
still Tag. Queued LMB is a cast. Ctrl+LMB remains reserved.
