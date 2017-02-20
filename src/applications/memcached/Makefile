# Memcached version 1.4.15
NAME := memcached

MEMCACHED_SRC := ${BIN_PATH}/memcached/src/
LIBEVENT_BUILD := $(BUILD_ROOT)/libs/libevent/$(BUILD_TYPE)

CONFIG_OPT := --prefix=$(BUILD_PATH) \
				--with-libevent==$(LIBEVENT_BUILD) \
				--mandir=/tmp --disable-coverage

include Makefile.$(BUILD_TYPE)

CCFLAGS += -std=gnu99 -DHAVE_CONFIG_H -Wall -I/usr/include/x86_64-linux-gnu
$(eval $(call expand-ccflags))


# Targets
.PHONY: buildlibs

ifdef REBUILD
all: pre_clean
endif
all:
	@${MAKE} buildlibs
	@${MAKE} buildmemcached

buildmemcached:
	cd $(MEMCACHED_SRC) && ACLOCAL=aclocal AUTOMAKE=automake ./autogen.sh > $(CONFIG_SCRIPT_LOG) || true
	cd $(MEMCACHED_SRC) && ./configure $(CONFIG_OPT) > $(CONFIG_SCRIPT_LOG)
	make -C $(MEMCACHED_SRC)  > $(CONFIG_SCRIPT_LOG)
	make install -C $(MEMCACHED_SRC)  > $(CONFIG_SCRIPT_LOG)

buildlibs: export BENCH_SUITE=libs
buildlibs:
	$(MAKE) BUILD_TYPE=$(BUILD_TYPE) -I $(PROJ_ROOT)/makefiles -C $(PROJ_ROOT)/src/libs/libevent

pre_clean:
	$(MAKE) -C $(MEMCACHED_SRC) clean > $(CONFIG_SCRIPT_LOG) || true

