NAME := histogram
ifneq ($(strip $(NUM_THREADS)),1)
	SRC := histogram-pthread
	LDFLAGS += -pthread
else
	SRC := histogram-seq
endif

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

CFLAGS += -I${PROJ_ROOT}/benchmarks/phoenix/include

all: $(BUILD_DIR)/$(NAME)
