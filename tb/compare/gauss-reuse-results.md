# Discrete-node algebraic reuse

Source `4c0755f5532225c99b0ca9725d37f33ee74d9474`, independent branch
`wip/g5-gauss-reuse` from `be23a1d`.
CI: https://github.com/kimstik/grbl/actions/runs/45849412464

Retain discrete delta and side weight. Compute v0 at the center, then
base=v0+delta^2*d and offset=2*delta*(e+t*d), giving vminus=base-offset and
vplus=base+offset. This reuses polynomial products; the three norms remain.
Reversal, realtime ordering and coordinate-risk fallback are unchanged.

Native binary32 model (`-O2 -ffast-math`) maximum local-chord Z errors:
short S 0.000276395439 mm, long S 0.00195163177 mm. These pass the historical
0.002 gate in this run; they are not AVR or true spatial accuracy measurements.
Current research policy treats 0.002/0.003/0.004 as comparison references, not
universal rejection thresholds.

Normal ATmega328P production links overflow by 386 bytes G94, 524 bytes G93.
Inferred linker extents: 33154/33292, versus original cached Gauss 32970/33108
(+184 in both modes) and norm/fixed16 32322/32458 (+832/+834).
Bootloader capacity 32256 is exceeded by 898/1036 bytes. No candidate production
ELF was produced. Runtime jobs were skipped, so startup, gap, actual G93/no-Z,
AVR accuracy and production stack are unmeasured. No oversized execution.
These limits do not erase the candidate or its measured native result.

No new persistent RAM declarations. Helper source locals are three float[2]
arrays (24 bytes), seven outer floats (28 bytes), four loop-scope floats (16 bytes)
and one uint8_t (1 byte): 69 bytes of declarations excluding parameters. This is
not the allocated frame or stack. Lifetimes, registers and spills require compiler
or production evidence. The caller's existing q/r temporaries remain.

The former variable-weight candidate reports native errors
0.000272580742/0.00198232017 mm; this rewrite slightly changes rounding and is
larger under the frozen compiler. No timing benefit has been established.
All branches and evidence retained; no merge, default change or variant sweep.
