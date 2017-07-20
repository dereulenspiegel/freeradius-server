package main

//#include "log.h"
import "C"

import (
	"fmt"
	"unsafe"

	"github.com/dereulenspiegel/freeradius-go"
)

type radlogger struct{}

var radlogInstance = radlogger{}

func (r radlogger) Radlog(level freeradius.LogType, format string, args ...interface{}) int {
	s := fmt.Sprintf(format, args...)
	cs := C.CString(s)
	defer C.free(unsafe.Pointer(cs))

	ret, _ := C.goradlog(C.int(level), cs)
	return int(ret)
}

func (r radlogger) Info(format string, args ...interface{}) {
	s := fmt.Sprintf(format, args...)
	cs := C.CString(s)
	defer C.free(unsafe.Pointer(cs))
	C.gowarn(cs)
}
