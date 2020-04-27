NAME := 482.sphinx3
SRC := spec_main_live_pretend parse_args_file live agc approx_cont_mgau ascr beam bio case ckd_alloc \
	cmd_ln cmn cmn_prior cont_mgau dict dict2pid err feat fillpen glist gs hash heap hmm io kb \
	kbcore lextree lm lmclass logs3 mdef new_fe new_fe_sp profile specrand str2words subvq tmat \
	unlimit utt vector vithist wid
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -DHAVE_CONFIG_H -Wno-format -Wno-unused-value
CFLAGS += -Isrc/libutil -Isrc
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
