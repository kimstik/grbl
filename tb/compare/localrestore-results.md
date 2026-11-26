# Redundant local Z restores

Frozen control `2347f8d359c7ec64cb5722763fecbe7ab68a9a66`; candidate `33da70b6d5667e9581c240d6dba6ef5b435c94a9`. Exactly two firmware preprocessor conditions change: the no-Z initialization restore and the estimate-completion restore remain enabled for cached absolute lengths but are excluded for LOCAL. No arithmetic, coefficient order, scratch layout, realtime, settings, fallback or emission changes.

## Read-only lifetime proof

Line references refer to frozen control:

- `motion_control.c:917` copies the complete initial XYZ position into point before cache initialization at 941. LOCAL cache initialization excludes all point writes at 864-878; the remaining coefficient stores target the separate union (`gcode.h:212-216`), not point.
- `mc_spline_next` aliases point at 556 but declares independent stack arrays q/r at 557. The evaluator's extra control-point writes at 463 go to q/r, not scratch point: calls use q/r at 595 and in the piece loop. Piece endpoint snapping writes their XY only.
- Before the no-Z restore at 651, state initialization touches step/rest/u/chord/poly, not point-Z. No-Z G94 can therefore retain the driver's original Z unchanged.
- During the fixed initial estimate, intermediate calls return true until completion at 745. There is no earlier emitted point whose Z would need resetting. Local fallback/re-estimation is absent: the coordinate-risk fallback at 748-773 is excluded. Point remains at initial Z through the second restore at 775, including actual G93 with no Z.
- Actual-G93 conversion at 835-847 touches the feed and spline remaining-length/Z state. Local previous-XY reset at 849-850 and the copies at 639/742 are in spline_z, not point. The point copy at 615 writes only XY and is on emission, after estimation.
- The driver performs no `mc_line` during true helper returns; realtime gets no scratch point. Abort exits without emitting it. Segments=1 goes directly to the final target Z assignment at 1034. Later emitted points use their existing Z emission logic.
- Normal hold/resume does not rewrite the input parser position. The realtime `gc_sync_position` at `protocol.c:389` is restricted to jog cancellation; G5 is not a jog command (`gcode.c:983` modal-group restriction), and normal G-code is rejected while JOG (`protocol.c:99`). Thus a supported realtime path cannot silently change the original position between the driver's copy and these redundant restores.

Both restores write the same initial Z already present when LOCAL is enabled. Other modes keep the exact old assignments.

## Static measurement

| Resource | Control G94 | Candidate G94 | Control G93 | Candidate G93 |
|---|---:|---:|---:|---:|
| Production flash, bytes | 32134 | 32074 | 32264 | 32208 |
| Static RAM, bytes | 1670 | 1670 | 1670 | 1670 |
| Bootloader application margin, bytes | +122 | +182 | -8 | +48 |
| Next helper symbol, bytes | 1660 | 1600 | 1790 | 1734 |
| Next helper local frame, bytes | 66 | 62 | 68 | 64 |
| Cache initialization local frame, bytes | 18 | 18 | 18 | 18 |

Serial IDLE static builds show savings of 60/56 bytes. Both modes now fit the strict 32256-byte application region for these options/toolchain, with 182/48 bytes margin. This is size evidence, not production stack safety or acceptance of the motion/accuracy tradeoff.

## Bounded regression

CI https://github.com/kimstik/grbl/actions/runs/45878477195 runs only the existing six-case actual-G94/G93 comparison against the frozen control, plus LOCAL-off exact ELF identity. The broad workflow is excluded. Ordinary motion is not launched in this stage.

CI succeeded. Independent parsing of raw artifacts confirmed all 1699 XYZ/feed/condition records per mode and every non-cycle summary/trace word across all six cases. LOCAL-off production ELFs match exactly in both modes. Enabled control production ELF matches the preceding initial-zero artifact; candidate CI production ELF matches the local static build byte for byte.

| Case | G94 control first, ms | G94 candidate first, ms | G93 control first, ms | G93 candidate first, ms |
|---|---:|---:|---:|---:|
| Short S | 23.3883125 | 23.3762500 | 22.3166875 | 22.3046875 |
| Long S | 26.7880625 | 26.7745000 | 25.5174375 | 25.5039375 |
| Translated line | 9.6618125 | 9.6562500 | 12.5137500 | 12.5122500 |
| Origin line | 9.5738125 | 9.5682500 | 12.4276875 | 12.4261875 |
| No Z | 1.2700625 | 1.2685625 | 22.0841875 | 22.0721875 |
| Near cusp | 26.1211875 | 26.1076250 | 25.0786875 | 25.0661875 |

First-target savings range from 24 to 217 cycles (.0015-.0135625 ms). All twelve maximum inter-target gaps are unchanged; total generator cycles decrease in all twelve captured cases. These are bench measurements, not evidence that ordinary-motion stops are removed.

Because the raw XYZ/feed/condition records are identical, the earlier bounded geometry and nominal G93 timing results are preserved for these inputs, including actual-G93 no-Z. This does not provide a general accuracy or production ISR stack certificate. The size result is strictly 32074/32208 bytes with 182/48-byte application-region margins, not rounded or inferred from an oversized link.

Artifacts `local-g94` and `local-g93` retain both arms, OFF images, raw bench/dump output and production sizes/disassembly/options/source records. No ordinary motion, further variant, default change or merge was performed.
