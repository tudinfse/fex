NAME := ocean
SRC := jacobcalc jacobcalc2 laplacalc linkup main multi slave1 slave2 subblock

VPATH := src:$(BUILD_PATH)

include Makefile.$(ACTION)
include ../config.mk

all: headers $(BUILD_PATH)/$(NAME)
headers: decs.h
