# ADR-003 — M03 crouch implementation
User authorized next milestone with Go. Ctrl+S remains exact requested default.
Reserve S from backward movement while Ctrl held to avoid an unintended reversal during forward
movement. This resolves a previously unspecified input policy; communicated before implementation.
One toggle per chord rising edge, either press order; failed stand requires release/repress.
Capsule shrinks with feet fixed. Eye snaps at same time for overhead safety, through camera owner.
Standing clearance queries full capsule with a small floor offset and excludes self. Shape copied
per actor. No crouch speed penalty and no velocity writes in posture. Baseline input braking still
operates; this does not implement slides or advanced momentum. No engine/ownership redesign.
