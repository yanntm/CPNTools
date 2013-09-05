all: pre

install: all
	cp pre.exe /cygdrive/c/WINNT

pre: main.c lex.yy.c
	gcc -o pre main.c lex.yy.c -lfl

lex.yy.c: include.l
	flex include.l
