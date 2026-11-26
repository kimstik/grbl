# Quadrature reference comparison

Constant-weight follow-up source `89ff190ece9d742bee6a96a551734b60d0954ea1`.
CI: https://github.com/kimstik/grbl/actions/runs/45850131952

The estimator formula is unchanged from `a0972b6`. The former hard native
0.002-mm gate became a finite-result check and explicit 0.002/0.003/0.004
references. The long-S result remains 0.00201283775 mm, exceeding 0.002 by
0.642%; this is a useful measured result, not an automatic research rejection.
No firmware tolerance or default was changed.

## Static comparison, AVR GCC 16.2.0

| Candidate           | G94 flash | G93 flash | G94 boot margin | G93 boot margin |
| ------------------- | --------: | --------: | --------------: | --------------: |
| Norm / fixed16      |     32322 |     32458 |             -66 |            -202 |
| Discrete Gauss      |     32970 |     33108 |            -714 |            -852 |
| Constant weights    |     32878 |     33016 |            -622 |            -760 |
| Algebraic reuse     |     33154 |     33292 |            -898 |           -1036 |

Norm sizes are ELF `.text + .data`. Candidate extents are inferred from normal
ATmega328P linker overflow, not valid production ELFs. Constant weights reduce
extent by 92 bytes versus discrete Gauss in both modes, but still overflow the
physical 32768-byte limit by 110/248 bytes. The normal link failed, candidate ELF
files are absent, and execution was skipped. No oversized images were executed.
The six flag-off production/bench/dump ELFs are byte-identical to fixed16 CI
45825563600; its production RAM is 1670 bytes. No new persistent state was added
to these formulas; actual candidate stack remains unmeasured.

## Native local-chord models

| Formula              | Short-S maximum Z error | Long-S maximum Z error |
| -------------------- | ----------------------: | ---------------------: |
| Discrete Gauss       |          0.000272580742  |         0.00198232017  |
| Constant weights     |          0.0004003731    |         0.00201283775  |
| Algebraic reuse      |          0.000276395439  |         0.00195163177  |

All are native binary32 `-O2 -ffast-math` models of local chords, not AVR rounded
absolute output or true spatial certificates. All are below 0.003/0.004; only the
constant-weight long case is above 0.002. These numbers do not establish runtime
accuracy improvements over fixed16.

## Existing AVR fixed16 reference

From bounded CI 45825563600, short/long S respectively:

| Mode | Emitted-chord Z error mm     | First target ms       | Maximum gap ms       |
| ---- | --------------------------- | --------------------- | -------------------- |
| G94  | 0.002442018 / 0.011884512    | 19.112813 / 18.651438 | 0.367500 / 0.372500 |
| G93  | 0.004530565 / 0.012220206    | 18.328438 / 17.826500 | 0.370813 / 0.372563 |

G93 nominal relative time errors are 4.33177824e-5 / 2.28188589e-5, not achieved
physical cycle times. These measured errors remain useful reference results.
The candidate formulas have no AVR first-target/gap/accuracy/G93 measurements,
including no-Z G93, because their normal production links do not fit. No speed
benefit is inferred from fewer arithmetic operations.

All branches and evidence retained. Research value and production readiness are
separate: these comparisons preserve partial improvements and their limits,
without selecting a winner, changing defaults or merging.
