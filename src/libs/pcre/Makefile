NAME := pcre

include Makefile.$(ACTION)
$(eval $(call expand-ccflags))

IGNORE_DOCS := dist_doc_DATA="" dist_html_DATA="" dist_man_MANS="" pcrecpp_html=""


ifdef REBUILD
all: pre_clean
endif
all:
	cd src && ./configure  --disable-shared --disable-cpp --prefix=$(BUILD_PATH) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src $(IGNORE_DOCS) > $(CONFIG_SCRIPT_LOG)
	$(MAKE) -C src install $(IGNORE_DOCS) > $(CONFIG_SCRIPT_LOG)

pre_clean:
	$(MAKE) -C src distclean > $(CONFIG_SCRIPT_LOG)  || true
