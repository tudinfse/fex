NAME := ocean
SRC := jacobcalc jacobcalc2 laplacalc linkup main multi slave1 slave2 subblock

VPATH := src/contiguous_partitions

include $(BUILD_TYPE).mk
include ../config.mk

all: headers $(BUILD_DIR)/$(NAME)
headers: decs.h
