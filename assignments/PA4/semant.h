#ifndef SEMANT_H_
#define SEMANT_H_

#include <assert.h>

#include <iostream>
#include <unordered_map>
#include <vector>

#include "cool-tree.h"
#include "list.h"
#include "stringtab.h"
#include "symtab.h"

#define TRUE 1
#define FALSE 0

class ClassTable;
typedef ClassTable* ClassTableP;

// This is a structure that may be used to contain the semantic
// information such as the inheritance graph.  You may use it or not as
// you like: it is only here to provide a container for the supplied
// methods.

class ClassTable {
private:
    int semant_errors;
    void install_basic_classes();
    ostream& error_stream;
	
    // TODO: acyclic inhert
    std::unordered_map<Symbol, Class_> class_table;
    std::unordered_map<Symbol, Symbol> inherit_table;

public:
    ClassTable(Classes);
    int errors() { return semant_errors; }
    ostream& semant_error();
    ostream& semant_error(Class_ c);
    ostream& semant_error(Symbol filename, tree_node* t);
    
    void add_new_class(Class_ c);
    bool check_acyclic_graph();
    bool check_method(Symbol s1, Symbol s2, Symbol name);
    bool check_formals(Formals formals, std::vector<Symbol> return_type, 
            Formal& formal, Symbol& wrong_type, Symbol& true_type, bool& wrong_number);
    bool is_class_exit(Symbol s);
    bool is_sub_class(Symbol s1, Symbol s2);
    Symbol  get_same_method_parent(Symbol child, Symbol name);
    Class_  get_class(Symbol s);
    Symbol  get_parents(Symbol s, std::vector<Symbol>& v);
    Formals get_formals(Symbol name, Symbol method);
    Symbol  get_return_type(Symbol name, Symbol method);
    Symbol lowest_common_ancestor(Symbol s1, Symbol s2);
};

#endif