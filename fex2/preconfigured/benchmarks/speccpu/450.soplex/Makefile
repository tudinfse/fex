NAME := 450.soplex
SRC := example changesoplex  didxset  dsvector  dvector  enter  factor  forest  idxset  leave  lpcolset  lprow \
	   lprowset  message  mpsinput  nameset  slufactor  solve   soplex  spxaggregatesm  spxbasis  spxbounds  \
	   spxchangebasis   spxdefaultpr  spxdefaultrt  spxdefines  spxdesc  spxdevexpr   spxequilisc  spxfastrt  \
	   spxgeneralsm  spxharrisrt   spxhybridpr  spxid  spxio  spxlp  spxlpfread  spxmpsread   spxmpswrite  spxparmultpr \
	    spxquality  spxredundantsm   spxrem1sm  spxscaler  spxshift  spxsolve  spxsolver   spxstarter  spxsteeppr  \
	    spxsumst  spxvecs  spxvectorst   spxweightpr  spxweightst  ssvector  svector  svset  timer   unitvector  \
	    update  updatevector  vector  vsolve
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CXXFLAGS  += -Wno-dangling-else -Wno-delete-non-virtual-dtor -Isrc -std=gnu++98
LDFLAGS += -lstdc++ -lm

all: $(BUILD_DIR)/$(NAME)
