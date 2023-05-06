-- 
class C {
    c : A;
};
class A inherits C {
    a : C;
};


class Main {
	main():C {(new C)};
};
