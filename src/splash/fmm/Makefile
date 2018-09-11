NAME := fmm
SRC := box construct_grid cost_zones defs fmm interactions memory particle partition_grid

VPATH := src:$(BUILD_DIR)

include Makefile.$(BUILD_TYPE)
include ../config.mk

all: $(BUILD_DIR)/memory.h $(BUILD_DIR)/$(NAME)
$(BUILD_DIR)/memory.h: defs.h memory.h particle.h box.h partition_grid.h cost_zones.h construct_grid.h interactions.h
