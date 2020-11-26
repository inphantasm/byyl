%{
    #include"common.h"
    extern TreeNode * root;
    int yylex();
    int yyerror( char const * );
    extern vector<layer> layers;
    extern vector<variable> curlayer;
    extern int lid;
    vector<variable> tmpfor;
    bool forflag = 0;
%}
%defines

%start program

%token ID IDadd IDptr INTEGER CHARACTER STRING
%token IF ELSE WHILE FOR
%token INT VOID CHAR
%token LPAREN RPAREN LBRACE RBRACE COMMA SEMICOLON
%token TRUE FALSE
%token ADD MINUS MULTI DIV MOD SELFADD SELFMIN NEG
%token ASSIGN ADDASS MINASS MULASS DIVASS MODASS
%token EQUAL NEQUAL BT BE LT LE NOT AND OR
%token PRINTF SCANF

%right NEG
%right OR
%right AND
%left EQUAL NEQUAL BT BE LT LE
%left ADD MINUS
%left MULTI DIV MOD
%right NOT
%right SELFADD SELFMIN 
%right ASSIGN ADDASS MINASS MULASS DIVASS MODASS
%nonassoc LOWER_THEN_ELSE
%nonassoc ELSE 
%%
program
    : statements {root=new TreeNode(NODE_PROG);root->addChild($1);}
    ;
statements
    : statement {$$=$1;}
    | statements statement{$$=$1;$$->addSibling($2);}
    ;
statement
    : instruction {$$=$1;}
    | if_else {$$=$1;}
    | while {$$=$1;}
    | for {$$=$1;}
    | LBRACE statements RBRACE {
        $$=$2;
        for(int i = layers.size()-1;i >= 0;i--)
        {
            layers[i].output();
        }
        while(!curlayer.empty())
        {
            printf("layer %d", lid);
            variable tmpv = curlayer[curlayer.size()-1];
            printf("    %s  %d\n", tmpv.name.c_str(), tmpv.vid);
            curlayer.pop_back();
        }
        printf("\n");
        curlayer = layers[layers.size()-1].varies;
        layers.pop_back();
        lid--;
    }
    | def_func {$$=$1;}
    | call_func {$$=$1;}
    | printf SEMICOLON {$$=$1;}
    | scanf SEMICOLON {$$=$1;}
    ;
ass
    : ID ASSIGN expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | ID ADDASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_ADD;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | ID MINASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MINUS;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | ID MULASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MULTI;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | ID DIVASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_DIV;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | ID MODASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MOD;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | ID SELFADD {
        TreeNode *node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_SADD;
        node->addChild($1);
        $$=node; 
    }
    | ID SELFMIN {
        TreeNode *node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_SMIN;
        node->addChild($1);
        $$=node; 
    }
    ;
args
    : ID {$$=$1;}
    | ass {$$=$1;}
    | args COMMA ID {$$=$1; $$->addSibling($3);}
    | args COMMA ass {$$=$1; $$->addSibling($3);}
    ;
call_args
    : ID {$$=$1;}
    | IDadd {$$=$1;}
    | IDptr {$$=$1;}
    | call_args COMMA ID {$$=$1; $$->addSibling($3);}
    | call_args COMMA IDadd {$$=$1; $$->addSibling($3);}
    | call_args COMMA IDptr {$$=$1; $$->addSibling($3);}
    ;
def_func
    : type ID LPAREN call_args RPAREN statement {
        TreeNode *node=new TreeNode(NODE_FUNC);
        node->addChild($1);
        node->addChild($2);
        node->addChild($4);
        node->addChild($6);
        $$=node;
    }
    | type ID LPAREN RPAREN statement {
        TreeNode *node=new TreeNode(NODE_FUNC);
        node->addChild($1);
        node->addChild($2);
        node->addChild($5);
        $$=node;
    }
    ;
call_func
    : type ID LPAREN call_args RPAREN statement {
        TreeNode *node=new TreeNode(NODE_FUNC);
        node->addChild($1);
        node->addChild($2);
        node->addChild($4);
        node->addChild($6);
        $$=node;
    }
    | type ID LPAREN RPAREN statement {
        TreeNode *node=new TreeNode(NODE_FUNC);
        node->addChild($1);
        node->addChild($2);
        node->addChild($5);
        $$=node;
    }
    ;
if_else
    : IF bool_statment statement %prec LOWER_THEN_ELSE {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($2);
        node->addChild($3);
        $$=node;
    }
    | IF bool_statment statement ELSE statement {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($2);
        node->addChild($3);
        node->addChild($5);
        $$=node;
    }
    ;
while
    : WHILE bool_statment statement {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_WHILE;
        node->addChild($2);
        node->addChild($3);
        $$=node;
    }
    ;
for
    : FOR for_expr statement{
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FOR;
        node->addChild($2);
        node->addChild($3);
        $$=node;
    }
for_expr
    : LPAREN instruction bool_expr SEMICOLON ass RPAREN{
        TreeNode *node=new TreeNode(NODE_FEXPR);
        node->addChild($2);
        node->addChild($3);
        node->addChild($5);
        forflag = 1;
        $$=node;
    }
bool_statment
    : LPAREN bool_expr RPAREN {$$=$2;}
    ;
instruction
    : type args SEMICOLON {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->addChild($1);
        node->addChild($2);
        $$=node;
        int preflag = 0;
        vector<variable> l;
        if(!layers.empty())
        {
            l = layers[layers.size()-1].varies;
        }
        for(int i = 1;i < node->childNum();i++)
        {
            TreeNode* cld = node->getChild(i);
            for(int j = l.size();j < curlayer.size();j++)
            {
                if(curlayer[j].name == (cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName))
                {
                    printf("ParseError(Same Variable)%s\n", (cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName).c_str());
                    preflag = 1;
                    break;
                }
            }
            if(!preflag)
            {
                curlayer.push_back(variable(cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName, curlayer.size()));
                if(forflag) tmpfor.push_back(variable(cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName, curlayer.size()));
                forflag = 0;
            }
            preflag = 0;
        }
    }
    | args SEMICOLON {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_ASSIGN;
        node->addChild($1);
        $$=node;  
    }
    ;
printf
    : PRINTF LPAREN STRING COMMA call_args RPAREN {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        node->addChild($5);
        $$=node;
    }
    | PRINTF LPAREN STRING RPAREN{
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        $$=node;
    }
    | PRINTF LPAREN ID RPAREN{                       // 0.c特供
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        $$=node;
    }
    ;
scanf
    : SCANF LPAREN STRING COMMA call_args RPAREN {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_SCANF;
        node->addChild($3);
        node->addChild($5);
        $$=node;
    }
    ;
bool_expr
    : TRUE {$$=$1;}
    | FALSE {$$=$1;}
    | expr EQUAL expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_EQ;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr NEQUAL expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NE;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr BT expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_BT;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr BE expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_BE;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr LT expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_LT;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr LE expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_LE;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | bool_expr AND bool_expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_AND;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | bool_expr OR bool_expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_OR;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | NOT bool_expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NOT;
        node->addChild($2);
        $$=node;        
    }
    ;
expr
    : ID {$$=$1;}
    | INTEGER {$$=$1;}
    | CHARACTER {$$=$1;}
    | STRING {$$=$1;}
    | expr ADD expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_ADD;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr MINUS expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MINUS;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr MULTI expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MULTI;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr DIV expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_DIV;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr MOD expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MOD;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | MINUS expr %prec NEG {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NEG;
        node->addChild($2);
        $$=node; 
    }
    ;
type
    : INT {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_INTEGER;
        $$=node; 
    }
    | VOID {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_VOID;
        $$=node;         
    }
    | CHAR {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_CHAR;
        $$=node;
    }
    ;

%%