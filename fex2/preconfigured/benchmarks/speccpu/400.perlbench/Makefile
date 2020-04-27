NAME := 400.perlbench
SRC := perlmain av deb doio doop dump globals gv hv locale mg numeric op pad perl perlapi perlio perly pp pp_ctl \
	   pp_hot pp_pack pp_sort pp_sys regcomp regexec run scope sv taint toke universal utf8 util xsutils Base64 Cwd \
	   Dumper HiRes IO Peek attrs poll stdio DynaLoader MD5 Storable Parser specrand Hostname Opcode
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -DPERL_CORE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -std=gnu89 -DSPEC_CPU_LINUX_X64
CFLAGS += -Isrc
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
