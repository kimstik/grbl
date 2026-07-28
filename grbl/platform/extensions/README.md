# `grbl/platform/extensions/` — the second injection axis

A **platform** answers *which silicon*: one `-include <board>/prelude.h`, one
entry point per board (CONTRACTS.md §0).

An **extension** answers *where is the edge*. It is not tied to any silicon; all
it does is change the **geometry of the periphery** of the frozen core. Its
prelude is injected **before** the board prelude, so first-definition-wins under
`#ifndef` discipline:

```make
CFLAGS += $(foreach e,$(EXT),-include ../extensions/$(e)/prelude.h)
CFLAGS += -include $(BOARD_DIR)/prelude.h      # existing line, stays last
```

Design, staging and the SEGX/1 contract: `grbl/platform/docs/SEGMENT-RUNTIME-PLAN.md`.

## Layout

```
extensions/<kebab-name>/
    prelude.h    macro injection; defines GRBL_EXT_<NAME>; NEVER GRBL_PRELUDE
    ext.mk       source add/exclude; hard $(error) on a TU both sides supply
    ext.md       per-extension contract doc
    *.c *.h      implementation
extensions/common/
    segframe.h   SEGX/1 canonical frames + little-endian wire codec
    seg_tap.h    GRBL_STEPPER_TU_EXPORTS bodies (readers / loaders)
```

Rules, each load-bearing:

- **No `platform.h` at an extension root.** `ci/pinmap_overlap_check.py`
  discovers ports as `grbl/platform/*/` directories containing a root
  `platform.h`; an extension with one would be adopted as a phantom port.
- A prelude defines `GRBL_EXT_<NAME>` and **never** `GRBL_PRELUDE` — hal.h:34's
  lost-prelude `#error` is the proven backstop against a dropped board prelude
  and must not be masked. It also cannot rely on the board prelude having run:
  it is textually first, so if it needs the config tuple it includes `grbl.h`
  itself (see `seg-trace/prelude.h`).
- `BUILD_DIR` and `BINARY_NAME` **must** key on the EXT set. This tree was bitten
  three times by un-keyed knobs relinking stale objects under the wrong name
  (BUILD twice, BOARD once). Unit naming is `<port>+<ext>`; `+` is unambiguous,
  no port or board name contains it.
- With `EXT` empty the `$(foreach)` contributes zero flags and zero sources, so
  every bare unit stays byte-identical — proven, not asserted, by
  `tools/build_artifacts.py check`.
- CI is a **sum**, never a product: every platform bare, plus each extension on
  one representative platform.

## Extensions here

| name | what it does | status |
|---|---|---|
| `seg-trace` | tees canonical SEGX/1 frames at the publish strobe into a RAM ring for offline replay | builds on ch32v006; no CI row yet |

`grbl/platform/sg2002/shm.h` is an extension in disguise — a silicon-independent
cross-core shared-memory channel welded into one port. Extracting it is separate
work; the constitutive-vs-optional distinction (a channel a port cannot function
without is library extraction, not an EXT knob) is the reason it has not moved.
