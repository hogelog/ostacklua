
#include "lostack.h"
#include "lstate.h"
#include "lgc.h"
#include "ltable.h"

LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size) {
  OStack *os = ostack(L);
  void *new = os->top;
  void *newtop = (void*)((char*)new + size);
  os->top = newtop;
  return new;
}

LUAI_FUNC Frame *ostack_newframe(lua_State *L) {
  OStack *os = ostack(L);
  void *ptop = os->top;
  size_t pindex = os->index;
  Frame *f = &os->frames[os->framenum];
  f->prevframe = os->last;
  f->top = ptop;
  f->index = pindex;
  f->framenum = os->framenum;
  os->last = f;
  os->framenum += 1;
  return f;
}

LUAI_FUNC Frame *ostack_closeframe(lua_State *L, Frame *f) {
  OStack *os = ostack(L);
  os->top = f->top;
  os->index = f->index;
  os->last = f->prevframe;
  os->framenum = f->framenum;
  return f;
}

LUAI_FUNC OStack *ostack_init(lua_State *L) {
  OStack *os = ostack(L);
  os->slots = malloc(sizeof(Slot));
  os->slots[0].start = malloc(OSTACK_MINSLOTSIZE);
  os->slots[0].end = (void*)((char*)os->slots[0].start + OSTACK_MINSLOTSIZE);
  os->slots[0].size = OSTACK_MINSLOTSIZE;
  os->slotsnum = 1;
  os->frames = malloc(sizeof(Frame)*OSTACK_MAXFRAME);
  os->framenum = 0;
  os->last = NULL;
  os->top = os->slots[0].start;
  os->index = 0;
  os->lastobj = (GCObject *)malloc(sizeof(GCObject));
  os->lastobj->gch.next = NULL;
  return os;
}

LUAI_FUNC void ostack_close(lua_State *L) {
  OStack *os = ostack(L);
  int i;
  while (os->last)
    ostack_closeframe(L, os->last);
  for (i=os->slotsnum-1;i>=0;--i)
    free(os->slots[i].start);
  free(os->slots);
  os->slots = NULL;
}
LUAI_FUNC int ostack_inframe_detail(OStack *os, Frame *frame, void *p) {
  size_t i;
  lua_assert(frame && (frame->index+1 < os->index));
  for (i=frame->index+1;i<os->index;i++) {
    Slot *slot = &os->slots[i];
    if (inrange(slot->start, slot->end, p))
      return 1;
  }
  return 0;
}

LUAI_FUNC Frame *ostack_getframe(lua_State *L, GCObject *o) {
  OStack *os = ostack(L);
  Frame *f = os->last;
  for (;f && !inframe(os,f,o);f=f->prevframe) ;
  return f;
}

LUAI_FUNC GCObject *lua_dupgcobj(lua_State *L, GCObject *src) {
  GCObject *dup = NULL;
  switch(src->gch.tt) {
    case LUA_TTABLE: {
      dup = obj2gco(luaH_duphobj(L, &src->h));
      break;
    }
    // TODO: implement
    case LUA_TSTRING:
    case LUA_TFUNCTION:
    case LUA_TUSERDATA:
    case LUA_TTHREAD:
    case LUA_TPROTO:
    case LUA_TUPVAL:
    default:
      lua_assert(0); 
      return NULL;
  }
  lua_ostack_fixptr(L, dup, src);
  return dup;
}

LUAI_FUNC void lua_ostack_fixptr(lua_State *L, GCObject *h, GCObject *s) {
  OStack *os = ostack(L);
  TValue *t;
  Frame *f = ostack_getframe(L, s);
  GCObject *o = f ? f->top : obj2gco(os->slots[0].start);

  while (o != os->lastobj) {
    lua_assert(onstack(o));
    switch(o->gch.tt) {
      case LUA_TTABLE: {
        luaH_ostack_fixptr(L, &o->h, h, s);
        break;
      }
      // TODO: implement
      case LUA_TSTRING:
      case LUA_TFUNCTION:
      case LUA_TUSERDATA:
      case LUA_TTHREAD:
      case LUA_TPROTO:
      case LUA_TUPVAL:
      default:
        lua_assert(0); 
        return ;
    }
    o = o->gch.next;
  }
  for (t=L->base;t < L->top;t++) {
    if (iscollectable(t) && gcvalue(t)==s) {
      t->value.gc = h;
    }
  }
}
