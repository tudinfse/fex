NAME := raytrace
SRC := bbox cr env fbuf geo huprn husetup hutv isect main matrix memory poly raystack shade sph trace tri workpool

VPATH := src:$(BUILD_PATH)

include Makefile.$(ACTION)
include ../config.mk

M4FLAGS += -I $(BUILD_PATH)
INC_DIR += $(BUILD_PATH) src

all: headers $(BUILD_PATH)/$(NAME)
headers: rt.h
