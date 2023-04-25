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

class Dispatch {
	test(x:Int):String {x(5,4,3,)};
	test(x:Int):String {x(,5,4,)};
	test(x:Int):String {x(4;3;)};
	test(x:Int):String {x(,)};
	ok(x:Int):String {x(5,4,3)};
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

class LE {
	f():Int {x<=y<=z};
};

class Loop {
	f() : Int {{
		while 1 loop 1 loop;
		while 1 pool 1 pool;
	}};

	g() : Int {while 1 1 loop};
};

class TypeError {
	a : Int <- 0;
	b : Int <- ;
	f(a : Int) : Int {new a};
	g(x : Object) : b {1};
	z(a : Int) : Int {a <- A};
};

class Let {
	f() : Int { let x : Int <- 1, b : Int <- B in a + B };
};

class BadExpr {
	f(a : Int) : Int {a++};
};

class InheritFromObject inherits obj {
	a : Int;
};



