# Matched local-length motion

## Scope

Harness `173d8cbf1b460da8689a47417532d465c3aabba2`, branch `wip/g5-local-frontier`. CI https://github.com/kimstik/grbl/actions/runs/45871688952 succeeded.

Frozen fixed24 control `500513d26e14e5a16bcdaa6c7976107d6a5f888c` versus combined fixed24/local-length `4eb683aade6a1250620e322ce36bd93f1416cb5c`. G94 only, cold p37-p40, size 5 mm, acceleration 2000, feeds 4000/5000 and sender delays 2/16 ms. Same existing dyn firmware harness and settings. No stride, realtime, autostart or density changes. Host-only observer adds raw XYZ words at planner entry; existing boundary probes retained. Simulator pinned to `13d4ed32433ad7a37bb757b7e0f7dbb5373396c0`.

## Independent verification

Downloaded artifacts were treated as data, not executed locally. Independent replay verified publication/slot/generation to consumption to empty, saved planned endpoint/exit values and publication cycle, empty segment ring and no outstanding published generation. All completed boundary calls paired by kind, saved program/line and duration; one terminal serial call in each arm does not return before finish.

Observed/blind end cycle, state, UART byte count and cycle-weighted UART hash match within each arm; UART files are byte-identical within each arm. Removing only new XYZ records from the control trace reproduces boundary run 45860588243 exactly. Production ELFs of both arms are byte-identical to their bounded counterparts in run 45870539098.

| Arm | End cycle | State | UART bytes | Timing hash | Publications = consumptions | Empties including final |
|---|---:|---:|---:|---:|---:|---:|
| Fixed24 | 168487364 | 6 | 917 | 1281633213 | 2901 | 24 |
| Combined | 168559240 | 6 | 917 | 2903540197 | 2896 | 24 |

These identities are within-arm noninterference checks, not a claim that different firmware should take identical cycles.

## Motion outcome

| Program | Feed | Sender ms | Intermediate empties control → combined | Duration control → combined ms |
|---|---:|---:|---:|---:|
| p37 | 4000 | 2 | 0 → 0 | 2426 → 2418 |
| p38 | 4000 | 16 | 11 → 11 | 2806 → 2802 |
| p39 | 5000 | 2 | 0 → 0 | 2424 → 2418 |
| p40 | 5000 | 16 | 9 → 9 | 2784 → 2806 |

Final completion occurs at point 684 in every program and is excluded explicitly, rather than inferred by subtracting a presumed final count. All reported XYZ endpoint errors are zero. Per-program stack watermarks are control 358/350/350/351 and combined 350/358/356/358 bytes: maximum 358 for both, scoped to this workload only.

All final consumed descriptors at empty have saved planned endpoint and block-exit speeds zero. These values are not physical velocity. Control planner queue at empty is zero throughout. Combined queue is one at p40 line 4 (cycle 131314263, point 115) and line 9 (cycle 149309811, point 400), zero otherwise. The queue count alone does not establish a cause or abrupt nonzero starvation.

p40 intermediate-event lines change from 3/4/5/6/7/9/10/11/13 to 3/4/5/7/9/10/11/12/13. Equal counts do not mean identical events.

## Raw shifted curves

All 2736 emitted XY targets across four programs are bit-identical. Z differs at 208 of 684 targets in each program, maximum absolute difference 2.384185791015625e-7 mm. Final raw XYZ targets match in every program. Thus the five full-identity cases in the bounded corpus do not imply full Z identity on repeated shifted ordinary curves. No new smooth-3D accuracy certificate follows from this comparison.

## Boundary timing

Ranges below exclude final completion. All values are wall milliseconds, not exclusive estimator or planner CPU time. Actual returned command LF is used, not serial entry or presumed wire arrival.

| Interval | p38 control | p38 combined | p40 control | p40 combined |
|---|---:|---:|---:|---:|
| LF return to empty | 17.06969–19.22450 | 17.59006–18.54125 | 16.89650–19.30238 | 17.48119–19.06469 |
| Empty to outer ISR return | 25.16413–25.17006 | 25.16413–25.17006 | 25.16413–25.17006 | 25.16413–25.17006 |
| Empty to first new publication | 50.33413–52.25781 | 50.35238–51.30838 | 50.43875–52.27125 | 25.54131–51.34456 |
| Empty to wake entry | 52.53263–54.45650 | 52.55106–53.50688 | 52.64050–54.47300 | 52.53394–53.56050 |

The shorter p40 publication delay does **not** imply wake after 25 ms. At the two queue-one empties, preparation was already active before empty and resumes after the ISR:

- Line 4: prep entry 131314144; empty 131314263; ISR return 131716889; first publication 131726972; prep return 131731792.
- Line 9: prep entry 149305303; empty 149309811; ISR return 149712532; first publication 149718472; prep return 149723387.

The next fresh preparation entry after each empty sees 15 queued blocks, but it is not necessarily the call producing the first publication: in these two cases the interrupted pre-existing call does so. This distinction prevents incorrectly attributing every restart to a single post-ISR full-queue preparation interval. All measured wake delays still exceed 52.5 ms. Other ISR work remains included in wall intervals.

## Resources and conclusion

Production flash: control 32316, combined 32352; static RAM 1670 both. Bootloader-region excess 60/96 bytes, full 32768-byte gate passes. Dyn flash is 32268/32304 with static RAM 1567. No oversized image was executed.

On this matched workload, the combination retains the same twenty intermediate empties. Durations move in both directions; no ordinary-motion continuity improvement is established. The bounded startup/spatial tradeoffs remain separate evidence. No universal .002 mm, fewer-stop, boot-fit or physical-velocity claim is made, and no production default or subsequent algorithm change is selected. All controls and artifacts remain preserved.
