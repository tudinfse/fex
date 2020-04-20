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

# paths
BUILD_ROOT ?= $(PROJ_ROOT)/build
BUILD_DIR ?= $(BUILD_ROOT)/$(BENCH_SUITE)/$(NAME)/$(BUILD_TYPE)
TYPE_MAKEFILE = $(BUILD_TYPE).mk

OBJ_FILES := $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(SRC)))

# ======== Common build targets ========
.PHONY: all clean make_dirs

all: make_dirs
make_dirs:
	-mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

# ======== File-type-specific build targets ========
# object files
$(BUILD_DIR)/%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.C
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cxx
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cc
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# executable
$(BUILD_DIR)/$(NAME): $(OBJ_FILES)
	$(LD) $? -o $@ $(LDFLAGS)
