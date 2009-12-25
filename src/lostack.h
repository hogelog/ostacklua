#ifndef lostack_h
#define lostack_h
#include <stdlib.h>

#include "lobject.h"

typedef struct SObject {
  GCObject *body;
} SObject;
typedef struct Frame {
  struct Frame *prevframe;
  size_t findex;
  SObject *base, *top;
} Frame;
typedef struct OStack {
  Frame *frames;
  size_t findex;
  Frame *lastframe;
  SObject *sobjs, *sobjs_last;
  SObject *top;
  size_t sobjsnum;
} OStack;

#define OSTACK_MAXFRAME 256
#define OSTACK_MINSOBJECTS 1024

#define ostack_new(L,t) cast(t *, ostack_alloc(L, sizeof(t)))

LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size);
LUAI_FUNC Frame *ostack_newframe(lua_State *L);
LUAI_FUNC Frame *ostack_closeframe(lua_State *L, Frame *f);
LUAI_FUNC OStack *ostack_init(lua_State *L);
LUAI_FUNC void ostack_close(lua_State *L);

LUAI_FUNC SObject *ostack_getsobj(OStack *os, Frame *frame, GCObject *o);
LUAI_FUNC Frame *ostack_getframe(lua_State *L, GCObject *o);
LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src);
LUAI_FUNC void lua_ostack_fixptr(lua_State *L, GCObject *h, GCObject *s);

#define ostack_getframenum(L,o) (ostack_getframe(L,obj2gco(o))->findex)

#define isneedcopy(L,t,o) (is_onstack(o) && \
     (!is_onstack(obj2gco(t)) || ostack_getframenum(L,t)<ostack_getframenum(L,o)))

#endif
