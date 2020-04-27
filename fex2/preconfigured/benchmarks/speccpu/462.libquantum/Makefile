NAME := 462.libquantum
SRC := shor classic complex decoherence expn gates matrix measure oaddn objcode omuln qec qft qureg version specrand
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -DSPEC_CPU_LINUX -Wno-format
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
