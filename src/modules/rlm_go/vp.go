package main

/*
#include <stdlib.h>
#include <freeradius-devel/libradius.h>

const char* go_vp_string(VALUE_PAIR *vp) {
  return vp->vp_strvalue;
}
*/
import "C"

import (
	"unsafe"
)

/*func lookUpDictAttrByName(name string) *C.struct_dict_attr {
	cname := C.CString(name)
	defer C.free(unsafe.Pointer(cname))
	return C.dict_attrbyname(cname)
}*/

type valuePair struct {
	cpair *C.struct_value_pair
}

func (v *valuePair) GetByName(name string) interface{} {
	/*dictAttr := lookUpDictAttrByName(name)
	if dictAttr == nil {
		return nil
	}*/
	return nil
}

func (v *valuePair) StringValue() string {
	cs := C.go_vp_string(v.cpair)
	defer C.free(unsafe.Pointer(cs))
	return C.GoString(cs)
}
