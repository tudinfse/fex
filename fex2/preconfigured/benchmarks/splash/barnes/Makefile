NAME := barnes
SRC := code code_io load grav getparam util
HEADER_DEPS := code.h defs.h util.h vectmath.h load.h code_io.h grav.h getparam.h

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

all: headers $(BUILD_DIR)/$(NAME)
headers: $(HEADER_DEPS) stdinc.h

