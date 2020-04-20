NAME := radiosity
SRC := display elemman modelman patchman rad_main rad_tools room_model smallobj taskman visible glib glibps
HEADER_DEPS := patch.h model.h parallel.h task.h structs.h

VPATH := src:src/glibps:src/glibdumb

include $(BUILD_TYPE).mk
include ../config.mk

$(BUILD_DIR)/glib.o: glib.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc/glibdumb -c $< -o $@

$(BUILD_DIR)/glibps.o: glibps.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc/glibps -c $< -o $@

CFLAGS += -Isrc/glibdumb -Isrc/glibps -Isrc

# enforce build order
all:
	@${MAKE} radiosity.h
	@${MAKE} $(BUILD_DIR)/$(NAME)

radiosity.h: $(HEADER_DEPS)
