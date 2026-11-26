# Fixed24 ordinary motion

Harness `89768c091af853de8f4dce3a2e71f7df6ccb0e9a`, frozen firmware
`500513d26e14e5a16bcdaa6c7976107d6a5f888c`.
CI https://github.com/kimstik/grbl/actions/runs/45854508653 completed successfully.
Pinned simulator `13d4ed32433ad7a37bb757b7e0f7dbb5373396c0`.

The existing host-only frontier observer and PC mapper from59148b2 are unchanged.
The sender workload from9b4a28f selects only its existing programs37..40: G94,
5 mm curves, acceleration2000, feed4000/5000 and sender turnaround2/16 ms.
Both arms start this isolated sequence cold, without the preceding36 programs.
Thus this is a fresh matched comparison, not cycle identity to an old full sweep.
Production RT, stepper, reversal and estimator behavior are unchanged except the
already-frozen fixed24 density flag. No broad matrix, steep programs or holds ran.

## Actual ISR empties

Counts exclude the one final empty at point684 in each program. Every earlier
empty occurs before point684. Counts derive from the ISR empty PC and consumed
segment generations, not delayed dyn stop/cut counters.

| Program | Feed | Sender ms | Fixed16 intermediate empties | Fixed24 intermediate empties | Fixed16 duration ms | Fixed24 duration ms |
| ------- | ---: | --------: | ---------------------------: | ---------------------------: | ------------------: | ------------------: |
| 37      | 4000 |         2 |                            0 |                            0 |                2422 |                2426 |
| 38      | 4000 |        16 |                           11 |                           11 |                2803 |                2806 |
| 39      | 5000 |         2 |                            0 |                            0 |                2429 |                2424 |
| 40      | 5000 |        16 |                           11 |                            9 |                2838 |                2784 |

All26 fixed16 and24 fixed24 empties (including finals) have saved published
endpoint speed0 and saved published block exit0. No nonzero-published-end empty
was observed. These saved planned speeds are not physical instantaneous velocity.

Fixed16 has two program40 empties with `queued_at_empty=1`:
cycle131547952, line4, point115; cycle142841611, line7, point286.
All other fixed16 empties and all fixed24 empties have queued_at_empty0.
Both queued cases still have published endpoint/exit0: queued planner blocks do
not imply a nonzero endpoint in the consumed segment. Sender, estimation and
restart contributions have not been independently separated.

In this bounded sample extra estimator density did not increase intermediate
empty count; program40 had two fewer. This is not a general starvation or physical
surface-quality guarantee. No winner selected from these four programs.

## Integrity and image limits

Each arm's observed and blind runs match exact end cycle/state, UART bytes and
cycle-weighted UART hash. Fixed16 end169305851 cycles, cpu_Done6,918 UART bytes,
hash1115854519,2894 publications/consumptions. Fixed24 end168487364, cpu_Done6,
917 bytes, hash1281633213,2901 publications/consumptions.
Independent raw replay matched every consume/empty to its saved publication,
checked endpoint and block-exit speeds, publication cycle, empty ring and absence
of pending live publications. All four motion XYZ endpoints are exact.

Production ELF files are byte-identical to the previous bounded accuracy run:
fixed16 flash32322/RAM1670; fixed24 flash32316/RAM1670. Physical32768 fits;
boot32256 does not (66/60 bytes over). Normal-size production and dyn links precede
execution. Dyn images are32274/32268 bytes flash,1567 bytes static RAM.
Measured workload stack maxima are358 in both arms. This is the selected dyn
workload watermark, not universal production stack proof or a bench-derived bound.

All source, raw observations and prior candidates retained. No firmware merge,
RT changes, default selection, cleanup or physical-velocity inference.
