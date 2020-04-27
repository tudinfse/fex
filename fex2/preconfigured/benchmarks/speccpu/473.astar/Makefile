NAME := 473.astar
SRC := CreateWay_ Places_ RegBounds_ RegMng_ Way2_ WayInit_ Random Region_ RegWay_ Way_ Library
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CXXFLAGS += -DSPEC_CPU_LITTLE_ENDIAN
ifeq ($(CXX),g++)
	CXXFLAGS += -Wno-literal-suffix
endif
LDFLAGS += -lstdc++ -lm

all: $(BUILD_DIR)/$(NAME)
