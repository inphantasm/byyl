COMMENT BEGIN	
	I'm level 1 test.
COMMENT END
a  3
s  3
ch  3
a  3
b  3
i  3
a  2
s  2
ch  2
a  2
a  1
s  1
ch  1
layer 4	2		i
layer 4	2		b
layer 4	2		a
layer 4	3		ch
layer 4	2		s
layer 4	2		a

a  2
s  2
ch  2
a  2
a  1
s  1
ch  1
layer 3	2		i
layer 3	2		b
layer 3	2		a
layer 3	3		ch
layer 3	2		s
layer 3	2		a

a  1
s  1
ch  1
layer 2	2		a
layer 2	3		ch
layer 2	2		s
layer 2	2		a

layer 1	3		ch
layer 1	2		s
layer 1	2		a

COMMENT: No more compilation error.0	program					child: 1
1	function				child: 2 3 4 8 12 16 19 22
2	type		VOID		child:
3	variable	main			child:
4	statement	DECL		child: 5 6 7
5	type		INTEGER		child:
6	variable	a			child:
7	variable	s			child:
8	statement	ASSIGN		child: 9
9	assign					child: 10 11
10	variable	a			child:
11	constint	10			child:
12	statement	ASSIGN		child: 13
13	assign					child: 14 15
14	variable	s			child:
15	constint	0			child:
16	statement	DECL		child: 17 18
17	type		CHARACTER	child:
18	variable	ch			child:
19	statement	SCANF		child: 20 21
20	conststr	%c			child:
21	variable	ch			child:
22	statement	WHILE		child: 23 41 45 48 52 56
23	op			&&			child: 24 27
24	op			>			child: 25 26
25	variable	a			child:
26	constint	0			child:
27	op			&&			child: 28 37
28	op			||			child: 29 32
29	op			<=			child: 30 31
30	variable	a			child:
31	constint	10			child:
32	op			==			child: 33 36
33	op			%			child: 34 35
34	variable	a			child:
35	constint	100			child:
36	constint	10			child:
37	op			!			child: 38
38	op			==			child: 39 40
39	variable	a			child:
40	constint	10			child:
41	statement	ASSIGN		child: 42
42	assign					child: 43 44
43	variable	a			child:
44	constint	1			child:
45	statement	DECL		child: 46 47
46	type		INTEGER		child:
47	variable	a			child:
48	statement	ASSIGN		child: 49
49	assign					child: 50 51
50	variable	a			child:
51	constint	10			child:
52	statement	ASSIGN		child: 53
53	assign					child: 54 55
54	variable	s			child:
55	variable	a			child:
56	statement	IF			child: 57 62 65 68 72
57	op			<			child: 58 60
58	op			NEGATIVE	child: 59
59	variable	s			child:
60	op			NEGATIVE	child: 61
61	constint	10			child:
62	statement	PRINTF		child: 63 64
63	conststr	result is: %d\n			child:
64	variable	s			child:
65	statement	DECL		child: 66 67
66	type		INTEGER		child:
67	variable	b			child:
68	statement	ASSIGN		child: 69
69	assign					child: 70 71
70	variable	b			child:
71	constint	10			child:
72	statement	FOR			child: 73 84
73	FORargs					child: 74 79 82
74	statement	DECL		child: 75 76
75	type		INTEGER		child:
76	assign					child: 77 78
77	variable	i			child:
78	constint	0			child:
79	op			<			child: 80 81
80	variable	i			child:
81	variable	b			child:
82	assign					child: 83
83	variable	i			child:
84	statement	PRINTF		child: 85 86
85	conststr	Have fun: %d\n			child:
86	variable	i			child:
