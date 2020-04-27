NAME := 470.lbm
SRC := lbm main
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -Wno-format
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
