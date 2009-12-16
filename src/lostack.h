#ifndef lostack_h
#define lostack_h
#include <stdlib.h>

#include "lobject.h"

typedef struct LinkHeader {
  GCObject *body;
} LinkHeader;
typedef struct Frame {
  struct Frame *prevframe;
  size_t framenum;
  LinkHeader *base, *top;
} Frame;
typedef struct OStack {
  Frame *frames;
  size_t framenum;
  Frame *lastframe;
  LinkHeader *links, *top;
} OStack;

#define ONSTACKBIT 0

#define OSTACK_MAXFRAME 256
#define OSTACK_MAXLINKS (10*1024)

#define ostack_new(L,t) cast(t *, ostack_alloc(L, sizeof(t)))

#define inrange(s,e,o) \
  (cast(void *,(s)) <= cast(void *,(o)) && cast(void *,(o)) < cast(void *, (e)))

LUAI_FUNC void *ostack_alloc(lua_State *L, size_t size);
LUAI_FUNC Frame *ostack_newframe(lua_State *L);
LUAI_FUNC Frame *ostack_closeframe(lua_State *L, Frame *f);
LUAI_FUNC OStack *ostack_init(lua_State *L);
LUAI_FUNC void ostack_close(lua_State *L);

LUAI_FUNC LinkHeader *ostack_getlinkheader(OStack *os, Frame *frame, GCObject *o);
LUAI_FUNC Frame *ostack_getframe(lua_State *L, GCObject *o);
LUAI_FUNC GCObject *ostack2heap(lua_State *L, GCObject *src);
LUAI_FUNC void lua_ostack_fixptr(lua_State *L, GCObject *h, GCObject *s);

#define ostack_getframenum(L,o) (ostack_getframe(L,obj2gco(o))->framenum)

#define isneedcopy(L,t,o) (onstack(o) && \
     ((t)->onstack==0 || ostack_getframenum(L,t)<ostack_getframenum(L,o)))

#endif
