NAME := matrix_multiply
ifneq ($(strip $(NUM_THREADS)),1)
	SRC := matrix_multiply-pthread
	LDFLAGS += -pthread
else
	SRC := matrix_multiply-seq
endif

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

all: $(BUILD_DIR)/$(NAME)
