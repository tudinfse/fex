BUILD_DIR = $(BUILD_ROOT)/$(BENCH_SUITE)/vips/$(BUILD_TYPE)/$(NAME)
include Makefile.$(BUILD_TYPE)
include $(PROJ_ROOT)/src/parsec/parsec_common.mk

all: $(BUILD_DIR)/../$(NAME).$(OBJ_EXT)

$(BUILD_DIR)/../$(NAME).$(OBJ_EXT): $(LLS)
	$(LD) $(LDRELOC) $^ -o $@
