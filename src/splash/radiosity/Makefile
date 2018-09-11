NAME := radiosity
SRC := display elemman modelman patchman rad_main rad_tools room_model smallobj taskman visible glib glibps
HEADER_DEPS := patch.h model.h parallel.h task.h structs.h

VPATH := src:$(BUILD_DIR)

include Makefile.$(BUILD_TYPE)
include ../config.mk

M4FLAGS += -I $(BUILD_DIR)
INC_DIR += $(BUILD_DIR) src

# enforce build order
all:
	@${MAKE} radiosity.h
	@${MAKE} $(BUILD_DIR)/$(NAME)

radiosity.h: $(HEADER_DEPS)
