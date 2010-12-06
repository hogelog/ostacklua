#define lregion_c
#define LUA_CORE

#include "lregion.h"
#include "lstate.h"
#include "lgc.h"
#include "ltable.h"
#include "lfunc.h"
#include "lstring.h"
#include "ldo.h"

static void buf_resize(lua_State *L, OStack *os, size_t nsize) {
  RObject *old = os->buf.head;
  luaM_reallocvector(L, os->buf.head, os->buf.size, nsize, RObject);
  os->buf.last = os->top + nsize;
  os->buf.size = nsize;
}

static void buf_fix(OStack *os, RObject *ohead) {
  int i;
  ptrdiff_t diff = os->buf.head - ohead;
  os->buf.top += diff;
  for (i=os->cur_region;i>=0;i--) {
    Region *r = &os->regions[i];
    r->base += diff;
  }
}

OStack *ostack_init(lua_State *L) {
  OStack *os = ostack(L);
  os->cur_region = -1;
  os->buf.head = os->buf.last = os->buf.top = NULL;
  os->buf.size = 0;
  buf_resize(L, os, OSTACK_MINBUFSIZE);
  buf_fix(os, NULL);
}

void ostack_close(lua_State *L) {
  OStack *os = ostack(L);
  ostack_closeregion(L, 0);
  buf_resize(L, os, 0);
}

int region_new(lua_State *L) {
  OStack *os = ostack(L);
  Region *r = &os->regions[++os->cur_region];
  lua_assert(os->cur_region < OSTACK_REGIONS);
  r->base = os->buf.top;
  return os->cur_region;
}

int region_renew(lua_State *L) {
  OStack *os = ostack(L);
  Region *r = os->regions[os->cur_region];
  RObject *top = os->buf.top;
  RObject *base = r->base;
  while (top != base) {
    --top;
    // TODO: free(top);
  }
  os->buf.top = top;
  return os->cur_region;
}

void region_close(lua_State *L) {
  OStack *os = ostack(L);
  Region *r = os->regions[os->cur_region];
  RObject *top = os->buf.top;
  RObject *base = r->base;
  while (top != base) {
    --top;
    // TODO: free(top);
  }
  os->buf.top = top;
  return --os->cur_region;
}

void *ostack_alloc(lua_State *L, size_t size) {
  OStack *os = ostack(L);
  Region *r = os->regions[os->cur_region];
  RObject *top = os->buf.top;
  if (top == os->buf.last) {
    RObject *ohead = os->buf.head;
    buf_resize(L, os, os->buf.size * 2);
    buf_fix(os, ohead);
    top = os->buf.top;
  }
  top->body = luaM_malloc(L, size);
  ++os->buf.top;
  return top->body;
}
