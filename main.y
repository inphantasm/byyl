%{
    #include"common.h"
    extern TreeNode * root;
    int yylex();
    int yyerror( char const * );
    extern vector<layer> layers;
    extern vector<variable> curlayer;
    extern int lid;
    extern vector<struct_def> strdef;
    vector<variable> tmpfor;
    bool forflag = 0;
%}
%defines

%start program

%token ID IDadd IDptr INTEGER CHARACTER STRING
%token IF ELSE WHILE FOR STRUCT
%token CONST
%token INT VOID CHAR 
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE COMMA SEMICOLON
%token TRUE FALSE
%token ADD MINUS MULTI DIV MOD SELFADD SELFMIN NEG
%token ASSIGN ADDASS MINASS MULASS DIVASS MODASS
%token EQUAL NEQUAL BT BE LT LE NOT AND OR
%token PRINTF SCANF
%token dot

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
            printf("layer %d\t", lid);
            variable tmpv = curlayer[curlayer.size()-1];
            printf("%d\t\t%s\n", tmpv.type, tmpv.name.c_str());
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
    | struct_def {$$=$1;}
    ;
struct_def
    : STRUCT ID LBRACE struct_ins RBRACE args SEMICOLON
    {
        TreeNode* node = new TreeNode(NODE_STRDEF);
        node->addChild($2);
        node->addChild($4);
        int cnum = node->childNum();
        node->addChild($6);
        layers.pop_back();
        struct_def str($2->varName, curlayer);
        str.struct_index = struct_num++;
        strdef.push_back(str);
        curlayer.clear();
        for(int i = cnum;i < node->childNum();i++)
        {
            curlayer.push_back(variable(struct_num, node->getChild(i)->varName));
        }
        while(!curlayer.empty())
        {
            printf("layer %d\t", lid);
            variable tmpv = curlayer[curlayer.size()-1];
            printf("%d\t\t%s\n", tmpv.type, tmpv.name.c_str());
            curlayer.pop_back();
        }
        $$=node;
    }
    | STRUCT ID LBRACE struct_ins RBRACE SEMICOLON
    {
        TreeNode* node = new TreeNode(NODE_STRDEF);
        node->addChild($2);
        node->addChild($4);
        layers.pop_back();
        struct_def str($2->varName, curlayer);
        str.struct_index = struct_num++;
        strdef.push_back(str);
        curlayer.clear();
        $$=node;
    }
    ;
struct_ins
    : instruction {$$=$1;}
    | struct_ins instruction {$$=$1;$$->addSibling($2);}
    ;
ass
    : IDS ASSIGN expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | IDS ADDASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_ADD;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | IDS MINASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MINUS;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | IDS MULASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MULTI;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | IDS DIVASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_DIV;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | IDS MODASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MOD;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | IDS SELFADD {
        TreeNode *node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_SADD;
        node->addChild($1);
        $$=node; 
    }
    | IDS SELFMIN {
        TreeNode *node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_SMIN;
        node->addChild($1);
        $$=node; 
    }
    ;
args
    : IDS {$$=$1;}
    | ass {$$=$1;}
    | args COMMA IDS {$$=$1; $$->addSibling($3);}
    | args COMMA ass {$$=$1; $$->addSibling($3);}
    ;
call_args
    : IDS {$$=$1;}
    | IDadd {$$=$1;}
    | IDptr {$$=$1;}
    | call_args COMMA IDS {$$=$1; $$->addSibling($3);}
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
                    printf("ParseError(Same Variable)\n");
                    preflag = 1;
                    break;
                }
            }
            if(!preflag)
            {
                curlayer.push_back(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName));
                if(forflag) tmpfor.push_back(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName));
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
    | CONST type args SEMICOLON {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->addChild($2);
        node->addChild($3);
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
                    printf("ParseError(Same Variable)\n");
                    preflag = 1;
                    break;
                }
            }
            if(!preflag)
            {
                curlayer.push_back(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName));
                if(forflag) tmpfor.push_back(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName));
                forflag = 0;
            }
            preflag = 0;
        }
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
    : IDS {$$=$1;}
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
IDARR
    : ID LBRACK expr RBRACK {
        $$=$1;
        $$->dim.push_back($3);
    }
    | IDARR LBRACK expr RBRACK {
        $$=$1;
        $$->dim.push_back($3);
    }
    ;
IDcld
    : ID dot ID {
        $$=$1;
        $$->addChild($3);
    }
    | IDARR dot ID {
        $$=$1;
        $$->addChild($3);
    }
    | ID dot IDARR {
        $$=$1;
        $$->addChild($3);
    }
    | IDARR dot IDARR {
        $$=$1;
        $$->addChild($3);
    }
    | IDcld dot ID {
        $$=$1;
        $$->addChild($3);
    }
    | IDcld dot ID {
        $$=$1;
        $$->addChild($3);
    }
    | IDcld dot IDARR {
        $$=$1;
        $$->addChild($3);
    }
    ;
IDS 
    : ID {$$=$1;}
    | IDARR {$$=$1;}
    | IDcld {$$=$1;}
%%