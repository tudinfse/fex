NAME := barnes
SRC := code code_io load grav getparam util
HEADER_DEPS := code.h defs.h util.h vectmath.h load.h code_io.h grav.h getparam.h

VPATH := src:$(BUILD_DIR)

include Makefile.$(BUILD_TYPE)
include ../config.mk

M4FLAGS += -I $(BUILD_DIR)
INC_DIR += $(BUILD_DIR) src

all: headers $(BUILD_DIR)/$(NAME)
headers: $(HEADER_DEPS) stdinc.h
