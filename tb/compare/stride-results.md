# Fixed24 cached stride

## Scope and evidence

One default-off candidate, `TB_Z_STRIDE_CACHE`, from frozen fixed24 firmware `500513d26e14e5a16bcdaa6c7976107d6a5f888c`. Firmware change: `a6561be40a7213fa11dda0de688b218efb76197c`. Workflow correction only: `e7c361d1aa5c96a2b39d731a12a9d7c989ad69b3`.

CI https://github.com/kimstik/grbl/actions/runs/45864885972 built both modes and completed all simulations. Its overall status is **failure**: the original new checker rejected an unmeasured positioning G0 target before the first G5. The corrected checker was run locally on the saved raw artifacts, not by rerunning downloaded firmware. Both mode comparisons pass. A separate parser independently confirmed all 1699 target/feed/condition records per mode. No green CI status is claimed.

The first attempt, run 45864505851, failed before compilation because checkout preceded Git installation and used REST archives without `.git`. Moving tool installation before checkout resolved that infrastructure issue without firmware changes.

## Storage proof

With the cached point configuration on AVR, coefficients occupy bytes 0-23 and point XYZ bytes 24-35 of the parser scratch. The existing consumed parser prefix occupies 38 bytes. The new uint16_t stride uses bytes 36-37, without enlarging the containing union, parser values or persistent RAM. AVR compile-time assertions verify scratch size 38, point offset 24, stride offset 36, scratch offset 0 in parser values, target XYZ offset 38 and parser-values size 50. The linked parser block remains 62 bytes; spline Z state remains unchanged.

Feed, spindle and tool values in that prefix have been consumed before spline execution. Post-spline handling reads target XYZ and modal state outside the scratch. Coefficients, point Z used for coordinate risk, and all spline estimator state remain untouched.

Only the original unclamped `(segments + 23)/24` expression is cached. Its operands and integer semantics are unchanged (normal segment cap 2000 gives stride 1-84). The original G94 minimum of five, remaining-segment clamp, pending reversal `todo` override and exact-sum selection remain in their original order. The cache is initialized once per curve, including no-Z G94 and actual G93 with zero Z; fallback does not overwrite it. No encoding or reinterpretation of live state is used.

The default-off guard requires fixed24, fixed/chords/cache/parser-workspace/parser-scratch, cubic splines and Z mode 3, and rejects SELECT. Without the flag, production ELF files are byte-identical to the frozen fixed24 control in both modes.

## Static cost

| Build | Control flash | Cached flash | Change | Static RAM | Helper local frame |
|---|---:|---:|---:|---:|---:|
| G94 | 32316 | 32342 | +26 | 1670 unchanged | 68 unchanged |
| G93 | 32456 | 32482 | +26 | 1670 unchanged | 70 unchanged |

ELF section sizes were independently recomputed from the downloaded data. Both candidates fit the full 32768-byte device, but exceed the 32256-byte bootloader region by 86/226 bytes. The helper symbol accounts for the entire increase: 1588 to 1614 bytes and 1728 to 1754 bytes. The unchanged local frames are not universal peak-stack proofs.

## Isolated startup measurements

Existing non-dump AVR bench, 16 MHz. It uses a Timer1 overflow timebase rather than the motion ISR; no shutdown idle-lock dwell contaminates these startup values. They remain measured wall cycles, including benchmark/timebase overhead, not an exclusive estimator CPU profile. Dump output is used only for identity, never timing.

| Case | G94 control ms | G94 cached ms | G94 saved cycles | G93 control ms | G93 cached ms | G93 saved cycles |
|---|---:|---:|---:|---:|---:|---:|
| Short S, Z -30 | 24.0569375 | 23.8095000 | 3959 | 22.9722500 | 22.7246875 | 3961 |
| Long S, Z -500 | 27.5456250 | 27.2575000 | 4610 | 26.2596875 | 25.9733750 | 4581 |
| Translated line, Z 1000 | 23.9069375 | 23.2523750 | 10473 | 26.6763125 | 25.6256250 | 16811 |
| Origin line, Z 1000 | 9.9131875 | 9.7888125 | 1990 | 13.1204375 | 12.6018750 | 8297 |
| Short S, no Z | 1.3138750 | 1.3256875 | -189 | 22.7296250 | 22.4840000 | 3930 |
| Near cusp, Z -10 | 26.9775000 | 26.6573750 | 5122 | 25.9213125 | 25.5493750 | 5951 |

No-Z G94 is slower by 189 cycles (0.0118125 ms): it pays initialization despite skipping estimation. This was not optimized away in a second variant.

Generation-cycle savings (bench total minus planner) in table order:

- G94: 3742, 5218, 10504, 2052, -220, 5091.
- G93: 3806, 4260, 16873, 8235, 3899, 5703.

Maximum inter-target gaps in cycles, control to cached:

- G94: 5895→5895, 5951→5948, 5935→5935, 5512→5512, 3592→3623, 5780→5780.
- G93: 5899→5899, 5971→5964, 5939→5970, 5516→5516, 3596→3596, 5818→5787.

These small gap differences are retained, not reported as a general gap improvement.

## Identity and exercised paths

All raw XYZ, feed and condition words match the control across all six cases in both actual feed modes (1699 targets per mode). Status, segment counts, endpoint checks, target hashes and estimator trace counters also match. Thus the retained measured accuracy is unchanged for these inputs; this is not a universal float proof.

- No-Z G94 has no estimate; no-Z actual G93 still estimates (21 coarse pieces) and retains identical feed.
- Translated line exercises fallback: G94 reports two estimates, eight coarse pieces and 46 summed segments; G93 reports two estimates and 86 summed segments. The origin control has one estimate (G94 eight coarse pieces/three sums; G93 43 sums).
- Near-cusp input is included for reversal-sensitive geometry, and its output/counters match. The present dump has no explicit `todo`-override counter; direct runtime coverage of that branch is **not established** by those counters alone. The source override is unchanged and still follows the cached base-stride load.

## Tradeoff and limits

The one candidate buys about 0.247-0.288 ms startup on the two S cases, and more on repeated exact-sum work, at +26 flash bytes and a small no-Z G94 regression. RAM and helper local frames do not grow. This is a bounded measured tradeoff, not a selected production default or boot-fit result.

No ordinary-motion, stop-count, restart-policy or realtime change was tested. No claim is made that these savings remove any of the twenty previously observed intermediate stops. No additional density/formula/compiler sweep was run. Original control, failed CI evidence and candidate remain preserved.
