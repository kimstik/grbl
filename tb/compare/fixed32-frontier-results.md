# Saved fixed32 ordinary motion

This matched experiment observes existing fixed24 and fixed32 firmware on cold p37-p40 G94 only. It adds no density, formula, local-length, stride, realtime, settings or autostart change. The workload, host observer (including boundary probes and raw XYZ), and simulator are unchanged from the preceding matched local-length observation.

## Provenance and execution gates

- Harness: `2737ca0445d17c3e5564104c311e7765dbc7cc64`.
- CI: https://github.com/kimstik/grbl/actions/runs/45875428572 (successful).
- Fixed24 source: `500513d26e14e5a16bcdaa6c7976107d6a5f888c`, `TB_Z_FIXED_24`.
- Fixed32 source: `b1d07643db957ea33e64c6986b9322fb2d06b4b2`, `TB_Z_FIXED_32`.
- Simulator: `13d4ed32433ad7a37bb757b7e0f7dbb5373396c0`.
- AVR gcc/binutils/libc: `16.2.0-1 / 2.47-1 / 2.3.2-4`.
- Both production images passed full 32768-byte flash and exact saved production ELF SHA256 gates **before simulation**. Fixed32 hash `2b46172047ba4089144fd90e905c15e01c4b948210f0ffe62b4a98fdbb8554f2` is the bounded accuracy run 45825563600 image. Fixed24 hash `d93935e3905e921e08fbcba16539ae062564e1b0a9e44ae97e7e1c7fa84d9278` is the saved bounded control.
- Observed/blind execution agrees on end cycle, cpu_Done, UART bytes and cycle-sensitive UART hash within each arm. Publication/consumption generations and saved endpoint speeds were independently replayed from raw traces, not only copied from classification JSON.
- The rerun fixed24 production ELF, dynamic ELF, observed trace, UART and blind trace are byte-identical to the earlier local-frontier matched control.

## Results

Intermediate empties exclude the final completion empty. These are actual segment-buffer empty events, not delayed UART stop counters.

| Program | Feed | Sender latency, ms | Fixed24 intermediate empties | Fixed32 intermediate empties | Fixed24 duration, ms | Fixed32 duration, ms | Delta, ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| p37 | 4000 | 2 | 0 | 0 | 2426 | 2425 | -1 |
| p38 | 4000 | 16 | 11 | 11 | 2806 | 2804 | -2 |
| p39 | 5000 | 2 | 0 | 0 | 2424 | 2422 | -2 |
| p40 | 5000 | 16 | 9 | 10 | 2784 | 2832 | +48 |

The saved fixed32 support point has 21 versus 20 intermediate empties here. Durations are mixed: three programs change by -1 or -2 ms, p40 increases by 48 ms. This is the observed price on these cold programs, not a universal density or latency rule. It does not establish the marginal CPU contribution of the estimator to each stop.

Every empty in both arms has saved published planned endpoint speed **zero** and planned block exit speed **zero**. No nonzero-publication starvation event occurs in this corpus. These saved planned quantities are not physical tool velocity.

Fixed24 planner queue is zero at every empty. Fixed32 has queue one at three p40 events: line4/point115/cycle131515099, line7/point286/cycle142808758, line12/point571/cycle160963400. All other fixed32 empties have queue zero. A nonempty planner queue does not imply a nonempty step-segment ring; no boundary-causality conclusion is drawn solely from these three observations. Further shutdown/prep diagnosis was unnecessary for the matched count/duration conclusion.

Raw target XYZ are **bit-identical across all 2736 points**, 684 per program; all endpoints also match. Thus the observed motion differences in this corpus are not accompanied by target-coordinate changes. This is independent of the different short/long S accuracy results: those are different saved inputs, not the ordinary-motion programs.

| Resource | Fixed24 | Fixed32 |
|---|---:|---:|
| Production flash, bytes | 32316 | 32322 |
| Production static RAM, bytes | 1670 | 1670 |
| Bootloader application margin, bytes | -60 | -66 |
| Dynamic image flash, bytes | 32268 | 32274 |
| Dynamic image static RAM, bytes | 1567 | 1567 |

Neither production image fits the 32256-byte application region. Headless/dynamic watermarks are not a proof of production ISR stack safety.

## Accuracy context, not an acceptance gate

The separate smooth-reference analysis gave directed emitted-polyline-to-intended-smooth-curve long S G94 numerical brackets approximately `[.004649005,.004650429]` mm for fixed24 and `[.001498435,.001499899]` mm for fixed32. That accuracy gain is now accompanied by the matched motion evidence above. It does not imply universal dominance: short S G93 favored fixed24 in that numerical comparison, and these motion durations are mixed. All support points are retained; .002 mm is not used here as an automatic rejection threshold.

## Raw anchors

Fixed24 final event: `end 168487364 6 917 1281633213 2901 2901 24`.

Fixed32 final event: `end 169151143 6 917 2936988272 2895 2895 25`.

CI artifact `fixed32-frontier` contains `fixed24/` and `fixed32/`, each with production/dynamic ELFs, options/source records, production identity gate, sizes, observed/blind raw traces and UART, and classification. The host observer and checker remain reproducible via `tb/compare/frontier_run.sh`. No downloaded executable was run locally. No merge, default selection or firmware fix is made by this report.
