#ifndef lregion_h
#define lregion_h
#include <stdlib.h>

#include "lobject.h"

typedef struct RObject {
  GCObject *body;
} RObject;

typedef RObject *Region;

#define OSTACK_REGIONS 256
#define OSTACK_MINBUFSIZE 1024

struct RObjectBuffer {
  RObject *head, *last;
  RObject *top;
  int size;
};

typedef struct OStack {
  Region regions[OSTACK_REGIONS];
  int cur_region;
  RObjectBuffer buf;
} OStack;

#define ostack_new(L,t) cast(t *, ostack_alloc(L, sizeof(t)))

LUAI_FUNC OStack *ostack_init(lua_State *L);
LUAI_FUNC void ostack_close(lua_State *L);
LUAI_FUNC int region_new(lua_State *L);
LUAI_FUNC int region_renew(lua_State *L, int region);
LUAI_FUNC int region_close(lua_State *L, int region);
LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size);

//LUAI_FUNC RObject *ostack_getrobject(OStack *os, Region *region, GCObject *o);
//LUAI_FUNC int ostack_getregion(lua_State *L, GCObject *o);
LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src);

#endif
