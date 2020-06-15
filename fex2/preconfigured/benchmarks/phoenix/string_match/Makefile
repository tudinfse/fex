NAME := string_match
ifneq ($(strip $(NUM_THREADS)),1)
	SRC := string_match-pthread
	LDFLAGS += -pthread
else
	SRC := string_match-seq
endif

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

all: $(BUILD_DIR)/$(NAME)
