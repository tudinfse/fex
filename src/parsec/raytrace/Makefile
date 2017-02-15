NAME := raytrace
# SRC is empty - no files are build directly

SUB_DIRS := LRT MiniView RTTL
SRC += $(SUB_DIRS)

VPATH := src

include common.mk

CCOMFLAGS += -pthread -DUSE_PBOS=1

MESA_BUILD_PATH:=$(BUILD_ROOT)/libs/mesa/$(ACTION)
LIB_DIRS += $(MESA_BUILD_PATH)/lib
LIBS += -lglut -lGL -lGLU -lXmu -lXext -lXau -lX11 -ldl

INC_DIR += $(PROJ_ROOT)/src/parsec/raytrace/src \
	       $(PROJ_ROOT)/src/parsec/raytrace/src/RTTL/ $(PROJ_ROOT)/src/parsec/raytrace/src/RTTL/common/ \
	       $(PROJ_ROOT)/src/parsec/raytrace/src/RTTL/BVH/ $(PROJ_ROOT)/src/parsec/raytrace/src/SG \
	       $(PROJ_ROOT)/src/parsec/raytrace/src/LRT/include $(PROJ_ROOT)/src/parsec/raytrace/src/LRT/
INC_DIR += $(MESA_BUILD_PATH)/include

include $(ACTION_MAKEFILE)
include ../parsec_common.mk

.PHONY: buildlibs prebuild

# enforce build order
all:
	@${MAKE} buildlibs
	@${MAKE} prebuild
	@${MAKE} $(BUILD_PATH)/$(NAME)

buildlibs: export BENCH_SUITE=libs
buildlibs:
	$(MAKE) ACTION=$(ACTION) -I $(PROJ_ROOT)/makefiles -C $(PROJ_ROOT)/src/$(BENCH_SUITE)/mesa

prebuild: export INC_DIR:=$(INC_DIR)
prebuild: export CCOMFLAGS:=$(CCOMFLAGS)
prebuild: export CFLAGS:=$(CFLAGS)
prebuild: export CXXFLAGS:=$(CXXFLAGS)
prebuild: export LIB_DIRS:=$(LIB_DIRS)
prebuild: export LIBS:=$(LIBS)
prebuild:
	$(foreach dir,$(SUB_DIRS),$(MAKE) -C src/$(dir) &&) printf ""

