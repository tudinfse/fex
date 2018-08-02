# sqlite3 version 3.8.9, with YCSB workloads

NAME := sqlite3
SRC := sqlite3 bench

COMFLAGS += -DNDEBUG -DSQLITE_THREADSAFE=1 -DSQLITE_OMIT_LOAD_EXTENSION
LIBS += -pthread -ldl

VPATH := src

include Makefile.$(BUILD_TYPE)

all: $(BUILD_DIR)/$(NAME)
