(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)



class Main inherits A2I {

   main() : Object {
      let inString: String in {
         while(not inString = "x") loop {
            (new IO).out_string(">");
            inString <- (new IO).in_string();
            executeStack(inString);
         } pool;
      }
   };

};
