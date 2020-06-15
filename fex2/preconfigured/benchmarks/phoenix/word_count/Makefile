NAME := word_count
ifneq ($(strip $(NUM_THREADS)),1)
	SRC := word_count-pthread sort-pthread
	LDFLAGS += -pthread
else
	SRC := word_count-seq
endif

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

all: $(BUILD_DIR)/$(NAME)
