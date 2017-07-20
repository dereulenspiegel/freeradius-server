#import "log.h"

int goradlog(int lvl,char const *fmt) {
  int ret = radlog(lvl,fmt);
  return ret;
}

void gowarn(char const *fmt) {
  INFO(fmt);
}
