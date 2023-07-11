#!/bin/bash
bison -dv misint.y
flex milex.l
gcc -g misint.tab.c symbTable.c lex.yy.c -lfl
./a.out test.fb
