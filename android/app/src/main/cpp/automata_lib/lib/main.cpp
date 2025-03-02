#include "NFA.hpp"
#include "DFA.hpp"
#include "ParseTree.hpp"
#include "AutomataUtil.hpp"

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
#include <fstream>
using namespace std;

#define EPSILON 'E'

typedef long long ll;

class DisjointSet
{
private:
    vector<int> parent;
    vector<int> size;
public:
    DisjointSet(int n) {
        size.assign(n, 1);
        parent.assign(n, -1);
        for(int i=0; i<n; i++) parent[i] = i;
    }

    int findPar(int u) {
        if(u == parent[u]) {
            return u;
        }
        return parent[u] = findPar(parent[u]);
    }

    void unionBySize(int u, int v) {
        int par_u = findPar(u);
        int par_v = findPar(v);
        if(size[par_u] <= size[par_v]) {
            parent[par_u] = par_v;
            size[par_v] += size[par_u];
        }
    }

    /**
     * @return map of parent to children {parent: set(child nodes)}
     */
    map<int, set<int>> getSubsets() {
        map<int, set<int>> subset;
        int n = parent.size();
        for(int i=0; i<n; i++) {
            subset[findPar(i)].insert(i);
        }
        return subset;
    } 
};


int prec(char c) {
  if (c == '*')
    return 3;
  else if (c == '.')
    return 2;
  else if (c == '+')
    return 1;
  else
    return -1;
}


string infix2post(string& reg) {
    string post;
    stack<char> st;
    
    for (char c : reg) {
        switch (c) {
        case '(':
        {
            st.push(c);
            break;
        }

        case ')':
        {
            while (st.top() != '(') {
                post += st.top();
                st.pop();
            }
            st.pop();
            break;
        }

        case '*':
        case '.':
        case '+':
        {
            while (!st.empty() && prec(c) <= prec(st.top())) {
                post += st.top();
                st.pop();
            }
            st.push(c);
            break;
        }

        default:
        {
            post += c;
            break;
        }
        }
    }

    while (!st.empty())
    {
        char c = st.top(); st.pop();
        post += c; 
    }
    
    return post;    
}

// ----------------------------------------- Parse Tree Start ----------------------------------------

ParseTree::Node::Node(char l) {
    label = l;
}

ParseTree::ParseTree(string& reg) {
    this->root = post2tree(infix2post(reg));
}

ParseTree::~ParseTree() {
    stack<Node*> st;
    st.push(root);
    while(!st.empty()) {
        Node* node = st.top(); st.pop();
        for(auto& child : node->children) {
            st.push(child);
        }
        delete node;
    }
}

string ParseTree::generateDotString() {
    string dotText;
    string header = R"(
graph ""
{
    fontname="Helvetica,Arial,sans-serif"
    node [fontname="Helvetica,Arial,sans-serif"]
    edge [fontname="Helvetica,Arial,sans-serif"]
#   node [fontsize=10,width=".2", height=".2", margin=0];
   graph[fontsize=8];
)";
    string footer = R"(
}
)";
    dotText += header;


    stack<Node*> st;
    map<Node*, string> nodeNameMap;
    st.push(root);
    ll cnt = 0;
    while (!st.empty())
    {
        Node* node = st.top(); st.pop();
        nodeNameMap[node] = "n" + to_string(cnt++);

        for(auto child : node->children) {
            st.push(child);
        }
    }

    st.push(root);
    while (!st.empty())
    {
        Node* node = st.top(); st.pop();
        dotText += "\t" + nodeNameMap[node] + " [label=\"" + node->label + "\"] ;\n";
        for(auto& child : node->children) {
            st.push(child);
            dotText += "\t" + nodeNameMap[node] + " -- " + nodeNameMap[child] + " ;\n";
        }
    }
    dotText += footer;

    return dotText;    
}

void ParseTree::generateDotfile() {
    cout << generateDotString();
}

ParseTree::Node* ParseTree::post2tree(const string& post) {
    int n = post.size();

    stack<Node*> st;
    for(const char& c : post) {
        switch(c)
        {
        case '*':
        {
            Node* e = st.top(); st.pop();
            Node* exp_node = new Node('*');
            exp_node->children.push_back(e);
            st.push(exp_node);
            break;
        }
        case '.':
        {
            Node* e1 = st.top(); st.pop();
            Node* e2 = st.top(); st.pop();
            Node* exp_node = new Node('.');
            exp_node->children.push_back(e2);
            exp_node->children.push_back(e1);
            st.push(exp_node);
            break;
        }
        case '+':
        {
            Node* e1 = st.top(); st.pop();
            Node* e2 = st.top(); st.pop();
            Node* exp_node = new Node('+');
            exp_node->children.push_back(e2);
            exp_node->children.push_back(e1);
            st.push(exp_node);
            break;
        }
        
        default:
        {
            st.push(new Node(c));
            break;
        }
        }
    }

    return st.top();
}

// ----------------------------------------- Parse Tree End ----------------------------------------

// ----------------------------------------- NFA Start ----------------------------------------

void NFA::State::addEdge(char c, State* ngb) {
    edges[c].insert(ngb);
}
NFA::nfa::nfa() {
    in = 0;
    out = 0;
}
NFA::nfa::nfa(State* arg_in, State* arg_out){
    in = arg_in; out = arg_out;
}
NFA::nfa* NFA::nfa::deepcopy() const {
    unordered_map<State*, State*> newStateMap;
    auto getNewState = [&] (State* oldState) -> State* {
        const auto& it =  newStateMap.find(oldState);
        State* newState;
        if(it == newStateMap.end()) {
            newState = new State();
            newStateMap[oldState] = newState;
        } else {
            newState = it->second;
        }
        return newState;
    };

    unordered_set<State*> vis;
    queue<State*> q;

    q.push(in);
    vis.insert(in);
    while (!q.empty()) {
        State* oldState = q.front(); q.pop();
        State* newState = getNewState(oldState);
        for(auto& it : oldState->edges){
            const char& sym = it.first;
            for(auto* oldNgbState : it.second) {
                State* newNgbState = getNewState(oldNgbState);
                newState->addEdge(sym, newNgbState);
                if(vis.count(oldNgbState) == 0) {
                    q.push(oldNgbState);
                    vis.insert(oldNgbState);
                }
            }
        }
    }
    return new nfa(
        getNewState(in),
        getNewState(out));
}
/**
 * @brief Get all states in the NFA.
 * 
 * This function performs a breadth-first search (BFS) to collect all states in the NFA.
 * The returned vector contains the start state at index 0 and the out state at the last index.
 * 
 * @return vector<State*> A vector of pointers to all states in the NFA, with the start state at index 0 and the out state at the last index.
 */
vector<NFA::State*> NFA::nfa::allStates() const {
    unordered_set<State*> vis;
    queue<State*> q;

    q.push(in);
    vis.insert(in);
    while(!q.empty()) {
        State* node = q.front(); q.pop();
        for(auto& it : node->edges) {
            for(auto& ngbState : it.second) {
                if(vis.count(ngbState) == 0) {
                    q.push(ngbState);
                    vis.insert(ngbState);
                }
            }
        }
    }

    vector<State*> stateList(vis.size());
    int ind = 0;
    stateList[ind++] = in;
    for(const auto& state : vis) {
        if(state != in && state != out) {
            stateList[ind++] = state;
        }
    }
    stateList[ind++] = out;
    return stateList;
}

NFA::NFA(string& reg) {
    string postfix = infix2post(reg);
    this->theNFA = post2nfa(postfix);
}

NFA::NFA(const DFA& dfa_class, bool removeDeadStates) {
    int dfaStateCnt = dfa_class.stateCount();
    vector<State*> dfaNfaStateMap(dfaStateCnt);
    for(int i=0; i<dfaStateCnt; ++i) dfaNfaStateMap[i] = new State();

    vector<char> dfaSymbols(dfa_class.getSymbols());

    vector<int> dfaDeadStates = dfa_class.getDeadStates();
    set<int> dfaDeadStatesSet(dfaDeadStates.begin(), dfaDeadStates.end());
    auto isDeadState = [&] (int stateIndex) -> bool {
        return dfaDeadStatesSet.count(stateIndex);
    };

    for(int stateIndex=0; stateIndex<dfaStateCnt; ++stateIndex) {
        if(removeDeadStates && isDeadState(stateIndex)) continue;
        State* currNfaState = dfaNfaStateMap[stateIndex];
        for(const char& sym : dfaSymbols) {
            int dfaNgbState = dfa_class.getStateNgb(stateIndex, sym);
            if(removeDeadStates && isDeadState(dfaNgbState)) continue;

            State* ngbNfaState = dfaNfaStateMap[dfaNgbState];
            currNfaState->addEdge(sym, ngbNfaState);
        }
    }

    State* in = dfaNfaStateMap[0];
    State* out = new State();
    for(const int& dfaFinalState : dfa_class.final_states) {
        dfaNfaStateMap[dfaFinalState]->addEdge(EPSILON, out);
    }

    theNFA = new nfa(in, out);
}

NFA::~NFA() {
    queue<State*> q;
    set<State*> visited;
    q.push(theNFA->in);
    visited.insert(theNFA->in);
    while(!q.empty()) {
        State* state = q.front(); q.pop();
        for(auto& it : state->edges) {
            for(auto& ngb : it.second) {
                if(visited.find(ngb) == visited.end())
                    q.push(ngb), visited.insert(ngb);
            }
        }
    }
    for(auto& it : visited) delete it;
    delete theNFA;
}

string NFA::generateDotString() {
    return generateDotString(theNFA);
}

void NFA::generateDotfile() {
    cout << generateDotString(theNFA);
}

const NFA::nfa* NFA::getNFA() const {
    return theNFA;
}

/**
* computationally expensive
*/
unordered_set<char> NFA::getSymbols() const {
   unordered_set<char> symbols;
   unordered_set<State*> vis;
   queue<State*> q;

   q.push(theNFA->in);
   while(!q.empty()){
       State* curr_state = q.front(); q.pop();
       vis.insert(curr_state);

       for(auto& it : curr_state->edges) {
           symbols.insert(it.first);
           for(State* ngbState : it.second) {
               if(!vis.count(ngbState)) q.push(ngbState);
           }
       }
   }

   return symbols;
}

/**
 * Multi source BFS for epsilon closure
 */
set<NFA::State*> NFA::Eclose(set<NFA::State*> stateSet) {
    queue<State*> q;
    set<State*> EStateSet;
    for(State* state : stateSet) q.push(state);

    while (!q.empty())
    {
        State* state = q.front(); q.pop();
        EStateSet.insert(state);

        for(State* ngb : state->edges[EPSILON]) {
            if (EStateSet.find(ngb) == EStateSet.end())
            {
                q.push(ngb);
            }
        }
    }

    return EStateSet;    
}

set<NFA::State*> NFA::getTransitionSet(char c, set<NFA::State*> stateSet) {
    set<State*> transStateSet;
    for(const State* state : stateSet) {
        if(state->edges.count(c) > 0) {
            for(auto& ngb : state->edges.at(c))
                transStateSet.insert(ngb);
        }
    }
    return transStateSet;
}

NFA NFA::unionNFA(const NFA& other) const {
    nfa* currNfa = theNFA->deepcopy();
    nfa* otherNfa = other.theNFA->deepcopy();
    nfa* resNfa = new nfa(new State(), new State());
    resNfa->in->addEdge(EPSILON, currNfa->in);
    resNfa->in->addEdge(EPSILON, otherNfa->in);
    currNfa->out->addEdge(EPSILON, resNfa->out);
    otherNfa->out->addEdge(EPSILON, resNfa->out);
    NFA res;
    res.theNFA = resNfa; 
    return res;
}

NFA NFA::intersection(const NFA& other) const {
    DFA currDfa(*this);
    DFA otherDfa(other);
    DFA resDfa = currDfa.intersection(otherDfa);
    return NFA(resDfa); 
}

NFA NFA::complement() const {
    DFA currDfa(*this);
    DFA resDfa = currDfa.complement();
    return NFA(resDfa);
}

NFA NFA::concat(const NFA& other) const {
    nfa* currNfa = theNFA->deepcopy();
    nfa* otherNfa = other.theNFA->deepcopy();
    currNfa->out->addEdge(EPSILON, otherNfa->in);
    currNfa->out = otherNfa->out;
    NFA res;
    res.theNFA = currNfa;
    return res;
}

NFA NFA::reverseNFA() const {
    vector<State*> stateList = theNFA->allStates();
    unordered_map<State*, State*> newStateMap;
    for(const auto& oldState : stateList) {
        newStateMap[oldState] = new State();
    }

    for(const auto& oldState : stateList) {
        for(const auto& it : oldState->edges) {
            char sym = it.first;
            for(const auto& oldStateNgb : it.second) {
                // reverse the edge in new Nfa
                newStateMap[oldStateNgb]->addEdge(sym, newStateMap[oldState]);
            }
        }
    }

    State* in = newStateMap[theNFA->out];
    State* out = newStateMap[theNFA->in];
    nfa* resNfa = new nfa(in, out);

    NFA res;
    res.theNFA = resNfa;
    return res;    
}

NFA::NFA(){}

NFA::nfa* NFA::post2nfa(string& post) {
    stack<nfa*> st;
    for(char c : post) {
        switch (c)
        {
        case '*':
        {
            nfa* e1 = st.top(); st.pop();
            e1->out->addEdge(EPSILON, e1->in);
            State* in_state = new State();
            State* out_state = new State();
            in_state->addEdge(EPSILON, out_state);
            in_state->addEdge(EPSILON, e1->in);
            e1->out->addEdge(EPSILON, out_state);
            nfa* exp = new nfa(in_state, out_state);
            st.push(exp);
            delete e1;
            break;
        }

        case '.':
        {
            nfa* e1 = st.top(); st.pop();
            nfa* e2 = st.top(); st.pop();
            e2->out->addEdge( EPSILON, e1->in);
            nfa* exp = new nfa(e2->in, e1->out);
            st.push(exp);
            delete e1, e2;
            break;
        }

        case '+':
        {
            nfa* e1 = st.top(); st.pop();
            nfa* e2 = st.top(); st.pop();
            nfa* exp = new nfa(new State(), new State());
            exp->in->addEdge( EPSILON,e1->in);
            exp->in->addEdge( EPSILON,e2->in);
            e1->out->addEdge( EPSILON,exp->out);
            e2->out->addEdge( EPSILON,exp->out);
            st.push(exp);
            delete e1, e2; // removing fragment of nfa to save memory
            break;
        }

        default:
        {
            nfa* exp = new nfa(new State(), new State());
            exp->in->addEdge( c,exp->out);
            st.push(exp);
            break;
        }
        }
    }

    return st.top();
}

string NFA::generateDotString(nfa* exp) {
    string dotText;
    string header = R"(
digraph finite_state_machine {
fontname="Helvetica,Arial,sans-serif"
node [fontname="Helvetica,Arial,sans-serif"]
edge [fontname="Helvetica,Arial,sans-serif"]
rankdir=LR;
node [shape = doublecircle];
node [shape = doublecircle]; -1;
node [shape = circle];
)";
    string footer = R"(
}
)";
    dotText += header;


    unordered_map<State*, ll> nodeNameMap;
    stack<State*> st;
    State* final_state = exp->out;
    nodeNameMap[final_state] = -1;

    ll cnt = 0;
    st.push(exp->in);
    nodeNameMap[exp->in] = cnt++;
    while(!st.empty()) {
        State* state = st.top(); st.pop();
        ll src_name = nodeNameMap[state];

        for(auto& it : state->edges) {
            for(auto& ngb : it.second) {
                // not visited state, push stack
                if(nodeNameMap.find(ngb) ==  nodeNameMap.end()) {
                    st.push(ngb);
                    nodeNameMap[ngb] = cnt++;
                }
                ll ngb_name = ngb != final_state ? nodeNameMap[ngb] : -1;
                dotText += "\t " + to_string(src_name) + " -> " + to_string(ngb_name) + " [label = \"" + it.first + "\"];\n";
            }
        }
    }
    dotText += footer;

    return dotText;
}

// ----------------------------------------- NFA End ----------------------------------------

// ----------------------------------------- DFA Start --------------------------------------

int DFA::appendRow() {
    table.push_back(vector<int>(symbols.size(), -1));
    return table.size() - 1;
}

void DFA::build(const NFA& nfa_class) {
    const NFA::nfa* exp = nfa_class.getNFA();
    queue<set<NFA::State*>> q;
    map<set<NFA::State*>, int> stateSet_Index_Map;
    set<NFA::State*> start_set = {exp->in};
    start_set = NFA::Eclose(start_set);
    
    q.push(start_set);
    stateSet_Index_Map[start_set] = appendRow(); 
    while(!q.empty()) {
        set<NFA::State*> src = q.front(); q.pop();
        int index = stateSet_Index_Map[src];


        for(const auto& it : symbols) {
            char c = it.first;
            int ind = it.second;
            set<NFA::State*> transition_state_set = NFA::getTransitionSet(c, src);
            transition_state_set = NFA::Eclose(transition_state_set);

            // state set visited for first time 
            if(stateSet_Index_Map.find(transition_state_set) == stateSet_Index_Map.end()) {
                stateSet_Index_Map[transition_state_set] = appendRow();
                q.push(transition_state_set);
            }

            table[index][ind] = stateSet_Index_Map[transition_state_set];
        }
    }

    NFA::State *final_state = exp->out;
    for(auto& it : stateSet_Index_Map) {
        const set<NFA::State*>& stateSet = it.first;
        int index = it.second;
        if(stateSet.find(final_state) != stateSet.end()) {
            final_states.insert(index);
        }
    }
}

DFA::DFA( vector<char> _symbols, vector<vector<int>> _table, vector<int> _final_states, bool _minimalDFA) {
    for(int i=0; i<_symbols.size(); ++i) {
        symbols[_symbols[i]] = i;
    }
    table = _table;
    final_states = unordered_set<int>(_final_states.begin(), _final_states.end());
    minimalDFA = _minimalDFA;
}

DFA::DFA( unordered_map<char, int> _symbols, vector<vector<int>> _table, unordered_set<int> _final_states, bool _minimalDFA) {
    symbols = _symbols;
    symbolSize = _symbols.size();
    table = _table;
    final_states = _final_states;
    minimalDFA = _minimalDFA;
}

// public methods 

DFA::DFA(string& reg) {
    string postfix = infix2post(reg);
    set<char> sym(postfix.begin(), postfix.end());

    for(const char& c : sym) {
        if(c != EPSILON && prec(c) == -1) {
            symbols[c] = symbols.size();
        }
    } 
    symbolSize = symbols.size();
    build(NFA(reg));
}

DFA::DFA( vector<char> _symbols, vector<vector<int>> _table, vector<int> _final_states) {
    // Validation of input
    if(_table.empty() || _table[0].size() != _symbols.size()) {
        cerr << "Dimension of table, symbol do not match" << endl;
        exit(EXIT_FAILURE);
    }

    int n = _table.size();
    for(auto& row : _table) {
        for(auto& i : row) {
            if(i < 0 || i > n) {
                cerr << "State out of Bound\nState: " << i << endl;
                exit(EXIT_FAILURE);                    
            }
        }
    }

    for(auto& i : _final_states) {
        if(i < 0 || i > n) {
            cerr << "State out of Bound\nState: " << i << endl;
            exit(EXIT_FAILURE);                    
        }
    }


    for(int i=0; i<_symbols.size(); ++i) {
        symbols[_symbols[i]] = i;
    }
    table = _table;
    final_states = unordered_set<int>(_final_states.begin(), _final_states.end());
    symbolSize = _symbols.size();
}

DFA::DFA(const NFA& nfa_class) {
    const NFA::nfa* exp = nfa_class.getNFA();
    
    int symbolCnt = 0;
    for(const char& sym : nfa_class.getSymbols()) {
        if(sym != EPSILON) symbols[sym] = symbolCnt++;
    }
    symbolSize = symbolCnt;

    
    queue<set<NFA::State*>> q; // queue of State_Set
    map<set<NFA::State*>, int> stateSet_Index_Map;
    set<NFA::State*> start_set = {exp->in};
    start_set = NFA::Eclose(start_set);
    
    q.push(start_set);
    stateSet_Index_Map[start_set] = appendRow();
    while(!q.empty()) {
        set<NFA::State*> currState = q.front(); q.pop();
        int currIndex = stateSet_Index_Map[currState];

        for(const auto& it : symbols) {
            char sym = it.first;
            int ind = it.second;
            set<NFA::State*> transitionStateSet = NFA::getTransitionSet(sym, currState);
            transitionStateSet = NFA::Eclose(transitionStateSet);
            
            // state set visited for first time 
            if(stateSet_Index_Map.find(transitionStateSet) == stateSet_Index_Map.end()) {
                stateSet_Index_Map[transitionStateSet] = appendRow();
                q.push(transitionStateSet);
            }

            table[currIndex][ind] = stateSet_Index_Map[transitionStateSet];
        }
    }

    NFA::State *finalState = exp->out;
    for(auto& it : stateSet_Index_Map) {
        const set<NFA::State*>& stateSet = it.first;
        int stateSetIndex = it.second;
        if(stateSet.find(finalState) != stateSet.end()) {
            final_states.insert(stateSetIndex);
        }
    }
}

/**
 * @brief create DFA from text file
 * @returns DFA object
 * 
 * File format:
 * m (number of symbols) n(number of states) f(number of final states)
 * a b c ... (symbols)
 * 0 1 2 ... (final states)
 * n x m transition table (t[i][j] = k means state i on symbol j goes to state k and 0 <= t[i][j] <= n-1)
 */
DFA DFA::read_txt(string path) {
    ifstream inputFile(path);
    if (!inputFile) {
        std::cerr << "Error: Could not open file " << path << "\n";
        exit(EXIT_FAILURE);
    }

    int m, n, f; // Number of symbols, states, and final states
    inputFile >> m >> n >> f;

    vector<char> symbols(m);
    for (int i = 0; i < m; ++i) {
        inputFile >> symbols[i];
    }

    vector<int> final_states(f);
    for (int i = 0; i < f; ++i) {
        inputFile >> final_states[i];
    }

    // Transition table: 2D vector (n x m)
    std::vector<std::vector<int>> table(n, std::vector<int>(m));
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m; ++j) {
            inputFile >> table[i][j];
        }
    }

    inputFile.close();

    return DFA(symbols, table, final_states);
}

/**
 * @returns DFA transition table
 */
vector<vector<int>> DFA::getTransitionTable() {
    return table;
}

int DFA::getStateNgb(int ind, const char sym) const {
    if(symbols.count(sym) == 0) return -1;
    return table[ind][symbols.at(sym)];
}

vector<char> DFA::getSymbols() const {
    vector<char> symbolVector(symbolSize);
    int ind = 0;
    for(auto& it : symbols) symbolVector[ind++] = it.first;
    return symbolVector;
}

/**
 * @brief print DFA transition table
 */
void DFA::printTable() {
    printf("\t\t");
    for(const auto& it : symbols) printf("%c\t\t ", it.first);
    printf("\n");


    for(int i=0; i<table.size(); ++i) {
        printf("%9d | ", i);
        for(int j=0; j<table[i].size(); ++j)
            printf("%9d ", table[i][j]);
        printf("\n");
    }

    printf("\n");
    for(const int& ind : final_states) printf("%9d ", ind);
    printf("\n");
}

bool DFA::isMinimal() const noexcept
{
    return minimalDFA;
}

bool DFA::isFinalState(const int& ind) const noexcept {
    return final_states.find(ind) != final_states.end();
}

size_t DFA::stateCount() const noexcept
{
    return table.size();
}

/**
 * @brief Final States are unreachable from Dead States
 * @return vector<int> of dead states
 * @details Perform Multi-source BFS on reverse DFA
 */
vector<int> DFA::getDeadStates() const {
    int n = stateCount();
    vector<list<int>> rev_table(n);
    for(int i=0; i<n; i++) {
        auto& row = table[i];
        int u = i;
        for(auto& v : row) rev_table[v].push_back(u);
    }

    vector<bool> visited(n, false);
    queue<int> q;

    for(const int& i : final_states) {
        q.push(i);
        visited[i] = true;
    }

    while(!q.empty()) {
        int state = q.front(); q.pop();
        for(int& ngb : rev_table[state]) {
            if(!visited[ngb]) {
                visited[ngb] = true;
                q.push(ngb);
            }
        }
    }

    vector<int> deadStates;
    for(int i=0; i<n; i++) {
        if(!visited[i]) deadStates.push_back(i);
    }

    return deadStates;
}

/**
 * @brief test string in DFA
 * 
 * Return True iff string belong to Language of DFA 
 */
bool DFA::test(const string& str) {
    int curr_state = 0;
    for(const char& c : str) {
        if(symbols.find(c) == symbols.end()) return false;
        curr_state = table[curr_state][symbols[c]];
    }

    return final_states.find(curr_state) != final_states.end();
}

/**
 * @brief Smallest string to go from start state to each state n
 * @returns Vector of pair {string (smallest string to state), bool (true if state final)}  
 */
vector<pair<string, bool>> DFA::getStringBFS() {
    vector<string> stateStr(stateCount(), "");
    vector<bool> vis(stateCount(), false);

    queue<int> q;

    q.push(0);
    stateStr[0] = "";
    vis[0] = true;
    while(!q.empty()) {
        int& state = q.front(); q.pop();
        for(const auto& it : symbols) {
            const char& c = it.first;
            const int& ngb = table[state][it.second];
            if(!vis[ngb]) {
                q.push(ngb);
                stateStr[ngb] = string(stateStr[state]) + c;
                vis[ngb] = true;
            }
        }
    }

    vector<pair<string, bool>> result(stateStr.size());
    for(int i=0; i<stateStr.size(); i++) {
        string s = vis[i] ? stateStr[i] : "UNREACHABLE";
        result[i] = { s, isFinalState(i)};
    }

    return result;
}

/**
 * @brief All strings of length %k
 * @param  k int Length of string
 * @returns Map of string and bool true if accepted
 */
map<string, bool> DFA::getStringK(int k) const {
    queue<pair<int, string>> q; // {state, string}
    q.push({0, ""});
    while(k--) {
        int n = q.size();
        while(n--) {
            auto& it = q.front(); q.pop();
            int state = it.first;
            string curr_str = it.second;
            
            for(const auto& it : symbols) {
                const char& c = it.first;
                const int& ngb = table[state][it.second];
                string new_str(curr_str);
                new_str.push_back(c);
                q.push({ngb, new_str});
            }                
        }
    }

    map<string, bool> result;
    while(!q.empty()) {
        auto& it = q.front(); q.pop();
        int& state = it.first;
        string& str = it.second;
        result[str] = isFinalState(state);
    }

    return result;
}

/**
 * @brief Find smallest string differentiating unequal DFA
 * @param max_depth max length to which search should be performed
 * (default = -1) to continue till first difference.
 * 
 * Perform Iterative Deepening Search till %max_depth 
 * or first different string found
 */
string DFA::getDiffString(const DFA& d2, int max_depth){
    DFA& d1 = *this;
    if(d1 == d2) return "";

    map<string, bool> m1, m2;
    int k = 0;
    while(true) {
        m1.clear(); m2.clear();
        m1 = d1.getStringK(k);
        m2 = d2.getStringK(k);
        k++;

        if(m1 != m2) {
            for(const auto& it : m1) {
                const string& str1 = it.first;
                if(m2.find(str1) == m2.end() ||
                    m1[str1] != m2[str1]) {
                    return str1;
                }
            }

            for(const auto& it : m2) {
                const string& str2 = it.first;
                if(m1.find(str2) == m1.end() ||
                    m1[str2] != m2[str2]) {
                    return str2;
                }
            }
        }
    }

    return ""; //should never be executed
}

/**
 * @brief Get minimal DFA
 * @return new Minimal DFA
 * 
 * Myhill-Nerode algorithm to minimize DFA
 */
DFA DFA::minimal() {
    int n = table.size();
    int symbolSize = symbols.size();
    vector<vector<int>> state_pair_matrix(n);
    queue<pair<int, int>> q;
    enum d {
        INDISTINGUISH, DISTINGUISH
    };

    //Table initialization
    for(int i=0; i<n; i++) {
        state_pair_matrix[i] = vector<int>(i, INDISTINGUISH);
        for(int j=0; j<i; j++) {
            bool final_i = final_states.find(i) != final_states.end();
            bool final_j = final_states.find(j) != final_states.end();
            //distingushable case
            if(final_i ^ final_j) {
                state_pair_matrix[i][j] = DISTINGUISH;
            }
            else {
                q.push({i, j});
            }
        }
    }

    bool change = true;
    while (change)
    {
        change = false;
        int iter_size = q.size();
        for(int iter=0; iter<iter_size; iter++) {
            auto& it = q.front(); q.pop();
            int i = it.first;
            int j = it.second;
            for(int ind=0; ind<symbolSize; ind++) {
                int u = table[i][ind];
                int v = table[j][ind];
                
                //Same exact state, INDISTINGUISH
                if(u==v) continue;
                if(u<v) swap(u, v);
                if (state_pair_matrix[u][v] == DISTINGUISH) {
                    state_pair_matrix[i][j] = DISTINGUISH;
                    change = true;
                    break; 
                }
            }
            if(state_pair_matrix[i][j] == INDISTINGUISH)
                q.push({i, j});
        }
    }
    
    DisjointSet ds(n);

    while (!q.empty()) {
        auto it = q.front(); q.pop();
        int i = it.first;
        int j = it.second;
        ds.unionBySize(i, j);
    }

    map<int, set<int>> subsets = ds.getSubsets();
    vector<int> parent(n);

    for(auto& it : subsets) {
        int parent_u = it.first;
        for(const int& u : it.second) {
            parent[u] = parent_u;
        }
    }

    vector<vector<int>> minimal_table;
    unordered_set<int> minimal_final_states;
    unordered_map<int, int> old_table_minimal_table_map; // maps DFA parent(subset representative) to minimal DFA state

    // Intializing minimal-DFA transition table by (copying DFA trasition table)
    // and a map from old DFA state to new DFA state
    int minimal_start = parent[0];
    minimal_table.push_back(table[minimal_start]);
    old_table_minimal_table_map[minimal_start] = 0;
    
    for(auto& it : subsets) {
        int parent = it.first;
        if(parent == minimal_start) continue;

        minimal_table.push_back(table[parent]);
        old_table_minimal_table_map[parent] = minimal_table.size() - 1;
    }

    //update to valid index transitions
    int minimal_tableSize = minimal_table.size();
    for(int state=0; state<minimal_tableSize; state++) {
        for(int j=0; j<symbolSize; j++) {
            int old_state = minimal_table[state][j];
            int new_state = old_table_minimal_table_map[parent[old_state]];
            minimal_table[state][j] = new_state;
        }
    }

    for(const int& fs : final_states) {
        minimal_final_states.insert(old_table_minimal_table_map[parent[fs]]);
    }
    return DFA(symbols, minimal_table, minimal_final_states, true);
}

DFA DFA::unionDFA(const DFA& other) const {
    NFA currNfa(*this);
    NFA otherNfa(other);
    NFA resNfa = currNfa.unionNFA(otherNfa);
    return DFA(resNfa);
}

DFA DFA::intersection(const DFA& other) const {
    int symCnt = 0;
    unordered_map<char,int> resSymbols;
    for(const auto& it : symbols) {
        const char sym = it.first;
        if(other.symbols.count(sym) != 0) {
            resSymbols[sym] = symCnt++;
        }
    }
    
    auto statePairToStr = [](pair<int, int> pairState) -> string {
        return to_string(pairState.first) + "_" + to_string(pairState.second);
    };

    vector<vector<int>> resTransitionTable;
    unordered_map<string, int> pairIndexMap;
    auto getIndex = [&](pair<int,int>& pairState) -> int {
        string s = statePairToStr(pairState);
        const auto& it = pairIndexMap.find(s);
        if(it == pairIndexMap.end()) {
            resTransitionTable.push_back(vector(symCnt, -1));
            pairIndexMap[s] = resTransitionTable.size()-1;
        }
        return pairIndexMap[s];
    };

    auto pairTransition = [&](const char& sym, pair<int,int>& pairState) -> pair<int,int> {
        return {
            getStateNgb(pairState.first, sym),
            other.getStateNgb(pairState.second, sym)
        };
    };

    queue<pair<int,int>> q;
    unordered_set<string> vis;
    auto visitedOrAdd = [&](pair<int,int> pairState) -> bool {
        string s = statePairToStr(pairState);
        bool vizRes = vis.find(s) != vis.end();
        if(!vizRes) vis.insert(s);
        return vizRes;
    };

    q.push({0,0});
    visitedOrAdd({0,0});
    while(!q.empty()) {
        auto& currStatePair = q.front(); q.pop();
        int currIndex = getIndex(currStatePair);
        for(const auto& symIter : resSymbols) {
            char sym = symIter.first;
            int symIndex = symIter.second;
            
            pair<int,int> ngbStatePair = pairTransition(sym, currStatePair);
            int ngbIndex = getIndex(ngbStatePair);
            
            resTransitionTable[currIndex][symIndex] = ngbIndex;
            if(!visitedOrAdd(ngbStatePair)) q.push(ngbStatePair);
        }
    }

    unordered_set<int> resFinalStates;
    for(const int& final_1 : final_states) {
        for(const int& final_2 : other.final_states) {
            string s = statePairToStr({final_1, final_2});
            if(pairIndexMap.find(s) != pairIndexMap.end()) {
                resFinalStates.insert(pairIndexMap[s]);
            }
        }
    }

    return DFA(resSymbols, resTransitionTable, resFinalStates, false);    
}

DFA DFA::complement() const {
    DFA resDfa(*this);
    unordered_set<int> resFinalState;
    int stateCount = table.size();
    
    for(int i=0; i<stateCount; ++i) 
        if(!isFinalState(i)) resFinalState.insert(i);
    
    resDfa.final_states = resFinalState;
    return resDfa;
}

DFA DFA::concat(const DFA& other) const {
    NFA currNfa(*this);
    NFA otherNfa(other);
    NFA resNfa = currNfa.concat(otherNfa);
    return DFA(resNfa);
}

DFA DFA::reverse() const {
    NFA currNfa(*this);
    NFA resNfa = currNfa.reverseNFA();
    return DFA(resNfa);
}

/**
 *  @brief  Minimal DFA equality comparison.
 *  @param  d2  A minimal DFA
 *  @return  True iff the symbols, number of state and transitions of the DFAs are equal.
 *
 *  This is an equivalence relation.  It is linear in the size of the
 *  DFAs.  DFAs are considered equivalent if their 
 *  symbols, number of state and transitions of the DFAs are equal.
 */
bool DFA::operator==(const DFA& d2) {
    if(!isMinimal() || !d2.isMinimal()) {
        cerr << "Both DFA should be generated by getMinimal()";
    }

    // Compare Language of both DFAs
    if(symbols.size() != d2.symbols.size()) return false;
    for(const auto& it : symbols) {
        if(d2.symbols.find(it.first) == d2.symbols.end())
            return false;
    }

    // Compare Number of states
    if(stateCount() != d2.stateCount()) return false;

    vector<int> stateMapDFA(table.size(), -1);
    queue<pair<int, int>> q; // {this DFA state, d2 state}

    q.push({0, 0});
    stateMapDFA[0] = 0;
    while (!q.empty())
    {
        auto& it = q.front(); q.pop();
        int s1 = it.first;
        int s2 = it.second;
        if(isFinalState(s1) != d2.isFinalState(s2)) return false;

        for(const auto& symbolIter : symbols) {
            char symbol = symbolIter.first;
            int ngb1 = table[s1][symbols[symbol]];
            int nbg2 = d2.table[s2][d2.symbols.find(symbol)->second];

            if(stateMapDFA[ngb1] == -1) {
                q.push({ngb1, nbg2});
                stateMapDFA[ngb1] = nbg2;
            }
            else if (stateMapDFA[ngb1] != nbg2) {
                return false;
            }
        }
    }
    
    return true;
}

/**
 *  @brief  Based on operator==
 */
bool DFA::operator!=(const DFA& d2) {
    return !(*this == d2);
}

/**
 * @brief Generate dot string for graphviz
 * @param showDeadStates Show dead states in output graph (default = true)
 */
string DFA::generateDotString(bool showDeadStates) {
    string dotText;

    string header = R"(
digraph finite_state_machine {
fontname="Helvetica,Arial,sans-serif"
node [fontname="Helvetica,Arial,sans-serif"]
edge [fontname="Helvetica,Arial,sans-serif"]
rankdir=LR;
)";
    string footer = R"(
}
)"; 

    dotText += header;

    unordered_set<int> deadStates;
    if (!showDeadStates)
    {
        vector<int> temp = getDeadStates();
        deadStates = unordered_set<int>(temp.begin(), temp.end());   
    }

    //Print final states
    if(!final_states.empty()) {
        dotText += "\tnode [shape = doublecircle];";
        for(const int& f : final_states) dotText +=  to_string(f) + " ";
        dotText += ";\n";
    }

    //Print DFA
    dotText += "\tnode [shape = circle];\n";
    for(int i=0; i<table.size(); i++) {
        for(const auto& it : symbols) {
            int& ngb = table[i][it.second];
            if(!showDeadStates && (deadStates.count(i) ||  deadStates.count(ngb))) continue;
            dotText += "\t" + to_string(i) + " -> " + to_string(ngb) + " [label = \"" + it.first + "\"];\n";
        }
    }
    dotText += footer;

    return dotText;
}

/**
 * @brief Print dotfile for graphviz to standard output
 * @param showDeadStates Show dead states in output graph (default = true)
 */
void DFA::generateDotfile(bool showDeadStates) {
    cout << generateDotString(showDeadStates);
}

/**
 * @brief Write DFA in standard format. 
 * 
 * m (number of symbols) n(number of states) f(number of final states)
 * a b c ... (symbols)
 * 0 1 2 ... (final states)
 * n x m transition table
 */
string DFA::generateTextString() {
    string text;
    text += to_string(symbols.size()) + " ";
    text += to_string(table.size()) + " ";
    text += to_string(final_states.size()) + "\n";
    
    for(auto& it : symbols) {
        text += it.first;
        text += " ";
    }
    text += "\n";

    for(const auto& i : final_states) {
        text += to_string(i);
    }
    text += "\n";

    for(auto& row : table) {
        for(auto& i : row) {
            text += to_string(i) + " ";
        }
        text += "\n";
    }

    return text;
}

// ------------------------------------ DFA end -----------------------------------------------