package main

// #include <freeradius-devel/radiusd.h>
// #include <freeradius-devel/modules.h>
// #include <freeradius-devel/rad_assert.h>
import "C"

import (
	"fmt"
	"unsafe"
)

//export Go_instantiate
func Go_instantiate(cconf *C.CONF_SECTION, instance unsafe.Pointer) C.int {
	fmt.Println("go_instantiate called!")
	instance = unsafe.Pointer(&C.struct_rlm_cloud_t{})
	return 0
}

func main() {}
