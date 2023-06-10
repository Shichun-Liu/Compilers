#!/bin/bash
if [ -e check_mine.txt ]; then 
  rm check_mine.txt 
fi
if [ -e check_expected.txt ]; then 
  rm check_expected.txt 
fi
../../bin/lexer $1 | ../../bin/parser $1 | ../../bin/semant $1 | ./cgen $1 > check_mine.txt 2>&1
../../bin/lexer $1 | ../../bin/parser $1 | ../../bin/semant $1 | ../../bin/cgen $1 > check_expected.txt 2>&1
result=$(diff check_mine.txt check_expected.txt)

if [ -z "$result" ]; then 
  echo "passed"
else 
  echo "$result"
  echo "failed"
fi
