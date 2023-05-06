-- inherits from an undefined class

class C inherits NotExistClass {};

class Main {
	main():C {(new C)};
};