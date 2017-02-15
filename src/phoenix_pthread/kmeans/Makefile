NAME := kmeans
SRC := kmeans-seq

ifneq ($(strip $(NUM_THREADS)),1)
	SRC := kmeans-pthread
	LIBS += -pthread
endif

INC_DIR := ${PROJ_ROOT}/src/phoenix_pthread/include
VPATH := src

include Makefile.$(ACTION)

all: $(BUILD_PATH)/$(NAME)
