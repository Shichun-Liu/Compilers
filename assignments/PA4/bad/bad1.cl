-- acyclic inheritance

class A inherits C {};

class B inherits A {};

class C inherits B {};


class Main {
	main():C {(new C)};
};
