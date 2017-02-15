NAME := radiosity
SRC := display elemman modelman patchman rad_main rad_tools room_model smallobj taskman visible glib glibps
HEADER_DEPS := patch.h model.h parallel.h task.h structs.h

VPATH := src:$(BUILD_PATH)

include Makefile.$(ACTION)
include ../config.mk

M4FLAGS += -I $(BUILD_PATH)
INC_DIR += $(BUILD_PATH) src

all: headers $(BUILD_PATH)/$(NAME)
headers: $(HEADER_DEPS) radiosity.h
