############################
# Date: 28/05/2015         #
# Project: Compiler        #
############################


all: mycompiler

mycompiler: mycompiler.tab.c lex.yy.c
	gcc -o mycompiler lex.yy.c mycompiler.tab.c -lfl

mycompiler.tab.c:
	bison -d -v -r all mycompiler.y

lex.yy.c:
	flex mycompiler.l

clean:
	rm lex.yy.c mycompiler.tab.c mycompiler.tab.h
	rm mycompiler.output mycompiler out_c.c c_output.c
	rm *~
