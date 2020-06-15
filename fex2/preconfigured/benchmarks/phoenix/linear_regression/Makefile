NAME := linear_regression
ifneq ($(strip $(NUM_THREADS)),1)
	SRC := linear_regression-pthread
	LDFLAGS += -pthread
else
	SRC := linear_regression-seq
endif

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk
CFLAGS += -fno-unroll-loops

all: $(BUILD_DIR)/$(NAME)
