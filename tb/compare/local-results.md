# Fixed24 with local lengths

## Scope and verification

One composition, not another density: frozen fixed24 `500513d26e14e5a16bcdaa6c7976107d6a5f888c` plus only the optional local-length firmware patch from `bdfd69b655fb65a852bc906a1fac07c4905fb22d`. Combined source `4eb683aade6a1250620e322ce36bd93f1416cb5c`, branch `wip/g5-fixed24-local`.

CI https://github.com/kimstik/grbl/actions/runs/45870539098 succeeded, all four jobs. Two actual feed modes, six cases each; frozen fixed24 control built alongside the candidate. Stride cache is absent. No realtime, settings, autostart or ordinary-motion changes. Broad workflow excluded before push.

Independent local parsing of downloaded raw data (no downloaded firmware executed) confirmed every reported chord-Z value, exact-line spatial distance and actual G93 nominal-time error. ELF section sizes were independently recomputed. Control production ELFs match the previous fixed24 run 45864885972 byte for byte. Candidate source with LOCAL_LENGTH disabled produces identical production ELFs to the frozen control in both modes.

All emitted XY bits and conditions match across 1699 targets per mode. Five of the six cases also retain complete XYZ/feed/condition identity: short S, long S, origin line, no-Z and near cusp. Only translated-line raw output changes. Timed and dump target hashes agree within every arm. This is the tested unaffected behavior; no broad build matrix or universal equivalence claim is made.

## Storage and length semantics

No struct or persistent workspace grows. `spline_z` stays 25 bytes, parser block 62 bytes, total static RAM 1670 bytes. The existing chord/poly pair holds the previous local XY point. It is zeroed at the local origin and reset after the initial estimate and any G93 feed conversion. Point Z still restores the initial Z after its temporary coordinate-risk use. Coefficients and parser workspace are unchanged.

Local evaluation computes segment norms before adding the absolute start coordinate for emitted XY. The absolute-coordinate risk fallback is deliberately disabled because its rounded absolute-chord path is no longer the length model. The configuration guard requires cached points and the norm helper, whose dependencies require fixed mode, parser workspace and Z mode 3 without SELECT.

Three metrics must remain separate:

1. **Chord-Z:** Z against cumulative lengths of the emitted, rounded absolute XY chords.
2. **Intended line 3D:** shortest distance to the exact specified straight segment for the two collinear cases. This is an exact geometric oracle, not sampled smooth-curve fitting.
3. **Actual G93 nominal time:** sum of emitted 3D segment lengths divided by their raw converted feeds, compared with 1/F (F=2, relative error `abs(2*time_minutes-1)`). This is nominal commanded time, not accelerated machine execution time.

Local-length does not guarantee agreement with metric 1. No general smooth-3D distance certificate is claimed for the S or near-cusp cases. The .002/.003/.004 references are comparisons, not automatic rejection thresholds.

## Resource cost

| Build | Control flash | Combined flash | Change | Boot-region excess | Static RAM |
|---|---:|---:|---:|---:|---:|
| G94 | 32316 | 32352 | +36 | 96 | 1670 unchanged |
| G93 | 32456 | 32482 | +26 | 226 | 1670 unchanged |

Both fit 32768 bytes; neither fits the 32256-byte bootloader region. Helper local frames decrease from 68 to 66 bytes (G94) and 70 to 68 (G93). Helper symbols grow 1588→1660 and 1728→1790 bytes; other code changes offset part of that growth. These frames are not a full production peak-stack bound.

## Startup and maximum gaps

Existing non-dump AVR bench at 16 MHz: Timer1 overflow timebase, not the stepper motion ISR. No 25 ms shutdown dwell contaminates these startup measurements. Values still include benchmark/interrupt overhead and are not exclusive estimator CPU time.

| Case | G94 control → combined startup ms | G93 control → combined startup ms |
|---|---:|---:|
| Short S | 24.0569375 → 23.4297500 | 22.9722500 → 22.3581250 |
| Long S | 27.5456250 → 26.8295000 | 26.2596875 → 25.5588750 |
| Translated line | 23.9069375 → 9.7013125 | 26.6763125 → 12.5532500 |
| Origin line | 9.9131875 → 9.6153125 | 13.1204375 → 12.4691875 |
| No-Z short S | 1.3138750 → 1.3115000 | 22.7296250 → 22.1236875 |
| Near cusp | 26.9775000 → 26.1622500 | 25.9213125 → 25.1197500 |

Maximum inter-target gaps in cycles, same case order:

- G94: 5895→5951, 5951→6007, 5935→5734, 5512→5568, 3592→3649, 5780→5836.
- G93: 5899→5986, 5971→6011, 5939→5738, 5516→5603, 3596→3653, 5818→5843.

Most maximum gaps grow modestly (up to 87 cycles, 0.0054375 ms); startup improvement is not a universal hot-path improvement.

## Accuracy and actual G93

| Case | G94 chord-Z control → combined mm | G93 chord-Z control → combined mm |
|---|---:|---:|
| Short S | .000602110565 → same | .001606599151 → same |
| Long S | .004804434313 → same | .005262197985 → same |
| Translated line | .000230784487 → 1.042501724508 | .000230784487 → 1.042501724508 |
| Origin line | .000334382057 → same | .000334382057 → same |
| No Z | 0 → 0 | 0 → 0 |
| Near cusp | .000273264065 → same | .000298059597 → same |

The large translated chord-Z difference is retained explicitly. For both feed modes, **intended exact-line 3D distance improves from .0034452199295751567 to .0021620748698105503 mm**. It remains above .002 mm. Origin-line distance stays .0000014953870668481163 mm. A better line-distance result does not make the 1.0425 mm chord-Z result disappear; the underlying length semantics differ.

Actual G93 relative nominal-time errors:

| Case | Control | Combined |
|---|---:|---:|
| Short S | 1.5261826007861856e-5 | same |
| Long S | 9.776162453456472e-6 | same |
| Translated line | 1.27535938032608e-7 | 1.4256236280374424e-7 |
| Origin line | 1.1225358931277185e-7 | same |
| No-Z short S | 5.437394818019747e-5 | same |
| Near cusp | 2.9303708481198676e-5 | same |

G93 is therefore still approximate. The no-Z G93 test checks the real conversion path, not merely a build with the option enabled.

## Work counters and limits

Translated G94 changes from two estimates, eight coarse pieces and 46 summed segments to one estimate, eight pieces and three sums. Translated G93 changes from two estimates/86 summed segments to one/43. This confirms removal of the absolute-risk repeat pass. Short/long S keep 21/24 coarse pieces; no-Z G94 keeps zero estimates, while no-Z G93 keeps one estimate/21 pieces.

Near-cusp output and work counters match the control, but these counters do not directly observe the `todo` override. Explicit runtime reversal-override coverage remains unverified; no native harness expansion was performed. The unchanged branch is not presented as observed coverage.

The composition retains fixed24's measured S outputs while improving translated-line startup and intended-line distance. It costs flash, increases most inter-target gaps slightly, and abandons agreement with rounded absolute-XY chord length on the translated case. No default is selected. No motion run was started, and no claim is made about removing intermediate stops, physical velocity, general spatial tolerance or boot fit. All controls and artifacts remain preserved.
