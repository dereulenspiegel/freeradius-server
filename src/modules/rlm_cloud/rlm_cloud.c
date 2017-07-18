#include <freeradius-devel/radiusd.h>
#include <freeradius-devel/modules.h>
#include <freeradius-devel/rad_assert.h>

typedef struct rlm_cloud_t {
       bool            cache;
       uint32_t        ttl;
       char const      *backend;
} rlm_cloud_t;

static const CONF_PARSER module_config[] = {
         {"ttl", FR_CONF_OFFSET( PW_TYPE_INTEGER, rlm_cloud_t, ttl),  "600" },
         {"cache", FR_CONF_OFFSET( PW_TYPE_BOOLEAN, rlm_cloud_t, cache),  "no" },
         {"backend", FR_CONF_OFFSET( PW_TYPE_STRING, rlm_cloud_t, backend), "https://auth.connctd.io" },
         { NULL, -1, 0, NULL, NULL }
 };

extern int Go_instantiate(CONF_SECTION *conf, void *instance);

static int mod_instantiate(CONF_SECTION *conf, void *instance) {
  return Go_instantiate(conf, instance);
}

static rlm_rcode_t CC_HINT(nonnull) mod_authorize(UNUSED void *instance, REQUEST *request) {
  return RLM_MODULE_OK;
}

static rlm_rcode_t CC_HINT(nonnull) mod_authenticate(UNUSED void *instance, UNUSED REQUEST *request) {
  return RLM_MODULE_OK;
}

static rlm_rcode_t CC_HINT(nonnull) mod_preacct(UNUSED void *instance, UNUSED REQUEST *request) {
  return RLM_MODULE_OK;
}

static rlm_rcode_t CC_HINT(nonnull) mod_accounting(UNUSED void *instance, UNUSED REQUEST *request) {
    return RLM_MODULE_OK;
}

static rlm_rcode_t CC_HINT(nonnull) mod_checksimul(UNUSED void *instance, REQUEST *request) {
  return RLM_MODULE_OK;
}

static int mod_detach(UNUSED void *instance) {
  return 0;
}

extern module_t rlm_cloud;
module_t rlm_cloud = {
  .magic = RLM_MODULE_INIT,
  .name = "cloud",
  .type = RLM_TYPE_THREAD_UNSAFE,
  .inst_size = sizeof(rlm_cloud_t),
  .config = module_config,
  .instantiate = mod_instantiate,
  .detach = mod_detach,
  .methods = {
    [MOD_AUTHENTICATE]      = mod_authenticate,
    [MOD_AUTHORIZE]         = mod_authorize,
#ifdef WITH_ACCOUNTING
    [MOD_PREACCT]           = mod_preacct,
    [MOD_ACCOUNTING]        = mod_accounting,
    [MOD_SESSION]           = mod_checksimul
#endif
  }
};