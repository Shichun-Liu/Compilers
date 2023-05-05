#ifndef SEMANT_H_
#define SEMANT_H_

#include <assert.h>
#include <iostream>  
#include "cool-tree.h"
#include "stringtab.h"
#include "symtab.h"
#include "list.h"

#include <vector>
#include <map>

#define TRUE 1
#define FALSE 0

class ClassTable;
typedef ClassTable *ClassTableP;

// This is a structure that may be used to contain the semantic
// information such as the inheritance graph.  You may use it or not as
// you like: it is only here to provide a container for the supplied
// methods.

class ClassTable {
private:
  int semant_errors;
  void install_basic_classes();
  ostream& error_stream;

public:
  ClassTable(Classes);
  int errors() { return semant_errors; }
  ostream& semant_error();
  ostream& semant_error(Class_ c);
  ostream& semant_error(Symbol filename, tree_node *t);

  // TODO:acyclic check
  std::map<Symbol,Class_> class_map;
  std::vector<Class_> get_inheritance_chain(Symbol target_class);
  typedef std::map<Symbol, Class_>::iterator iter;
  typedef std::vector<Class_> chain;
  typedef std::vector<Class_>::iterator chain_iter;
  bool is_parent_of(Symbol parent,Symbol child);
  Symbol LCA(Symbol u,Symbol v);
};


#endif

