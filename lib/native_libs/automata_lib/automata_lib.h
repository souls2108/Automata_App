#ifndef AUTOMATA_LIB_CPP_H
#define AUTOMATA_LIB_CPP_H

#ifdef __cplusplus
extern "C" {  // Ensure C++ functions are accessible from C
#endif

typedef struct ParseTree  ParseTree;
typedef struct NFA NFA;
typedef struct DFA DFA;

// ParseTree class Definition
ParseTree* ParseTree_create_instance(const char* reg);
void ParseTree_destroy_instance(ParseTree* instance);
const char* ParseTree_generateDotText(ParseTree* instance);

// NFA class Definition
NFA* NFA_create_instance(const char* reg);
void NFA_destroy_instance(NFA* instance);
const char* NFA_generateDotText(NFA* instance);

// DFA class Definition
DFA* DFA_create_instance(const char* reg);
DFA* DFA_create_instance_from_data(
    char* symbols, int symbols_size, int* table, 
    int table_size, int* final_states, int final_states_size
);
void DFA_destroy_instance(DFA* instance);
const char* DFA_generateDotText(DFA* instance);
int DFA_test(DFA* instance, const char* str);
DFA* DFA_minimalDFA(DFA* instance);
int DFA_isMinimal(DFA* instance);
int DFA_equalsDFA(DFA* instance, DFA* other);
const char* DFA_getDiffString(DFA* instance, DFA* other, int max_depth);
const char* DFA_getDFAText(DFA* instance);





#ifdef __cplusplus
}
#endif

#endif