#ifndef lregion_h
#define lregion_h
#include <stdlib.h>

#include "lobject.h"

typedef struct RObject {
  GCObject *body;
} RObject;

typedef struct Region {
  RObject *base, *top;
} Region;

#define OSTACK_REGIONS 256
#define OSTACK_MINBUFSIZE 1024

struct RObjectBuffer {
  RObject *head, *last;
  int size;
};

typedef struct OStack {
  Region regions[OSTACK_REGIONS];
  int regnum;
  Region *region;
  struct RObjectBuffer rbuf;
} OStack;

#define ostack_new(L,t) cast(t *, ostack_alloc(L, sizeof(t)))

LUAI_FUNC OStack *ostack_init(lua_State *L);
LUAI_FUNC void ostack_close(lua_State *L);
LUAI_FUNC void region_new(lua_State *L);
LUAI_FUNC void region_renew(lua_State *L);
LUAI_FUNC void region_free(lua_State *L);
LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size);

//LUAI_FUNC int ostack_getregion(lua_State *L, GCObject *o) {
//LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src);
LUAI_FUNC void ostack_reject(lua_State *L, GCObject *src);

#define is_must_reject(parent,child) \
  (is_region(child) && (is_region(parent) || (parent)->gch.region < (child)->gch.region))

#endif
