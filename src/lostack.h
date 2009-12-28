#ifndef lostack_h
#define lostack_h
#include <stdlib.h>

#include "lobject.h"

typedef struct SObject {
  GCObject *body;
} SObject;
typedef struct Frame {
  SObject *base, *top;
} Frame;
typedef struct OStack {
  Frame *frames;
  int framesnum, findex;
  SObject *sobjs, *sobjs_last;
  SObject *top;
  int sobjsnum;
} OStack;

#define OSTACK_MINFRAME 256
#define OSTACK_MINSOBJECTS 1024

#define ostack_new(L,t) cast(t *, ostack_alloc(L, sizeof(t)))

LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size);
LUAI_FUNC int ostack_newframe(lua_State *L);
LUAI_FUNC int ostack_closeframe(lua_State *L, int findex);
LUAI_FUNC OStack *ostack_init(lua_State *L);
LUAI_FUNC void ostack_close(lua_State *L);

LUAI_FUNC SObject *ostack_getsobj(OStack *os, Frame *frame, GCObject *o);
LUAI_FUNC int ostack_getframe(lua_State *L, GCObject *o);
LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src);

#define isneedcopy(L,t,o) (is_onstack(o) && \
     (!is_onstack(obj2gco(t)) || ostack_getframe(L,obj2gco(t))<ostack_getframe(L,o)))

#endif
