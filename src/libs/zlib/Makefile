NAME := zlib

# undefine variables from recursive calls
undefine BUILD_DIR

# import type-specific configuration
include Makefile.$(BUILD_TYPE)
LIBS :=  # remove junk libs - not necessary for the glib
$(eval $(call expand-ccflags))
CFLAGS += -Derrno="(*__errno_location())"

ifdef REBUILD
all: pre_clean
endif
all:
	cd src && ./configure.shared  --prefix=$(BUILD_DIR) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src distclean > $(CONFIG_SCRIPT_LOG) || true
