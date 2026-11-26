# Local initial zero lifetime

Frozen risk-max control: `cbedce7ac328c3158d61df8cc1bea7060f90c77c`. Candidate: `2347f8d359c7ec64cb5722763fecbe7ab68a9a66`.

## Reader proof and scope

The candidate omits `p[Z_AXIS] = 0.0f` in `mc_spline_cache_init` only under `BEZIER_LOCAL_LENGTH`. The pointer declaration is also restricted to nonlocal mode to avoid a new unused-variable warning. First/second pointers, coefficient expressions/order, union layout, realtime service, fallback and emission are untouched.

In the frozen control, the driver copies position to point at `motion_control.c:914`, before cache initialization. Therefore without the cache zero store point-Z remains defined as the original position Z, not uninitialized memory. The risk maximum reader at line 755 is excluded for LOCAL. Before any emitted intermediate target, the no-Z G94 initialization restores Z at 651, or estimate completion restores Z at 775, including actual-G93 no-Z. Nonzero-Z emission writes Z at 608. The final target assignment at 1031 also covers segments=1, when the helper loop does not execute.

While the helper returns true, the driver calls realtime at 979 without passing the scratch point; it does not call `mc_line` until false. Abort returns without emitting the temporary point. The parser's scratch point is separate from its coefficient union, and the workspace is passed only to the spline driver; no ISR reads this temporary Z value. Consequently the removed zero cannot reach an emitted target on these paths.

## Static comparison

| Resource | Risk-max G94 | Candidate G94 | Risk-max G93 | Candidate G93 |
|---|---:|---:|---:|---:|
| Production flash, bytes | 32144 | 32134 | 32274 | 32264 |
| Static RAM, bytes | 1670 | 1670 | 1670 | 1670 |
| Bootloader application margin, bytes | +112 | +122 | -18 | -8 |
| Cache initialization symbol, bytes | 302 | 292 | 302 | 292 |
| Cache initialization local frame, bytes | 18 | 18 | 18 | 18 |
| Next helper local frame, bytes | 66 | 66 | 68 | 68 |

Measured saving is ten bytes in each mode. G93 still exceeds the 32256-byte application region by **eight bytes**; this is not rounded away. Both modes fit full 32768-byte flash. No stack-safety claim follows from these local frames.

The initial minimal edit left a now-unused local pointer warning. Moving only that declaration under the same nonlocal guard removed the warning. Before/after declaration-only cleanup, exact ELF bytes were compared in all four combinations LOCAL on/off and G94/G93; all were identical. Existing EEPROM boolean-shift warnings at `eeprom.c:133,144` remain. All local static builds ran serially at IDLE; no AVR artifact was executed locally.

## Bounded regression

One matched CI: https://github.com/kimstik/grbl/actions/runs/45877561271 . Both enabled arms use LOCAL; separate LOCAL-off production builds check exact ELF equality. The six cases are short S, long S, translated line, origin line, no-Z and near-cusp, in actual G94/G93. The checker requires all XYZ/feed/condition words and all non-cycle summary/trace words to match. No ordinary-motion run or further optimization variant is included.

CI succeeded in all four build/run jobs. Independent raw parsing verified all 1699 XYZ/feed/condition records per mode, all non-cycle summary fields and all trace words in the six cases. LOCAL-off production ELF bytes are identical. Enabled control ELF matches the preceding risk-max artifact; candidate CI ELF matches the corresponding local static build exactly.

| Case | G94 control first, ms | G94 candidate first, ms | G93 control first, ms | G93 candidate first, ms |
|---|---:|---:|---:|---:|
| Short S | 23.3888750 | 23.3883125 | 22.3172500 | 22.3166875 |
| Long S | 26.7886250 | 26.7880625 | 25.5180000 | 25.5174375 |
| Translated line | 9.6623750 | 9.6618125 | 12.5143125 | 12.5137500 |
| Origin line | 9.5743750 | 9.5738125 | 12.4282500 | 12.4276875 |
| No Z | 1.2706250 | 1.2700625 | 22.0847500 | 22.0841875 |
| Near cusp | 26.1217500 | 26.1211875 | 25.0792500 | 25.0786875 |

First-target latency decreases by exactly nine cycles (.0005625 ms) in all twelve cases. All maximum inter-target gaps are unchanged. Total generator cycles decrease by nine in nine cases and by 71 for long S G94; near-cusp totals **increase by 22 cycles in both modes**, despite earlier first targets. These measured aggregate timings include interrupts and are not a uniform whole-generator speed improvement.

Raw output identity preserves the previously measured bounded geometry and nominal G93 time for these captured records, not a general correctness certificate. Ordinary motion was not run, so no stop-count or duration result is claimed for this candidate. No further microvariant was tried to remove the remaining eight-byte G93 boot excess.

Artifacts `local-g94` and `local-g93` contain both arms, OFF images, raw bench/dump records, options/source, sizes, disassembly and symbols. No merge or default selection was made.
