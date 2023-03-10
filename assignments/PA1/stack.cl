(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

-- 根据list.cl的设计
class Stack {
   isNil() : Bool {true};
   top() : String {{abort(); "";}};
   next() : Stack {{abort(); self;}};
   push(val : String) : Stack {
      (new Cons).init(val, self)
   };
   -- pop() : Object {{}}
};

class Cons inherits Stack {
   val : String;
   next : Stack;
   isNil() : Bool {false};
   top() : String {val};
   next() : Stack {next};
   init(newVal : String, oriStk: Stack) : Stack {
      {
         val <- newVal;
         next <- oriStk;
         self;
      }
   };
};

class Main inherits IO {
   stack : Stack;
   command : String;

   printStack(s : Stack) : Object {
      if s.isNil() then out_string("\n")
      else {
         out_string(s.top());
         out_string("\n");
         printStack(s.next());
      }
      fi
   };

   pop() : Stack {
      stack <- stack.next()
   };

   plus() : Object {
      let sum : A2I <- new A2I in 
         let num1 : Int <- sum.a2i(stack.top()), num2 : Int <- sum.a2i(stack.next().top()) in {
            pop();pop();
            out_string(sum.i2a(num1));out_string(sum.i2a(num2));
            stack.push(sum.i2a(num1+num2));
         }
   };

   swap() : Object {
      let s1 : String <- stack.top(), s2 : String <- stack.next().top() in {
         pop();pop();
         stack.push(s1);
         stack.push(s2);
      }
   };

   execute(): Object {
      if stack.isNil() then 0 
      else if (stack.top() = "s") then {
         pop();swap();
      } else if (stack.top() = "+") then {
         pop(); plus();
      } else 0
      fi fi fi
   };

   main() : Object {{
      stack <- new Stack;

      let inputCmd: String in {
         while(not inputCmd = "x") loop {
            (new IO).out_string(">");
            inputCmd <- (new IO).in_string();

            if (inputCmd = "d") then 
               printStack(stack)
            else if (inputCmd = "s") then 
               stack <- stack.push("s")
            else if (inputCmd = "+") then 
               stack <- stack.push("+")
            else if (inputCmd = "e") then 
               execute()
            else stack <- stack.push(inputCmd)
            fi fi fi fi;
         } pool;
         
      };
   }
   };

};
