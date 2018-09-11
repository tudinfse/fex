NAME := libxml2

# undefine variables from recursive calls
undefine BUILD_PATH

# import type-specific configuration
include Makefile.$(BUILD_TYPE)
#LIBS :=  # remove junk libs - not necessary for the glib

# zlib is always compiled before libxml2, so we can rely on files existing
CFLAGS  += -I$(BUILD_ROOT)/libs/zlib/$(BUILD_TYPE)/include
CFLAGS += -DTRIO_COMPILER_SUPPORTS_C99
LDFLAGS += -L$(BUILD_ROOT)/libs/zlib/$(BUILD_TYPE)/lib
LIBS += -ldl

CONFIGFLAGS = --disable-shared --without-threads
ifdef version
  ifeq "$(version)" "pthreads"
    CONFIGFLAGS = --disable-shared --with-threads
  endif
endif

$(eval $(call expand-ccflags))

ifdef REBUILD
all: pre_clean
endif
all:
	cp configure src/configure
	cp Makefile.in src/Makefile.in
	cd src && ./configure $(CONFIGFLAGS) --prefix=$(BUILD_PATH) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src distclean > $(CONFIG_SCRIPT_LOG) || true
