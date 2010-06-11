#!/bin/sh

function massif() {
    valgrind --tool=massif --time-unit=B --massif-out-file=$*
}
massif massif-original.out ../../src/bin/lua-original FileLoop.lua
massif massif-stackalloc.out ../../src/bin/lua-master FileLoop.lua
