#ifndef NFA_HPP
#define NFA_HPP

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

// Forward declaration of DFA class
class DFA;

class NFA {
    friend class DFA;
public:
    struct State
    {
        map<char, set<State*>> edges;
        void addEdge(char c, State* ngb);
    };

    struct nfa
    {
        State* in;
        State* out;
        nfa();
        nfa(State* arg_in, State* arg_out);
        nfa* deepcopy() const;
        vector<State*> allStates() const;
    };

    NFA(string& reg);
    NFA(const DFA& dfa_class, bool removeDeadStates = true);
    ~NFA();

    string generateDotString();
    void generateDotfile();
    const nfa* getNFA() const;
    unordered_set<char> getSymbols() const;
    static set<State*> Eclose(set<State*> stateSet);
    static set<State*> getTransitionSet(char c, set<State*> stateSet);

    NFA unionNFA(const NFA& other) const;
    NFA intersection(const NFA& other) const;
    NFA complement() const;
    NFA concat(const NFA& other) const;
    NFA reverseNFA() const;
private:
    
    nfa* theNFA;

    NFA();
    nfa* post2nfa(string& post);
    string generateDotString(nfa* exp);
};

#endif