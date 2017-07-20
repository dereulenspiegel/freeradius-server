package main

// #include <freeradius-devel/radiusd.h>
// #include <freeradius-devel/modules.h>
// #include <freeradius-devel/rad_assert.h>
import "C"

import (
	//"fmt"
	//"unsafe"
	"github.com/dereulenspiegel/freeradius-go"
)

//export go_instantiate
func go_instantiate(cconf *C.CONF_SECTION, plugin *C.char) C.int {
	radlogInstance.Radlog(freeradius.LogTypeInfo, "Inintiated via GO!")
	pluginPath := C.GoString(plugin)
	radlogInstance.Radlog(freeradius.LogTypeInfo, "using pluginpath %s", pluginPath)
	return 0
}

func main() {}
