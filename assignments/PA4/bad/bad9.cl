-- feature check
class A {};
class B inherits A {
    f0() : Int {1};
};

class C inherits B {
    --not error
    c : C;
    d : D;
    bl : Bool;
    it : Int;

    -- wrong attribute
    self : C;
    it_wrong : Int <- "True";

    f0() : Int {1};
    f00(a : Int) : Int {a};
    c(a: Int, b: Bool) : Int {c.f0()};

    -- method type check, with self type and cur_class->get_name()
    f() : C {self};
    f1() : Int { (new C) };
    f2() : Int { self };
    f3() : F {self};
    f4() : SELF_TYPE {self};
    f5() : SELF_TYPE {(new C)}; --error, but weird

    -- formal check
    f6(a : Int, a : Bool) : Int {1};
    f7(a : SELF_TYPE) : Int {1};

    -- assign check
    f8(a : Int, b : Bool) : Int {a <- b};
    f9() : Int {{self <- c;1;}};

    -- dispatch check
    f10() : Int {{(new C).f00(it, it); 1;}};
    f11() : Int {{c.f00(bl); 1;}};
    f12() : Int {{c@B.f0();}}; --not error

    -- condition check
    f13() : Int {{if c then 1 else 1 fi;1;}};
    f14() : Int {{while c loop 1 pool;1;}};

    -- let
    f15() : Int {{let self : C <- c in 1;1;}};
    f16() : Int {{let a : Bool <- 1+1 in 1;1;}};
    f16_1() : Int {{let a : Bool, a : Int in 1;1;}};
    f16_2() : Int {{let a : SELF_TYPE in 1;1;}};

    -- +-*/
    f17() : Int {{1 + c; 1;}};
    f18() : Int {{1 - c; 1;}};
    f19() : Int {{1 * c; 1;}};
    f20() : Int {{1 / c; 1;}};
    f20_1() : Int {{1 / 0; 1;}}; --not error
    f21() : Int {{1 < c; 1;}};
    f22() : Int {{1 = c; 1;}};
    f23() : Int {{1 <= c; 1;}};
    f24() : Int {{not c; 1;}};
    f24_1() : Int {{~bl; 1;}};

    -- new
    f25() : Int {{new F; 1;}};

    -- isvoid
    f26() : Int {{isvoid c; 1;}};

};

class D {};

class Main {
	a : C;
	main():C {(new C)};
};