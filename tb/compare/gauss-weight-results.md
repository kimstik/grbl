# Constant-weight quadrature gate

Isolated follow-up to the cached discrete Gauss candidate. Source
`a0972b62bf22230910809630dd17c90d5acde7e3`, branch `wip/g5-cached-gauss-weights`.
CI: https://github.com/kimstik/grbl/actions/runs/45848141192

Only the formula changes: side weights `5/18`, middle weight `4/9`, node displacement
`h*sqrtf(.15f*(m*m-1))`. Existing reversal checks, realtime ordering, coefficient
cache, and coordinate-risk fallback remain unchanged. No coordinate variant merged.

Weights sum to one and the discrete variance is preserved:
`2*(5/18)*(3/20)*(m*m-1) = (m*m-1)/12`.
The approximate fourth moment `(m*m-1)^2/80` exceeds the exact discrete moment
`(m*m-1)*(3*m*m-7)/240` by `(m*m-1)/60`. This is not degree-five exact discrete
Gauss quadrature. Removing weight division alone does not establish a speed gain.

## Native binary32 result

The existing local-chord model is compiled with `-O2 -ffast-math`. The added gate
returns failure if either maximum local Z error exceeds 0.002 mm.

| Case          | Estimated XY length | Local chord sum | Maximum local Z error |
| ------------- | ------------------: | --------------: | --------------------: |
| Short S N124  |           18.894207 |   18.8944664001 |          0.0004003731 |
| Long S N1238  |         1889.59058  | 1889.58403611   |          0.00201283775 |

The long S exceeds the gate by 0.00001283775 mm. All four matrix jobs stop at the
same native formula gate, before any AVR compilation. The matrix's fixed16 labels
do not mean fixed16 failed this accuracy check: all jobs run the candidate model
before building their respective arms.

No production link, bench or dump ELF was created. Normal 32768-byte fit,
32256-byte bootloader fit, AVR timing, true spatial accuracy, actual G93/no-Z,
flag-off ELF identity and stack were not measured for this follow-up. The run job
was skipped, and the inherited full G5 matrix was cancelled. No oversized image
was executed. The previous `gauss-results.md` describes only the earlier variable-
weight candidate, not this formula.

This single-formula experiment stops at the requested native gate. No extra
arithmetic variant, optimization sweep, default change or merge was attempted.
