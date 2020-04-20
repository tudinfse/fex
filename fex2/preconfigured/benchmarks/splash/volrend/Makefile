NAME := volrend
SRC := adaptive file main map normal octree opacity option raytrace render view
HEADER_DEPS := anl.h user_options.h const.h my_types.h global.h macros.h address.h incl.h

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

CFLAGS += -Isrc -Isrc/libtiff
LDFLAGS += -L$(BUILD_DIR) -ltiff


.PHONY: buildlibs prebuild

# enforce build order
all:
	@${MAKE} prebuild
	@${MAKE} headers
	@${MAKE} $(BUILD_DIR)/$(NAME)

prebuild: export CFLAGS:=$(CFLAGS)
prebuild: export CC:=$(CC)
prebuild: export CXXFLAGS:=$(CXXFLAGS)
prebuild:
	$(MAKE) -C src/libtiff clean all
	mv src/libtiff/libtiff.a $(BUILD_DIR)

headers: $(HEADER_DEPS)
