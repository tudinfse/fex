NAME := kmeans
ifneq ($(strip $(NUM_THREADS)),1)
	SRC := kmeans-pthread
	LDFLAGS += -pthread
else
	SRC := kmeans-seq
endif

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

all: $(BUILD_DIR)/$(NAME)
