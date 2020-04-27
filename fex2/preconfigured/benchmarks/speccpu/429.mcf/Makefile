NAME := 429.mcf
SRC := mcf mcfutil readmin implicit pstart output treeup pbla pflowup psimplex pbeampp
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -DWANT_STDC_PROTO

all: $(BUILD_DIR)/$(NAME)

