# The following variables have to be specified at this point:
# PROJ_ROOT, NAME, ACTION

ifndef ACTION
$(error ACTION is not specified)
endif

BUILD_ROOT = $(PROJ_ROOT)/build
BUILD_PATH = $(BUILD_ROOT)/$(BENCH_SUITE)/$(NAME)/$(ACTION)
ACTION_MAKEFILE = Makefile.$(ACTION)

M4 := m4

CCOMFLAGS += -O3

ifdef DEBUG
    CCOMFLAGS += -ggdb
else
    CCOMFLAGS += -DNODPRINTF -DNDEBUG
endif

ifdef VERBOSE
    CONFIG_SCRIPT_LOG := /dev/stdout
else
    CONFIG_SCRIPT_LOG := /dev/null 2>&1
    MAKE += -s
endif

# ======== LIBS ========
# sources to be linked together and processed by custom passes (makes sense only for Clang/LLVM)
LLS = $(addprefix $(BUILD_PATH)/, $(addsuffix .$(OBJ_EXT), $(SRC)))

# Directories
INCLUDE = $(addprefix -I,$(INC_DIR))
INCLUDE_LIB_DIRS = $(addprefix -L,$(LIB_DIRS))


# ============= OS ================
OS = -D_LINUX_
ARCHTYPE = $(shell uname -p)

ifeq ($(shell uname -m),x86_64)
ARCH = -D__x86_64__
endif

CCOMFLAGS += $(OS)
CCOMFLAGS += $(ARCH)


# ======== Common build targets ========
.PHONY: all clean make_dirs

all: make_dirs

make_dirs:
	-mkdir -p $(BUILD_PATH)
	@echo "" > $(BUILD_PATH)/.need_cxx

clean:
	rm -rf $(BUILD_PATH)

