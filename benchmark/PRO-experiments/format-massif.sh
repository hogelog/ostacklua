#!/bin/sh

perl -le'$/="#-----------";while(<>){print($1, " ", $2+$3) if/time=(\d+)\nmem_heap_B=(\d+)\nmem_heap_extra_B=(\d+)/}' $1
