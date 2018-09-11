NAME := volrend
SRC := adaptive file main map normal octree opacity option raytrace render view
HEADER_DEPS := anl.h user_options.h const.h my_types.h global.h macros.h address.h incl.h

VPATH := src:$(BUILD_DIR)

include Makefile.$(BUILD_TYPE)
include ../config.mk

M4FLAGS += -I $(BUILD_DIR)
INC_DIR += $(BUILD_DIR) src src/libtiff
LIB_DIRS += $(BUILD_DIR)
LIBS += -ltiff


.PHONY: buildlibs prebuild

# enforce build order
all:
	@${MAKE} prebuild
	@${MAKE} headers
	@${MAKE} $(BUILD_DIR)/$(NAME)

prebuild: export INC_DIR:=$(INC_DIR)
prebuild: export CFLAGS:=$(CFLAGS)
prebuild: export CXXFLAGS:=$(CXXFLAGS)
prebuild: export LIB_DIRS:=$(LIB_DIRS)
prebuild: export LIBS:=$(LIBS)
prebuild: export BUILD_DIR:=$(BUILD_DIR)
prebuild:
	$(MAKE) -C src/libtiff

headers: $(HEADER_DEPS)
