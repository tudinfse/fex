NAME := 445.gobmk
SRC := main sgf_utils sgftree sgfnode aftermath board cache combination dragon filllib fuseki genmove hash \
       engine_influence interface matchpat move_reasons movelist optics owl printutils readconnect reading score \
       semeai sgfdecide sgffile shapes showbord utils value_moves worm globals persistent handicap surround gtp \
       play_ascii play_gtp play_solo play_test connections dfa helpers transform owl_attackpat conn patterns apatterns \
       dpatterns owl_vital_apat eyes influence barriers endgame aa_attackpat owl_defendpat fusekipat fuseki9 fuseki13 \
       fuseki19 josekidb handipat getopt getopt1 gg_utils random
VPATH := src:src/interface:src/sgf:src/engine:src/patterns:src/utils

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -Isrc/include
CFLAGS += -DHAVE_CONFIG_H -Wno-format-security
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
