#pragma once
#include<vector>
#include<string>
using namespace std;
enum NodeType
{
    NODE_PROG,
    NODE_STMT,
    NODE_OP,
    NODE_TYPE,
    NODE_BOOL,
    NODE_CONINT,
    NODE_CONCHAR,
    NODE_CONSTR,
    NODE_FEXPR,
    NODE_WEXPR,
    NODE_VAR,
    NODE_FUNC,
    NODE_ASSIGN,
    NODE_STRDEF
};
enum OPType
{
    OP_ADD, OP_MINUS, OP_MULTI, OP_DIV, OP_MOD,
    OP_SADD, OP_SMIN, OP_NEG,
    OP_NOT, OP_AND, OP_OR,
    OP_EQ, OP_LT, OP_LE, OP_BT, OP_BE, OP_NE
};
enum STMTType
{
    STMT_IF,
    STMT_WHILE,
    STMT_FOR,
    STMT_DECL,
    STMT_ASSIGN,
    STMT_PRINTF,
    STMT_SCANF
};
enum VarType
{
    VAR_VOID,
    VAR_BOOLEAN,
    VAR_INTEGER,
    VAR_CHAR,
    VAR_STR
};
enum VarFlag
{
    VAR_COMMON,
    VAR_ADDRESS,
    VAR_POINTER
};
static int NodeIndex = 0;
class TreeNode
{
public:
    TreeNode(int NodeType);
    void addChild(TreeNode *child);     // 加个孩子
    void addSibling(TreeNode *sibling); // 加个兄弟
    void genNodeId();                   // 递归给id
    void printAST();                    
    void printASM();                    
    TreeNode *getChild(int index);      // 良好的封装
    int childNum();                     // 是坠吼的
    vector<int> dim; // Level2的数组
    int nodeType, nodeIndex;            
    int opType, stmtType;
    int varType, int_val, varFlag;
    bool bool_val;
    vector<string> code;
    string str_val;
    string varName;                     // 属性，看你心情
private:
    vector<TreeNode *> CHILDREN;        // 孩子
    vector<TreeNode *> SIBLING;         // 兄弟
                                        // 因为左孩子右兄弟结构太麻烦了而且容易出错，所以干脆这么玩
};