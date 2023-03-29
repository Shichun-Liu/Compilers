 /*
 *  The scanner definition for COOL.
 */

 /*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%option noyywrap

%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
static int comment_layers = 0;
int buf_leng = 0;

%}

/*
 * Define names for regular expressions here.
 */

%startComment COMMENT
%startString STRING
%startESCAPE ESCAPE_STRING

%%


 /*
  *  Nested comments
  */
--.*$ {}

"(*" { 
  comment_layers++;
  BEGIN COMMENT;
}

<COMMENT>"*)" {
  comment_layers--;
  if (comment_layers == 0) {
    BEGIN 0;
  }
}

<COMMENT>[^\n(*]* {  }

<COMMENT>\n {
  ++curr_lineno;
}

<COMMENT><<EOF>> {
  cool_yylval.error_msg = "EOF in comment";
  BEGIN 0;
  return ERROR;
}

"*)" {
  cool_yylval.error_msg = "Unmatched *)";
  return ERROR; 
}

 /*
  *  The multiple-character operators.
  */

"=>" { return DARROW; }
"<-" { return ASSIGN; }
"<=" { return LE; }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

(?i:class) { return CLASS; }
(?i:else) { return ELSE; }
(?i:fi) { return FI; }
(?i:if) { return IF; }
(?i:in) { return IN; }
(?i:inherits) { return INHERITS; }
(?i:let) { return LET; }
(?i:loop) { return LOOP; }
(?i:pool) { return POOL; }
(?i:then) { return THEN; }
(?i:while) { return WHILE; }
(?i:case) { return CASE; }
(?i:esac) { return ESAC; }
(?i:of) { return OF; }
(?i:new) { return NEW; }
(?i:isvoid) { return ISVOID; }
(?i:not) { return NOT; }

<INITIAL>t(?i:rue) {
  cool_yylval.boolean = true;
  return BOOL_CONST;
}

<INITIAL>f(?i:alse) {
  cool_yylval.boolean = false;
  return BOOL_CONST;
}
<INITIAL>[0-9]+ {
  cool_yylval.symbol = inttable.add_string(yytext);
  return INT_CONST;
}

<INITIAL>[A-Z][a-zA-Z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}

<INITIAL>[a-z][a-zA-Z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

<INITIAL>\" {
  BEGIN(STRING);
  string_buf_ptr = string_buf;
}

<STRING>[^\"\\]*\" {

  // copy the yytext to the end of the string_buf
  strcpy(string_buf_ptr, yytext);

  // not include the last character ", and add the \0 on the end.
  *(string_buf_ptr + yyleng) = '\0';
  
  buf_leng = buf_leng + yyleng;
  if (buf_leng > MAX_STR_CONST) {
    cool_yylval.error_msg = "String constant too long";
    BEGIN 0;
    return ERROR;
  }
  
  cool_yylval.symbol = stringtable.add_string(string_buf);
  buf_leng = 0;
  BEGIN 0;
  return STR_CONST;
}

<STRING>[^\"\\]*\\ {
  
  strcpy(string_buf_ptr, yytext);

  // not include the last character escape
  string_buf_ptr = string_buf + buf_leng;
  buf_leng = buf_leng + yyleng - 1;

  BEGIN(ESCAPE_STRING);
}

<ESCAPE_STRING>"n" {
  
  *string_buf_ptr++ = '\n';
  BEGIN(STRING);
}

<ESCAPE_STRING>"b" {
  *string_buf_ptr++ = '\b';
  BEGIN(STRING);
}

<ESCAPE_STRING>"t" {
  *string_buf_ptr++ = '\t';
  BEGIN(STRING);
}

<ESCAPE_STRING>"f" {
  *string_buf_ptr++ = '\f';
  BEGIN(STRING);
}

<ESCAPE_STRING>. {
  *string_buf_ptr++ = yytext[0];
  BEGIN(STRING);
}

<ESCAPE_STRING>\n {
  *string_buf_ptr++ = '\n';
  curr_lineno++;
  BEGIN(STRING);
}

<ESCAPE_STRING><<EOF>> {
  cool_yylval.error_msg = "EOF in string constant";
  BEGIN STRING;
  return ERROR;
}
<STRING>[^\"\\]*$ {
  strcpy(string_buf_ptr, yytext);
  buf_leng = buf_leng + yyleng;
  cool_yylval.error_msg = "Unterminated string constant";
  BEGIN 0;
  curr_lineno++;
  return ERROR;
}

<STRING><<EOF>> {
  cool_yylval.error_msg = "EOF in string constant";
  BEGIN 0;
  return ERROR;
}

[ \f\r\t\v]+ { }
"\n" { curr_lineno++; }

[\[\]'>] {
  cool_yylval.error_msg = yytext;
  return (ERROR);
}

. {
  return yytext[0];
}
%%