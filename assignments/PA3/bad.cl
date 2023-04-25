(* no error *)
class A {
};

(* error:  b is not a type identifier *)
class b inherits A {
};

(* error:  a is not a type identifier *)
class C inherits a {
};

(* error:  keyword inherits is misspelled *)
class D inherts A {
};

(* error:  closing brace is missing *)
class E inherits A {
;

class FeatureList {
	f(x : Int) : Int { x(5,4,3,) };
	f(x : Int) : Int { x(,5,4,) };
	f(x : Int) : Int { x(4;3;) };
	f(x : Int) : Int { x(,) };
	f(x : Int) : Int { };
	f(x : Int) : Int { x@.f(2) };
	
};

class BadFeatureName {
	Y : Int;
	x : int;
	z : Int
};

class badClassName {
	a : Int;
};

class {
	a : Int;
};

class BadLE {
	f() : Int { x<=y<=z };
};

class BadLoop {
	f() : Int { while 1 loop 1 loop };
	f() : Int { while 1 1 loop };
	f() : Int { while 1 pool 1 pool };
};

class BadIf {
	f() : Int { if 1 then 0  };
};

class TypeError {
	a : Int <- 0;
	b : Int <- ;
	f(a : Int) : Int {new a};
	g(x : Object) : b {1};
	z(a : Int) : Int {a <- A};
};

class BadExpr {
	f(a : Int) : Int {a++};
};

class InheritFromObject inherits obj {
	a : Int;
};
