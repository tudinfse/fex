CFLAGS += -std=c11
CCOMFLAGS += -pthread -D_XOPEN_SOURCE=500 -D_POSIX_C_SOURCE=200112 -fno-strict-aliasing
LDFLAGS += -lm

MACROS += $(COMP_BENCH)/src/splash/pthread_macros/pthread.m4.stougie

M4FLAGS += -Ulen -Uindex

$(BUILD_PATH)/%.$(OBJ_EXT): %.C
	$(M4) $(M4FLAGS) $(MACROS) $< > $(BUILD_PATH)/$*.c
	$(CC) $(CCOMFLAGS) $(CFLAGS) -c $(BUILD_PATH)/$*.c -o $@ $(INCLUDE)
