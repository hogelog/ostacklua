#ifndef lostack_h
#define lostack_h
#include <stdlib.h>

#include "lobject.h"

typedef struct Frame {
  /*CommonHeader;*/
  struct Frame *prevframe;
  GCObject *top;
  size_t index;
  size_t framenum;
} Frame;
typedef struct Slot {
  void *start;
  void *end;
  size_t size;
} Slot;
typedef struct OStack {
  Slot *slots;
  size_t slotsnum;
  Frame *frames;
  size_t framenum;
  Frame *last;
  void *top;
  size_t index;
  GCObject *lastobj;
} OStack;

#define OSTACK_MINSLOTSIZE 1024
#define OSTACK_MAXFRAME 256

#define ostack_new(L,t,c) ((t *)ostack_alloc(L, sizeof(t)*(c)))

#define inrange(s,e,o) \
  (cast(void *,(s)) <= cast(void *,(o)) && cast(void *,(o)) < cast(void *, (e)))

LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size);
LUAI_FUNC void *ostack_lalloc(lua_State *L, size_t size);
LUAI_FUNC Frame *ostack_newframe(lua_State *L);
LUAI_FUNC Frame *ostack_closeframe(lua_State *L, Frame *f);
LUAI_FUNC OStack *ostack_init(lua_State *L);
LUAI_FUNC void ostack_close(lua_State *L);

LUAI_FUNC int ostack_inframe_detail(OStack *os, Frame *frame, void *p);
LUAI_FUNC Frame *ostack_getframe(lua_State *L, GCObject *o);
LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src);
LUAI_FUNC void lua_ostack_fixptr(lua_State *L, GCObject *h, GCObject *s);

#define ostack_getframenum(L,o) (ostack_getframe(L,obj2gco(o))->framenum)

#define inframe(os,f,o) ( \
    !(f) || \
    (((f)->index==(os)->index && inrange((f)->top, (os)->top, (o))) || \
     ((f)->index < (os)->index && \
      (inrange((os)->slots[(os)->index].start, (os)->top, (o)) || \
       inrange((f)->top, (os)->slots[(f)->index].end, (o)))) || \
     ((f)->index+1 < (os)->index && ostack_inframe_detail((os),(f),(o)))))
#define inlastframe(os,o) inframe((os),(os)->last,o)

#define ostack_pushgco(os,o) { \
    (o)->gch.next = (os)->lastobj; \
    (os)->lastobj = (o); \
  }

#define isneedcopy(L,t,o) (onstack(o) && \
     ((t)->onstack==0 || ostack_getframenum(L,t)<ostack_getframenum(L,o)))

#endif
