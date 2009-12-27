
#define lostack_c
#define LUA_CORE

#include "lostack.h"
#include "lstate.h"
#include "lgc.h"
#include "ltable.h"
#include "lfunc.h"
#include "lstring.h"

static void freeobj (lua_State *L, GCObject *o) {
  lua_assert(is_onstack(o));
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
      luaM_freemem(L, o, sizeudata(gco2u(o)));
      break;
    }
    default: lua_assert(0);
  }
}

static void sobjs_resize(lua_State *L, OStack *os, size_t nsize) {
  SObject *old = os->sobjs;
  ptrdiff_t diff;
  Frame *f = os->lastframe;
  luaM_reallocvector(L, os->sobjs, os->sobjsnum, nsize, SObject);
  os->sobjs_last = os->sobjs + nsize;
  diff = os->sobjs - old;
  os->sobjsnum = nsize;
  os->top += diff;
  while (f) {
    f->base += diff;
    f->top += diff;
    f = f->prevframe;
  }
}
static void frames_resize(lua_State *L, OStack *os, size_t nsize) {
  luaM_reallocvector(L, os->frames, os->framesnum, nsize, Frame);
  os->framesnum = nsize;
}

LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size) {
  OStack *os = ostack(L);
  SObject *head;
  Frame *f = os->lastframe;
  if (os->top == os->sobjs_last) {
    sobjs_resize(L, os, os->sobjsnum * 2);
  }
  head = os->top;
  head->body = luaM_malloc(L, size);
  f->top = os->top = os->top + 1;
  return head->body;
}

LUAI_FUNC Frame *ostack_newframe(lua_State *L) {
  OStack *os = ostack(L);
  Frame *f = &os->frames[os->findex];
  f->prevframe = os->lastframe;
  f->findex = os->findex;
  f->base = f->top = os->top;
  os->lastframe = f;
  os->findex += 1;
  lua_assert(os->findex < os->framesnum);
  return f;
}

LUAI_FUNC Frame *ostack_closeframe(lua_State *L, int findex) {
  OStack *os = ostack(L);
  Frame *f = &os->frames[findex];
  SObject *top = os->top, *base = f->base;
  while (top != base) {
    top -= 1;
    if (top->body) {
      freeobj(L, top->body);
    }
  }
  os->lastframe = f - 1;
  os->findex = findex;
  os->top = f->base;
  return os->lastframe;
}

LUAI_FUNC OStack *ostack_init(lua_State *L) {
  OStack *os = ostack(L);
  os->framesnum = 0;
  os->findex = 0;
  os->lastframe = NULL;
  frames_resize(L, os, OSTACK_MINFRAME);
  os->sobjs = NULL;
  os->sobjsnum = 0;
  os->top = NULL;
  sobjs_resize(L, os, OSTACK_MINSOBJECTS);
  ostack_newframe(L);
  return os;
}

LUAI_FUNC void ostack_close(lua_State *L) {
  OStack *os = ostack(L);
  ostack_closeframe(L, 0);
  luaM_freearray(L, os->frames, os->framesnum, Frame);
  luaM_freearray(L, os->sobjs, os->sobjsnum, SObject);
}
LUAI_FUNC SObject *ostack_getsobj(OStack *os, Frame *frame, GCObject *o) {
  SObject *top = check_exp(frame, frame->top), *base = frame->base;
  while (top != base) {
    top -= 1;
    if (top->body == o)
      return top;
  }
  return NULL;
}

LUAI_FUNC Frame *ostack_getframe(lua_State *L, GCObject *o) {
  OStack *os = ostack(L);
  Frame *f = os->lastframe;
  lua_assert(is_onstack(o));
  lua_assert(f);
  while (f) {
    if (ostack_getsobj(os, f, o))
      return f;
    f = f->prevframe;
  }
  lua_assert(0);
  return NULL;
}

LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src) {
  OStack *os = ostack(L);
  Frame *f = os->lastframe;
  SObject *head;
  lua_assert(f);
  while (!(head = ostack_getsobj(os, f, src))) {
    f = f->prevframe;
    lua_assert(f);
  }
  lua_assert(head);
  lua_assert(head->body && src == head->body);
  switch(src->gch.tt) {
    case LUA_TTABLE:
      luaH_ostack2heap(L, &src->h);
      break;
    // TODO: implement
    default:
      lua_assert(0);
  }
  head->body = NULL;
  luaC_link(L, src, src->gch.tt);
  return src;
}
