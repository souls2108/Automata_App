#ifndef ParseTree_HPP
#define ParseTree_HPP

#include <string>
#include <stack>
#include <queue>
#include <list>
#include <iostream>
#include <vector>
#include <map>
#include <set>
#include <unordered_map>
#include <unordered_set>
#include <algorithm>
#include <iterator>
using namespace std;

class ParseTree
{
public:
    struct Node
    {
        char label;
        vector<Node*> children;
        Node(char l);
    };    

    ParseTree(string& reg);
    ~ParseTree();
    string generateDotString();
    void generateDotfile();

private:
    Node* root;

    Node* post2tree(const string& post);

};


#endif