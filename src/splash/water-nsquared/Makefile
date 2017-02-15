NAME := water-nsquared
SRC := bndry cnstnt cshift initia interf intraf kineti mdmain poteng predcor syscons water

VPATH := src:$(BUILD_PATH)

include Makefile.$(ACTION)
include ../config.mk

M4FLAGS += -I $(BUILD_PATH)
INC_DIR += $(BUILD_PATH) src

all: headers $(BUILD_PATH)/$(NAME)
all:
	-cp src/random.in ${PROJ_ROOT}
	@${MAKE} headers
	@${MAKE} $(BUILD_PATH)/$(NAME)

headers: parameters.h mdvar.h water.h wwpot.h cnst.h mddata.h fileio.h frcnst.h randno.h global.h split.h
