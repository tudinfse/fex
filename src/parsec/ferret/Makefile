NAME := ferret
SRC := ferret-serial arena assign bench bitmap cass cass_dist cass_reg cuckoo_hash dataset dist emd env error \
       hash hash_table heap import map matrix raw stat table timer topk tp  util edge extract image srm \
       local LSH LSH_query_batch LSH_query perturb recall

VPATH := src

INC_DIR += $(PROJ_ROOT)/src/parsec/ferret/src/include
CCOMFLAGS += -Wno-int-conversion -Wno-incompatible-pointer-types -Wno-implicit-function-declaration -Wno-int-to-pointer-cast

LIB_DIRS += $(PROJ_ROOT)/build/libs/gsl/$(ACTION)/lib \
			$(PROJ_ROOT)/build/libs/libjpeg/$(ACTION)/lib
LIBS += -lrt -lm -lgsl -lgslcblas -ljpeg

ifneq ($(strip $(NUM_THREADS)),1)
    SRC := $(filter-out ferret-serial,$(SRC))
    SRC += ferret-pthreads tpool queue
endif

include Makefile.$(ACTION)
include ../parsec_common.mk

.PHONY: buildlibs

all:
	@${MAKE} buildlibs
	@${MAKE} $(BUILD_PATH)/$(NAME)

buildlibs: export BENCH_SUITE=libs

buildlibs:
	$(MAKE) ACTION=$(ACTION) -I $(PROJ_ROOT)/makefiles -C $(PROJ_ROOT)/src/$(BENCH_SUITE)/gsl
	$(MAKE) ACTION=$(ACTION) -I $(PROJ_ROOT)/makefiles -C $(PROJ_ROOT)/src/$(BENCH_SUITE)/libjpeg

