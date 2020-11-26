COMMENT: int a = 0;
COMMENT: int b = 2;
COMMENT: if(!2==3){
COMMENT:     int a=2;
COMMENT:     a=a+2;
COMMENT: }
COMMENT: while(a==b){
COMMENT:     printf(a);
COMMENT: }
0	program					child: 1
1	statement	DECL		child: 2 3
2	type		INTEGER		child:
3	assign					child: 4 5
4	variable	t			child:
5	variable	a			child: 6
6	variable	b			child:
