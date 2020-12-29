%option noyywrap
%{
    #include"common.h"
    #include"main.tab.hh"
    int firstword = 0;
    extern vector<layer> layers;
    extern vector<variable> curlayer;
    extern int lid;
    
    int otoi(string s)
    {
        int ans=0;
        for(int i=1;i<s.size();i++)
            ans=ans*8+s[i]-'0';
        return ans;
    }
    int htoi(string s)
    {
        int ans=0;
        for(int i=1;i<s.size();i++)
            ans=ans*16+s[i]-'0';
        return ans;
    }
%}

INTEGER 0|[1-9][0-9]*
INT8 00|0[1-9][0-9]+
INT16 0x0|0x[1-9][0-9]
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
"string" return STR;
 
"for" return FOR;
"if" return IF;
"while" return WHILE;
"else" return ELSE;
"struct" return STRUCT;

"printf" return PRINTF;
"scanf" return SCANF;

"const" return CONST;

"." return dot;
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
"[" return LBRACK;
"]" return RBRACK;
"{" {
    layers.push_back(layer(curlayer, lid++));
    return LBRACE;
}
"}" return RBRACE;

{INTEGER} {
    TreeNode *node = new TreeNode(NODE_CONINT);
    node->int_val = atoi(yytext);
    node->varType = VAR_INTEGER;
    yylval = node;
    return INTEGER;
}
{INT8} {
    TreeNode *node = new TreeNode(NODE_CONINT);
    node->int_val = otoi(yytext);
    node->varType = VAR_INTEGER;
    yylval = node;
    return INTEGER;
}
{INT16} {
    TreeNode *node = new TreeNode(NODE_CONINT);
    node->int_val = htoi(yytext);
    node->varType = VAR_INTEGER;
    yylval = node;
    return INTEGER;
}
{CHARACTER} {
    TreeNode *node = new TreeNode(NODE_CONCHAR);
    node->int_val = int(string(yytext)[1]);
    node->varType = VAR_CHAR;
    yylval = node;
    return CHARACTER;
}
{STRING} {
    TreeNode *node = new TreeNode(NODE_CONSTR);
    string str = string(yytext);
    str.erase(0,str.find_first_not_of("\""));
    str.erase(str.find_last_not_of("\"") + 1);
    node->str_val = str;
    node->varType = VAR_STR;
    yylval = node;
    return STRING;
}
{ID} {
    TreeNode *node = new TreeNode(NODE_VAR);
    node->varName = string(yytext);
    vector<variable>::reverse_iterator it = curlayer.rbegin();
    while(it != curlayer.rend())
    {
        if((*it).name == node->varName)
        {
            node->varType = (*it).type;
            break;
        }
        it++;
    }
    yylval = node;
    return ID;
}
{IDadd} {
    TreeNode *node = new TreeNode(NODE_VAR);
    string str = string(yytext);
    str.erase(str.begin());
    node->varName = str;
    node->varFlag = VAR_ADDRESS;
    vector<variable>::reverse_iterator it = curlayer.rbegin();
    while(it != curlayer.rend())
    {
        if((*it).name == node->varName)
        {
            node->varType = (*it).type;
            break;
        }
        it++;
    }
    yylval = node;
    return ID;
}
{IDptr} {
    TreeNode *node = new TreeNode(NODE_VAR);
    string str = string(yytext);
    str.erase(str.begin());
    node->varName = str;
    node->varFlag = VAR_POINTER;
    vector<variable>::reverse_iterator it = curlayer.rbegin();
    while(it != curlayer.rend())
    {
        if((*it).name == node->varName)
        {
            node->varType = (*it).type;
            break;
        }
        it++;
    }
    yylval = node;
    return ID;
}
{EOL}
{WHITE}

{commentbegin} { BEGIN LONGCOMMENT; printf("# COMMENT BEGIN\t"); }
<LONGCOMMENT>{commentelement} { if(!firstword) printf("#\t"); printf("%s", yytext); firstword = 1; }
<LONGCOMMENT>{commentspace} { if(firstword) printf("%s", yytext); }
<LONGCOMMENT>{commentnextline} { printf("\n"); firstword = 0; }
<LONGCOMMENT>{commentend} { printf("# COMMENT END\n"); BEGIN INITIAL; }

{ALTERcomment} { BEGIN SHORTCOMMENT; printf("# COMMENT:"); }
<SHORTCOMMENT>{commentelement} { printf("%s", yytext); }
<SHORTCOMMENT>{commentspace} { printf("%s", yytext); }
<SHORTCOMMENT>{commentnextline} { printf("\n"); BEGIN INITIAL; }
%%