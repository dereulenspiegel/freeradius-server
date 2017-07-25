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

CGO_CFLAGS1 := $(subst -I,-I${top_srcdir}/,$(CFLAGS))
CGO_CFLAGS2 := $(subst -include ,-include ${top_srcdir}/, $(CGO_CFLAGS1))
# This is probably really hacky, but cgo seems to generate code causing errors
#CGO_CFLAGS3 := $(subst -Wstrict-prototypes,,$(CGO_CFLAGS2))
#CGO_CFLAGS4 := $(subst -Wmissing-prototypes,,$(CGO_CFLAGS3))
#CGO_CFLAGS5 := $(subst -Wmissing-declarations,,$(CGO_CFLAGS4))
# Ok, lets just remove everything causing errors
CGO_CFLAGS := $(patsubst -W%,,$(CGO_CFLAGS2))

CGO_LDFLAGS := -L${top_srcdir}/build/lib/.libs/ -lfreeradius-server -lfreeradius-radius
CGO_LDFLAGS += $(LDFLAGS)

go_build_static: $(BASE) go_build_dynamic
	cd $(BASE) && \
	GOPATH='$(LOCAL_GOPATH)' CGO_CFLAGS='$(CGO_CFLAGS)' CGO_LDFLAGS='$(CGO_LDFLAGS)' \
	go build -buildmode=c-archive \
	-o $(top_builddir)/$(BUILD_DIR)/lib/local/$(PACKAGE).a ./

go_build_dynamic: $(BASE)
	@echo "CGO_CFLAGS $(CGO_CFLAGS)"
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
