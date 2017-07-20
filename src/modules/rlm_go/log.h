#ifndef GOLOGGING_H_
#define GOLOGGING_H_
#include <freeradius-devel/radiusd.h>
#include <freeradius-devel/log.h>

int goradlog(int lvl,char const *fmt);
void gowarn(char const *fmt);

#endif