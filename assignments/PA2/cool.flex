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
#include <vector>

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

// char string_buf[MAX_STR_CONST]; /* to assemble string constants */
// char *string_buf_ptr;

std::vector<char> string_buf(MAX_STR_CONST);

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

int comment_depth = 0;

%}

%x COMMENT
%x STRING
%x STRING_ESCAPE

/*
 * Define names for regular expressions here.
 */

DARROW          =>
CLASS           class
ELSE            else
FI              fi
IF              if
IN              in
INHERITS        inherits
LET             let
LOOP            loop
POOL            pool
THEN            then
WHILE           while
CASE            case
ESAC            esac
OF              of
NEW             new
ISVOID          isvoid
ASSIGN          <-
NOT             not
LE              <=
        
%%
[ \f\r\t\v]+ { }

"\n" { curr_lineno++; }

[\[\]'>] {
  cool_yylval.error_msg = yytext;
  return(ERROR);
}

 /*
  *  Nested comments
  */

--.* 				{ }
<INITIAL, COMMENT>"(*" { 
  comment_depth++;
  BEGIN(COMMENT);
}

<COMMENT>[^(\*\))] 	{ if (yytext[0] == '\n') 	++curr_lineno;}

<COMMENT>"*)" 		{ 
  comment_depth--;
  if(comment_depth == 0) BEGIN(0); 
}

<COMMENT><<EOF>> {
  cool_yylval.error_msg = "EOF in comment";
  BEGIN 0;
  return (ERROR);
}	

"*)" {
  cool_yylval.error_msg = "Unmatched *)";
  return (ERROR);
}

 /*
  *  The multiple-character operators.
  */

{DARROW} 	{ return (DARROW); }
{CLASS} 	{ return (CLASS); }
{ELSE} 		{ return (ELSE); }
{FI} 		{ return (FI); }
{IF} 		{ return (IF); }
{IN} 		{ return (IN); }
{INHERITS} 	{ return (INHERITS); }
{LET} 		{ return (LET); }
{LOOP} { return (LOOP); }
{POOL} { return (POOL); }
{THEN} { return (THEN); }
{WHILE} { return (WHILE); }
{CASE} { return (CASE); }
{ESAC} { return (ESAC); }
{OF} { return (OF); }
{NEW} { return (NEW); }
{ISVOID} { return (ISVOID); }
{ASSIGN} { return (ASSIGN); }
{NOT} { return (NOT); }
{LE} { return (LE); }



 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

t(?i:rue) {
  cool_yylval.boolean = true;
  return BOOL_CONST;
}
f(?i:alse) {
  cool_yylval.boolean = false;
  return BOOL_CONST;
}
[0-9]+ {
  cool_yylval.symbol = inttable.add_string(yytext);
  return INT_CONST;
}
[A-Z][a-zA-Z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}
[a-z][a-zA-Z0-9_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\" {
    string_buf.clear();
    BEGIN(STRING);
}

<STRING>[^\"\\]*\\ {
    string_buf.insert(string_buf.end(), yytext, yytext + yyleng - 1);
    BEGIN(STRING_ESCAPE);
}
<STRING><<EOF>> {
    cool_yylval.error_msg = "EOF in string constant";
    BEGIN 0;
    return (ERROR);
}
<STRING>[^\"\\]*\" {
    string_buf.insert(string_buf.end(), yytext, yytext + yyleng - 1);
    if (string_buf.size() > MAX_STR_CONST) {
        cool_yylval.error_msg = "String constant too long";
        BEGIN (0);
        return (ERROR);
    } 
    cool_yylval.symbol = stringtable.add_string(&string_buf[0], string_buf.size());
    BEGIN 0;
    return (STR_CONST);
}
<STRING>[^\"\\]*$ {
    string_buf.insert(string_buf.end(), yytext, yytext + yyleng);
    cool_yylval.error_msg = "Unterminated string constant";
    BEGIN 0;
    ++curr_lineno;
    return (ERROR);
}


<STRING_ESCAPE>n {
    string_buf.push_back('\n');
    BEGIN(STRING);
}
<STRING_ESCAPE>b {
    string_buf.push_back('\b');
    BEGIN(STRING);
}
<STRING_ESCAPE>t {
    string_buf.push_back('\t');
    BEGIN(STRING);
}
<STRING_ESCAPE>f {
    string_buf.push_back('\f');
    BEGIN(STRING);
}

<STRING_ESCAPE>'\0' {
    cool_yylval.error_msg = "String contains null character";
    BEGIN(STRING);
    return (ERROR);
}

<STRING_ESCAPE>\n {
    string_buf.push_back('\n');
    ++curr_lineno;
    BEGIN(STRING);
}
<STRING_ESCAPE><<EOF>> {
    cool_yylval.error_msg = "EOF in string constant";
    BEGIN(STRING);
    return (ERROR);
}
<STRING_ESCAPE>. {
    string_buf.push_back(yytext[0]);
    BEGIN(STRING);
}

. {
  return yytext[0];
}
%%