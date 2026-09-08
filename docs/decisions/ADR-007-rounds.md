# ADR-007 — M07 practice round lifecycle
User authorized M07 with Go. 180 s simulation timer, no score/winner invented for one-player/dummy
slice. Starts at scene ready, Escape does not pause. Manager physics priority -100 ends before actor
ticks. End latches once, disables actors/damage/recapture while keeping HUD live.
Restart button requests one deferred full current-scene reload, ensuring arena and actor state reset
without stale timers. Standalone export presets supplied but no templates/executable verified here.
First-slice features implemented; Gate A still requires PC manual playtest and standalone verification.
