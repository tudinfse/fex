NAME := libjpeg

# undefine variables from recursive calls
undefine BUILD_DIR

# import type-specific configuration
include Makefile.$(BUILD_TYPE)
$(eval $(call expand-ccflags))

ifdef REBUILD
all: pre_clean
endif
all:
	cd src && ./configure --disable-shared --prefix=$(BUILD_DIR) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src distclean > $(CONFIG_SCRIPT_LOG) || true
