#include "./automata_lib.h"
#include "./lib/main.cpp"
#include <cstring> // for c_str, strdup


// ParseTree class
ParseTree* ParseTree_create_instance(const char* reg) {
    string regStr(reg);
    return new ParseTree(regStr);
}

void ParseTree_destroy_instance(ParseTree* instance) {
    delete instance;
}

const char* ParseTree_generateDotText(ParseTree* instance) {
    return strdup(instance->generateDotString().c_str());
}

// NFA class
NFA* NFA_create_instance(const char* reg) {
    string regStr(reg);
    return new NFA(regStr);
}

NFA* NFA_create_instance_from_NFA(NFA* other) {
    return new NFA(*other);
}

NFA* NFA_create_instance_from_DFA(DFA* dfa, int removeDeadStates) {
    return new NFA(*dfa, removeDeadStates);
}

void NFA_destroy_instance(NFA* instance) {
    delete instance;
}

const char* NFA_generateDotText(NFA* instance) {
    return strdup(instance->generateDotString().c_str());
}

NFA* NFA_unionNFA(const NFA* instance, const NFA* otherInstance) {
    return new NFA(instance->unionNFA(*otherInstance));
}
NFA* NFA_intersection(const NFA* instance, const NFA* otherInstance) {
    return new NFA(instance->intersection(*otherInstance));
}
NFA* NFA_complement(const NFA* instance) {
    return new NFA(instance->complement());
}
NFA* NFA_concat(const NFA* instance, const NFA* otherInstance) {
    return new NFA(instance->concat(*otherInstance));
}
NFA* NFA_reverseNFA(const NFA* instance) {
    return new NFA(instance->reverseNFA());
}

// DFA class
DFA* DFA_create_instance(const char* reg) {
    string regStr(reg);
    return new DFA(regStr);
}

DFA* DFA_create_instance_from_data(char* symbols, int symbols_size, int* table, int table_size, int* final_states, int final_states_size) {
    vector<char> _symbols(symbols, symbols + symbols_size);
    vector<vector<int>> _table;
    for(int i=0; i<table_size; i+=symbols_size) {
        vector<int> row(table + i, table + i + symbols_size);
        _table.push_back(row);
    }
    vector<int> _final_states(final_states, final_states + final_states_size);
    return new DFA(_symbols, _table, _final_states);
}

DFA* DFA_create_instance_from_DFA(DFA* other) {
    return new DFA(*other);
}

DFA* DFA_create_instance_from_NFA(NFA* nfa) {
    return new DFA(*nfa);
}

void DFA_destroy_instance(DFA* instance) {
    delete instance;
}

int DFA_getStateNgb(DFA* instance, int ind, char sym) {
    return instance->getStateNgb(ind, sym);
}

const char* DFA_getSymbols(DFA* instance) {
    string symbols = "";
    for(const char& sym : instance->getSymbols()) {
        symbols += sym;
    }
    return strdup(symbols.c_str());
}

int DFA_isMinimal(DFA* instance) {
    return instance->isMinimal();
}

int DFA_isFinalState(DFA* instance, int ind) {
    return instance->isFinalState(ind);
}

int DFA_stateCount(DFA* instance) {
    return instance->stateCount();
}

int* DFA_getDeadStates(DFA* instance) {
    vector<int> deadStates = instance->getDeadStates();
    int* deadStatesArr = new int[deadStates.size()];
    for(int i=0; i<deadStates.size(); i++) {
        deadStatesArr[i] = deadStates[i];
    }
    return deadStatesArr;
}


int DFA_test(DFA* instance, const char* str) {
    return instance->test(string(str));
}

const char* DFA_getDiffString(DFA* instance, DFA* other, int max_depth) {
    return strdup(instance->getDiffString(*other).c_str());
}


DFA* DFA_minimalDFA(DFA* instance) {
    return new DFA(instance->minimal());
}

DFA* DFA_unionDFA(DFA* instance, DFA* other) {
    return new DFA(instance->unionDFA(*other));
}

DFA* DFA_intersection(DFA* instance, DFA* other) {
    return new DFA(instance->intersection(*other));
}

DFA* DFA_complement(DFA* instance) {
    return new DFA(instance->complement());
}

DFA* DFA_concat(DFA* instance, DFA* other) {
    return new DFA(instance->concat(*other));
}

DFA* DFA_reverse(DFA* instance) {
    return new DFA(instance->reverse());
}

int DFA_isSubset(DFA* instance, DFA* other) {
    return instance->isSubset(*other);
}

int DFA_isSuperset(DFA* instance, DFA* other) {
    return instance->isSuperset(*other);
}

int DFA_equalsDFA(DFA* instance, DFA* other) {
    return *instance == *other;
}

const char* DFA_getDFAText(DFA* instance) {
    return strdup(instance->generateTextString().c_str());
}

const char* DFA_generateDotText(DFA* instance, int showDeadStates) {
    return strdup(instance->generateDotString(showDeadStates).c_str());
}