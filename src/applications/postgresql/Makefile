# postgresql version 9.1.20

NAME := postgresql
POSTGRESQL_PATH := ${DATA_PATH}/postgres/postgres-REL9_5_1

include Makefile.$(ACTION)

all:
	cd $(POSTGRESQL_PATH) && ./configure --without-readline --without-zlib --prefix=$(BUILD_PATH)
	make -C $(POSTGRESQL_PATH)
	make install -C $(POSTGRESQL_PATH)
