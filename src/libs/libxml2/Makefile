NAME := libxml2

include common.mk
include $(ACTION_MAKEFILE)

# zlib is always compiled before libxml2, so we can rely on files existing
CFLAGS  += -I$(BUILD_ROOT)/libs/zlib/$(ACTION)/include
LDFLAGS += -L$(BUILD_ROOT)/libs/zlib/$(ACTION)/lib
LIBS += -ldl

CONFIGFLAGS = --disable-shared --without-threads
ifdef version
  ifeq "$(version)" "pthreads"
    CONFIGFLAGS = --disable-shared --with-threads
  endif
endif

CFLAGS += $(CCOMFLAGS)
CXXFLAGS += $(CCOMFLAGS)
export

ifdef REBUILD
all: pre_clean
endif

# the `> $(CONFIG_SCRIPT_LOG)` redirection is nessesary to silence the build process
all:
	cd src && ./configure $(CONFIGFLAGS) --prefix=$(BUILD_PATH) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src distclean > $(CONFIG_SCRIPT_LOG) || true
