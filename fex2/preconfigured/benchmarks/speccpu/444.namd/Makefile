NAME := 444.namd
SRC := spec_namd Compute ComputeList ComputeNonbondedUtil LJTable Molecule Patch PatchList ResultSet SimParameters erf
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

LDFLAGS += -lstdc++ -lm

all: $(BUILD_DIR)/$(NAME)

# namd has strange file names
# thus, we need to customize the standard target
$(BUILD_DIR)/%.o: %.C
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@
