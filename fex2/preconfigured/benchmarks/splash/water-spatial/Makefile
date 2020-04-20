NAME := water-spatial
SRC := bndry cnstnt cshift initia interf intraf kineti mdmain poteng predcor syscons water

VPATH := src

include $(BUILD_TYPE).mk
include ../config.mk

M4FLAGS += -I $(BUILD_DIR)
INC_DIR += $(BUILD_DIR) src

all: headers $(BUILD_DIR)/$(NAME)
all:
	-cp src/random.in ${PROJ_ROOT}
	@${MAKE} headers
	@${MAKE} $(BUILD_DIR)/$(NAME)

headers: parameters.h mdvar.h water.h wwpot.h cnst.h mddata.h fileio.h frcnst.h randno.h global.h split.h
