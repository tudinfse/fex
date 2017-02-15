NAME := fmm
SRC := box construct_grid cost_zones defs fmm interactions memory particle partition_grid

VPATH := src:$(BUILD_PATH)

include Makefile.$(ACTION)
include ../config.mk

all: $(BUILD_PATH)/memory.h $(BUILD_PATH)/$(NAME)
$(BUILD_PATH)/memory.h: defs.h memory.h particle.h box.h partition_grid.h cost_zones.h construct_grid.h interactions.h
