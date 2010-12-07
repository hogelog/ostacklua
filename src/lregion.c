#define lregion_c
#define LUA_CORE

#include "lregion.h"
#include "lstate.h"
#include "lgc.h"
#include "ltable.h"
#include "lfunc.h"
#include "lstring.h"
#include "ldo.h"

static void freeobj (lua_State *L, GCObject *o) {
  global_State *g = G(L);
  lua_assert(is_robj(o));
  switch (o->gch.tt) {
    case LUA_TPROTO: luaF_freeproto(L, gco2p(o)); break;
    case LUA_TFUNCTION: luaF_freeclosure(L, gco2cl(o)); break;
    case LUA_TUPVAL: luaF_freeupval(L, gco2uv(o)); break;
    case LUA_TTABLE: luaH_free(L, gco2h(o)); break;
    case LUA_TTHREAD: {
      lua_assert(gco2th(o) != L && gco2th(o) != G(L)->mainthread);
      luaE_freethread(L, gco2th(o));
      break;
    }
    case LUA_TSTRING: {
      G(L)->strt.nuse--;
      luaM_freemem(L, o, sizestring(gco2ts(o)));
      break;
    }
    case LUA_TUSERDATA: {
      const Udata *udata = rawgco2u(o);
      const TValue *tm = fasttm(L, udata->uv.metatable, TM_GC);
      if (tm != NULL) {
        lu_byte oldah = L->allowhook;
        lu_mem oldt = g->GCthreshold;
        L->allowhook = 0;  /* stop debug hooks during GC tag method */
        g->GCthreshold = 2*g->totalbytes;  /* avoid GC steps */
        setobj2s(L, L->top, tm);
        setuvalue(L, L->top+1, udata);
        L->top += 2;
        luaD_call(L, L->top - 2, 0);
        L->allowhook = oldah;  /* restore hooks */
        g->GCthreshold = oldt;  /* restore threshold */
      }
      luaM_freemem(L, o, sizeudata(gco2u(o)));
      break;
    }
    default: lua_assert(0);
  }
}

static void buf_resize(lua_State *L, OStack *os, size_t nsize) {
  RObject *old = os->rbuf.head;
  luaM_reallocvector(L, os->rbuf.head, os->rbuf.size, nsize, RObject);
  os->rbuf.last = os->rbuf.head + nsize;
  os->rbuf.size = nsize;
}

static void buf_fix(OStack *os, RObject *ohead) {
  Region *r = os->regions, *last = os->creg + 1;
  ptrdiff_t diff = os->rbuf.head - ohead;
  for (; r != last; r++) {
    r->base += diff;
    r->top += diff;
  }
}

void ostack_init(lua_State *L) {
  OStack *os = ostack(L);
  os->rbuf.head = os->rbuf.last = NULL;
  os->rbuf.size = 0;
  buf_resize(L, os, OSTACK_MINBUFSIZE);
  os->cregnum = 0;
  os->creg = os->regions;
  os->creg->top = os->creg->base = os->rbuf.head;
}

void ostack_close(lua_State *L) {
  OStack *os = ostack(L);
  while (os->cregnum > 0)
    region_free(L);
  buf_resize(L, os, 0);
}

void region_new(lua_State *L) {
  OStack *os = ostack(L);
  RObject *top = os->creg->top;
  Region *r = os->creg = &os->regions[++os->cregnum];
  lua_assert(os->cregnum > 0 && os->cregnum < OSTACK_REGIONS);
  r->base = top;
}

void region_renew(lua_State *L) {
  OStack *os = ostack(L);
  Region *r = os->creg;
  RObject *top = r->top;
  RObject *base = r->base;
  lua_assert(os->cregnum > 0 && os->cregnum < OSTACK_REGIONS);
  while (top != base) {
    GCObject *o = (--top)->body;
    if (top->body)
      freeobj(L, top->body);
  }
}

void region_free(lua_State *L) {
  OStack *os = ostack(L);
  Region *r = os->creg;
  RObject *top = r->top;
  RObject *base = r->base;
  lua_assert(os->cregnum > 0 && os->cregnum < OSTACK_REGIONS);
  while (top != base) {
    GCObject *o = (--top)->body;
    if (top->body)
      freeobj(L, top->body);
  }
  os->creg = &os->regions[--os->cregnum];
}

void *ostack_alloc(lua_State *L, size_t size) {
  OStack *os = ostack(L);
  if (os->cregnum == 0) {
    return luaM_malloc(L, size);
  }
  else {
    Region *r = os->creg;
    RObject *top = r->top;
    if (top == os->rbuf.last) {
      RObject *ohead = os->rbuf.head;
      buf_resize(L, os, os->rbuf.size * 2);
      buf_fix(os, ohead);
      top = r->top;
    }
    top->body = luaM_malloc(L, size);
    ++r->top;
    return top->body;
  }
}

static RObject *ostack_getrobj(OStack *os, GCObject *o) {
  int regnum = get_regnum(o);
  Region *r = &os->regions[regnum];
  RObject *top = r->top, *base = r->base;
  lua_assert(regnum > 0 && regnum < OSTACK_REGIONS);
  while (top != base) {
    --top;
    if (top->body == o)
      return top;
  }
  return NULL;
}

/*
int ostack_getregion(lua_State *L, GCObject *o) {
  OStack *os = ostack(L);
  int region = os->cregnum;
  Region *r = &os->regions[region];
  while (region >= 0) {
    if (region_getrobj(r, o))
      return region;
    r = &os->regions[--region];
  }
  lua_assert(0);
  return -1;
}
*/

/*
static RObject *ostack_getrobj(OStack *os, GCObject *O) {
  RObject *top = os->rbuf.top, *base = os->rbuf.head;
  while (top != base) {
    --top;
    if (top->body == o)
      return top;
  }
  return NULL;
}
*/

void ostack_reject(lua_State *L, GCObject *src) {
  OStack *os = ostack(L);
  RObject *robj = ostack_getrobj(os, src);
  lua_assert(robj && src == robj->body);
  switch(src->gch.tt) {
    //case LUA_TTABLE:
    //  luaH_ostack2heap(L, gco2h(src));
    //  break;
    //case LUA_TUSERDATA:
    //  luaS_ostack2heapu(L, rawgco2u(src));
    //  break;
    // TODO: implement
    default:
      lua_assert(0);
  }
  robj->body = NULL;
  luaC_link(L, src, src->gch.tt);
}
