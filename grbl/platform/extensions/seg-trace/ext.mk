# ext.mk - seg-trace. Included by a participating port's Makefile via
# $(foreach e,$(EXT),$(eval include ../extensions/$(e)/ext.mk)).
# Part of Grbl / Intelligence assisted / License: MIT

SEG_TRACE_DIR := ../extensions/seg-trace

# An extension and a platform supplying the same TU is a hard error, never a
# link-order accident (extensions/README.md).
ifneq ($(filter seg_trace.c,$(notdir $(PLATFORM_SOURCES) $(GRBL_SOURCES))),)
  $(error seg-trace: seg_trace.c is already supplied by the platform)
endif

EXT_SOURCES  += $(SEG_TRACE_DIR)/seg_trace.c
EXT_CFLAGS   += -I$(SEG_TRACE_DIR) -I../extensions/common

# Capacity knob, in RECORDS. Validated here rather than trusted, because a zero
# or a 1 makes the ring degenerate (next == tail on the first push) and would
# silently record nothing but overruns.
SEG_TRACE_RECORDS ?= 32
ifeq ($(shell test $(SEG_TRACE_RECORDS) -ge 4 && echo ok),)
  $(error seg-trace: SEG_TRACE_RECORDS must be >= 4 (got $(SEG_TRACE_RECORDS)))
endif
EXT_CFLAGS += -DSEG_TRACE_RECORDS=$(SEG_TRACE_RECORDS)

# POST-LINK GUARD. Appended to $(EXT_POSTLINK), which the port Makefile runs at
# the end of the link recipe and which is EMPTY when EXT is empty. See
# live_check.sh's header for what it caught the first time it ran.
EXT_POSTLINK += sh $(SEG_TRACE_DIR)/live_check.sh $(NM) $(ELF_FILE) $(SEG_TRACE_RECORDS);
