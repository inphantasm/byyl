%option noyywrap
%{
    #include"common.h"
    #include"main.tab.hh"
    int firstword = 0;
    extern vector<layer> layers;
    extern vector<variable> curlayer;
    extern int lid;
%}

INTEGER [0-9]+
CHARACTER \'(.*)\'
STRING \"(.*)\"
ID [[:alpha:]_][[:alpha:][:digit:]_]*
IDadd \&[[:alpha:]_][[:alpha:][:digit:]_]*
IDptr \*[[:alpha:]_][[:alpha:][:digit:]_]*

EOL (\r\n|\n)
WHITE [\t ]

commentbegin "/*"
commentspace [ \t]
commentelement [^ \t\n]
commentnextline \n
commentend "*/"
ALTERcomment "//"
%x LONGCOMMENT
%x SHORTCOMMENT

%%

"true" {
    TreeNode *node = new TreeNode(NODE_BOOL);
    node->bool_val = true;
    yylval = node;
    return TRUE;
}
"false" {
    TreeNode *node = new TreeNode(NODE_BOOL);
    node->bool_val = false;
    yylval = node;
    return FALSE;
}

"int" return INT;
"void" return VOID;
"char" return CHAR;

"for" return FOR;
"if" return IF;
"while" return WHILE;
"else" return ELSE;

"printf" return PRINTF;
"scanf" return SCANF;

"=" return ASSIGN;
"+=" return ADDASS;
"-=" return MINASS;
"*=" return MULASS;
"/=" return DIVASS;
"%=" return MODASS;

"++" return SELFADD;
"--" return SELFMIN;
"+" return ADD;
"-" return MINUS;
"*" return MULTI;
"/" return DIV;
"%" return MOD;

"!" return NOT;
"&&" return AND;
"||" return OR;
"==" return EQUAL;
"!=" return NEQUAL;
">" return BT;
">=" return BE;
"<" return LT;
"<=" return LE;

"," return COMMA;
";" return SEMICOLON;
"(" return LPAREN;
")" return RPAREN;
"{" {
    layers.push_back(layer(curlayer, lid++));
    return LBRACE;
}
"}" return RBRACE;

{INTEGER} {
    TreeNode *node = new TreeNode(NODE_CONINT);
    node->int_val = atoi(yytext);
    yylval = node;
    return INTEGER;
}
{CHARACTER} {
    TreeNode *node = new TreeNode(NODE_CONCHAR);
    node->int_val = int(string(yytext)[1]);
    yylval = node;
    return CHARACTER;
}
{STRING} {
    TreeNode *node = new TreeNode(NODE_CONSTR);
    string str = string(yytext);
    str.erase(0,str.find_first_not_of("\""));
    str.erase(str.find_last_not_of("\"") + 1);
    node->str_val = str;
    yylval = node;
    return STRING;
}
{ID} {
    TreeNode *node = new TreeNode(NODE_VAR);
    node->varName = string(yytext);
    yylval = node;
    return ID;
}
{IDadd} {
    TreeNode *node = new TreeNode(NODE_VAR);
    string str = string(yytext);
    str.erase(str.begin());
    node->varName = str;
    node->varFlag = VAR_ADDRESS;
    yylval = node;
    return ID;
}
{IDptr} {
    TreeNode *node = new TreeNode(NODE_VAR);
    string str = string(yytext);
    str.erase(str.begin());
    node->varName = str;
    node->varFlag = VAR_POINTER;
    yylval = node;
    return ID;
}
{EOL}
{WHITE}

{commentbegin} { BEGIN LONGCOMMENT; printf("COMMENT BEGIN\t"); }
<LONGCOMMENT>{commentelement} { if(!firstword) printf("\t"); printf("%s", yytext); firstword = 1; }
<LONGCOMMENT>{commentspace} { if(firstword) printf("%s", yytext); }
<LONGCOMMENT>{commentnextline} { printf("\n"); firstword = 0; }
<LONGCOMMENT>{commentend} { printf("COMMENT END\n"); BEGIN INITIAL; }

{ALTERcomment} { BEGIN SHORTCOMMENT; printf("COMMENT:"); }
<SHORTCOMMENT>{commentelement} { printf("%s", yytext); }
<SHORTCOMMENT>{commentspace} { printf("%s", yytext); }
<SHORTCOMMENT>{commentnextline} { printf("\n"); BEGIN INITIAL; }
%%