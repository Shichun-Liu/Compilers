(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

-- 根据list.cl的设计
class Stack inherits IO{
	val : String;
	next : Stack;

	isNil() : Bool {true};

	top() : String {{abort(); "";}};

	next() : Stack {{abort(); self;}};

	push(newVal : String) : Stack {
		(new Cons).init(newVal, self) 
	};
};

class Cons inherits Stack {
	isNil() : Bool {false};

	top() : String {val};

	next() : Stack {next};

	init(newVal : String, oriStk: Stack) : Stack {{
		val <- newVal;
		next <- oriStk;
		self;
	}};
};

class Main inherits IO {
   	stack : Stack;

	push(s : String) : Object {
		stack <- stack.push(s)
	};

	pop() : Object {
		stack <- stack.next()
	};

	print(s : Stack) : Object {
		if s.isNil() then 0
		else {
			out_string(s.top());
			out_string("\n");
			print(s.next());
		} fi
	};

	plus() : Object {
		let sum : A2I <- new A2I in 
			let num1 : Int <- sum.a2i(stack.top()), num2 : Int <- sum.a2i(stack.next().top()) in {
				pop();
				pop();
				push(sum.i2a(num1+num2));
			}
	};

	swap() : Object {
		let s1 : String <- stack.top(), s2 : String <- stack.next().top() in {
			pop();
			pop();
			push(s1);
			push(s2);
		}
	};

	execute(): Object {{
		push("e");pop();
		if stack.isNil() then 0 
		else if (stack.top() = "s") then {
			pop(); swap();
		} else if (stack.top() = "+") then {
			pop(); plus();
		} else 0
		fi fi fi;
	}};

	main() : Object {{
		stack <- new Stack;
		let inputCmd: String in {
			while(not inputCmd = "x") loop {
				(new IO).out_string(">");
				inputCmd <- (new IO).in_string();
				if (inputCmd = "d") then 
					print(stack)
				else if (inputCmd = "e") then 
					execute()
				else 
					push(inputCmd)
				fi fi;
			} pool;
			
		};
	}};

};
