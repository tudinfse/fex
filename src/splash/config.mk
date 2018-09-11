CFLAGS += -std=c11
CCFLAGS += -pthread -D_XOPEN_SOURCE=500 -D_POSIX_C_SOURCE=200112 -fno-strict-aliasing
LDFLAGS += -lm

MACROS += $(PROJ_ROOT)/src/splash/pthread_macros/pthread.m4.stougie

M4FLAGS += -Ulen -Uindex

$(BUILD_DIR)/%.$(OBJ_EXT): %.C
	$(M4) $(M4FLAGS) $(MACROS) $< > $(BUILD_DIR)/$*.c
	$(CC) $(CCFLAGS) $(CFLAGS) -c $(BUILD_DIR)/$*.c -o $@ $(INCLUDE_HEADER_DIRS)
