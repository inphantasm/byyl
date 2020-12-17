#pragma once
#include<iostream>
#include<string>
#include<vector>
#include"tree.h"
using namespace std;
class rodata{
private:
    vector<string> _rodata;
public:
    void output();
    void push_back(string str);
    int size();
};
class function{
private:
    int funcType;
    bool buf;
    vector<string> code;
    vector<string> codebuf;
    string name;
    int ret;
public:
    function(int _funcType, string _name);
    void set(int _funcType, string _name);
    void output();
    void addCode(string _code);
    string delCode();
    void resetCode(string _code);
    void ASM_Expr_erg(TreeNode *node);
    void ASM_Expr(TreeNode* node);
};