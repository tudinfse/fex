NAME := raytrace
SRC := bbox cr env fbuf geo huprn husetup hutv isect main matrix memory poly raystack shade sph trace tri workpool

VPATH := src:$(BUILD_DIR)

include Makefile.$(BUILD_TYPE)
include ../config.mk

M4FLAGS += -I $(BUILD_DIR)
INC_DIR += $(BUILD_DIR) src

all: headers $(BUILD_DIR)/$(NAME)
headers: rt.h
