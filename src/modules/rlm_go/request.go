package main

/*
#include <stdlib.h>
#include <freeradius-devel/radiusd.h>

void go_create_value_pair(RADIUS_PACKET *packet,const char *attrName, const char *attrValue) {
  // TODO we probably need to make the operator available in the Go side
  fr_pair_make(packet, packet->vps, attrName, attrValue, T_OP_SET);
}
*/
import "C"

import (
	//"unsafe"
	"net"
	"time"

	"github.com/dereulenspiegel/freeradius-go"
)

type packet struct {
	radPacket *C.struct_radius_packet
}

func (p *packet) AddValuePair(attribute, value string) {
	as := C.CString(attribute)
	vs := C.CString(value)
	C.go_create_value_pair(p.radPacket, as, vs)
}

func (p *packet) Code() uint {
	return uint(p.radPacket.code)
}

func (p *packet) Id() int {
	return int(p.radPacket.id)
}

func (p *packet) Timestamp() time.Time {
	// TODO convert struct timeval to gos time.Time
	return time.Time{}
}

func (p *packet) DestinationIp() net.IP {
	// TODO convert fr_ipaddr_t to net.IP
	return make(net.IP, 16)
}

func (p *packet) SourceIp() net.IP {
	// TODO convert fr_ipaddr_t to net.IP
	return make(net.IP, 16)
}

func (p *packet) DestinationPort() uint16 {
	return uint16(p.radPacket.dst_port)
}

func (p *packet) SourcePort() uint16 {
	return uint16(p.radPacket.src_port)
}

type request struct {
	radRequest *C.struct_rad_request
}

func NewRequest(in *C.struct_rad_request) *request {
	return &request{in}
}

func (r *request) Reply() freeradius.Packet {
	//return &packet{r.radRequest.reply}
	return nil
}

func (r *request) AddValuePair(attribute, value string) {

}

func (r *request) Packet() freeradius.Packet {
	//return &packet{r.radRequest.packet}
	return nil
}

type reply struct {
	radReply *C.struct_radius_packet
}

func (r *reply) AddValuePair(attribute, value string) {
	as := C.CString(attribute)
	vs := C.CString(value)
	// TODO do we need to free these strings????
	C.go_create_value_pair(r.radReply, as, vs)
}
