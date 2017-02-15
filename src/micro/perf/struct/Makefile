NAME := struct
SRC := struct

include Makefile.$(ACTION)

CCOMFLAGS := $(filter-out -O3,$(CCOMFLAGS))
CCOMFLAGS += -O2

all: $(BUILD_PATH)/$(NAME)
