NAME := cholesky
SRC := amal assign bfac bksolve block2 fo malloc mf numLL parts seg solve tree util

VPATH := src:$(BUILD_DIR)

include Makefile.$(BUILD_TYPE)
include ../config.mk

M4FLAGS += -I $(BUILD_DIR)
INC_DIR += $(BUILD_DIR) src

all: headers $(BUILD_DIR)/$(NAME)
headers: matrix.h
