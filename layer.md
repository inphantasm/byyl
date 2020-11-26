#include<string>
#include<vector>
using namespace std;

/*
    作用域和分层功能，尚未实装
*/

/*
    TODO: 将本部分加入【定义类】的位置
*/
#if(0)

class variable
{
public:
    string name;
    int vid;
    variable(string name, int vid)
    {
        this->name = name;
        this->vid = vid;
    }
};
class layer
{
public:
    vector<variable> varies;
    int lindex;
    layer(vector<variable> varies, int lindex)
    {
        this->varies = varies;
        this->lindex = lindex;
    }
};
vector<layer> layers;
vector<variable> curlayer;

#endif

/*
    TODO: 将本部分加入【定义变量】的位置
*/
#if(0)

int preflag = 0;
vector<variable> l;
if(!layers.empty())
{
    l = layers[layers.size()-1].varies;
}
for(int i = l.size();i < curlayer.size();i++)
{
    if(curlayer[i].name == yytext)
    {
        printf("ParseError: this variable presents.\n");
        preflag = 1;
        break;
    }
}
if(!preflag)
    curlayer.push_back(variable(yytext, curlayer.size()));

#endif

/*
    TODO: 将本部分加入【新作用域左界】的位置
*/
#if(0)

layers.push_back(layer(curlayer, lid++));

#endif

/*
    TODO: 将本部分加入【新作用域右界】的位置
*/
#if(0)

while(!curlayer.empty())
{
    // printf("layer: %d", lid);
    variable tmpv = curlayer[curlayer.size()-1];
    // printf("    %s  %d\n", tmpv.name.c_str(), tmpv.vid);
    curlayer.pop_back();
}
curlayer = layers[layers.size()-1].varies;
lid--;

#endif


/*
    TODO: 将本部分加入【新作用域右界】的位置
*/
#if(0)

int preflag = 0;
vector<variable> l;
if(!layers.empty())
{
    l = layers[layers.size()-1].varies;
}
for(int i = l.size();i < curlayer.size();i++)
{
    if(curlayer[i].name == yytext)
    {
        printf("ParseError: this variable presents.\n");
        preflag = 1;
        break;
    }
}
if(!preflag)
    curlayer.push_back(variable(yytext, curlayer.size()));

#endif