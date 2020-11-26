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
    VAR_INTEGER,
    VAR_CHAR,
    VAR_STRING,
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
    void addChild(TreeNode *child);
    void addSibling(TreeNode *sibling);
    void genNodeId();
    void printAST();
    TreeNode* getChild(int index);
    int childNum();

    vector<TreeNode *> dim;
    int nodeType, nodeIndex;
    int opType, stmtType;
    int varType, int_val, varFlag;
    bool bool_val;
    string str_val;
    string varName;
private:
    vector<TreeNode *> CHILDREN;
    vector<TreeNode *> SIBLING;
};