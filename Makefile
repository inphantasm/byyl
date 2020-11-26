.PHONY: all clean main run test debug t0 t1 t2 t3
all: run
main.tab.cc: main.y
	bison -o main.tab.cc -v main.y
lex.yy.cc: main.l
	flex -o lex.yy.cc main.l
main:
	g++ $(shell ls *.cpp *.cc) -o main.out
run: lex.yy.cc main.tab.cc main
test:run
	for file in $(basename $(shell find test/*.c)); \
	do \
		./main.out <$$file.c >$$file.res; \
	done
clean:
	rm -f *.output *.yy.* *.tab.* *.out test/*.res
t0:run
	./main.out <test/0.c >test/0.res
	rm -f *.output *.yy.* *.tab.* *.out
t1:run
	./main.out <test/1.c >test/1.res
	rm -f *.output *.yy.* *.tab.* *.out
t2:run
	./main.out <test/2.c >test/2.res
	rm -f *.output *.yy.* *.tab.* *.out
t3:run
	./main.out <test/3.c >test/3.res
	rm -f *.output *.yy.* *.tab.* *.out