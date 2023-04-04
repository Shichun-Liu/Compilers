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

// std::vector<char> string_buf(MAX_STR_CONST);

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

--.* { }

<INITIAL,COMMENT>"(*" { 
	comment_depth++;
	BEGIN(COMMENT);
}

<COMMENT>[^(\*\))] { 
	if (yytext[0] == '\n') 	++curr_lineno;
}

<COMMENT>"*)" { 
	comment_depth--;
	if(comment_depth == 0) BEGIN(0); 
}

<COMMENT><<EOF>> {
	cool_yylval.error_msg = "EOF in comment";
	BEGIN (0);
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
{ASSIGN} 	{ return (ASSIGN); }
{LE} 		{ return (LE); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{CLASS} 	{ return (CLASS); }
{ELSE} 		{ return (ELSE); }
{FI} 		{ return (FI); }
{IF} 		{ return (IF); }
{IN} 		{ return (IN); }
{INHERITS} 	{ return (INHERITS); }
{LET} 		{ return (LET); }
{LOOP} 		{ return (LOOP); }
{POOL} 		{ return (POOL); }
{THEN} 		{ return (THEN); }
{WHILE} 	{ return (WHILE); }
{CASE} 		{ return (CASE); }
{ESAC} 		{ return (ESAC); }
{OF} 		{ return (OF); }
{NEW} 		{ return (NEW); }
{ISVOID} 	{ return (ISVOID); }
{NOT} 		{ return (NOT); }


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
    BEGIN(STRING);
	yymore();
}

<STRING>[^\\\"\n]* 	{ yymore();}
<STRING>\\[^\n] 	{ yymore();}

<STRING>\\\n {
	curr_lineno++;
	yymore();
}

<STRING><<EOF>> {
	if(yyleng > MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
	} else {
		cool_yylval.error_msg = "EOF in string constant";
	}
		yyrestart(fin);
		BEGIN(0);
		return (ERROR);
	
}

<STRING>\n {
	if(yyleng > MAX_STR_CONST) {
		cool_yylval.error_msg = "String constant too long";
		curr_lineno++;
		BEGIN(0);
		return (ERROR);
	} else {
		cool_yylval.error_msg = "Unterminated string constant";
		curr_lineno++;
		BEGIN(0);
		return (ERROR);
	}
}
 /* 
<STRING>\\0 {
	yylval.error_msg = "Unterminated string constant";
    BEGIN(0);
    return ERROR;
} */

<STRING>\" {
	std::string input_buf(yytext, yyleng);
	input_buf = input_buf.substr(1, input_buf.length() - 2);
	std::string output_buf = "";
	std::string::size_type pos;

	while((pos = input_buf.find_first_of('\\')) != std::string::npos) {
		output_buf += input_buf.substr(0, pos);
		switch(input_buf[pos + 1]) {
			case 'n':
				output_buf += "\n";
				break;
			case 't':
				output_buf += "\t";
				break;
			case 'b':
				output_buf += "\b";
				break;
			case 'f':
				output_buf += "\f";
				break;
			case '\0':
				yylval.error_msg = "String contains escaped null character.";
				BEGIN(0);
				return ERROR;
			default:
				output_buf += input_buf[pos + 1];
				break;
		}
		input_buf = input_buf.substr(pos + 2, input_buf.length() - 2);
	}

	if(input_buf.find_first_of('\0') != std::string::npos) {
		yylval.error_msg = "String contains null character.";
		BEGIN(0);
		return ERROR;
	}

	output_buf += input_buf;
	if(output_buf.length() > MAX_STR_CONST) {
		yylval.error_msg = "String constant too long";
		BEGIN(0);
		return ERROR;
	}
	cool_yylval.symbol = stringtable.add_string((char*)output_buf.c_str());
	BEGIN(0);
	return STR_CONST;
}

. {
  return yytext[0];
}
%%