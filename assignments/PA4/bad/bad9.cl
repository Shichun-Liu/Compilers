-- 'self' cannot be the name of an attribute.

class C inherits IO {
    self : C;
    f() : C {self};
    f1() : Int { (new C) };
    f2() : Int { self };
    f3() : D {self};
    f4() : SELF_TYPE {self};
};

class Main {
	a : C;
	main():C {(new C)};
};