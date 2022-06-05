#!/bin/bash
bison -dv misint.y
flex milex.l
gcc misint.tab.c lex.yy.c -lfl
./a.out test.fb
