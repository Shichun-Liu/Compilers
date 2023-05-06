-- multiple defined classes

class C inherits IO {};
class C inherits Object {};

class Main {
	main():C {(new C)};
};