%{
    #include"common.h"
    #include<string>
    #include<queue>
    extern TreeNode * root;
    int yylex();
    int yyerror( char const * );
    extern vector<layer> layers;
    extern vector<variable> curlayer;
    extern int lid;
    extern vector<struct_def> strdef;
    extern rodata _rodata;
    extern function _function;
    int tmpins = 1;
    bool insflag = 0;
    bool scanflag = 0;
    bool whileflag = 0;
    bool forflagi = 0;
    bool forflagb = 0;
    bool forflaga = 0;
    vector<string> whilecode;
    vector<string> forcode;
    int curlabel;
    vector<int> label;
    int if_lev = 0;
    int whilectr = 0;
    int forctr = 0;
    int bool_breaker = 0;
    vector<tmpvariable> tmpfor;
    int forlevel = 0;
%}
%defines

%start program

%token ID IDadd IDptr INTEGER CHARACTER STRING
%token IF ELSE WHILE FOR STRUCT
%token CONST
%token INT VOID CHAR STR
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE COMMA SEMICOLON
%token TRUE FALSE
%token ADD MINUS MULTI DIV MOD SELFADD SELFMIN NEG
%token ASSIGN ADDASS MINASS MULASS DIVASS MODASS
%token EQUAL NEQUAL BT BE LT LE NOT AND OR
%token PRINTF SCANF
%token dot

%right ASSIGN ADDASS MINASS MULASS DIVASS MODASS
%right SELFADD SELFMIN
%right OR
%left ADD MINUS
%left MULTI DIV MOD
%left EQUAL NEQUAL BT BE LT LE
%right AND
%right NOT
%right NEG 
%nonassoc LOWER_THEN_ELSE
%nonassoc ELSE 
%%
program
    : statements {
        root=new TreeNode(NODE_PROG);
        root->addChild($1);
        printf("\n\t.text\n\t.section\t.rodata\n");
        _rodata.output();
        _function.output();
        printf("\t.section\t.note.GNU-stack,\"\",@progbits\n\n");
    }
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
        // for(int i = layers.size()-1;i >= 0;i--)
        // {
        //     layers[i].output();
        // }
        vector<variable> var = layers[layers.size()-1].varies;
        while(curlayer.size()!=var.size())
        {
            // printf("layer %d\t", lid);
            // variable tmpv = curlayer[curlayer.size()-1];
            // printf("%d\t\t%s\n", tmpv.type, tmpv.name.c_str());
            if(curlayer[curlayer.size()-1].type != 4) _function.addCode("\taddl\t$4, %esp\n");
            curlayer.pop_back();
        }
        layers.pop_back();
        lid--;
    }
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
        curlayer.clear();
        str.struct_index = struct_num++;
        strdef.push_back(str);
        for(int i = cnum;i < node->childNum();i++)
        {
            curlayer.push_back(variable(struct_num, node->getChild(i)->varName));
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
        string index;
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->addChild($1);
        node->addChild($3);
        if($1->varType != -1 && $1->varType != $3->varType)
        {
            printf("INVALID type\n");
            exit(1);
        }
        if($3->varType == VAR_STR)
            goto END1;
        if($1->int_val == -1)
            index = to_string(4*(tmpins++));
        else
            index = to_string(4*$1->int_val);
        if(forflaga)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tmovl\t%eax, -"+index+"(%ebp)\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tmovl\t%eax, -"+index+"(%ebp)\n");
        }
        if(insflag) _function.addCode("\tsubl\t$4, %esp\n");
        END1:$$=node;
    }
    | IDS ADDASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_ADD;
        node->addChild($1);
        node->addChild($3);
        if($1->varType != -1 && $1->varType != $3->varType)
        {
            printf("INVALID type\n");
            exit(1);
        }
        string str = "\tpopl\t%eax\n";
        str += "\taddl\t-" + to_string(4*$1->int_val) + "(%ebp), %eax\n";
        str += "\tmovl\t%eax, -"+to_string(4*$1->int_val)+"(%ebp)\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;
    }
    | IDS MINASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MINUS;
        node->addChild($1);
        node->addChild($3);
        if($1->varType != -1 && $1->varType != $3->varType)
        {
            printf("INVALID type\n");
            exit(1);
        }
        string str = "\tpopl\t%eax\n";
        str += "\tsubl\t-" + to_string(4*$1->int_val) + "(%ebp), %eax\n";
        str += "\tmovl\t$-1, %ebx\n";
        str += "\timull\t%ebx\n";
        str += "\tmovl\t%eax, -"+to_string(4*$1->int_val)+"(%ebp)\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;
    }
    | IDS MULASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MULTI;
        node->addChild($1);
        node->addChild($3);
        if($1->varType != -1 && !($1->varType == $3->varType && $1->varType == VAR_INTEGER))
        {
            printf("INVALID type\n");
            exit(1);
        }
        string str = "\tpopl\t%ebx\n";
        str += "\tmovl\t-" + to_string(4*$1->int_val) + "(%ebp), %eax\n";
        str += "\timull\t%ebx\n";
        str += "\tmovl\t%eax, -"+to_string(4*$1->int_val)+"(%ebp)\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;
    }
    | IDS DIVASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_DIV;
        node->addChild($1);
        node->addChild($3);
        string str = "\tpopl\t%ebx\n";
        str += "\tmovl\t-" + to_string(4*$1->int_val) + "(%ebp), %eax\n";
        str += "\tcltd\n";
        str += "\tidivl\t%ebx\n";
        str += "\tmovl\t%eax, -"+to_string(4*$1->int_val)+"(%ebp)\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;
    }
    | IDS MODASS expr{
        TreeNode* node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_MOD;
        node->addChild($1);
        node->addChild($3);
        string str = "\tpopl\t%ebx\n";
        str += "\tmovl\t-" + to_string(4*$1->int_val) + "(%ebp), %eax\n";
        str += "\tcltd\n";
        str += "\tidivl\t%ebx\n";
        str += "\tmovl\t%edx, -"+to_string(4*$1->int_val)+"(%ebp)\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;
    }
    | IDS SELFADD {
        TreeNode *node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_SADD;
        node->addChild($1);
        string str = "\tmovl\t$1, %eax\n";
        str += "\taddl\t-" + to_string(4*$1->int_val) + "(%ebp), %eax\n";
        str += "\tmovl\t%eax, -"+to_string(4*$1->int_val)+"(%ebp)\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node; 
    }
    | IDS SELFMIN {
        TreeNode *node=new TreeNode(NODE_ASSIGN);
        node->opType=OP_SMIN;
        node->addChild($1);
        $$=node; 
        string str = "\tmovl\t$-1, %eax\n";
        str += "\taddl\t-" + to_string(4*$1->int_val) + "(%ebp), %eax\n";
        str += "\tmovl\t%eax, -"+to_string(4*$1->int_val)+"(%ebp)\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
    }
    ;
args
    : IDS {
        $$=$1; 
        string index;
        if($1->int_val == -1)
            index = to_string(4*(tmpins++));
        else
            index = to_string(4*$1->int_val);
        _function.addCode("\tmovl\t$0, -"+index+"(%ebp)\n"); 
        if(insflag) _function.addCode("\tsubl\t$4, %esp\n");
    }
    | ass {$$=$1;}
    | args COMMA IDS {
        $$=$1;
        $$->addSibling($3);
        string index;
        if($1->int_val == -1)
            index = to_string(4*(tmpins++));
        else
            index = to_string(4*$3->int_val);
        _function.addCode("\tmovl\t$0, -"+index+"(%ebp)\n"); 
        if(insflag) _function.addCode("\tsubl\t$4, %esp\n");
    }
    | args COMMA ass {$$=$1; $$->addSibling($3);}
    ;
call_args
    : expr {$$=$1;}
    | IDadd {$$=$1;}
    | IDptr {$$=$1;}
    | call_args COMMA expr {$$=$1; $$->addSibling($3);}
    | call_args COMMA IDadd {$$=$1; $$->addSibling($3);}
    | call_args COMMA IDptr {$$=$1; $$->addSibling($3);}
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
        _function.set($1->varType, $2->varName);
        $$=node;
    }
    ;
_else
    : ELSE
    {
        curlabel = label[if_lev-1];
        string lb1 = "LB" + to_string(curlabel) + to_string(if_lev - 1);
        string lb2 = "LB" + to_string(curlabel-1) + to_string(if_lev - 1);
        _function.addCode("\tjmp\t" + lb1 + "\n");
        _function.addCode(lb2 + ":\n");
        label.push_back(curlabel);
        curlabel = 0;
    }
    ;
iftest
    : IF bool_statment
    {
        _function.addCode("\tpopl\t%eax\n");
        _function.addCode("\tcmp\t$1, %eax\n");
        string lb = "LB" + to_string(curlabel++) + to_string(if_lev++);
        _function.addCode("\tjne\t"+lb+"\n");
        label.push_back(curlabel);
        curlabel = 0;
        $$=$2;
    }
    ;
if_else
    : iftest statement %prec LOWER_THEN_ELSE {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($1);
        node->addChild($2);
        curlabel = label[if_lev-1];
        string lb = "LB" + to_string(curlabel-1) + to_string(--if_lev);
        _function.addCode(lb + ":\n");
        label.pop_back();
        $$=node;
    }
    | iftest statement _else statement {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($1);
        node->addChild($2);
        node->addChild($4);
        curlabel = label[if_lev-1];
        string lb = "LB" + to_string(curlabel) + to_string(--if_lev);
        _function.addCode(lb + ":\n");
        label.pop_back();
        $$=node;
    }
    ;
_while
    : WHILE {
        whileflag = 1;
    }
whiletest
    : _while bool_statment {
        TreeNode *node=new TreeNode(NODE_WEXPR);
        node->int_val=whilectr;
        node->addChild($2);
        _function.addCode("WS"+to_string(whilectr)+":\n");
        for(int i = 0;i < whilecode.size();i++)
        {
            _function.addCode(whilecode[i]);
        }
        whilecode.clear();
        _function.addCode("\tpopl\t%eax\n");
        _function.addCode("\tcmpl\t$1, %eax\n");
        _function.addCode("\tjne\tWE"+to_string(whilectr++)+"\n");
        whileflag = 0;
        $$=node;
    }
while
    : whiletest statement {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_WHILE;
        node->addChild($1);
        node->addChild($2);
        _function.addCode("\tjmp\tWS"+to_string($1->int_val)+"\n");
        _function.addCode("WE"+to_string($1->int_val)+":\n");
        $$=node;
    }
    ;
for
    : _for for_expr statement{
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FOR;
        node->addChild($2);
        node->addChild($3);
        $$=node;
        while(tmpfor[tmpfor.size()-1].l == forlevel)
        {
            curlayer.pop_back();
            tmpfor.pop_back();
        }
        forlevel--;
        for(int i = 0;i < forcode.size();i++)
        {
            _function.addCode(forcode[i]);
        }
        forcode.clear();
        _function.addCode("\tjmp\tFS"+to_string($2->getChild(0)->int_val)+"\n");
        _function.addCode("FE"+to_string($2->getChild(0)->int_val)+":\n");
    }
    ;
_for
    : FOR
    {
        $$=$1;
        forflagi = 1;
        forflagb = 0;
        forflaga = 0;
    }
for_expr
    : for_expr1 for_expr2 {
        TreeNode *node=new TreeNode(NODE_FEXPR);
        node->int_val = forctr;
        node->addChild($1);
        node->addChild($2);
        $$ = node;
    }
for_expr1
    : LPAREN instruction bool_expr SEMICOLON {
        TreeNode *node=new TreeNode(NODE_FEXPR);
        node->int_val = forctr;
        node->addChild($2);
        node->addChild($3);
        for(int i = 0;i < forcode.size();i++)
        {
            _function.addCode(forcode[i]);
        }
        forcode.clear();
        _function.addCode("\tpopl\t%eax\n");
        _function.addCode("\tcmpl\t$1, %eax\n");
        _function.addCode("\tjne\tFE"+to_string(forctr)+"\n");
        forflagb = 0;
        forflaga = 1;
        $$=node;
    }
for_expr2
    : ass RPAREN {
        TreeNode *node=new TreeNode(NODE_FEXPR);
        node->int_val = forctr++;
        node->addChild($1);
        forflaga = 0;
        $$ = node;
        forlevel++;
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
        int vtype = $1->varType;
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
            if(cld->childNum() != 0 && cld->getChild(1)->varType != vtype)
            {
                printf("INVALID type\n");
                exit(1);
            }
            for(int j = l.size();j < curlayer.size();j++)
            {
                if(curlayer[j].name == (cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName))
                {
                    printf("ParseError(Same Variable)");
                    layer(curlayer, lid).output();
                    preflag = 1;
                    break;
                }
            }
            if(!preflag)
            {
                if(vtype == VAR_STR)
                {
                    if(cld->childNum() == 0)
                    {
                        printf("STRING NOT CONSTANT\n");
                        exit(1);
                    }
                    curlayer.push_back(variable(cld->getChild(0)->varName, _rodata.size()));
                    _rodata.push_back(cld->getChild(1)->str_val);
                    if(forflagi) tmpfor.push_back(tmpvariable(variable(cld->getChild(0)->varName, _rodata.size()), forlevel));
                    goto EA;
                }
                curlayer.push_back(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName));
                for(int j = 0;j < cld->dim.size();j++)
                {
                    curlayer[curlayer.size()-1].dim.push_back(cld->dim[j]);
                }
                if(forflagi) tmpfor.push_back(tmpvariable(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName), forlevel));
            }
            EA:preflag = 0;
        }
        if(forflagi) 
        {
            forflagb = 1;
            _function.addCode("FS" + to_string(forctr) + ":\n");
        }
        forflagi = 0;
        insflag = 0;
        tmpins = curlayer.size() + 1;
    }
    | args SEMICOLON {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_ASSIGN;
        node->addChild($1);
        for(int i = 0;i < node->childNum();i++)
        {
            TreeNode* cld = node->getChild(i);
            if(cld->childNum() != 1 && cld->getChild(0)->varType != cld->getChild(1)->varType)
            {
                printf("INVALID type\n");
                exit(1);
            }
        }
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
                    printf("ParseError(Same Variable)");
                    layer(curlayer, lid).output();
                    preflag = 1;
                    break;
                }
            }
            if(!preflag)
            {
                curlayer.push_back(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName));
                for(int j = 0;j < cld->dim.size();j++)
                {
                    curlayer[curlayer.size()-1].dim.push_back(cld->dim[j]);
                }
                if(forflagi) tmpfor.push_back(tmpvariable(variable($1->varType, cld->nodeType==NODE_ASSIGN?cld->getChild(0)->varName:cld->varName), forlevel));
            }
            preflag = 0;
        }
        forflagi = 0;
        forflagb = 1;
    }
    ;
printf
    : PRINTF LPAREN STRING COMMA call_args RPAREN {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        node->addChild($5);
        _rodata.push_back($3->str_val);
        vector<int> q;
        string str = $3->str_val;
        for(int i = 0;i < str.length();i++)
        {
            if(str[i] == '%')
            {
                if(i+1 == str.length())
                {
                    printf("INVALID CONTROL\n");
                    exit(1);
                }
                switch(str[i+1])
                {
                    case 'd':
                        q.push_back(VAR_INTEGER);
                        break;
                    case 'c':
                        q.push_back(VAR_CHAR);
                        break;
                    case 's':
                        q.push_back(VAR_STR);
                        break;
                    default:
                        printf("INVALID CONTROL.\n");
                        exit(1);
                }
            }
        }
        if(q.size()+1 != node->childNum())
        {
            printf("INVALID SCANF.\n");
            exit(1);
        }
        vector<string> tmpv;
        for(int i = 0;i < q.size();i++)
        {
            TreeNode* cld = node->getChild(i+1);
            if(q[i] != cld->varType)
            {
                printf("INVALID type\n");
                exit(1);
            }
            tmpv.push_back(_function.delCode());
        }
        for(int i = 0;i < tmpv.size();i++)
        {
            _function.addCode(tmpv[i]);
        }
        _function.addCode("\tsubl\t$"+to_string(curlayer.size()*4)+", %ebp\n");
        _function.addCode("\tpushl\t$STR"+to_string(_rodata.size()-1)+"\n");
        _function.addCode("\tcall\tprintf\n");
        _function.addCode("\taddl\t$"+to_string(curlayer.size()*4)+", %ebp\n");
        _function.addCode("\taddl\t$"+to_string(q.size()*4+4)+", %esp\n");
        $$=node;
    }
    | PRINTF LPAREN STRING RPAREN{
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        _rodata.push_back($3->str_val);
        _function.addCode("\tsubl\t$"+to_string(curlayer.size()*4)+", %ebp\n");
        _function.addCode("\tpushl\t$STR"+to_string(_rodata.size()-1)+"\n");
        _function.addCode("\tcall\tprintf\n");
        _function.addCode("\taddl\t$"+to_string(curlayer.size()*4)+", %ebp\n");
        _function.addCode("\taddl\t$4, %esp\n");
        $$=node;
    }
    ;
_SCANF
    : SCANF
    {
        scanflag = 1;
    }
scanf
    : _SCANF LPAREN STRING COMMA call_args RPAREN {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_SCANF;
        node->addChild($3);
        node->addChild($5);
        _rodata.push_back($3->str_val);
        vector<int> q;
        string str = $3->str_val;
        for(int i = 0;i < str.length();i++)
        {
            if(str[i] == '%')
            {
                if(i+1 == str.length())
                {
                    printf("INVALID CONTROL\n");
                    exit(1);
                }
                switch(str[i+1])
                {
                    case 'd':
                        q.push_back(VAR_INTEGER);
                        break;
                    case 'c':
                        q.push_back(VAR_CHAR);
                        break;
                    case 's':
                        q.push_back(VAR_STR);
                        break;
                    default:
                        printf("INVALID CONTROL.\n");
                        exit(1);
                }
            }
        }
        if(q.size()+1 != node->childNum())
        {
            printf("INVALID SCANF.\n");
            exit(1);
        }
        vector<string> tmpv;
        for(int i = 0;i < q.size();i++)
        {
            TreeNode* cld = node->getChild(i+1);
            if(q[i] != cld->varType)
            {
                printf("INVALID type\n");
                exit(1);
            }
            tmpv.push_back(_function.delCode());
        }
        for(int i = 0;i < tmpv.size();i++)
        {
            string str = tmpv[i].substr(7);
            str = "\tleal\t" + str.substr(0, str.find("\n")) + ", %eax\n";
            _function.addCode(str);
            _function.addCode("\tpushl\t%eax\n");
        }
        _function.addCode("\tsubl\t$"+to_string(curlayer.size()*4)+", %ebp\n");
        _function.addCode("\tpushl\t$STR"+to_string(_rodata.size()-1)+"\n");
        _function.addCode("\tcall\tscanf\n");
        _function.addCode("\taddl\t$"+to_string(curlayer.size()*4)+", %ebp\n");
        _function.addCode("\taddl\t$"+to_string(q.size()*4+4)+", %esp\n");
        $$=node;
        scanflag = 0;
    }
    ;
bool_expr
    : TRUE {
        $$=$1; 
        $$->varType = VAR_BOOLEAN; 
        if(whileflag)
        {
            whilecode.push_back("\tpushl\t$1\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpushl\t$1\n");
        }
        else
        {
            _function.addCode("\tpushl\t$1\n");
        }
    }
    | FALSE {
        $$=$1; 
        $$->varType = VAR_BOOLEAN; 
        if(whileflag)
        {
            whilecode.push_back("\tpushl\t$0\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpushl\t$0\n");
        }
        else
        {
            _function.addCode("\tpushl\t$0\n");
        }
    }
    | expr EQUAL expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_EQ;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        if($1->varType != $3->varType)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        string str = "\tpopl\t%eax\n"; 
        str += "\tpopl\t%ebx\n";
        str += "\tcmpl\t%eax, %ebx\n";
        str += "\tjne\t.BB" + to_string(bool_breaker++) + "\n";
        str += "\tpushl\t$1\n";
        str += "\tjmp\t.BB" + to_string(bool_breaker++) + "\n";
        str += ".BB" + to_string(bool_breaker-2) + ":\n";
        str += "\tpushl\t$0\n";
        str += ".BB" + to_string(bool_breaker-1) + ":\n";
        if(whileflag)
        {
            whilecode.push_back(str);
        }
        else if(forflagb)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;
    }
    | expr NEQUAL expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NE;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        if($1->varType != $3->varType)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        if(whileflag)
        {
            whilecode.push_back("\tpopl\t%eax\n");
            whilecode.push_back("\tpopl\t%ebx\n");
            whilecode.push_back("\tcmpl\t%eax, %ebx\n");
            whilecode.push_back("\tje\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back("\tpushl\t$1\n");
            whilecode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            whilecode.push_back("\tpushl\t$0\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tpopl\t%ebx\n");
            forcode.push_back("\tcmpl\t%eax, %ebx\n");
            forcode.push_back("\tje\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back("\tpushl\t$1\n");
            forcode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            forcode.push_back("\tpushl\t$0\n");
            forcode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\tcmpl\t%eax, %ebx\n");
            _function.addCode("\tje\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode("\tpushl\t$1\n");
            _function.addCode("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode(".BB" + to_string(bool_breaker-2) + ":\n");
            _function.addCode("\tpushl\t$0\n");
            _function.addCode(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        $$=node;
    }
    | expr BT expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_BT;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        $$=node;
        if(whileflag)
        {
            whilecode.push_back("\tpopl\t%eax\n");
            whilecode.push_back("\tpopl\t%ebx\n");
            whilecode.push_back("\tcmpl\t%eax, %ebx\n");
            whilecode.push_back("\tjle\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back("\tpushl\t$1\n");
            whilecode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            whilecode.push_back("\tpushl\t$0\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tpopl\t%ebx\n");
            forcode.push_back("\tcmpl\t%eax, %ebx\n");
            forcode.push_back("\tjle\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back("\tpushl\t$1\n");
            forcode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            forcode.push_back("\tpushl\t$0\n");
            forcode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\tcmpl\t%eax, %ebx\n");
            _function.addCode("\tjle\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode("\tpushl\t$1\n");
            _function.addCode("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode(".BB" + to_string(bool_breaker-2) + ":\n");
            _function.addCode("\tpushl\t$0\n");
            _function.addCode(".BB" + to_string(bool_breaker-1) + ":\n");
        }
    }
    | expr BE expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_BE;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        $$=node;
        if(whileflag)
        {
            whilecode.push_back("\tpopl\t%eax\n");
            whilecode.push_back("\tpopl\t%ebx\n");
            whilecode.push_back("\tcmpl\t%eax, %ebx\n");
            whilecode.push_back("\tjl\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back("\tpushl\t$1\n");
            whilecode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            whilecode.push_back("\tpushl\t$0\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tpopl\t%ebx\n");
            forcode.push_back("\tcmpl\t%eax, %ebx\n");
            forcode.push_back("\tjl\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back("\tpushl\t$1\n");
            forcode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            forcode.push_back("\tpushl\t$0\n");
            forcode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\tcmpl\t%eax, %ebx\n");
            _function.addCode("\tjl\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode("\tpushl\t$1\n");
            _function.addCode("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode(".BB" + to_string(bool_breaker-2) + ":\n");
            _function.addCode("\tpushl\t$0\n");
            _function.addCode(".BB" + to_string(bool_breaker-1) + ":\n");
        }
    }
    | expr LT expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_LT;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        if(whileflag)
        {
            whilecode.push_back("\tpopl\t%eax\n");
            whilecode.push_back("\tpopl\t%ebx\n");
            whilecode.push_back("\tcmpl\t%eax, %ebx\n");
            whilecode.push_back("\tjge\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back("\tpushl\t$1\n");
            whilecode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            whilecode.push_back("\tpushl\t$0\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tpopl\t%ebx\n");
            forcode.push_back("\tcmpl\t%eax, %ebx\n");
            forcode.push_back("\tjge\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back("\tpushl\t$1\n");
            forcode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            forcode.push_back("\tpushl\t$0\n");
            forcode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\tcmpl\t%eax, %ebx\n");
            _function.addCode("\tjge\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode("\tpushl\t$1\n");
            _function.addCode("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode(".BB" + to_string(bool_breaker-2) + ":\n");
            _function.addCode("\tpushl\t$0\n");
            _function.addCode(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        $$=node;
    }
    | expr LE expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_LE;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        if(whileflag)
        {
            whilecode.push_back("\tpopl\t%eax\n");
            whilecode.push_back("\tpopl\t%ebx\n");
            whilecode.push_back("\tcmpl\t%eax, %ebx\n");
            whilecode.push_back("\tjg\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back("\tpushl\t$1\n");
            whilecode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            whilecode.push_back("\tpushl\t$0\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tpopl\t%ebx\n");
            forcode.push_back("\tcmpl\t%eax, %ebx\n");
            forcode.push_back("\tjg\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back("\tpushl\t$1\n");
            forcode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            forcode.push_back("\tpushl\t$0\n");
            forcode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\tcmpl\t%eax, %ebx\n");
            _function.addCode("\tjg\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode("\tpushl\t$1\n");
            _function.addCode("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode(".BB" + to_string(bool_breaker-2) + ":\n");
            _function.addCode("\tpushl\t$0\n");
            _function.addCode(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        $$=node;
    }
    | bool_expr AND bool_expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_AND;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        // if($1->varType != VAR_BOOLEAN || $3->varType != VAR_BOOLEAN)
        // {
        //     printf("INVALID TYPE\n");
        //     exit(1);
        // }
        if(whileflag)
        {
            whilecode.push_back("\tpopl\t%eax\n");
            whilecode.push_back("\tpopl\t%ebx\n");
            whilecode.push_back("\taddl\t%eax, %ebx\n");
            whilecode.push_back("\tmovl\t$2, %eax\n");
            whilecode.push_back("\tcmpl\t%ebx, %eax\n");
            whilecode.push_back("\tjne\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back("\tpushl\t$1\n");
            whilecode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            whilecode.push_back("\tpushl\t$0\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tpopl\t%ebx\n");
            forcode.push_back("\taddl\t%eax, %ebx\n");
            forcode.push_back("\tmovl\t$2, %eax\n");
            forcode.push_back("\tcmpl\t%ebx, %eax\n");
            forcode.push_back("\tjne\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back("\tpushl\t$1\n");
            forcode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            forcode.push_back("\tpushl\t$0\n");
            forcode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\taddl\t%eax, %ebx\n");
            _function.addCode("\tmovl\t$2, %eax\n");
            _function.addCode("\tcmpl\t%ebx, %eax\n");
            _function.addCode("\tjne\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode("\tpushl\t$1\n");
            _function.addCode("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode(".BB" + to_string(bool_breaker-2) + ":\n");
            _function.addCode("\tpushl\t$0\n");
            _function.addCode(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        $$=node;
    }
    | bool_expr OR bool_expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_OR;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_BOOLEAN;
        // if($1->varType != VAR_BOOLEAN || $3->varType != VAR_BOOLEAN)
        // {
        //     printf("INVALID TYPE\n");
        //     exit(1);
        // }
        if(whileflag)
        {
            whilecode.push_back("\tpopl\t%eax\n");
            whilecode.push_back("\tpopl\t%ebx\n");
            whilecode.push_back("\taddl\t%eax, %ebx\n");
            whilecode.push_back("\tmovl\t$0, %eax\n");
            whilecode.push_back("\tcmpl\t%ebx, %eax\n");
            whilecode.push_back("\tje\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back("\tpushl\t$1\n");
            whilecode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            whilecode.push_back("\tpushl\t$0\n");
            whilecode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else if(forflagb)
        {
            forcode.push_back("\tpopl\t%eax\n");
            forcode.push_back("\tpopl\t%ebx\n");
            forcode.push_back("\taddl\t%eax, %ebx\n");
            forcode.push_back("\tmovl\t$0, %eax\n");
            forcode.push_back("\tcmpl\t%ebx, %eax\n");
            forcode.push_back("\tje\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back("\tpushl\t$1\n");
            forcode.push_back("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            forcode.push_back(".BB" + to_string(bool_breaker-2) + ":\n");
            forcode.push_back("\tpushl\t$0\n");
            forcode.push_back(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        else
        {
            _function.addCode("\tpopl\t%eax\n");
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\taddl\t%eax, %ebx\n");
            _function.addCode("\tmovl\t$0, %eax\n");
            _function.addCode("\tcmpl\t%ebx, %eax\n");
            _function.addCode("\tje\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode("\tpushl\t$1\n");
            _function.addCode("\tjmp\t.BB" + to_string(bool_breaker++) + "\n");
            _function.addCode(".BB" + to_string(bool_breaker-2) + ":\n");
            _function.addCode("\tpushl\t$0\n");
            _function.addCode(".BB" + to_string(bool_breaker-1) + ":\n");
        }
        $$=node;
    }
    | NOT bool_expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NOT;
        node->addChild($2);
        node->varType=VAR_BOOLEAN;
        // if($2->varType != VAR_BOOLEAN)
        // {
        //     printf("INVALID TYPE\n");
        //     exit(1);
        // }
        string str = "\tpopl\t%eax\n";
        str += "\tcmpl\t$0, %eax\n";
        str += "\tjne\t.BB" + to_string(bool_breaker++) + "\n";
        str += "\tpushl\t$1\n";
        str += "\tjmp\t.BB" + to_string(bool_breaker++) + "\n";
        str += ".BB" + to_string(bool_breaker-2) + ":\n";
        str += "\tpushl\t$0\n";
        str += ".BB" + to_string(bool_breaker-1) + ":\n";
        if(whileflag)
        {
            whilecode.push_back(str);
        }
        else if(forflagb)
        {
            forcode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;        
    }
    | expr
    {
        $$=$1;
        string str = "\tpopl\t%eax\n";
        str += "\tcmpl\t$0, %eax\n";
        str += "\tje\t.BB" + to_string(bool_breaker++) + "\n";
        str += "\tpushl\t$1\n";
        str += "\tjmp\t.BB" + to_string(bool_breaker++) + "\n";
        str += ".BB" + to_string(bool_breaker-2) + ":\n";
        str += "\tpushl\t$0\n";
        str += ".BB" + to_string(bool_breaker-1) + ":\n";
        _function.addCode(str);
    }
    ;
expr
    : IDS {
        $$=$1;
        vector<variable>::reverse_iterator it = curlayer.rbegin();
        int i = 0;
        while(it != curlayer.rend())
        {
            if((*it).name == $$->varName)
            {
                string code = "\tpushl\t";
                if($$->varType == VAR_STR)
                    code += "$STR" + to_string($$->int_val) + "\n";
                else
                    code += "-" + to_string(4*(curlayer.size()-i)) + "(%ebp)\n";
                if(whileflag)
                {
                    whilecode.push_back(code);
                }
                else if(forflagb || forflaga)
                {
                    forcode.push_back(code);
                }
                else
                {
                    _function.addCode(code);
                }
                break;
            }
            it++;
            i++;
        }
    }
    | INTEGER {
        $$=$1;
        if(whileflag)
        {
            whilecode.push_back("\tpushl\t$" + to_string($$->int_val) + "\n");
        }
        else if(forflagb || forflaga)
        {
            forcode.push_back("\tpushl\t$" + to_string($$->int_val) + "\n");
        }
        else
        {
            _function.addCode("\tpushl\t$" + to_string($$->int_val) + "\n");
        }
    }
    | CHARACTER {$$=$1;}
    | STRING {$$=$1;}
    | expr ADD expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_ADD;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_INTEGER;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        } 
        string str = "\tpopl\t%ebx\n\tpopl\t%eax\n\taddl\t%eax, %ebx\n\tpushl\t%ebx\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else if(whileflag)
        {
            whilecode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;   
    }
    | expr MINUS expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MINUS;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_INTEGER;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        string str = "\tpopl\t%eax\n\tpopl\t%ebx\n\tsubl\t%eax, %ebx\n\tpushl\t%ebx\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else if(whileflag)
        {
            whilecode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;   
    }
    | expr MULTI expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MULTI;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_INTEGER;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        string str = "\tpopl\t%ebx\n\tpopl\t%eax\n\timull\t%ebx\n\tpushl\t%eax\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else if(whileflag)
        {
            whilecode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;   
    }
    | expr DIV expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_DIV;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_INTEGER;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        string str = "\tpopl\t%ebx\n\tpopl\t%eax\n\tcltd\n\tidivl\t%ebx\n\tpushl\t%eax\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else if(whileflag)
        {
            whilecode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;   
    }
    | expr MOD expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MOD;
        node->addChild($1);
        node->addChild($3);
        node->varType=VAR_INTEGER;
        if($1->varType != VAR_INTEGER || $3->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        string str = "\tpopl\t%ebx\n\tpopl\t%eax\n\tcltd\n\tidivl\t%ebx\n\tpushl\t%edx\n";
        if(forflaga)
        {
            forcode.push_back(str);
        }
        else if(whileflag)
        {
            whilecode.push_back(str);
        }
        else
        {
            _function.addCode(str);
        }
        $$=node;   
    }
    | MINUS expr %prec NEG {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NEG;
        node->addChild($2);
        node->varType=VAR_INTEGER;
        if($2->varType != VAR_INTEGER)
        {
            printf("INVALID TYPE\n");
            exit(1);
        }
        TreeNode* cld = node->getChild(0);
        if(cld->varName == "#")
        {
            _function.resetCode("\tpushl\t$-" + to_string(cld->int_val) + "\n");
        }
        else
        {
            _function.addCode("\tpopl\t%ebx\n");
            _function.addCode("\tmovl\t$-1, %eax\n");
            _function.addCode("\timull\t%ebx\n");
            _function.addCode("\tpushl\t%eax\n");
        }
        $$=node; 
    }
    ;
type
    : INT {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_INTEGER;
        insflag = 1;
        $$=node; 
    }
    | VOID {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_VOID;
        insflag = 1;
        $$=node;         
    }
    | CHAR {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_CHAR;
        insflag = 1;
        $$=node;
    }
    | STR {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_STR;
        insflag = 1;
        $$=node;
    }
    ;
IDARR
    : ID LBRACK expr RBRACK {
        $$=$1;
        $$->dim.push_back($3->int_val);
    }
    | IDARR LBRACK expr RBRACK {
        $$=$1;
        $$->dim.push_back($3->int_val);
    }
    ;
IDcld
    : ID dot ID {
        $$=$1;
        $$->varType = $3->varType;
        $$->addChild($3);
    }
    | IDARR dot ID {
        $$=$1;
        $$->varType = $3->varType;
        $$->addChild($3);
    }
    | ID dot IDARR {
        $$=$1;
        $$->varType = $3->varType;
        $$->addChild($3);
    }
    | IDARR dot IDARR {
        $$=$1;
        $$->varType = $3->varType;
        $$->addChild($3);
    }
    | IDcld dot ID {
        $$=$1;
        $$->varType = $3->varType;
        $$->addChild($3);
    }
    | IDcld dot IDARR {
        $$=$1;
        $$->varType = $3->varType;
        $$->addChild($3);
    }
    ;
IDS 
    : ID {
        $$=$1;
        if($$->int_val == -1)
        {
            vector<variable>::reverse_iterator it = curlayer.rbegin();
            int i = 0;
            while(it != curlayer.rend())
            {
                if((*it).name == $$->varName)
                {
                    break;
                }
                it++;
                i++;
            }
            if(!insflag) $$->int_val = curlayer.size() - i;
            if($$->varType == VAR_STR) $$->int_val = (*it).ro_index;
        }
    }
    | IDARR {$$=$1;}
    | IDcld {$$=$1;}
%%