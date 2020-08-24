# check that m4 is installed
a := $(shell which m4)
ifneq ($(.SHELLSTATUS), 0)
$(error m4 is not installed or your make does not support .SHELLSTATUS (since make 4.2 - 2016))
endif

CFLAGS += -std=c11 -pthread -D_XOPEN_SOURCE=500 -D_POSIX_C_SOURCE=200112 -fno-strict-aliasing
CXXFLAGS += -pthread -D_XOPEN_SOURCE=500 -D_POSIX_C_SOURCE=200112 -fno-strict-aliasing
LDFLAGS += -lm -lpthread

MACROS += $(PROJ_ROOT)/benchmarks/splash/pthread_macros/pthread.m4.stougie

M4FLAGS += -Ulen -Uindex

# M4
%.h: %.h.in
	$(M4) $(M4FLAGS) $(MACROS) $^ > $@

%.c: %.c.in
	$(M4) $(M4FLAGS) $(MACROS) $< > $@
