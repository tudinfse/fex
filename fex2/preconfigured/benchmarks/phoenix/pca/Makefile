NAME := pca
ifneq ($(strip $(NUM_THREADS)),1)
	SRC := pca-pthread
	LDFLAGS += -pthread
else
	SRC := pca-seq
endif

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

all: $(BUILD_DIR)/$(NAME)
