#!/bin/sh

set -e

ocamlbuild -cflags -w,P -cflags "-cc clang" aurochs_tool.native $@
