#include"main.tab.hh"
#include"common.h"
#include<iostream>
using std::cout;
using std::endl;
TreeNode *root=nullptr;
vector<layer> layers;
vector<variable> curlayer;
vector<struct_def> strdef;
rodata _rodata;
function _function(-1, "");
int lid = 0;
int main ()
{
    yyparse();
    if(root){
        root->genNodeId();
        root->printAST();
    }
}
int yyerror(char const* message)
{
  cout << message << endl;
  return -1;
}