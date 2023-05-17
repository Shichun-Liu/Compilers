-- multiple defined methods

class C inherits IO {};

class Main {
    f0() : Int {1};
    f0(a : Int) : Int {a};
	main():C {(new C)};
};