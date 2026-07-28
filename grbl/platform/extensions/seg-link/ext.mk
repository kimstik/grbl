# ext.mk - seg-link. Included by a participating port's Makefile via
# $(foreach e,$(EXT),$(eval include ../extensions/$(e)/ext.mk)).
# Part of Grbl / Intelligence assisted / License: MIT

SEG_LINK_DIR := ../extensions/seg-link

# An extension and a platform supplying the same TU is a hard error, never a
# link-order accident (extensions/README.md).
ifneq ($(filter seg_link.c seg_link_null.c,$(notdir $(PLATFORM_SOURCES) $(GRBL_SOURCES))),)
  $(error seg-link: a seg_link TU is already supplied by the platform)
endif

EXT_SOURCES += $(SEG_LINK_DIR)/seg_link.c
EXT_CFLAGS  += -I$(SEG_LINK_DIR) -I../extensions/common

# The board transport. Until a board supplies a real one, the null sink keeps
# the build honest rather than silently inert; see seg_link_null.c.
SEG_LINK_TRANSPORT ?= null
ifeq ($(SEG_LINK_TRANSPORT),null)
  EXT_SOURCES  += $(SEG_LINK_DIR)/seg_link_null.c
  EXT_POSTLINK += sh $(SEG_LINK_DIR)/live_check.sh $(NM) $(ELF_FILE);
else
  $(error seg-link: SEG_LINK_TRANSPORT=$(SEG_LINK_TRANSPORT) has no implementation yet)
endif
