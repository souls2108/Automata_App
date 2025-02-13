#include "./automata_lib.h"
#include "./automata_lib.cpp"
#include <cstring> // for c_str, strdup


extern "C" 
{

// ParseTree class
ParseTree* ParseTree_create_instance(const char* reg) {
    string reg_str(reg);
    return new ParseTree(reg_str);
}

void ParseTree_destroy_instance(ParseTree* instance) {
    delete instance;
}

const char* ParseTree_generateDotText(ParseTree* instance) {
    string dot_text = instance->generateDotString();
    return strdup(dot_text.c_str());
}

// NFA class
NFA* NFA_create_instance(const char* reg) {
    string reg_str(reg);
    return new NFA(reg_str);
}

void NFA_destroy_instance(NFA* instance) {
    delete instance;
}

const char* NFA_generateDotText(NFA* instance) {
    string dot_text = instance->generateDotString();
    return strdup(dot_text.c_str());
}

// DFA class
DFA* DFA_create_instance(const char* reg) {
    string reg_str(reg);
    return new DFA(reg_str);
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

void DFA_destroy_instance(DFA* instance) {
    delete instance;
}

const char* DFA_generateDotText(DFA* instance) {
    string dot_text = instance->generateDotString();
    return strdup(dot_text.c_str());
}

int DFA_test(DFA* instance, const char* str) {
    return instance->test(string(str));
}

DFA* DFA_minimalDFA(DFA* instance) {
    DFA* mDFA = new DFA(instance->minimal());
    return  mDFA;
}

int DFA_isMinimal(DFA* instance) {
    return instance->isMinimal();
}

int DFA_equalsDFA(DFA* instance, DFA* other) {
    return *instance == *other;
}

const char* DFA_getDiffString(DFA* instance, DFA* other, int max_depth) {
    string diff = instance->getDiffString(*other, max_depth);
    return strdup(diff.c_str());
}

const char* DFA_getDFAText(DFA* instance) {
    string text = instance->generateTextString();
    return strdup(text.c_str());
}

// Utility functions

void delete_text(const char* text) {
    free((void*)text);
}

} // extern "C"
