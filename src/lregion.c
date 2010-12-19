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

static void buf_resize(lua_State *L, RStack *rs, size_t nsize) {
  luaM_reallocvector(L, rs->rbuf.head, rs->rbuf.size, nsize, RObject);
  rs->rbuf.last = rs->rbuf.head + nsize;
  rs->rbuf.size = nsize;
}


static void buf_fix (RStack *rs, RObject *ohead) {
  Region *r = rs->regions, *last = rs->creg + 1;
  ptrdiff_t diff = rs->rbuf.head - ohead;
  for (; r != last; r++) {
    r->base += diff;
    r->top += diff;
  }
}


void rstack_init (lua_State *L) {
  RStack *rs = rstack(L);
  rs->rbuf.head = rs->rbuf.last = NULL;
  rs->rbuf.size = 0;
  buf_resize(L, rs, RStack_MINBUFSIZE);
  rs->cregnum = 0;
  rs->creg = rs->regions;
  rs->creg->top = rs->creg->base = rs->rbuf.head;
}


void rstack_close (lua_State *L) {
  RStack *rs = rstack(L);
  lua_assert(rs->cregnum == 0);
  lua_assert(rs->creg->top == rs->rbuf.head);
  buf_resize(L, rs, 0);
}


void region_new (RStack *rs) {
  RObject *top = rs->creg->top;
  Region *r = ++rs->creg;
  ++rs->cregnum;
  lua_assert(rs->cregnum > 0 && rs->cregnum < RStack_REGIONS);
  r->base = r->top = top;
}


void region_renew_ (RStack *rs, Region *creg, RObject *base, RObject *top) {
  creg->top = base;
  lua_assert(0 < rs->cregnum && rs->cregnum < RStack_REGIONS);
  do {
    GCObject *o = (--top)->body;
    if (o)
      freeobj(rs->state, o);
  } while (top != base);
}


void region_free (RStack *rs) {
  Region *creg = rs->creg;
  RObject *top = creg->top;
  RObject *base = creg->base;
  lua_assert(0 < rs->cregnum && rs->cregnum < RStack_REGIONS);
  --rs->cregnum;
  --rs->creg;
  while (top != base) {
    GCObject *o = (--top)->body;
    if (o)
      freeobj(rs->state, o);
  }
  lua_assert(creg->top == base);
}


void *rstack_alloc (lua_State *L, size_t size) {
  RStack *rs = rstack(L);
  Region *r = check_exp(rs->cregnum > 0, rs->creg);
  RObject *top = r->top;
  if (top == rs->rbuf.last) {
    RObject *ohead = rs->rbuf.head;
    buf_resize(L, rs, rs->rbuf.size * 2);
    buf_fix(rs, ohead);
    top = r->top;
  }
  top->body = luaM_malloc(L, size);
  ++r->top;
  return top->body;
}


static RObject *rstack_getrobj (RStack *rs, GCObject *o) {
  int regnum = get_regnum(o);
  Region *r = &rs->regions[regnum];
  RObject *top = r->top, *base = r->base;
  lua_assert(regnum > 0 && regnum < RStack_REGIONS);
  while (top != base) {
    --top;
    if (top->body == o)
      return top;
  }
  return NULL;
}


void rstack_reject (lua_State *L, GCObject *src) {
  RStack *rs = rstack(L);
  RObject *robj = rstack_getrobj(rs, src);
  lua_assert(robj && src == robj->body);
  luaC_link(L, src, src->gch.tt);
  switch(src->gch.tt) {
    case LUA_TTABLE:
      luaH_reject(L, gco2h(src));
      break;
    //case LUA_TUSERDATA:
    //  luaS_rstack2heapu(L, rawgco2u(src));
    //  break;
    // TODO: implement
    default:
      lua_assert(0);
  }
  robj->body = NULL;
}

void rstack_link (lua_State *L, GCObject *o, lu_byte tt) {
  global_State *g = G(L);
  RStack *rs = rstack(L);
  o->gch.tt = tt;
  o->gch.next = NULL;
  o->gch.marked = luaC_white(g);
  set_regnum(o, rs->cregnum);
}
