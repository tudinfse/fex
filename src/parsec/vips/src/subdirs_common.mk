BUILD_PATH = $(BUILD_ROOT)/$(BENCH_SUITE)/vips/$(ACTION)/$(NAME)
include Makefile.$(ACTION)
include $(PROJ_ROOT)/src/parsec/parsec_common.mk

all: $(BUILD_PATH)/../$(NAME).$(OBJ_EXT)

$(BUILD_PATH)/../$(NAME).$(OBJ_EXT): $(LLS)
	$(LD) $(LDRELOC) $^ -o $@
