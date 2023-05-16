class C {
	a : Int;
	b : Bool;
	init(x : Int, y : Bool) : C {{
		a <- x;
		b <- y;
		self;
    }};
	f1() : Int {
		let x : Int, value : Int <- x + 1 in 
			let value : Int <- 1 in 
				x + value
	};
};

Class Main inherits IO{
	main():C {
	  	(new C).init(1,true)
	};
};

