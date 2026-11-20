# Chord-interior audit

The common `tb --dump-strict` check reports dense curve-to-polyline distances
and emitted-vertex-to-dense-curve distances. It does not inspect every interior
point of each chord in the reverse direction. `audit.py` adds an independent
numerical check of both entire polylines without modifying the firmware or the
common captured corpus.

```sh
python tb/compare/audit.py --self-test
python tb/compare/audit.py adaptive.dump.clean adaptive.strict --budget .02
```

Inputs are the actual AVR target dump and its completed zero-failure
`--dump-strict` output. The latter prints host-parsed binary32 control points
with nine significant digits; the audit restores their exact binary32 values
before using double arithmetic. This is not proof that another AVR compiler
produced identical parser intermediates. All methods must be audited against
the appropriate identical net, and parser-vs-direct-call cases stay distinct.

## Reference and distance calculation

The reference is built by de Casteljau subdivision in double precision,
independently of the firmware's Horner polynomial, accepted parameters, segment
count or arc fitting decisions. A leaf is accepted when both inner controls
are within `epsilon = budget/128` of its finite chord. The convex capsule then
contains the exact leaf curve; continuity of its projection along the chord
provides the reverse geometric bound in exact real arithmetic. Degenerate
zero-length chords, loops and collinear reversals are subdivided rather than
silently assumed flat.

For each directed distance between the reference polyline and the actual
polyline, nearest-segment queries use a BVH. A source chord is bounded using:

- a lower bound from its endpoints and midpoint;
- the distance-to-set Lipschitz bound from those samples;
- an upper bound given by the largest endpoint distance to any one selected
  convex target segment (the nearest segments at the three samples are tried).

Refinement bisects the currently largest upper-bound interval until the global
lower/upper gap is at most epsilon. The curve-reference epsilon is then added
on the outside. Source/target subdivision and refinement have explicit depth,
size and iteration limits; exhaustion fails rather than silently accepting.
The script reports PASS, FAIL or UNRESOLVED from the final error interval. Both
FAIL and UNRESOLVED return a nonzero exit code.

**Limits:** computations are ordinary binary64, not outward-rounded interval
arithmetic. These are numerical enclosures justified by geometric inequalities,
not a certified floating-point proof, a guarantee for all firmware inputs, a
Z-by-length/time check, or a physical/step-quantized path guarantee. A successful
specific-input audit must not be described as universal strict accuracy.

## Initial measured check

Actual AVR GCC 7.3 dumps of all eight shared core curves, tol .01, final budget
.02, XY/G94, both direct Wang and adaptive chord-normal candidate:

| Build             | Largest numerical upper bound | Final budget | Curves passed |
|-------------------|------------------------------:|-------------:|--------------:|
| Wang              |                    0.01788123 |         0.02 |           8/8 |
| Adaptive normal   |                    0.01831422 |         0.02 |           8/8 |

The adaptive candidate's tight large-handle curve uses its Wang fallback; the
captured geometry is not counted as an adaptive accuracy improvement. This
small corpus and one compiler do not replace random/adversarial testing.
