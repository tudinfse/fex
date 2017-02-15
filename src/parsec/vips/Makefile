NAME := vips
SRC := vips dummy im_clamp bool_dispatch boolean

SUB_DIRS := iofuncs arithmetic resample colour conversion deprecated convolution format freq_filt histograms_lut \
            inplace mask morphology mosaicing other relational video
SRC += $(SUB_DIRS)

VPATH := src

INC_DIR += $(PROJ_ROOT)/src/parsec/vips/src/include
CCOMFLAGS += -DG_DISABLE_CAST_CHECKS -DHAVE_CONFIG_H -D restrict=__restrict__  -pthread
CFLAGS += -Wno-int-conversion -Wno-incompatible-pointer-types -Wno-implicit-function-declaration -Wno-int-to-pointer-cast \
		  -funroll-loops -fprefetch-loop-arrays
CXXFLAGS += -fexceptions

LIB_DIRS += $(PROJ_ROOT)/build/libs/zlib/$(ACTION)/lib \
			$(PROJ_ROOT)/build/libs/glib/$(ACTION)/lib \
			$(PROJ_ROOT)/build/libs/libxml2/$(ACTION)/lib
LIBS += -lgmodule-2.0 -lxml2 -lgobject-2.0 -lgthread-2.0 -lglib-2.0 -lz -ldl

include Makefile.$(ACTION)
include ../parsec_common.mk

.PHONY: buildlibs prebuild

# enforce build order
all:
	@${MAKE} buildlibs
	@${MAKE} prebuild
	@${MAKE} $(BUILD_PATH)/$(NAME)

buildlibs: export BENCH_SUITE=libs
buildlibs:
	$(MAKE) ACTION=$(ACTION) -I $(PROJ_ROOT)/makefiles -C $(PROJ_ROOT)/src/$(BENCH_SUITE)/zlib
	$(MAKE) ACTION=$(ACTION) -I $(PROJ_ROOT)/makefiles -C $(PROJ_ROOT)/src/$(BENCH_SUITE)/glib
	$(MAKE) ACTION=$(ACTION) -I $(PROJ_ROOT)/makefiles -C $(PROJ_ROOT)/src/$(BENCH_SUITE)/libxml2

prebuild: export INC_DIR:=$(INC_DIR)
prebuild: export CFLAGS:=$(CFLAGS) $(CCOMFLAGS)
prebuild: export CXXFLAGS:=$(CXXFLAGS) $(CCOMFLAGS)
prebuild: export LIB_DIRS:=$(LIB_DIRS)
prebuild: export LIBS:=$(LIBS)
prebuild:
	$(foreach dir,$(SUB_DIRS),$(MAKE) -C src/$(dir) &&) printf ""

