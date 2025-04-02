#ifndef AUTOMATA_LIB_CPP_H
#define AUTOMATA_LIB_CPP_H

#ifdef __cplusplus
extern "C" {  // Ensure C++ functions are accessible from C
#endif

typedef struct ParseTree ParseTree;
typedef struct NFA NFA;
typedef struct DFA DFA;

// ParseTree class Definition
ParseTree* ParseTree_create_instance(const char* reg);
void ParseTree_destroy_instance(ParseTree* instance);
const char* ParseTree_generateDotText(ParseTree* instance);

// NFA class Definition
NFA* NFA_create_instance(const char* reg);
NFA* NFA_create_instance_from_NFA(NFA* other);
NFA* NFA_create_instance_from_DFA(DFA* dfa, int removeDeadStates);
void NFA_destroy_instance(NFA* instance);
const char* NFA_generateDotText(NFA* instance);
NFA* NFA_unionNFA(const NFA* instance, const NFA* otherInstance);
NFA* NFA_intersection(const NFA* instance, const NFA* otherInstance);
NFA* NFA_complement(const NFA* instance);
NFA* NFA_concat(const NFA* instance, const NFA* otherInstance);
NFA* NFA_reverseNFA(const NFA* instance);

// DFA class Definition
DFA* DFA_create_instance(const char* reg);
DFA* DFA_create_instance_from_data(
    char* symbols, int symbols_size, int* table, 
    int table_size, int* final_states, int final_states_size
);
DFA* DFA_create_instance_from_DFA(DFA* other);
DFA* DFA_create_instance_from_NFA(NFA* nfa);
void DFA_destroy_instance(DFA* instance);

int DFA_getStateNgb(DFA* instance, int ind, char sym);
const char* DFA_getSymbols(DFA* instance);
int DFA_isMinimal(DFA* instance);
int DFA_isFinalState(DFA* instance, int ind);
int DFA_stateCount(DFA* instance);
int* DFA_getDeadStates(DFA* instance);

int DFA_test(DFA* instance, const char* str);
const char* DFA_getDiffString(DFA* instance, DFA* other, int max_depth);

DFA* DFA_minimalDFA(DFA* instance);
const char* DFA_regex(DFA* instance);
DFA* DFA_unionDFA(DFA* instance, DFA* other);
DFA* DFA_intersection(DFA* instance, DFA* other);
DFA* DFA_complement(DFA* instance);
DFA* DFA_concat(DFA* instance, DFA* other);
DFA* DFA_reverse(DFA* instance);
int DFA_equalsDFA(DFA* instance, DFA* other);
int DFA_isSubset(DFA* instance, DFA* other);
int DFA_isSuperset(DFA* instance, DFA* other);

const char* DFA_generateDotText(DFA* instance, int showDeadStates);
const char* DFA_getDFAText(DFA* instance);





#ifdef __cplusplus
}
#endif

#endif