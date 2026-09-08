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
| jump | Space | Yes, ground only, fresh press |
| sprint | Shift | Yes, hold |

Movement is disabled while capture is released; gravity continues. Focus loss releases capture.
First motion after recapture is discarded to avoid a warp delta. View pitch limits ±85 degrees.

Reserved future design: Space jump; Shift sprint; CTRL+S crouch toggle; LMB empty-queue Tag /
nonempty-queue cast; 1/2/3 rune insertion; C clear; Q teleport; V invisibility; R detection;
Shift+RMB block; MMB wand throw; Ctrl+Space hat; F harness/finisher; Ctrl+LMB link;
Ctrl+RMB bind/pull. Broom mount binding unresolved.
Ctrl+S backward-input arbitration must be resolved before M03. Crouch itself must not reset
momentum. Modifier precedence must be centralized before adding overlapping actions.

M02 tuning: sprint is 9 m/s in any input direction, including airborne; no stamina, acceleration,
FOV change or buffered jump yet. Jump launch speed 7 m/s, gravity 20 m/s². These are tunable
baseline choices, not finalized movement balance.
