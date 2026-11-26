# Fixed24 intermediate density

Source `500513d26e14e5a16bcdaa6c7976107d6a5f888c`, branch `wip/g5-fixed24`, from
norm `acc353d`. CI https://github.com/kimstik/grbl/actions/runs/45851819455 completed
all four builds and four runs. No broad matrix ran.

Only the default-off `TB_Z_FIXED_24` partition changes: `(segments+23)/24` instead
of `(segments+15)/16`. Same polygon estimator, chord correction, reversal handling,
coordinate-risk fallback, realtime ordering and defaults. No quadrature code.

## Comparability and integrity

Frozen toolchain avr-gcc16.2.0-1, binutils2.47-1, libc2.3.2-4 matches bounded CI
45825563600. Options match that run's fixed32 except the density macro. Four-case
corpus and raw checker are unchanged. Fixed16 production/bench/dump ELFs and raw
bench/dump outputs are byte-identical to the older run, both G94 and G93.
Recomputing all four raw reports with the reviewed local checker reproduces saved
metrics exactly, including separate no-Z controls. No downloaded scripts executed.

## Flash and RAM

| Density | G94 flash | G93 flash | G94 boot margin | G93 boot margin | RAM |
| ------- | --------: | --------: | --------------: | --------------: | --: |
| Fixed16 |     32322 |     32458 |             -66 |            -202 | 1670 |
| Fixed24 |     32316 |     32456 |             -60 |            -200 | 1670 |
| Fixed32 |     32322 |     32458 |             -66 |            -202 | 1670 |

All fit physical 32768 bytes, none fit 32256 with these options. Fixed24 costs no
new persistent RAM and is 6/2 bytes smaller than fixed16. This does not establish
production stack or motion behavior; headless bench is not stepper evidence.

## Measured AVR targets and timing

Errors below are Z relative to cumulative **emitted absolute XY chords**, not a
local polynomial model and not true spatial distance for the S curves.
Short S has124 segments, long S1238. First/gap are headless bench milliseconds.

| Mode | Density | Short Z error mm | Long Z error mm | Short first ms | Long first ms | Short gap ms | Long gap ms |
| ---- | ------- | ---------------: | --------------: | -------------: | ------------: | -----------: | ----------: |
| G94  | 16      |      0.002442018 |     0.011884512 |      19.112813 |     18.651438 |     0.367500 |    0.372500 |
| G94  | 24      |      0.000602111 |     0.004804434 |      24.056938 |     27.545625 |     0.368438 |    0.371938 |
| G94  | 32      |      0.000322954 |     0.000714753 |      28.126625 |     35.983313 |     0.367688 |    0.373063 |
| G93  | 16      |      0.004530565 |     0.012220206 |      18.328438 |     17.826500 |     0.370813 |    0.372563 |
| G93  | 24      |      0.001606599 |     0.005262198 |      22.972250 |     26.259688 |     0.368688 |    0.373188 |
| G93  | 32      |      0.002232210 |     0.000518502 |      33.023688 |     34.223938 |     0.369500 |    0.372188 |

Fixed24 completes21 coarse pieces on short S and24 on long S, no summed segments,
one estimate in both modes. Density is nominal: rounding, cost cutoff and reversal
can change piece counts. Fixed24 short G93 is both more accurate and faster than
fixed32 in this test; accuracy is not universally monotone with density.
Its long-S errors exceed all .002/.003/.004 references. They remain useful measured
intermediate results, not grounds for deleting the candidate or selecting a winner.

## Actual inverse-time controls

Commands really use G93 F2, with converted path feed (inverse-time segment flags
cleared). Relative nominal duration errors, not achieved physical cycle times:

| Density | Short S with Z | Long S with Z | Short S with zero Z |
| ------- | -------------: | ------------: | ------------------: |
| 16      | 4.33177824e-5  | 2.28188589e-5 | 1.53382842e-4       |
| 24      | 1.52618260e-5  | 9.77616245e-6 | 5.43739482e-5       |
| 32      | 2.12691684e-5  | 4.01331718e-7 | not measured        |

The separate zero-Z control has124 points, XY chord length18.894467038422903 mm,
all Z exactly0, exact endpoint(10,0,0), valid raw target hash and finite positive
feeds. Its one estimator pass has16/21 pieces. No no-Z first/gap claim: this
additional control is dump-only.

## Exact straight-line spatial oracle

Fixed24 does not fix coordinate quantization. Both modes retain translated-line
true3D distance0.0034452199295751567 mm, despite chord-Z0.000230784487 mm. At the
origin true3D is0.0000014953870668481163 mm and chord-Z0.000334382057 mm.
Fixed16/24/32 share those line errors. For fixed24 first times translated/origin
are23.9069375/9.9131875 ms G94 and26.6763125/13.1204375 ms G93. The straight-line
projection oracle is justified here; no true3D certificate claimed for S curves.

This is one preserved intermediate accuracy/startup tradeoff. No additional
densities/formulas, default change, merge, hardware claim, or motion/stack inference.
