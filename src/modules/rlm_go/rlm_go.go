package main

// #include <freeradius-devel/radiusd.h>
// #include <freeradius-devel/modules.h>
// #include <freeradius-devel/rad_assert.h>
import "C"

import (
	//"fmt"
	//"unsafe"
	"plugin"
	"sync"

	"github.com/dereulenspiegel/freeradius-go"
)

const (
	createModuleSymbol = "CreateModule"
)

var (
	instanceMap = make(map[string]freeradius.Module)
	mapLock     = &sync.Mutex{}
)

func insertInstance(path string, mod freeradius.Module) {
	mapLock.Lock()
	defer mapLock.Unlock()
	instanceMap[path] = mod
}

func getInstance(path string) freeradius.Module {
	mapLock.Lock()
	defer mapLock.Unlock()
	return instanceMap[path]
}

func getInstanceC(cs *C.char) freeradius.Module {
	path := C.GoString(cs)
	return getInstance(path)
}

//export go_instantiate
func go_instantiate(cconf *C.CONF_SECTION, pl *C.char) C.int {
	pluginPath := C.GoString(pl)
	radlogInstance.Radlog(freeradius.LogTypeInfo, "using pluginpath %s", pluginPath)
	gomodule, err := plugin.Open(pluginPath)
	if err != nil || gomodule == nil {
		radlogInstance.Radlog(freeradius.LogTypeError, "Failed to load plugin %s: %#v", pluginPath, err)
		return -1
	}

	createModule, err := gomodule.Lookup(createModuleSymbol)
	if err != nil {
		radlogInstance.Radlog(freeradius.LogTypeError, "Unable to lookup symbol %s: %#v", createModuleSymbol, err)
		return -1
	}

	instance := createModule.(freeradius.ModuleFunc)()
	if instance == nil {
		radlogInstance.Radlog(freeradius.LogTypeError, "Created go module instance is nil")
		return -1
	}

	if err := instance.Init(radlogInstance); err != nil {
		radlogInstance.Radlog(freeradius.LogTypeError, "Unable to initialize go module %s: %#v", pluginPath, err)
	}

	insertInstance(pluginPath, instance)
	return 0
}

//export go_authorize
func go_authorize(instancePath *C.char, request *C.REQUEST) C.int {

	mod := getInstanceC(instancePath)
	if mod == nil {
		// Should never happen
		return toRlmCodeT(freeradius.RlmCodeFail)
	}

	req := NewRequest(request)

	return toRlmCodeT(mod.Authorize(req))
}

func toRlmCodeT(in freeradius.RlmCode) C.int {
	return C.int(in)
}

func main() {}
