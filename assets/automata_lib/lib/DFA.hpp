#ifndef DFA_HPP
#define DFA_HPP

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

#include "NFA.hpp"

class DFA
{
    friend class NFA;
private:
    int symbolSize;
    unordered_map<char, int> symbols; // maps symbol to index
    vector<vector<int>> table; // transition table of DFA
    unordered_set<int> final_states; // final states of DFA
    bool minimalDFA;


    int appendRow();
    void build(const NFA& nfa_class);
    DFA( vector<char> _symbols, vector<vector<int>> _table, vector<int> _final_states, bool _minimalDFA);
    DFA( unordered_map<char, int> _symbols, vector<vector<int>> _table, unordered_set<int> _final_states, bool _minimalDFA);
public:
    DFA(string& reg);
    DFA( vector<char> _symbols, vector<vector<int>> _table, vector<int> _final_states);
    DFA(const NFA& nfa_class);
    static DFA read_txt(string path);
    vector<vector<int>> getTransitionTable();
    int getStateNgb(int ind, char sym) const;
    vector<char> getSymbols() const;
    void printTable();
    bool isMinimal() const noexcept;
    bool isFinalState(const int& ind) const noexcept;
    size_t stateCount() const noexcept;
    vector<int> getDeadStates() const;
    bool test(const string& str);
    vector<pair<string, bool>> getStringBFS();
    map<string, bool> getStringK(int k) const;
    string getDiffString(const DFA& d2, int max_depth=-1);
    DFA minimal() const;
    string regex() const;
    DFA unionDFA(const DFA& other) const;
    DFA intersection(const DFA& other) const;
    DFA complement() const;
    DFA concat(const DFA& other) const;
    DFA reverse() const;
    bool isSubset(const DFA& other) const;
    bool isSuperset(const DFA& other) const;
    bool operator==(const DFA& d2);
    bool operator!=(const DFA& d2);
    string generateDotString(bool showDeadStates = true);
    void generateDotfile(bool showDeadStates = true);
    string generateTextString();
};


#endif