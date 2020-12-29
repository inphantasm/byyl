# COMMENT BEGIN	
#	I'm level 1 test.
# COMMENT END
# COMMENT: No more compilation error.
	.text
	.section	.rodata
STR0:
	.string "%c"
STR1:
	.string "%c"
STR2:
	.string "result is: %d\n"
STR3:
	.string "Have fun: %d\n"
	.text
	.globl	main
	.type	main, @function
main:
	pushl	%ebp
	movl	%esp, %ebp
	movl	$0, -4(%ebp)
	subl	$4, %esp
	movl	$0, -8(%ebp)
	subl	$4, %esp
	pushl	$10
	popl	%eax
	movl	%eax, -4(%ebp)
	pushl	$0
	popl	%eax
	movl	%eax, -8(%ebp)
	movl	$0, -12(%ebp)
	subl	$4, %esp
	leal	-12(%ebp), %eax
	pushl	%eax
	subl	$12, %ebp
	pushl	$STR0
	call	scanf
	addl	$12, %ebp
	addl	$8, %esp
	pushl	-12(%ebp)
	subl	$12, %ebp
	pushl	$STR1
	call	printf
	addl	$12, %ebp
	addl	$8, %esp
WS0:
	pushl	-4(%ebp)
	pushl	$0
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jle	.BB0
	pushl	$1
	jmp	.BB1
.BB0:
	pushl	$0
.BB1:
	pushl	-4(%ebp)
	pushl	$10
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jg	.BB2
	pushl	$1
	jmp	.BB3
.BB2:
	pushl	$0
.BB3:
	popl	%eax
	popl	%ebx
	addl	%eax, %ebx
	movl	$2, %eax
	cmpl	%ebx, %eax
	jne	.BB4
	pushl	$1
	jmp	.BB5
.BB4:
	pushl	$0
.BB5:
	pushl	-4(%ebp)
	pushl	$100
	popl	%ebx
	popl	%eax
	cltd
	idivl	%ebx
	pushl	%edx
	pushl	$10
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jne	.BB6
	pushl	$1
	jmp	.BB7
.BB6:
	pushl	$0
.BB7:
	popl	%eax
	popl	%ebx
	addl	%eax, %ebx
	movl	$0, %eax
	cmpl	%ebx, %eax
	je	.BB8
	pushl	$1
	jmp	.BB9
.BB8:
	pushl	$0
.BB9:
	popl	%eax
	cmpl	$1, %eax
	jne	WE0
	pushl	$1
	popl	%eax
	subl	-4(%ebp), %eax
	movl	$-1, %ebx
	imull	%ebx
	movl	%eax, -4(%ebp)
	pushl	$10
	popl	%eax
	movl	%eax, -4(%ebp)
	pushl	-4(%ebp)
	popl	%eax
	addl	-8(%ebp), %eax
	movl	%eax, -8(%ebp)
	pushl	-8(%ebp)
	pushl	$-10
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jle	.BB10
	pushl	$1
	jmp	.BB11
.BB10:
	pushl	$0
.BB11:
	popl	%eax
	cmp	$1, %eax
	jne	LB00
	pushl	-8(%ebp)
	subl	$12, %ebp
	pushl	$STR2
	call	printf
	addl	$12, %ebp
	addl	$8, %esp
	movl	$0, -16(%ebp)
	subl	$4, %esp
	pushl	$10
	popl	%eax
	movl	%eax, -16(%ebp)
	pushl	$0
	popl	%eax
	movl	%eax, -20(%ebp)
	subl	$4, %esp
FS0:
	pushl	-20(%ebp)
	pushl	-16(%ebp)
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jge	.BB12
	pushl	$1
	jmp	.BB13
.BB12:
	pushl	$0
.BB13:
	popl	%eax
	cmpl	$1, %eax
	jne	FE0
	pushl	-20(%ebp)
	subl	$20, %ebp
	pushl	$STR3
	call	printf
	addl	$20, %ebp
	addl	$8, %esp
	movl	$1, %eax
	addl	-20(%ebp), %eax
	movl	%eax, -20(%ebp)
	jmp	FS0
FE0:
	addl	$4, %esp
	addl	$4, %esp
LB00:
	jmp	WS0
WE0:
	addl	$4, %esp
	addl	$4, %esp
	addl	$4, %esp
	popl	%ebp
	movl	$0, %eax
	ret
	.section	.note.GNU-stack,"",@progbits

# 0	program					child: 1
# 1	function				child: 2 3 4 8 12 16 19 22 25
# 2	type		VOID		child:
# 3	variable	main			child:
# 4	statement	DECL		child: 5 6 7
# 5	type		INTEGER		child:
# 6	variable	a			child:
# 7	variable	s			child:
# 8	statement	ASSIGN		child: 9
# 9	assign					child: 10 11
# 10	variable	a			child:
# 11	constint	10			child:
# 12	statement	ASSIGN		child: 13
# 13	assign					child: 14 15
# 14	variable	s			child:
# 15	constint	0			child:
# 16	statement	DECL		child: 17 18
# 17	type		CHARACTER	child:
# 18	variable	ch			child:
# 19	statement	SCANF		child: 20 21
# 20	conststr	%c			child:
# 21	variable	ch			child:
# 22	statement	PRINTF		child: 23 24
# 23	conststr	%c			child:
# 24	variable	ch			child:
# 25	statement	WHILE		child: 26 40 44 48 52
# 26			child: 27
# 27	op			||			child: 28 35
# 28	op			&&			child: 29 32
# 29	op			>			child: 30 31
# 30	variable	a			child:
# 31	constint	0			child:
# 32	op			<=			child: 33 34
# 33	variable	a			child:
# 34	constint	10			child:
# 35	op			==			child: 36 39
# 36	op			%			child: 37 38
# 37	variable	a			child:
# 38	constint	100			child:
# 39	constint	10			child:
# 40	statement	ASSIGN		child: 41
# 41	assign					child: 42 43
# 42	variable	a			child:
# 43	constint	1			child:
# 44	statement	ASSIGN		child: 45
# 45	assign					child: 46 47
# 46	variable	a			child:
# 47	constint	10			child:
# 48	statement	ASSIGN		child: 49
# 49	assign					child: 50 51
# 50	variable	s			child:
# 51	variable	a			child:
# 52	statement	IF			child: 53 57 60 63 67
# 53	op			>			child: 54 55
# 54	variable	s			child:
# 55	op			NEGATIVE	child: 56
# 56	constint	10			child:
# 57	statement	PRINTF		child: 58 59
# 58	conststr	result is: %d\n			child:
# 59	variable	s			child:
# 60	statement	DECL		child: 61 62
# 61	type		INTEGER		child:
# 62	variable	b			child:
# 63	statement	ASSIGN		child: 64
# 64	assign					child: 65 66
# 65	variable	b			child:
# 66	constint	10			child:
# 67	statement	FOR			child: 68 81
# 68	FORargs					child: 69 78
# 69	FORargs					child: 70 75
# 70	statement	DECL		child: 71 72
# 71	type		INTEGER		child:
# 72	assign					child: 73 74
# 73	variable	i			child:
# 74	constint	0			child:
# 75	op			<			child: 76 77
# 76	variable	i			child:
# 77	variable	b			child:
# 78	FORargs					child: 79
# 79	assign					child: 80
# 80	variable	i			child:
# 81	statement	PRINTF		child: 82 83
# 82	conststr	Have fun: %d\n			child:
# 83	variable	i			child:
