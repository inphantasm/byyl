#pragma once
#include"tree.h"
#include<string>
using namespace std;
class struct_def
{
public:
    string name;
    vector<variable> var;
    int struct_index;
    struct_def(string name, vector<variable> var)
    {
        this->name = name;
        this->var = var;
    }
};
static int struct_num = 4;