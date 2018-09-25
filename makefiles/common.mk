###############################
# Common functionality:
# - variables and default values
# - targets
# - helper functions
###############################

# check that required variables are specified
ifndef PROJ_ROOT
$(error PROJ_ROOT is not specified)
endif

ifndef BUILD_TYPE
$(error BUILD_TYPE is not specified)
endif

ifndef NAME
$(error NAME is not specified)
endif

# ======== Main variables ========
# directories
ifndef BUILD_ROOT
    BUILD_ROOT = $(PROJ_ROOT)/build
endif

ifndef BUILD_DIR
    BUILD_DIR = $(BUILD_ROOT)/$(BENCH_SUITE)/$(NAME)/$(BUILD_TYPE)
endif

TYPE_MAKEFILE = Makefile.$(BUILD_TYPE)

# build flags
ifdef DEBUG
    CCFLAGS += -ggdb -O1
else
    CCFLAGS += -DNODPRINTF -DNDEBUG -O3 -ggdb
endif

ifdef VERBOSE
    CONFIG_SCRIPT_LOG := /dev/stdout
else
    CONFIG_SCRIPT_LOG := /dev/null 2>&1
    MAKE += -s
endif

# programs
ifndef FINAL_CC
    FINAL_CC = $(CXX)
endif

M4 := m4

# ======== LIBS ========
# list of sources
LLS = $(addprefix $(BUILD_DIR)/, $(addsuffix .$(OBJ_EXT), $(SRC)))

# included directories
INCLUDE_HEADER_DIRS = $(addprefix -I,$(INC_DIR))
INCLUDE_LIB_DIRS = $(addprefix -L,$(LIB_DIRS))


# ============= OS ================
OS = -D_LINUX_
ARCHTYPE = $(shell uname -p)

ifeq ($(shell uname -m),x86_64)
ARCH = -D__x86_64__
endif

CCFLAGS += $(OS) $(ARCH)

# ======== Common build targets ========
.PHONY: all clean make_dirs

all: make_dirs

make_dirs:
	-mkdir -p $(BUILD_DIR)
	@echo "" > $(BUILD_DIR)/.need_cxx

clean:
	rm -rf $(BUILD_DIR)

# ======== File-type-specific build targets ========
# headers
%.h: %.H
	$(M4) $(M4FLAGS) $(MACROS) $^ > $(BUILD_DIR)/$@

# object files
$(BUILD_DIR)/%.$(OBJ_EXT): %.c
	$(CC) $(CCFLAGS) $(CFLAGS) -c $< -o $@ $(INCLUDE_HEADER_DIRS)

$(BUILD_DIR)/%.$(OBJ_EXT): %.C
	$(CC) $(CCFLAGS) $(CFLAGS) -c $< -o $@ $(INCLUDE_HEADER_DIRS)

$(BUILD_DIR)/%.$(OBJ_EXT): %.cpp
	$(CXX) $(CCFLAGS) $(CXXFLAGS) -c $< -o $@ $(INCLUDE_HEADER_DIRS)

$(BUILD_DIR)/%.$(OBJ_EXT): %.cxx
	$(CXX) $(CCFLAGS) $(CXXFLAGS) -c $< -o $@ $(INCLUDE_HEADER_DIRS)

$(BUILD_DIR)/%.$(OBJ_EXT): %.cc
	$(CXX) $(CCFLAGS) $(CXXFLAGS) -c $< -o $@ $(INCLUDE_HEADER_DIRS)

# executable
$(BUILD_DIR)/$(NAME): $(LLS)
	$(FINAL_CC) $(FINAL_CCFLAGS) $(CCFLAGS) $(CXXFLAGS) -o $@ $^ $(INCLUDE_HEADER_DIRS) $(INCLUDE_LIB_DIRS) $(LIBS)


# ======== Helper functions ========
# $(eval $(call expand-ccflags))
define expand-ccflags
	CFLAGS += $(CCFLAGS)
	CXXFLAGS += $(CCFLAGS)
	export
endef

