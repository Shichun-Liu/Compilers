#include <assert.h>
#include <stdio.h>

#include <list>
#include <map>
#include <vector>

#include "cool-tree.h"
#include "emit.h"
#include "symtab.h"

enum Basicness { Basic,
                 NotBasic };
#define TRUE 1
#define FALSE 0
#define ATTR_BASE_OFFSET 3
#define DISPATCH_OFFSET 2

class CgenClassTable;
typedef CgenClassTable *CgenClassTableP;

class CgenNode;
typedef CgenNode *CgenNodeP;

typedef std::vector<attr_class *> attrList;
typedef std::vector<method_class *> methodList;
typedef std::map<Symbol, int> attrOffsetList;
typedef std::map<Symbol, int> methOffsetList;
typedef std::vector<std::pair<Symbol, Symbol>> dispatchTab;
typedef std::vector<CgenNodeP> inheritChain; 

class CgenClassTable : public SymbolTable<Symbol, CgenNode> {
private:
    List<CgenNode> *nds;
    ostream &str;
    int stringclasstag;
    int intclasstag;
    int boolclasstag;
    int labelid_;
    
    // my code
    std::map<int, Symbol> class_tag_to_name_map_;
    std::map<Symbol, CgenNodeP> name_to_cgen_map_;
    std::map<Symbol, attrList> class_local_attr_map_;      
    std::map<Symbol, methodList> class_local_method_map_;  
    std::map<Symbol, attrOffsetList> attr_offset_map_;
    std::map<Symbol, methOffsetList> method_offset_map_;
    std::map<Symbol, dispatchTab> dispatch_tab_map_;
    std::map<Symbol, inheritChain> parent_chain_map_;
    CgenNodeP curr_cgenclass_;
    // The following methods emit code for
    // constants and global declarations.

    void code_global_data();
    void code_global_text();
    void code_bools(int);
    void code_select_gc();
    void code_constants();

    // first pass
    void code_class_nametabs();
    void code_class_objtabs();
    void code_object_disptabs();
    // second pass
    void code_protobjs();
    void code_object_inits();
    // third stage
    void code_methods();

    // The following creates an inheritance graph from
    // a list of classes.  The graph is implemented as
    // a tree of `CgenNode', and class names are placed
    // in the base class symbol table.
    void install_basic_classes();
    void install_class(CgenNodeP nd);
    void install_classes(Classes cs);
    void install_classtags();
    void dfs_set_tags(CgenNodeP curr_cgen, int &curr_tag);
    int  set_subclass_cnt(CgenNodeP curr_cgen);
    void install_attrs_and_methods();
    void install_name_to_cgen();
    void build_inheritance_tree();
    void set_relations(CgenNodeP nd);

public:
    CgenClassTable(Classes, ostream &str);
    int get_labelid_and_add() { return labelid_++; }

    CgenNodeP get_cgennode(Symbol name) { return name_to_cgen_map_[name]; }
    CgenNodeP get_curr_class() const { return curr_cgenclass_; }

    bool get_attr_offset(Symbol cls, Symbol attr, int *offset);
    bool get_meth_offset(Symbol cls1, Symbol cls2, Symbol meth, int *offset);
    bool get_meth_offset(Symbol cls, Symbol meth, int *offset);

    ostream &codege_str() {
        return str;
    }
    void code();
    CgenNodeP root();
};

class Env {
public:
    typedef std::list<std::pair<Symbol, int>> symbolOffsetList;

private:
    std::list<symbolOffsetList> envList_;
    int formal_fp_offset_;
    int local_fp_offset_;
    int last_local_fp_offset_;

    void init_formal_fpoffset() {
        formal_fp_offset_ = DEFAULT_OBJFIELDS;
    }
    void init_local_fpoffset() {
        local_fp_offset_ = -1;
        last_local_fp_offset_ = -1;
    }

public:
    Env(){};
    void enterframe();
    void exitframe();
    void enterscope();
    void exitscope();

    void add_formal_id(Symbol name);
    void add_local_id(Symbol name);
    bool lookup(Symbol name, int *offset);
};

void Env::enterframe() {
    init_formal_fpoffset();
    init_local_fpoffset();
    enterscope();
}

void Env::exitframe() {
    exitscope();
    init_formal_fpoffset();
    init_local_fpoffset();
}

void Env::enterscope() {
    last_local_fp_offset_ = local_fp_offset_;
    envList_.push_back({});
}

void Env::exitscope() {
    envList_.pop_back();
    local_fp_offset_ = last_local_fp_offset_;
}

void Env::add_formal_id(Symbol name) {
    envList_.back().push_back({name, formal_fp_offset_++});
}

void Env::add_local_id(Symbol name) {
    envList_.back().push_back({name, local_fp_offset_--});
}

bool Env::lookup(Symbol name, int *offset) {
    for (auto rit = envList_.rbegin(); rit != envList_.rend(); ++rit) {
        const symbolOffsetList &sym_off_list = *rit;
        for (auto rlit = sym_off_list.rbegin(); rlit != sym_off_list.rend(); ++rlit) {
            if (rlit->first == name) {
                *offset = rlit->second;
                return true;
            }
        }
    }
    return false;
}

class CgenNode : public class__class {
private:
    int chain_depth_;
    int class_tag_;
    int subclass_cnt_;
    CgenNodeP parentnd;        // Parent of class
    List<CgenNode> *children;  // Children of class
    Basicness basic_status;    // `Basic' if class is basic
                               // `NotBasic' otherwise

public:
    CgenNode(Class_ c, Basicness bstatus, CgenClassTableP class_table);

    void add_child(CgenNodeP child);
    List<CgenNode> *get_children() { return children; }
    void set_parentnd(CgenNodeP p);
    void set_classtag(int tag) { class_tag_ = tag; }
    void set_chain_depth(int depth) { chain_depth_ = depth; }
    void set_subclass_cnt(int subcnt) { subclass_cnt_ = subcnt; }
    int get_classtag() const { return class_tag_; }
    int get_chain_depth() const { return chain_depth_; }
    int get_subclass_cnt() const { return subclass_cnt_; }
    CgenNodeP get_parentnd() { return parentnd; }
    std::vector<CgenNodeP> get_parents_list();

    int basic() { return (basic_status == Basic); }
};

class BoolConst {
private:
    int val;

public:
    BoolConst(int);
    void code_def(ostream &, int boolclasstag);
    void code_ref(ostream &) const;
};
