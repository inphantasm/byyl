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
	.string "5d"
STR2:
	.string "6d"
STR3:
	.string "%d"
	.text
	.globl	main
	.type	main, @function
main:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	$12
	popl	%eax
	movl	%eax, -4(%ebp)
	subl	$4, %esp
	pushl	$3
	popl	%eax
	movl	%eax, -8(%ebp)
	subl	$4, %esp
	pushl	-4(%ebp)
	pushl	$12
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jne	.BB0
	pushl	$1
	jmp	.BB1
.BB0:
	pushl	$0
.BB1:
	popl	%eax
	cmp	$1, %eax
	jne	LB00
	pushl	-8(%ebp)
	subl	$4, %ebp
	pushl	$STR0
	call	printf
	addl	$4, %ebp
	addl	$8, %esp
	pushl	-4(%ebp)
	pushl	$13
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jne	.BB2
	pushl	$1
	jmp	.BB3
.BB2:
	pushl	$0
.BB3:
	popl	%eax
	cmp	$1, %eax
	jne	LB01
	subl	$8, %ebp
	pushl	$STR1
	call	printf
	addl	$8, %ebp
	addl	$4, %esp
LB01:
	pushl	-4(%ebp)
	pushl	$12
	popl	%eax
	popl	%ebx
	cmpl	%eax, %ebx
	jne	.BB4
	pushl	$1
	jmp	.BB5
.BB4:
	pushl	$0
.BB5:
	popl	%eax
	cmp	$1, %eax
	jne	LB11
	subl	$8, %ebp
	pushl	$STR2
	call	printf
	addl	$8, %ebp
	addl	$4, %esp
LB11:
	jmp	LB10
LB00:
	pushl	-4(%ebp)
	subl	$4, %ebp
	pushl	$STR3
	call	printf
	addl	$4, %ebp
	addl	$8, %esp
LB10:
	addl	$4, %esp
	addl	$4, %esp
	popl	%ebp
	movl	$0, %eax
	ret
	.section	.note.GNU-stack,"",@progbits

# 0	program					child: 1
# 1	function				child: 2 3 4 12
# 2	type		VOID		child:
# 3	variable	main			child:
# 4	statement	DECL		child: 5 6 9
# 5	type		INTEGER		child:
# 6	assign					child: 7 8
# 7	variable	a			child:
# 8	constint	12			child:
# 9	assign					child: 10 11
# 10	variable	b			child:
# 11	constint	3			child:
# 12	statement	IF			child: 13 16 19 25 31
# 13	op			==			child: 14 15
# 14	variable	a			child:
# 15	constint	12			child:
# 16	statement	PRINTF		child: 17 18
# 17	conststr	%d			child:
# 18	variable	b			child:
# 19	statement	IF			child: 20 23
# 20	op			==			child: 21 22
# 21	variable	a			child:
# 22	constint	13			child:
# 23	statement	PRINTF		child: 24
# 24	conststr	5d			child:
# 25	statement	IF			child: 26 29
# 26	op			==			child: 27 28
# 27	variable	a			child:
# 28	constint	12			child:
# 29	statement	PRINTF		child: 30
# 30	conststr	6d			child:
# 31	statement	PRINTF		child: 32 33
# 32	conststr	%d			child:
# 33	variable	a			child:
