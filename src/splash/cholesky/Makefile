NAME := cholesky
SRC := amal assign bfac bksolve block2 fo malloc mf numLL parts seg solve tree util

VPATH := src:$(BUILD_PATH)

include common.mk
include $(ACTION_MAKEFILE)
include ../config.mk

M4FLAGS += -I $(BUILD_PATH)
INC_DIR += $(BUILD_PATH) src

all: headers $(BUILD_PATH)/$(NAME)
headers: matrix.h
