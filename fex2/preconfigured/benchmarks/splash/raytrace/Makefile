NAME := raytrace
SRC := bbox cr env fbuf geo huprn husetup hutv isect main matrix memory poly raystack shade sph trace tri workpool

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

all: headers $(BUILD_DIR)/$(NAME)
headers: rt.h
