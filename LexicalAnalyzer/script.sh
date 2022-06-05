#!/bin/bash
flex milex.l
gcc lex.yy.c -lfl
./a.out test.fb
