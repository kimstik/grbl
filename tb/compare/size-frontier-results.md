# Boot-fitting candidate motion

Matched cold p37-p40 G94 observation of frozen combined `4eb683aade6a1250620e322ce36bd93f1416cb5c` and the final size candidate `33da70b6d5667e9581c240d6dba6ef5b435c94a9`. Harness `361e79fe94b1225273bfd4d6c49247631f297016`; CI https://github.com/kimstik/grbl/actions/runs/45879111923 succeeded. No firmware, density, settings, realtime, default or numerical change was made in this harness. This is **G94 motion**, not actual-G93 motion evidence.

## Identity and gates

The simulator remains `13d4ed32433ad7a37bb757b7e0f7dbb5373396c0`, with AVR gcc/binutils/libc `16.2.0-1 / 2.47-1 / 2.3.2-4`. The host frontier/boundary/XYZ observer and dynamic bench are unchanged. Both arms use fixed24 and LOCAL, with the same workload and settings.

Before any simulation, the production images passed the normal 32768-byte gate and exact SHA256 checks against their saved bounded artifacts:

- Combined: `623b1e8d5019a4f0d7fdd749a086cce61eeaeeb716b4cf5cde9a917c6ea9ee62`, bounded run 45870539098.
- Candidate: `482c6d098adeeaf4db536b959296b5da3a08a49b2a95ae3fa2f05c1415a00e29`, bounded run 45878477195.

The candidate additionally passed a strict 32256-byte application-region gate. The control's known application-region overflow is recorded rather than waived as a fit.

Independent raw replay verifies publication/consumption generations, no live segments at the empty ring, saved publication cycle and planned speeds. Observed/blind runs agree within each arm on end cycle, cpu_Done, UART bytes and cycle-sensitive UART hash. The repeated control production ELF, dynamic ELF, observed trace, UART and blind trace are byte-identical to the preceding combined motion capture.

## Matched motion results

Intermediate counts exclude final completion empties and come from actual ISR segment-buffer events, not delayed UART counters.

| Program | Feed | Sender latency, ms | Control intermediate empties | Candidate intermediate empties | Control duration, ms | Candidate duration, ms | Delta, ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| p37 | 4000 | 2 | 0 | 0 | 2418 | 2414 | -4 |
| p38 | 4000 | 16 | 11 | 11 | 2802 | 2951 | +149 |
| p39 | 5000 | 2 | 0 | 0 | 2418 | 2429 | +11 |
| p40 | 5000 | 16 | 9 | 8 | 2806 | 2801 | -5 |

The total count falls from 20 to 19, but duration is mixed, with a substantial **149 ms p38 regression**. Fewer empties is not sufficient to call this a motion improvement. No realtime change is proposed or applied to hide that result.

All **2736 raw XYZ targets are bit-identical**, 684 per program; final endpoints match. Every empty in both arms has saved planned endpoint speed and saved planned block-exit speed zero. These are publication-time planned quantities, not physical velocity. No nonzero-publication starvation event appears in this corpus.

## Boundary distinction needed for p38

Control p38 has planner queue zero at all eleven intermediate empties. Candidate p38 has queue one at all eleven, at points 58/115/172/229/286/343/400/457/514/571/628. Each candidate empty interrupts an already active `st_prep_buffer` call; its first subsequent publication occurs before that same call returns. Control has no p38 empty inside an active prep call.

Consequently candidate empty-to-first-publication is only 25.325125-25.626375 ms, versus control 50.352375-51.308375 ms. But empty-to-actual-wake remains 53.1069375-53.3698125 ms, versus control 52.5510625-53.506875 ms. The early publication therefore **does not mean an earlier motion restart**. These raw boundaries invalidate that tempting interpretation; they do not by themselves isolate the full cause of the 149 ms duration difference.

### P38 elapsed-time accounting

Raw `program 38` to `program 39` markers are control cycles 39745156-84680371 and candidate 39673827-86981239. They include report/setup overhead, so their exact durations differ from the bench's reset Timer2-derived integer milliseconds. The following disjoint intervals sum exactly to each marker-to-marker duration:

| P38 interval | Control, ms | Candidate, ms | Delta, ms |
|---|---:|---:|---:|
| Program marker to first wake | 80.1378125 | 80.4555000 | +0.3176875 |
| Eleven intermediate empty-to-wake intervals, summed | 587.0442500 | 584.9540000 | -2.0902500 |
| Twelve wake-to-empty intervals, summed | 2110.7813125 | 2260.8070625 | +150.0257500 |
| Final empty to next program marker | 30.4875625 | 30.4966875 | +0.0091250 |
| Whole marker interval | 2808.4509375 | 2956.7132500 | +148.2623125 |

Thus the extra time is in wake-to-empty intervals, not the sum of empty-to-wake waits. The exact decomposition has zero arithmetic residual. The difference between the reported +149 ms and marker delta +148.2623125 ms is .7376875 ms; these are different measurement windows and Timer2 quantization, not a separately measured firmware activity.

Saved published descriptors matched to consumed generations provide further evidence: control consumes 720 p38 segments, candidate 731. Control has 60 segments in each of twelve wake-to-empty periods; candidate has 60 initially, then 61 in each subsequent period. Summed descriptor `n_step * cycles_per_tick` is 2107.6756875 ms versus 2257.8668125 ms, a **+150.191125 ms** increase. The difference between wake-to-empty elapsed and this nominal timer work is 3.105625 ms versus 2.94025 ms (delta -.165375 ms). Timer work is not exact wall time: this remainder can include ISR/dispatch/phase effects and is not causally assigned here. The increase is therefore reflected in saved segment timing, not explained by early publication alone. Which planner/preparation phase interaction produced those different descriptors is not isolated by this accounting.

Both programs are entered from the bench's IDLE/empty-planner transition, and setup resets system/parser positions to zero. Final p38 empty records are at cycles 84192570 and 86493292, point 684, queue zero, empty ring; all p38 empty records have raw sys/suspend/rt values `8/0/0`. The following program transition occurs only after IDLE and empty planner. Raw target endpoints and bench final position errors agree.

Each arm has 13 UART `ok` callbacks and 13 actual serial LF returns. Relative to the program marker, first/second/last `ok` are control 17.607 / 217.833375 / 2739.850375 ms and candidate 17.9725 / 217.9214375 / 2887.67075 ms. The interval from second to last `ok` increases by 147.7323125 ms. First/last LF returns are control 17.0549375 / 2530.996875 ms and candidate 17.4204375 / 2664.4329375 ms. Sender progression therefore diverges with the changed execution intervals despite the same configured turnaround and workload. These callback times are not an independent cause attribution; the bench sends subsequent lines in response to firmware progress. Full arrays are retained by the reproducible raw verifier.

Other queue-one empties: control p40 line4/point115 and line9/point400; candidate p40 line3/point58, line5/point172 and line11/point514. All remaining empties have queue zero. A queued planner block is not a queued step segment.

## Resources and comparable watermark

| Resource | Combined control | Final size candidate |
|---|---:|---:|
| Production flash, bytes | 32352 | 32074 |
| Production static RAM, bytes | 1670 | 1670 |
| Application-region margin, bytes | -96 | +182 |
| Dynamic image flash, bytes | 32304 | 32026 |
| Dynamic image static RAM, bytes | 1567 | 1567 |
| Dynamic watermark p37, bytes used | 350 | 350 |
| Dynamic watermark p38, bytes used | 358 | 356 |
| Dynamic watermark p39, bytes used | 356 | 350 |
| Dynamic watermark p40, bytes used | 358 | 350 |

The dynamic bench and its memory layout are matched, so these observed watermarks are comparable within this workload. They are not a production/ISR worst-case stack proof and must not be subtracted from production free RAM as if they were measured production margins. The separate bounded G93 production size is 32208 bytes with +48-byte application margin; it was not exercised as actual-G93 motion here.

## Evidence anchors and disposition

Control final raw record: `end 168559240 6 917 2903540197 2896 2896 24`.

Candidate final raw record: `end 170945520 6 917 29120226 2915 2915 23`.

Artifact `size-frontier` retains both arms, source/options, exact-image and size gates, production/dynamic ELFs, disassembly/layout checks, observed/blind raw traces and UART, and classifications. Raw output identity and boot fit survive this test, but ordinary-motion durations do not establish dominance. The candidate and all prior comparison points are retained. No default selection, merge, extra optimization or broader robustness/plane-support work is part of this experiment.
