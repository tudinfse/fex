NAME := 456.hmmer
SRC := hmmcalibrate alphabet core_algorithms debug display emit emulation fast_algorithms histogram hmmio hmmsearch \
 	   mathsupport masks misc modelmakers plan7 plan9 postprob prior tophits trace ucbqsort a2m aligneval alignio \
 	   clustal cluster dayhoff eps file getopt gki gsi hsregex iupac msa msf phylip revcomp rk selex seqencode shuffle \
 	   sqerror sqio squidcore sre_ctype sre_math sre_random sre_string ssi stack stockholm translate types \
 	   vectorops weight
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -Wno-implicit-function-declaration
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
