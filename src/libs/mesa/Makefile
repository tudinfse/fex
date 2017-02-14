NAME := mesa

include common.mk
include $(ACTION_MAKEFILE)

CFLAGS += -I$(COMP_BENCH)/src/parsec_libs/mesa

CFLAGS += $(CCOMFLAGS)
CXXFLAGS += $(CCOMFLAGS)
export

ifdef REBUILD
all: pre_clean
endif

# the `> $(CONFIG_SCRIPT_LOG)` redirection is nessesary to silence the build process
all:
	ln -s /usr/include/X11 X11 || true  # dirty hack to include X11 headers even under SGX (assumes `/usr/include/X11` exists)
	$(MAKE) -C src clean > $(CONFIG_SCRIPT_LOG)  || true
	cd src && ./configure --with-driver=xlib --enable-glut --enable-static --disable-shared --prefix=$(BUILD_PATH) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src clean > $(CONFIG_SCRIPT_LOG)  || true




g++
 -O3 -fexceptions -pthread
 -DNODPRINTF -DNDEBUG -D_LINUX_ -D__x86_64__ -DG_DISABLE_CAST_CHECKS -DHAVE_CONFIG_H  -D restrict=__restrict__

 -o /root/code/compiler-bench//build/parsec/vips/gcc_native/vips /root/code/compiler-bench//build/parsec/vips/gcc_native/vips.o /root/code/compiler-bench//build/parsec/vips/gcc_native/dummy.o /root/code/compiler-bench//build/parsec/vips/gcc_native/im_clamp.o /root/code/compiler-bench//build/parsec/vips/gcc_native/bool_dispatch.o /root/code/compiler-bench//build/parsec/vips/gcc_native/boolean.o /root/code/compiler-bench//build/parsec/vips/gcc_native/iofuncs.o /root/code/compiler-bench//build/parsec/vips/gcc_native/arithmetic.o /root/code/compiler-bench//build/parsec/vips/gcc_native/resample.o /root/code/compiler-bench//build/parsec/vips/gcc_native/colour.o /root/code/compiler-bench//build/parsec/vips/gcc_native/conversion.o /root/code/compiler-bench//build/parsec/vips/gcc_native/deprecated.o /root/code/compiler-bench//build/parsec/vips/gcc_native/convolution.o /root/code/compiler-bench//build/parsec/vips/gcc_native/format.o /root/code/compiler-bench//build/parsec/vips/gcc_native/freq_filt.o /root/code/compiler-bench//build/parsec/vips/gcc_native/histograms_lut.o /root/code/compiler-bench//build/parsec/vips/gcc_native/inplace.o /root/code/compiler-bench//build/parsec/vips/gcc_native/mask.o /root/code/compiler-bench//build/parsec/vips/gcc_native/morphology.o /root/code/compiler-bench//build/parsec/vips/gcc_native/mosaicing.o /root/code/compiler-bench//build/parsec/vips/gcc_native/other.o /root/code/compiler-bench//build/parsec/vips/gcc_native/relational.o /root/code/compiler-bench//build/parsec/vips/gcc_native/video.o

 -I/root/code/compiler-bench//src/parsec/vips/src/include

 -L/root/code/compiler-bench//build/parsec_libs/zlib/gcc_native/lib
 -L/root/code/compiler-bench//build/parsec_libs/glib/gcc_native/lib
 -L/root/code/compiler-bench//build/parsec_libs/libxml2/gcc_native/lib
 -lgmodule-2.0 -lxml2 -lgobject-2.0 -lgthread-2.0 -lglib-2.0 -lz -ldl
