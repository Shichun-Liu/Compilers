-- bad inherit

class C inherits Int {};

class Main {
	main():C {(new C)};
};