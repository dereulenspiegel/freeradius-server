#.PHONY: go_clean go_build_static go_build_dynamic

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

PACKAGE  = rlm_go
BASE_DIR = ${top_srcdir}/src/modules/$(PACKAGE)
PACKAGE_GOPATH = $(BASE_DIR)/.gopath
GOPATH   += $(PACKAGE_GOPATH)
LOCAL_GOPATH = $(subst $(SPACE),:,$(GOPATH))
BASE     = $(PACKAGE_GOPATH)/src/$(PACKAGE)

TARGET = $(PACKAGE).a

# Very dirty hack, to prevent ar from trying to link stuff together. cgo has already taken care of that
TGT_LINKER := "echo"

# TODO somehow use regex to add ${top_srcdir} before every include path
CGO_CFLAGS := -I. -I${top_srcdir}/src \
	-include ${top_srcdir}/src/freeradius-devel/autoconf.h \
	-include ${top_srcdir}/src/freeradius-devel/build.h \
	-include ${top_srcdir}/src/freeradius-devel/features.h \
	-include ${top_srcdir}/src/freeradius-devel/radpaths.h \
	-fno-strict-aliasing -g3 -Wall -std=c99 -D_GNU_SOURCE \
	-D_REENTRANT -D_POSIX_PTHREAD_SEMANTICS -DDARWIN -DOPENSSL_NO_KRB5 \
	-Wdocumentation -Wshadow -Wpointer-arith -Wcast-qual \
	-Wcast-align -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes \
	-Wmissing-declarations -Wnested-externs -W -Wredundant-decls -Wundef \
	-Wformat-y2k -Wno-format-extra-args -Wno-format-zero-length -Wno-cast-align \
	-Wformat-nonliteral -Wformat-security -Wformat=2 -DWITH_VERIFY_PTR=1 -DIS_MODULE=1

CGO_LDFLAGS := -L${top_srcdir}/build/lib/.libs/ -lfreeradius-server
CGO_LDFLAGS += $(LDFLAGS)

go_build_static: $(BASE) go_build_dynamic
	cd $(BASE) && \
	GOPATH='$(LOCAL_GOPATH)' CGO_CFLAGS='$(CGO_CFLAGS)' CGO_LDFLAGS='$(CGO_LDFLAGS)' \
	go build -buildmode=c-archive \
	-o $(top_builddir)/$(BUILD_DIR)/lib/local/$(PACKAGE).a ./

go_build_dynamic: $(BASE)
	cd $(BASE) && \
	GOPATH='$(LOCAL_GOPATH)' CGO_CFLAGS='$(CGO_CFLAGS)' CGO_LDFLAGS='$(CGO_LDFLAGS)' \
	go build -buildmode=c-shared \
	-o $(top_builddir)/$(BUILD_DIR)/lib/local/$(PACKAGE).dylib ./

$(BASE):
	@mkdir -p $(dir $@)
	@ln -sf $(BASE_DIR) $@

build/lib/local/rlm_go.la: go_build_static

build/lib/local/rlm_go.dylib: go_build_dynamic

clean_rlm_go.la: go_clean

go_clean:
	@rm -rf $(GOPATH)
