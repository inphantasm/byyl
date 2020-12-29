.PHONY: all clean main run git testall debug t0 m0 t1 m1 t2 m2 t3 m3
all: run
main.tab.cc: main.y
	bison -o main.tab.cc -v main.y
lex.yy.cc: main.l
	flex -o lex.yy.cc main.l
main:
	g++ $(shell ls *.cpp *.cc) -o main.out
run: lex.yy.cc main.tab.cc main
git:
	git add .
	git commit -m "$(shell date +%Y/%m/%d-%T)"
	git push -f origin HW6
testall:run
	for file in $(basename $(shell find test/*.c)); \
	do \
		./main.out <$$file.c >$$file.res; \
	done
clean:
	rm -f *.output *.yy.* *.tab.* *.out test/*.res
t0:run
	./main.out <test/0.c >test/0.res
	./main.out <test/0.c >test/0.s
	rm -f *.output *.yy.* *.tab.* *.out
m0:
	gcc test/0.s -m32 -o test/0.out
	qemu-i386 test/0.out <test/testin >test/ASM0.res
	rm -f test/*.out test/*.s
t1:run
	./main.out <test/1.c >test/1.res
	./main.out <test/1.c >test/1.s
	rm -f *.output *.yy.* *.tab.* *.out
m1:
	gcc test/1.s -m32 -o test/1.out
	qemu-i386 test/1.out <test/testin >test/ASM1.res
	rm -f test/*.out test/*.s
t2:run
	./main.out <test/2.c >test/2.res
	./main.out <test/2.c >test/2.s
	rm -f *.output *.yy.* *.tab.* *.out
m2:
	gcc test/2.s -m32 -o test/2.out
	qemu-i386 test/2.out >test/ASM2.res
	rm -f test/*.out test/*.s
t3:run
	./main.out <test/3.c >test/3.res
	./main.out <test/3.c >test/3.s
	rm -f *.output *.yy.* *.tab.* *.out
m3:
	gcc test/3.s -m32 -o test/3.out
	qemu-i386 test/3.out >test/ASM3.res
	rm -f test/*.out test/*.s