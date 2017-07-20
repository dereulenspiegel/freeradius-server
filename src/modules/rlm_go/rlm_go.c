#include <freeradius-devel/radiusd.h>
#include <freeradius-devel/modules.h>
#include <freeradius-devel/rad_assert.h>

typedef struct rlm_go_t {
       char const      *plugin;
} rlm_go_t;

static const CONF_PARSER module_config[] = {
         {"plugin", FR_CONF_OFFSET( PW_TYPE_STRING, rlm_go_t, plugin), "undefined" },
         { NULL, -1, 0, NULL, NULL }
 };

extern int go_instantiate(CONF_SECTION *conf, char const *plugin);

static int mod_instantiate(CONF_SECTION *conf, void *instance) {
  rlm_go_t *inst = instance;
  radlog(L_WARN, "Found plugin %s",inst->plugin);
  return go_instantiate(conf, inst->plugin);
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
  .name = "go",
  .type = RLM_TYPE_THREAD_UNSAFE,
  .inst_size = sizeof(rlm_go_t),
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