
#define lostack_c
#define LUA_CORE

#include "lostack.h"
#include "lstate.h"
#include "lgc.h"
#include "ltable.h"
#include "lfunc.h"
#include "lstring.h"

static void freeobj (lua_State *L, GCObject *o) {
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

LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size) {
  OStack *os = ostack(L);
  //LinkHeader *head = luaM_new(L, LinkHeader);
  LinkHeader *head = malloc(sizeof(LinkHeader));
  Frame *f = os->lastframe;
  head->body = luaM_malloc(L, size);
  head->prev = &f->list;
  head->next = f->list.next;
  f->list.next->prev = head;
  f->list.next = head;
  return head->body;
}

LUAI_FUNC Frame *ostack_newframe(lua_State *L) {
  OStack *os = ostack(L);
  Frame *f = &os->frames[os->framenum];
  f->prevframe = os->lastframe;
  f->framenum = os->framenum;
  f->list.prev = f->list.next = &f->list;
  os->lastframe = f;
  os->framenum += 1;
  return f;
}

LUAI_FUNC Frame *ostack_closeframe(lua_State *L, Frame *f) {
  OStack *os = ostack(L);
  LinkHeader *list = &f->list;
  LinkHeader *head = list->next;
  while (head != list) {
    head = head->next;
    freeobj(L, head->prev->body);
    free(head->prev);
  }
  os->lastframe = f->prevframe;
  os->framenum = f->framenum;
  return f;
}

LUAI_FUNC OStack *ostack_init(lua_State *L) {
  OStack *os = ostack(L);
  os->frames = luaM_newvector(L, OSTACK_MAXFRAME, Frame);
  os->framenum = 0;
  os->lastframe = NULL;
  return os;
}

LUAI_FUNC void ostack_close(lua_State *L) {
  OStack *os = ostack(L);
  while (os->lastframe)
    ostack_closeframe(L, os->lastframe);
  luaM_freearray(L, os->frames, OSTACK_MAXFRAME, Frame);
}
LUAI_FUNC LinkHeader *ostack_getlinkheader(OStack *os, Frame *frame, GCObject *o) {
  LinkHeader *list, *head;
  lua_assert(frame);
  list = &frame->list;
  head = list->next;
  while (head != list) {
    if (head->body == o)
      return head;
    head = head->next;
  }
  return NULL;
}

LUAI_FUNC Frame *ostack_getframe(lua_State *L, GCObject *o) {
  OStack *os = ostack(L);
  Frame *f = os->lastframe;
  lua_assert(onstack(o));
  while (!ostack_getlinkheader(os, f, o)) {
    lua_assert(f);
    f = f->prevframe;
  }
  return f;
}

LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src) {
  OStack *os = ostack(L);
  Frame *f = os->lastframe;
  LinkHeader *head;
  while (!(head = ostack_getlinkheader(os, f, src))) {
    lua_assert(f);
    f = f->prevframe;
  }
  lua_assert(head);
  lua_assert(src == head->body);
  head->prev->next = head->next;
  head->next->prev = head->prev;
  free(head);
  luaC_link(L, src, src->gch.tt);
  return src;
}
