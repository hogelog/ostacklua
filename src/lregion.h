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
  int cregnum;
  Region *creg;
  struct RObjectBuffer rbuf;
} OStack;

#define is_validregnum(num) ((num) >= 0 && (num) <= OSTACK_REGIONS)
#define is_notonregnum(num) ((num) == 0)
#define is_onregnum(num) ((num) > 0 && (num) <= OSTACK_REGIONS)

#define ostack_new(L,t) cast(t *, ostack_alloc(L, sizeof(t)))

LUAI_FUNC void ostack_init(lua_State *L);
LUAI_FUNC void ostack_close(lua_State *L);
LUAI_FUNC void region_new(lua_State *L);
LUAI_FUNC void region_renew(lua_State *L);
LUAI_FUNC void region_free(lua_State *L);
LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size);

//LUAI_FUNC int ostack_getregion(lua_State *L, GCObject *o) {
//LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src);
LUAI_FUNC void ostack_reject(lua_State *L, GCObject *src);

#define is_must_reject(parent,child) \
  ((parent)->gch.region < (child)->gch.region)

#endif
