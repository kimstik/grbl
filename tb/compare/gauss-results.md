# Cached discrete three-node estimate

Bounded experiment on base `acc353d03e1e058383aa1ed39948a81e63f70906`, candidate
`be23a1d1e2d2ff5d32451524f8fe6887353eed4b`.
CI: https://github.com/kimstik/grbl/actions/runs/45846250159

`BEZIER_Z_GAUSS` is default-off. It replaces only the fixed coarse length
accumulation, using the existing `g`, `e0`, `d` coefficient cache. Endpoint and
control-point evaluation, reversal subdivision, coordinate-risk fallback and
realtime service ordering remain unchanged. No persistent state was added.

## Model

For `m` consecutive midpoint samples, `h=1/N`, center `t=(start+m/2)h`,
one third of the chord velocity is
`v(t)=g+2*t*e0+(t*t+h*h/12)*d`.
The nodes are `t`, `t +/- h*sqrt((3*m*m-7)/20)`, the side weight is
`5*(m*m-1)/(6*(3*m*m-7))`, and the middle weight is `1-2*side`.
Multiply the weighted norms by `3*m*h`.
The existing cost cutoff sums pieces of three or fewer chords exactly;
an explicit guard also handles fewer than three samples if that cutoff changes.

This is a discrete local-coordinate model, not the sum of rounded absolute XY
vertices. Retaining the existing coordinate-risk heuristic does not make the
estimate a floating-point accuracy certificate.

The implementation retains the geometric reversal check, so three norms replace
four norms but add a square root, division, weights and node arithmetic. Norm count
alone does not predict a startup improvement.

## Results

Frozen CI toolchain: AVR GCC 16.2.0, binutils 2.47, avr-libc 2.3.2.

| Build              | Fixed16 flash | Candidate linker extent | Change | Over 32768 |
| ------------------ | ------------: | ----------------------: | -----: | ---------: |
| G94                |         32322 |                   32970 |   +648 |        202 |
| G93                |         32458 |                   33108 |   +650 |        340 |

Candidate extent is inferred from the linker's normal ATmega328P flash overflow,
not a successful ELF measurement. Both candidate links fail; neither produces a
production ELF. No enlarged-device link or execution was attempted. The combined
run stage was skipped. Candidate AVR startup, maximum gap, emitted-path accuracy,
G93 timing (including no-Z), and stack are therefore unmeasured.

All six flag-off binaries (`production.elf`, `bench.elf`, `dump.elf`, both modes)
are byte-identical to the fixed16 artifacts of bounded CI 45825563600. Independently
parsed production ELF sections confirm 32322/32458 bytes `.text`, zero `.data`,
and 1670 bytes `.bss`.

The native binary32 local-chord model, compiled with `-O2 -ffast-math`, reports:

| Model              | Estimated XY length | Sum of local chords | Maximum local Z error |
| ------------------ | ------------------: | ------------------: | --------------------: |
| Short S, N=124     |          18.894289  |      18.8944664001   |        0.000272580742 |
| Long S, N=1238     |        1889.59045   |    1889.58403611     |        0.00198232017  |

The long-case margin below 0.002 mm is only about 0.00001768 mm in this native
model. This does not establish AVR arithmetic accuracy or true spatial accuracy.
It differs from the earlier double-precision model's 0.0016988783 mm.

Conclusion: this one cached candidate does not fit the physical device. It is
not an accepted startup optimization. No broader variant sweep, default change,
merge or production stack conclusion follows from this experiment.
