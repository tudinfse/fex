NAME := dedup
SRC := binheap decoder dedup encoder hashtable queue rabin tree util

VPATH := src

include common.mk

CFLAGS += -DMD32_REG_T=int -D_REENTRANT -DL_ENDIAN -DUSE_MMAP -D_XOPEN_SOURCE=600 -U_FORTIFY_SOURCE
CXXFLAGS += -DMD32_REG_T=int -D_REENTRANT -DL_ENDIAN -DUSE_MMAP -D_XOPEN_SOURCE=600 -U_FORTIFY_SOURCE

INC_DIR += $(COMP_BENCH)/src/parsec/dedup/src/include
LIB_DIRS += $(BUILD_ROOT)/parsec_libs/zlib/$(ACTION)/lib \
            $(BUILD_ROOT)/parsec_libs/ssl/$(ACTION)/lib
LIBS += -lssl -lz -lcrypto

include $(ACTION_MAKEFILE)
include ../parsec_common.mk

.PHONY: buildlibs

all:
	@${MAKE} buildlibs
	@${MAKE} $(BUILD_PATH)/$(NAME)

buildlibs: export BENCH_SUITE=parsec_libs

buildlibs:
	$(MAKE) ACTION=$(ACTION) -I $(COMP_BENCH)/makefiles -C $(COMP_BENCH)/src/$(BENCH_SUITE)/zlib
	$(MAKE) ACTION=$(ACTION) -I $(COMP_BENCH)/makefiles -C $(COMP_BENCH)/src/$(BENCH_SUITE)/ssl

