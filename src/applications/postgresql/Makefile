# postgresql version 9.1.20

NAME := postgresql
POSTGRESQL_PATH := ${DATA_PATH}/postgres/postgres-REL9_5_1

include Makefile.$(BUILD_TYPE)

all:
	cd $(POSTGRESQL_PATH) && ./configure --without-readline --without-zlib --prefix=$(BUILD_DIR)  > $(CONFIG_SCRIPT_LOG)
	make -C $(POSTGRESQL_PATH) > $(CONFIG_SCRIPT_LOG)
	make install -C $(POSTGRESQL_PATH) > $(CONFIG_SCRIPT_LOG)
