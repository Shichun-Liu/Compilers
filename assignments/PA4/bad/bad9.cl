-- feature check
class A {};
class B inherits A {};

class C inherits IO {
    self : C;
    c : C;
    bl : Bool;
    it : Int;
    f0(a: Int, b: Bool) : Int {1};

    -- method type check, with self type and cur_class->get_name()
    f() : C {self};
    f1() : Int { (new C) };
    f2() : Int { self };
    f3() : D {self};
    f4() : SELF_TYPE {self};
    f5() : SELF_TYPE {(new C)}; --weird

    -- formal check
    f6(a : Int, a : Bool) : Int {1};
    f7(a : SELF_TYPE) : Int {1};

    -- assign check
    f8(a : Int, b : Bool) : Int {a <- b};
    f9() : Int {{self <- c;1;}};

    -- dispatch check
    f10() : Int {{(new C).f0(it, it); 1;}};
    f11() : Int {{c.f0(it, it); 1;}};
};

class Main {
	a : C;
	main():C {(new C)};
};