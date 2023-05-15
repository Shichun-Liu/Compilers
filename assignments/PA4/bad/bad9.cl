-- feature check
class A {};
class B inherits A {};

class C inherits IO {
    self : C;
    c : C;
    f() : C {self};
    f1() : Int { (new C) };
    f2() : Int { self };
    f3() : D {self};
    f4() : SELF_TYPE {self};
    f5() : SELF_TYPE {(new C)}; --weird

    
    -- f6(a : Int, a : Bool) : Int {1};
    -- f7(a : SELF_TYPE) : Int {1};

    -- f8(a : Int, b : Bool) : Int {a <- b};
    f9() : Int {{self <- c;1;}};
};

class Main {
	a : C;
	main():C {(new C)};
};