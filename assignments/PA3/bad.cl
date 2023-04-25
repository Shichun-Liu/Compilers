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

(* error: dispatch *)
class TestDispatch {
	test(x:Int):String {x(5,4,3,)};
	test(x:Int):String {x(,5,4,)};
	test(x:Int):String {x(4;3;)};
	test(x:Int):String {x(,)};
	ok(x:Int):String {x(5,4,3)};
};

(* error: empty explist *)
class TestEmptyExpList {
	test(x:Int):String {{}};
	test():String {{}};
	test():String {{;}};
};

(* error: bad feature *)
class TestFeatureName {
	badVariable : Int;
	Y : Int;
	x : int;
	z : int
};



