-- multiple defined attributes

class C inherits IO {};

class Main {
	a : Int;
	a : C;
	main():C {(new C)};
};