# check that m4 is installed
M4_INSTALLED := $(shell which m4 2>/dev/null 1>&2; echo $$?)
ifneq ($(M4_INSTALLED), 0)
$(error m4 is not installed)
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
