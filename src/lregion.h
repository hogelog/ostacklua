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

#define RStack_REGIONS 256
#define RStack_MINBUFSIZE 1024

struct RObjectBuffer {
  RObject *head, *last;
  int size;
};

typedef struct RStack {
  Region regions[RStack_REGIONS];
  int cregnum;
  Region *creg;
  struct RObjectBuffer rbuf;
} RStack;

#define is_validregnum(num) ((num) >= 0 && (num) <= RStack_REGIONS)
#define is_notonregnum(num) ((num) == 0)
#define is_onregnum(num) ((num) > 0 && (num) <= RStack_REGIONS)

#define rstack_new(L,t) cast(t *, rstack_alloc(L, sizeof(t)))

LUAI_FUNC void rstack_init (lua_State *L);
LUAI_FUNC void rstack_close (lua_State *L);
LUAI_FUNC int region_new (lua_State *L);
LUAI_FUNC void region_renew (lua_State *L, int regnum);
LUAI_FUNC void region_free (lua_State *L, int regnum);
LUAI_FUNC void *rstack_alloc (lua_State *L, size_t size);
LUAI_FUNC void rstack_link (lua_State *L, GCObject *o, lu_byte tt);

//LUAI_FUNC int rstack_getregion(lua_State *L, GCObject *o) {
LUAI_FUNC void rstack_reject(lua_State *L, GCObject *src);

#define must_reject(parent,child) \
  ((parent)->gch.region < (child)->gch.region)

#endif
