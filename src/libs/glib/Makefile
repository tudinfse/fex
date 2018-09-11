NAME := glib

# undefine variables from recursive calls
undefine BUILD_PATH

# import type-specific configuration
include Makefile.$(BUILD_TYPE)
#LIBS :=  # remove junk libs - not necessary for the glib

# zlib is always compiled before glib, so we can rely on files existing
CFLAGS  += -I$(BUILD_ROOT)/libs/zlib/$(BUILD_TYPE)/include
LDFLAGS += -L$(BUILD_ROOT)/libs/zlib/$(BUILD_TYPE)/lib

$(eval $(call expand-ccflags))

# Note: We always compile with thread support enabled because
# the serial version of glib is broken.

ifdef REBUILD
all: pre_clean
endif
all:
	cp configure src/configure
	cp Makefile.in src/Makefile.in
	cp Makefile.in.gobj src/gobject/Makefile.in
	cd src && ./configure --disable-shared --enable-threads --with-threads=posix --prefix=$(BUILD_PATH) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src distclean > $(CONFIG_SCRIPT_LOG) || true
