-- 'self' cannot be the name of an attribute.

class C inherits IO {
    self : C;
    f() : C {self};
};

class Main {
	a : C;
	main():C {(new C)};
};