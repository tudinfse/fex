# postgresql version 12.3

NAME := postgresql
POSTGRESQL_PATH := ${PROJ_ROOT}/benchmarks/postgresql/postgres-12.3/src

include $(BUILD_TYPE).mk

all:
	sudo chown -R $(USER) $(BUILD_DIR)

	cd $(BUILD_DIR) && $(POSTGRESQL_PATH)/configure --without-readline --without-zlib --prefix=$(BUILD_DIR)
	make -C $(BUILD_DIR) MAKELEVEL=0
	make install -C $(BUILD_DIR) MAKELEVEL=0

	sudo chown -R fex2_postgres:$(USER) $(BUILD_DIR)
