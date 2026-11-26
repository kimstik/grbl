# Unused local coordinate-risk accumulation

## Change and reader audit

Frozen combined control: `4eb683aade6a1250620e322ce36bd93f1416cb5c`. Candidate: `cbedce7ac328c3158d61df8cc1bea7060f90c77c`. The only firmware change guards the two coordinate-risk maximum updates in `mc_spline_cache_init` with `#ifndef BEZIER_LOCAL_LENGTH`. The initial zero assignment is retained. Coefficient expressions, evaluation order, cache alias layout, realtime calls, estimation and emission algorithms are unchanged. The nonlocal risk fallback is unchanged.

The audit below refers to the frozen combined source before the two guard lines were added:

- `motion_control.c:755` is the only consumer of the saved risk maximum, inside `#ifndef BEZIER_LOCAL_LENGTH` at lines 748-773.
- Cache initialization writes zero at line 864 and updates the maximum at 872-873. Coefficients occupy the union at `gcode.h:212-215`, while `point` is a separate array at line 216. Removing the point-Z updates cannot overwrite or expose the coefficient storage.
- No-Z G94 restores `point[Z]` from the initial position at `motion_control.c:651` before returning an emitted point. Nonzero-Z and actual-G93 estimation restore it at line 775 before emission; actual G93 with no Z follows this path too.
- Emission writes Z at line 608 when remaining Z is nonzero. Final target assignment at line 1029 covers the one-segment path, including when no helper iteration runs.
- The driver initializes point from position at line 912, calls cache initialization at 936, and calls realtime while `mc_spline_next` returns true at 970-979. No point is passed to `mc_line` until the helper returns false, line 1003. Realtime does not receive the scratch point.
- Actual-G93 feed conversion at lines 835-847 uses remaining length/Z state, not point-Z. Local previous-XY reset is at 849-850.
- The configuration requires local-length mode to use the cache and norm options, which require fixed mode 3 and parser workspace without SELECT. Other modes do not acquire this change.

Thus with LOCAL enabled the accumulated maximum is dead before the next overwrite. Initial zero remains for a defined temporary state; no additional dead-store elimination was attempted.

## Static results

Serial IDLE local builds used the frozen AVR toolchain and ordinary link capacity; no local AVR image was executed.

| Resource | Combined G94 | Candidate G94 | Combined G93 | Candidate G93 |
|---|---:|---:|---:|---:|
| Production flash, bytes | 32352 | 32144 | 32482 | 32274 |
| Static RAM, bytes | 1670 | 1670 | 1670 | 1670 |
| Bootloader application margin, bytes | -96 | +112 | -226 | -18 |
| Cache initialization symbol, bytes | 510 | 302 | 510 | 302 |
| Cache initialization local frame, bytes | 32 | 18 | 32 | 18 |
| Next helper local frame, bytes | 66 | 66 | 68 | 68 |

The measured saving is 208 bytes in both modes. G94 now fits the 32256-byte application region; G93 still exceeds it by 18 bytes. Both fit full 32768-byte flash. Local frame measurements do not establish production/ISR stack safety.

## Bounded validation

CI https://github.com/kimstik/grbl/actions/runs/45876482182 compares the frozen combined control against the candidate in actual G94 and G93 on short S, long S, translated line, origin line, no-Z and near-cusp. Both enabled arms use LOCAL; separate LOCAL-off production builds compare exact ELF bytes. Tools are installed before checkout, and the unrelated broad workflow is excluded. No ordinary-motion run is part of this experiment.

CI succeeded in all four jobs. Independent raw parsing confirmed all 1699 target records per mode: XYZ/feed/condition words are identical in all six cases, including actual G93 with no Z. Every non-cycle summary field and all emitted trace words are identical. LOCAL-off production ELF bytes match the frozen control in both modes. Enabled control production ELFs match the preceding combined run, and all four CI production ELFs match the corresponding local static builds exactly.

| Case | G94 control first, ms | G94 candidate first, ms | G93 control first, ms | G93 candidate first, ms |
|---|---:|---:|---:|---:|
| Short S | 23.4297500 | 23.3888750 | 22.3581250 | 22.3172500 |
| Long S | 26.8295000 | 26.7886250 | 25.5588750 | 25.5180000 |
| Translated line | 9.7013125 | 9.6623750 | 12.5532500 | 12.5143125 |
| Origin line | 9.6153125 | 9.5743750 | 12.4691875 | 12.4282500 |
| No Z | 1.3115000 | 1.2706250 | 22.1236875 | 22.0847500 |
| Near cusp | 26.1622500 | 26.1217500 | 25.1197500 | 25.0792500 |

First-target savings are 623-655 cycles, or .0389375-.0409375 ms at 16 MHz. Maximum inter-target gap is identical in eleven of twelve cases; actual-G93 no-Z increases from 3653 to 3677 cycles (+24 cycles, .0015 ms). Total generator time decreases in all twelve cases, but not by exactly the initializer savings because these timings include interrupt phase effects; no uniform hot-path improvement is claimed.

Geometry, chord-Z, the saved smooth-reference S results and nominal actual-G93 time remain unchanged for these records because all output coordinates and feeds are bit-identical. This is a bounded regression result, not general accuracy certification. No ordinary-motion run was launched, so earlier intermediate-empty counts cannot be attributed to this candidate.

CI artifacts `local-g94` and `local-g93` retain both arms, raw bench/dump output, production ELF, disassembly, symbols, option/source records and exact OFF-image comparisons. The useful measured result is a 208-byte saving without changed bounded outputs, with a small startup reduction. G93's remaining 18-byte application-region excess is not waived. No merge/default selection or further optimization is included.
