.PHONY: go_clean go_build_static

PACKAGE  = rlm_cloud
BASE_DIR = ${top_srcdir}/src/modules/$(PACKAGE)
GOPATH   = $(BASE_DIR)/.gopath
BASE     = $(GOPATH)/src/$(PACKAGE)

TARGET = $(PACKAGE).a

# Very dirty hack, to prevent ar from trying to link stuff together. cgo has already taken care of that
TGT_LINKER := "echo"

# TODO somehow use regex to add ${top_srcdir} before every include path
CGO_CFLAGS := -I. -I${top_srcdir}/src \
	-include ${top_srcdir}/src/freeradius-devel/autoconf.h \
	-include ${top_srcdir}/src/freeradius-devel/build.h \
	-include ${top_srcdir}/src/freeradius-devel/features.h \
	-include ${top_srcdir}/src/freeradius-devel/radpaths.h

go_build_static: $(BASE) go_build_dynamic
	cd $(BASE) && CGO_CFLAGS='$(CGO_CFLAGS)' go build -buildmode=c-archive  -o $(top_builddir)/$(BUILD_DIR)/lib/local/$(PACKAGE).a ./

go_build_dynamic: $(BASE)
	cd $(BASE) && CGO_CFLAGS='$(CGO_CFLAGS)' go build -buildmode=c-shared  -o $(top_builddir)/$(BUILD_DIR)/lib/local/$(PACKAGE).dylib ./

$(BASE):
	@mkdir -p $(dir $@)
	@ln -sf $(BASE_DIR) $@

build/lib/local/rlm_cloud.la: go_build_static

build/lib/local/rlm_cloud.dylib: go_build_dynamic

clean_rlm_cloud.la: go_clean

go_clean:
	@rm -rf $(GOPATH)
