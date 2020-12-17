COMMENT BEGIN	
	I'm level 2 test. Without pointer.
COMMENT END
m1  3
m2  3
m3  3
len  3
i  3
j  3
m1  2
m2  2
m3  2
len  2
i  2
m1  1
m2  1
m3  1
len  1
layer 4	1		j
layer 4	1		i
layer 4	-1		len
layer 4	5		m3
layer 4	5		m2
layer 4	5		m1

m1  2
m2  2
m3  2
len  2
i  2
m1  1
m2  1
m3  1
len  1
layer 3	1		j
layer 3	1		i
layer 3	-1		len
layer 3	5		m3
layer 3	5		m2
layer 3	5		m1

m1  3
m2  3
m3  3
len  3
i  3
j  3
m1  2
m2  2
m3  2
len  2
i  2
m1  1
m2  1
m3  1
len  1
layer 4	1		j
layer 4	1		i
layer 4	-1		len
layer 4	5		m3
layer 4	5		m2
layer 4	5		m1

m1  2
m2  2
m3  2
len  2
i  2
m1  1
m2  1
m3  1
len  1
layer 3	1		j
layer 3	1		i
layer 3	-1		len
layer 3	5		m3
layer 3	5		m2
layer 3	5		m1

m1  1
m2  1
m3  1
len  1
layer 2	-1		len
layer 2	5		m3
layer 2	5		m2
layer 2	5		m1

0	program					child: 1 12 17
1	struct					child: 2 3 6 9 10 11
2	variable	Matrix			child:
3	statement	DECL		child: 4 5
4	type		INTEGER		child:
5	variable	id			child:
6	statement	DECL		child: 7 8
7	type		INTEGER		child:
8	variable	arr			child:
9	variable	m1			child:
10	variable	m2			child:
11	variable	m3			child:
12	statement	DECL		child: 13 14
13	type		INTEGER		child:
14	assign					child: 15 16
15	variable	len			child:
16	constint	10			child:
17	function				child: 18 19 20 33 76
18	type		VOID		child:
19	variable	main			child:
20	statement	ASSIGN		child: 21 25 29
21	assign					child: 22 24
22	variable	m1			child: 23
23	variable	id			child:
24	constint	1			child:
25	assign					child: 26 28
26	variable	m2			child: 27
27	variable	id			child:
28	constint	2			child:
29	assign					child: 30 32
30	variable	m3			child: 31
31	variable	id			child:
32	constint	3			child:
33	statement	FOR			child: 34 45
34	FORargs					child: 35 40 43
35	statement	DECL		child: 36 37
36	type		INTEGER		child:
37	assign					child: 38 39
38	variable	i			child:
39	constint	0			child:
40	op			<			child: 41 42
41	variable	i			child:
42	variable	len			child:
43	assign					child: 44
44	variable	i			child:
45	statement	FOR			child: 46 57 62 67
46	FORargs					child: 47 52 55
47	statement	DECL		child: 48 49
48	type		INTEGER		child:
49	assign					child: 50 51
50	variable	j			child:
51	constint	0			child:
52	op			<			child: 53 54
53	variable	j			child:
54	variable	len			child:
55	assign					child: 56
56	variable	j			child:
57	statement	ASSIGN		child: 58
58	assign					child: 59 61
59	variable	m1			child: 60
60	variable	arr			child:
61	variable	i			child:
62	statement	ASSIGN		child: 63
63	assign					child: 64 66
64	variable	m2			child: 65
65	variable	arr			child:
66	variable	j			child:
67	statement	ASSIGN		child: 68
68	assign					child: 69 71
69	variable	m3			child: 70
70	variable	arr			child:
71	op			+			child: 72 74
72	variable	m1			child: 73
73	variable	arr			child:
74	variable	m2			child: 75
75	variable	arr			child:
76	statement	FOR			child: 77 88 108
77	FORargs					child: 78 83 86
78	statement	DECL		child: 79 80
79	type		INTEGER		child:
80	assign					child: 81 82
81	variable	i			child:
82	constint	0			child:
83	op			<			child: 84 85
84	variable	i			child:
85	variable	len			child:
86	assign					child: 87
87	variable	i			child:
88	statement	FOR			child: 89 100
89	FORargs					child: 90 95 98
90	statement	DECL		child: 91 92
91	type		INTEGER		child:
92	assign					child: 93 94
93	variable	j			child:
94	constint	0			child:
95	op			<			child: 96 97
96	variable	j			child:
97	variable	len			child:
98	assign					child: 99
99	variable	j			child:
100	statement	PRINTF		child: 101 102 104 105 106
101	conststr	<%d>[%d][%d] %d\t			child:
102	variable	m3			child: 103
103	variable	id			child:
104	variable	i			child:
105	variable	j			child:
106	variable	m3			child: 107
107	variable	arr			child:
108	statement	PRINTF		child: 109
109	conststr	\n			child:
