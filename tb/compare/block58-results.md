# Bounded planner exit-choice observation

Harness `2ee188e241e5200cf06d88b9e7a412c1bd78b48c`, workflow run45881535916 succeeded. Frozen combined firmware4eb683aade6a1250620e322ce36bd93f1416cb5c versus size candidate33da70b6d5667e9581c240d6dba6ef5b435c94a9; cold p37-40 G94, unchanged settings, realtime ordering, simulator and build options. No firmware changes. Additional host-only events are restricted to p38 targets23-28 and57-60.

## Integrity and attribution

Normal/full32768 and candidate32256 gates and expected production SHA256 checks run before execution. The downloaded production/dyn ELFs, blind trace, observed UART and blind UART match the preceding size-frontier45879111923 artifacts byte for byte for each arm. After removing only `probe_` rows, all118281 control /128382 candidate original trace lines match exactly. The existing checker verifies observed/blind cycle, state, UART and publication/consumption parity. Thus the new probes do not change emulated behavior.

Planner identity is `(program, slot, monotonic slot generation)`, saved on successful head advancement together with target ordinal. PLAN_OK is verified at the paired plan_buffer_line return. Index alone is not identity. Every additional publication record is matched to the original segment slot/generation and independently reconstructed step coverage:12 selected publications for control,13 for candidate all match target attribution. Reconstruction still covers684 blocks/15000 base step events in p38. Block24 is slot3 generation45, block58 slot5 generation47, block59 slot6 generation47 in both arms.

LTO removes the standalone `plan_get_exec_block_exit_speed_sqr` symbol. The mapper instead asserts the disassembled normal-motion successor selection, four successor entry-speed loads, register moves and following sqrtf call. It records the inlined selection entry and float ABI r22-r25 at the sqrt argument/result, not an invented standalone call/return. Both saved ELF mappings were checked before CI; workflow repeats mapping on its ELFs. Source layout assertions verify planner block50 bytes, entry/max-entry offsets18/22, prep recalculate flag1, segment block index4, and previous observer layouts. Per-run `pc.probe-map.json` retains the exact instruction window. No timer-register probes were added.

## First divergence: target24

| Event / value | Combined | Size candidate |
|---|---:|---:|
| Successful insertion return cycle |41442103|41375373|
| Entry speed squared then |1741553|1741553|
| Preparation acquisition cycle |41739519|41701998|
| Head / tail / planned at acquisition |6 /3 /3|7 /3 /3|
| Target24 entry speed squared at acquisition |5336470.5|5336470.5|
| Inlined exit selection cycle |41743072|41705123|
| Returned exit speed squared |3594917.5|5441717.5|
| sqrt result, mm/min |1896.02673|2332.74902|
| Publication cycle |41751518|41717221|

Candidate additionally records st_update_plan_block_parameters at41699374 for this generation, before acquisition. The differing published speed is directly linked to differing successor entry-speed values selected by the same source path. This establishes the local dynamic mechanism; it does not attribute the later aggregate slowdown to this first descriptor.

## Target58: zero exit committed before successor insertion

| Event | Combined cycle | Size candidate cycle |
|---|---:|---:|
| Target58 insertion head advance |44258228|43772563|
| Target58 successful PLAN_OK return |44258428|43772763|
| Target59 insertion head advance |44282813|44207456|
| Target58 preparation acquisition |44652035|43773276|
| Inlined exit selection entry |44653986|43775166|
| Exit-squared value available |44654014|43775185|
| sqrt result available |44654480|43775231|
| Target58 first descriptor publication |44659553|44186017|
| Target58 second descriptor publication |44664250|44190411|

Candidate has head6/tail5/planned5 when selecting the exit: successor index6 equals head6, so no successor is available. Captured exit squared and sqrt result are both exactly0. Both target58 descriptors publish before target59 insertion (by21439 and17045 cycles respectively). Their saved exit stays0; recalculate_flag is0 at acquisition and both publications. There is no st_update_plan_block_parameters event for this target generation and no second exit selection before those publications. The first descriptor current speed is1003.45966 mm/min, the second ends at0.

Control inserts target59 before target58 acquisition. Its exit-squared value is3580200 and sqrt result1892.1416 mm/min, retained at both publications. Its head4/tail5 indicates15 queued blocks. Update events for target58 are recorded at44283216 and44308742, before acquisition. Target59 enters with speed squared3256200.25 after insertion/recalculation and later reaches3580200; candidate target59's successful insertion return has entry squared0 because target58 has already been removed from the planner tail.

This confirms the bounded hypothesis: candidate target58 is prepared and published with a zero exit while no successor exists, without revision before publication. Control prepares the same geometric block with successor lookahead. Independent coverage remains32 base events; nominal descriptor time181024 versus255992 cycles, difference74968 cycles=4.6855 ms. The old p38 aggregate nominal increase150.191125 ms is NOT fully explained or proved causal by this one block. No mitigation, policy change, autostart change or reordering was tested.

## Reproduction and scope

Raw artifacts: `.tmp/g5-research/block58-45881535916/{combined,candidate}`. Independent local verifier `.tmp/g5-research/verify-block58.py` writes `verified-block58.json`; it reuses the saved independent `size-first-divergence.json` coverage reconstruction. Run `python -I -B .tmp/g5-research/verify-block58.py` from the project workspace. Downloaded ELF files are inspected as data only, never executed locally.

Event fields for probe_insert/insert_return/acquire/update/exit_enter/publish: cycle,program,planner_slot,generation,target_ordinal,head,tail,planned,pl_block_pointer,recalculate_flag,entry_speed_squared,max_entry_speed_squared,current_speed,exit_speed. probe_exit_value/sqrt replace the final fields with captured ABI float,head,tail. probe_segment maps original segment slot/generation to planner slot/generation/target and stored stepper block indexes. Insertion snapshots precede planner_recalculate; paired successful-return snapshots follow it. st_update is entry-only, not a claim that its mutation has already occurred.
