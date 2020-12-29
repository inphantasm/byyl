# COMMENT: int a = 1
# COMMENT: int b = 2;
# COMMENT: if(!2==3){
# COMMENT:     int a=2;
# COMMENT:     a=a+2;
# COMMENT: }
# COMMENT: while(a==b){
# COMMENT:     printf("%d", a);
# COMMENT: }

	.text
	.section	.rodata
STR0:
	.string "%d"
STR1:
	.string "%d\n"
STR2:
	.string "WHILE%d\n"
STR3:
	.string "MOD%d\n"
STR4:
	.string "FOR%d\n"
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
	movl	%eax, -12(%ebp)
	subl	$4, %esp
	leal	-8(%ebp), %eax
	pushl	%eax
	subl	$12, %ebp
	pushl	$STR0
	call	scanf
	addl	$12, %ebp
	addl	$8, %esp
	pushl	-4(%ebp)
	subl	$12, %ebp
	pushl	$STR1
	call	printf
	addl	$12, %ebp
	addl	$8, %esp
WS0:
	pushl	-4(%ebp)
	pushl	-12(%ebp)
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jge	.BB0
	pushl	$1
	jmp	.BB1
.BB0:
	pushl	$0
.BB1:
	popl	%eax
	cmpl	$1, %eax
	jne	WE0
	movl	$1, %eax
	addl	-4(%ebp), %eax
	movl	%eax, -4(%ebp)
	pushl	-4(%ebp)
	subl	$12, %ebp
	pushl	$STR2
	call	printf
	addl	$12, %ebp
	addl	$8, %esp
	jmp	WS0
WE0:
	pushl	-8(%ebp)
	pushl	-12(%ebp)
	popl	%ebx
	popl	%eax
	cltd
	idivl	%ebx
	pushl	%edx
	subl	$12, %ebp
	pushl	$STR3
	call	printf
	addl	$12, %ebp
	addl	$8, %esp
	pushl	$0
	popl	%eax
	movl	%eax, -16(%ebp)
	subl	$4, %esp
FS0:
	pushl	-16(%ebp)
	pushl	-8(%ebp)
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jge	.BB2
	pushl	$1
	jmp	.BB3
.BB2:
	pushl	$0
.BB3:
	popl	%eax
	cmpl	$1, %eax
	jne	FE0
	pushl	-4(%ebp)
	pushl	-12(%ebp)
	pushl	-16(%ebp)
	popl	%ebx
	popl	%eax
	imull	%ebx
	pushl	%eax
	popl	%ebx
	popl	%eax
	addl	%eax, %ebx
	pushl	%ebx
	subl	$16, %ebp
	pushl	$STR4
	call	printf
	addl	$16, %ebp
	addl	$8, %esp
	movl	$1, %eax
	addl	-16(%ebp), %eax
	movl	%eax, -16(%ebp)
	jmp	FS0
FE0:
	addl	$4, %esp
	addl	$4, %esp
	addl	$4, %esp
	addl	$4, %esp
	popl	%ebp
	movl	$0, %eax
	ret
	.section	.note.GNU-stack,"",@progbits

# 0	program					child: 1
# 1	function				child: 2 3 4 11 14 17 28 33
# 2	type		VOID		child:
# 3	variable	main			child:
# 4	statement	DECL		child: 5 6 7 8
# 5	type		INTEGER		child:
# 6	variable	a			child:
# 7	variable	b			child:
# 8	assign					child: 9 10
# 9	variable	c			child:
# 10	constint	10			child:
# 11	statement	SCANF		child: 12 13
# 12	conststr	%d			child:
# 13	variable	b			child:
# 14	statement	PRINTF		child: 15 16
# 15	conststr	%d\n			child:
# 16	variable	a			child:
# 17	statement	WHILE		child: 18 22 25
# 18			child: 19
# 19	op			<			child: 20 21
# 20	variable	a			child:
# 21	variable	c			child:
# 22	statement	ASSIGN		child: 23
# 23	assign					child: 24
# 24	variable	a			child:
# 25	statement	PRINTF		child: 26 27
# 26	conststr	WHILE%d\n			child:
# 27	variable	a			child:
# 28	statement	PRINTF		child: 29 30
# 29	conststr	MOD%d\n			child:
# 30	op			%			child: 31 32
# 31	variable	b			child:
# 32	variable	c			child:
# 33	statement	FOR			child: 34 47
# 34	FORargs					child: 35 44
# 35	FORargs					child: 36 41
# 36	statement	DECL		child: 37 38
# 37	type		INTEGER		child:
# 38	assign					child: 39 40
# 39	variable	i			child:
# 40	constint	0			child:
# 41	op			<			child: 42 43
# 42	variable	i			child:
# 43	variable	b			child:
# 44	FORargs					child: 45
# 45	assign					child: 46
# 46	variable	i			child:
# 47	statement	PRINTF		child: 48 49
# 48	conststr	FOR%d\n			child:
# 49	op			+			child: 50 51
# 50	variable	a			child:
# 51	op			*			child: 52 53
# 52	variable	c			child:
# 53	variable	i			child:
