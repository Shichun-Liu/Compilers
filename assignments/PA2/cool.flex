 
 /* 
 * The scanner definition for COOL.
 * Stuff enclosed in %{ %} in the first section is copied verbatim to the
 * output, so headers and global definitions are placed here to be visible
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

/* 
 * define YY_INPUT so we read from the FILE fin:
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
int comment_layer = 0;
int buf_len = 0;

%}

/*
 * Define names for regular expressions here.
*/

DARROW          =>
ASSIGN		  	<-
LE				<=
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
NOT             not
TYPEID        [A-Z_][A-Za-z0-9_]*
OBJECTID      [a-z][A-Za-z0-9_]*
INT_CONST     [0-9]+
STR_CONST     \".*\"
WIHTE_SPACE   [\ \t\n]+
LINE          \n
%startComment	COMMENT
%startString  	STRING
%startESCAPE  	ESCAPE_STRING

%%

 /*
  *  Nested comments
  */
--[^\n]* {}
"(*" { comment_layer++; BEGIN COMMENT; }

<COMMENT>[^\n(*]* 	{}
<COMMENT>\n			{ curr_lineno++;}
<COMMENT>"*)" 		{ 
						comment_layer--; 
						if (comment_layer == 0) BEGIN INITIAL; 
					}

<COMMENT><<EOF>>	{ 
						cool_yylval.error_msg = "EOF in comment";
						BEGIN INITIAL;
						return (ERROR);
					}
"*)"				{
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
{LOOP} 		{ return (LOOP); }
{POOL} 		{ return (POOL); }
{THEN} 		{ return (THEN); }
{WHILE} 	{ return (WHILE); }
{CASE} 		{ return (CASE); }
{ESAC} 		{ return (ESAC); }
{OF} 		{ return (OF); }
{NEW} 		{ return (NEW); }
{ISVOID} 	{ return (ISVOID); }
{ASSIGN} 	{ return (ASSIGN); }
{NOT} 		{ return (NOT); }
{LE} 		{ return (LE); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

t(?i:rue) 	{ cool_yylval.boolean = true; return BOOL_CONST; }
f(?i:alse) 	{ cool_yylval.boolean = false; return BOOL_CONST; }
[0-9]+ 		{ cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }
[A-Z_][A-Za-z0-9_]* { cool_yylval.symbol = idtable.add_string(yytext); return TYPEID; }
[a-z][A-Za-z0-9_]* 	{ cool_yylval.symbol = idtable.add_string(yytext); return OBJECTID; }
 
 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
<INITIAL>\"			{ BEGIN STRING; string_buf_ptr = string_buf; }
<STRING>[^\"\\]*\"	{ 
						strcpy(string_buf_ptr, yytext);
						*(string_buf_ptr + yyleng) = '\0';

						buf_len += yyleng;
						if (buf_len > MAX_STR_CONST) {
							cool_yylval.error_msg = "String constant too long";
							BEGIN INITIAL;
							return (ERROR);
						}

						cool_yylval.symbol = stringtable.add_string(string_buf);
						buf_len = 0;
						BEGIN INITIAL;
						return STR_CONST;
					}
<STRING>[^\"\\]*\\	{ 
						strcpy(string_buf_ptr, yytext);
						string_buf_ptr += yyleng - 1;
						BEGIN ESCAPE_STRING;
					}
<ESCAPE_STRING>"n"	{ *string_buf_ptr++ = '\n';BEGIN STRING; }
<ESCAPE_STRING>"b"	{ *string_buf_ptr++ = '\b';BEGIN STRING; }
<ESCAPE_STRING>"t"	{ *string_buf_ptr++ = '\t';BEGIN STRING; }
<ESCAPE_STRING>"f"	{ *string_buf_ptr++ = '\f';BEGIN STRING; }
<ESCAPE_STRING>.	{ *string_buf_ptr++ = yytext[0];BEGIN STRING; }
<ESCAPE_STRING>\n	{ *string_buf_ptr++ = '\n';curr_lineno++; BEGIN STRING; }
<ESCAPE_STRING><<EOF>>	{ 
						cool_yylval.error_msg = "EOF in string constant";
						BEGIN INITIAL;
						return (ERROR);
					}
<STRING>[^\"\\]*$	{ 
						strcpy(string_buf_ptr, yytext);
						// string_buf_ptr += yyleng;
						buf_len += yyleng;
						cool_yylval.error_msg = "Unterminated string constant";
						curr_lineno++;
						BEGIN INITIAL;
						return (ERROR);
					}
<STRING><<EOF>>		{ 
						cool_yylval.error_msg = "EOF in string constant";
						BEGIN INITIAL;
						return (ERROR);
					}

 /*
  *  Single-character operators
  */
[  \f\r\t\v]+ 	{}
"\n"			{curr_lineno++;}
[\[\]'>]		{
					cool_yylval.error_msg = yytext;
					return (ERROR);
				}
.				{ return yytext[0]; }
%%
