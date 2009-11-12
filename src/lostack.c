
#include "lostack.h"
#include "lstate.h"
#include "lgc.h"
#include "ltable.h"

static Slot *addslot(OStack *os, size_t slotsize) {
  size_t n = os->slotsnum;
  os->slots = realloc(os->slots, (n+1)*sizeof(Slot));
  os->slots[n].start = malloc(slotsize);
  os->slots[n].end = (void*)((char*)os->slots[n].start + slotsize);
  os->slotsnum = n+1;
  return os->slots[n].start;
}
static size_t ostack_grow(OStack *os) {
  size_t slotsnum = os->slotsnum;
  size_t newsize = 0;
  size_t i;
  for(i=0;i<slotsnum;++i) {
    Slot *slot = &os->slots[i];
    newsize += (char*)slot->end - (char*) slot->start;
  }
  addslot(os, newsize);
  return os->slotsnum;
}
LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size) {
  OStack *os = ostack(L);
  void *new = os->top;
  void *newtop = (void*)((char*)new + size);
  Slot *curslot = &os->slots[os->index];
  while (newtop > curslot->end) {
    ++os->index;
    if (os->index == os->slotsnum)
      ostack_grow(os);
    os->top = os->slots[os->index].start;
    curslot = &os->slots[os->index];
    new = curslot->start;
    newtop = (void*)((char*)new + size);
  }
  os->top = newtop;
  return new;
}
LUAI_FUNC void *ostack_lalloc(lua_State *L, size_t size) {
  OStack *os = ostack(L);
  FObject *fo;
  Frame *f = os->last;
  if (!f) return NULL;
  fo = malloc(sizeof(FObject)+size);
  return (void*)(fo + 1);
}
LUAI_FUNC Frame *ostack_newframe(lua_State *L) {
  OStack *os = ostack(L);
  void *ptop = os->top;
  size_t pindex = os->index;
  Frame *f = ostack_alloc(L, sizeof(Frame));
  f->tt = LUA_TFRAME;
  f->onstack = 1;
  f->prevframe = os->last;
  f->top = ptop;
  f->index = pindex;
  f->marked = luaC_white(G(L));
  os->last = f;
  ostack_setlastobj(os, obj2gco(f));
  return f;
}
LUAI_FUNC Frame *ostack_closeframe(lua_State *L, Frame *f) {
  OStack *os = ostack(L);
  os->top = f->top;
  os->index = f->index;
  os->last = f->prevframe;
  return f;
}
LUAI_FUNC OStack *ostack_init(lua_State *L) {
  OStack *os = ostack(L);
  os->slots = malloc(sizeof(Slot));
  os->slots[0].start = malloc(OSTACK_MINSLOTSIZE);
  os->slots[0].end = (void*)((char*)os->slots[0].start + OSTACK_MINSLOTSIZE);
  os->slotsnum = 1;
  os->last = NULL;
  os->top = os->slots[0].start;
  os->index = 0;
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
LUAI_FUNC Frame *ostack_fmove(lua_State *L, Frame *to, FObject *fo) {
  if (fo->next) fo->next->prev = fo->prev;
  fo->prev->next = fo->next;
  return to;
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
LUAI_FUNC GCObject *lua_dupgcobj(lua_State *L, GCObject *src) {
  GCObject *dup = NULL;
  switch(src->gch.tt) {
    case LUA_TTABLE: {
      //return obj2gco(luaH_duphobj(L, &src->h));
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
    case LUA_TFRAME:
    default:
      lua_assert(0); 
      return NULL;
  }
  lua_ostack_refix(L, dup, src);
  return dup;
}
LUAI_FUNC void lua_ostack_refix(lua_State *L, GCObject *h, GCObject *s) {
  OStack *os = ostack(L);
  GCObject *o = obj2gco(os->slots[0].start);
  TValue *t;
  while (o) {
    lua_assert(onstack(o));
    switch(o->gch.tt) {
      case LUA_TTABLE: {
        luaH_ostack_refix(L, &o->h, h, s);
        break;
      }
      case LUA_TFRAME: break;
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
  for (t=L->stack;t < L->stack_last;t++) {
    if (iscollectable(t) && gcvalue(t)==s) {
      t->value.gc = h;
    }
  }
}
LUAI_FUNC Frame *ostack_getframe(lua_State *L, GCObject *o) {
  OStack *os = ostack(L);
  Frame *f = os->last;
  return f;
}
