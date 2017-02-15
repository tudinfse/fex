NAME := mesa

include Makefile.$(ACTION)

CFLAGS += -I$(PROJ_ROOT)/src/libs/mesa
$(eval $(call expand-ccflags))

ifdef REBUILD
all: pre_clean
endif
all:
	ln -s /usr/include/X11 X11 || true  # dirty hack to include X11 headers even under SGX (assumes `/usr/include/X11` exists)
	$(MAKE) -C src clean > $(CONFIG_SCRIPT_LOG)  || true
	cd src && ./configure --with-driver=xlib --enable-glut --enable-static --disable-shared --prefix=$(BUILD_PATH) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src clean > $(CONFIG_SCRIPT_LOG)  || true

