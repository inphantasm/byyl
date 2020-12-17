#include"asm.h"
void rodata::output()
{
    {
        int i = 0;
        for (vector<string>::iterator it = _rodata.begin(); it != _rodata.end(); it++, i++)
        {
            printf("STR%d:\n\t.string \"%s\"\n", i, (*it).c_str());
        }
    }
}
void rodata::push_back(string str)
{
    _rodata.push_back(str);
}
int rodata::size()
{
    return _rodata.size();
}

function::function(int _funcType, string _name)
{
    funcType = _funcType;
    name = _name;
    ret = 0;
    buf = false;
}
void function::set(int _funcType, string _name)
{
    funcType = _funcType;
    name = _name;
}
void function::output()
{
    printf("\t.text\n");
    printf("\t.globl\t%s\n", name.c_str());
    printf("\t.type\t%s, @function\n", name.c_str());
    printf("%s:\n", name.c_str());
    printf("\tpushl\t%%ebp\n");
    printf("\tmovl\t%%esp, %%ebp\n");
    for (vector<string>::iterator it = code.begin(); it != code.end(); it++)
    {
        if(*(it) == "\tpushl\t%eax\n" && *(it+1) == "\tpopl\t%eax\n")
        {
            it += 2;
        }
        if(*(it) == "\tpushl\t%ebx\n" && *(it+1) == "\tpopl\t%ebx\n")
        {
            it += 2;
        }
        printf("%s", (*it).c_str());
    }
    printf("\tpopl\t%%ebp\n");
    printf("\tmovl\t$%d, %%eax\n", ret);
    printf("\tret\n");
}
void function::addCode(string _code)
{
    code.push_back(_code);
}
string function::delCode()
{
    string str = code[code.size() - 1];
    code.pop_back();
    return str;
}
void function::resetCode(string _code)
{
    code[code.size() - 1] = _code;
}
void function::ASM_Expr_erg(TreeNode *node)
{
    if(node->childNum() < 2)
    {
        string str = "\tpushl\t$" + to_string(node->childNum() ? (0 - node->getChild(0)->int_val) : node->int_val) + "\n";
        addCode(str);
        return;
    }
    else
    {
        ASM_Expr_erg(node->getChild(0));
        ASM_Expr_erg(node->getChild(1));
    }
}
void function::ASM_Expr(TreeNode *node)
{
    ASM_Expr_erg(node);
    string str = "\tpopl\t%ebx\n";
    addCode(str);
}