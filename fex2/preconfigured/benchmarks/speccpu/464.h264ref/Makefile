NAME := 464.h264ref
SRC := lencod annexb biariencode block cabac configfile context_ini decoder explicit_gop fast_me filehandle fmo header \
	   image intrarefresh leaky_bucket loopFilter macroblock mb_access mbuffer memalloc mv-search nal nalu nalucommon \
	   output parset parsetcommon q_matrix q_offsets ratectl rdopt rdopt_coding_state rdpicdecision refbuf rtp sei \
	   slice transform8x8 vlc weighted_prediction specrand
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -Wno-pointer-sign -Wno-format -Wno-parentheses-equality
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
