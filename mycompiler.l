%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "mycompiler.tab.h"


int line_num = 1;
/*
	A primitive macro facility:
	just one macro is allowed to be defined!
*/

int mactable_size = 0;
#define MAXMACRO 32
char* mactable[MAXMACRO][2];
/* Return 1 on success, 0 on failure (macro table full) */
int set_macro(char* name, char* def);

/* Return def for macro, or NULL if no such macro is defined. */
char* get_macro(char* name);
int def_fix = 0;
/*
--------------------------------------------------------------------------------
*/
%}

digit      [0-9]
alpha      [a-zA-Z]
under      [a-zA-Z\_0-9]
spec_1       ("\\n"|"\\t"|"\\r"|"\\\\"|"\\\'")
spec_2       ("\\n"|"\\t"|"\\r"|"\\\\"|"\\\"")
puncts     ("!"|"@"|"#"|"$"|"%"|"^"|"&"|"*"|"?"|":"|"."|"("|")"|"+"|"-"|"^"|"="|"/")
combo      ([A-Z]|[a-z]|[0-9]|" "|{puncts})


IDS        {alpha}{under}*{alpha}*
POS_INT    ((0{digit}*)|({digit}*))*
POS_REAL   ((0{digit}*)|({digit}*))*\.({digit})+([e|E][+|-]?{digit}*)*
CON_STR_1  ("\"")({combo}*{spec_1}*{combo}*)*("\"")
CON_STR_2  ("\'")({combo}*{spec_2}*{combo}*)*("\'")
CON_STR    {CON_STR_1}|{CON_STR_2}
AR_OP      ("+"|"-"|"*"|"/"|"mod"|"div")
ASSIGNMENT (":=")


%x comment
%x macro

%%
program             { printf("token KW_PROGRAM: %s\n", yytext);
                      return KW_PROGRAM;}
begin               { printf("token KW_BEGIN: %s\n", yytext);
                      return KW_BEGIN;}
end                 { printf("token KW_END: %s\n", yytext);
                      return KW_END;}
and                 { printf("token KW_AND: %s\n", yytext);
                      return KW_AND;}
array               { printf("token KW_ARRAY: %s\n", yytext);
                      return KW_ARRAY;}
boolean             { printf("token KW_BOOLEAN: %s\n", yytext);
											yylval.crepr = strdup(yytext);
                      return KW_BOOLEAN;}
char                { printf("token KW_CHAR: %s\n", yytext);
                      yylval.crepr = strdup(yytext);
                      return KW_CHAR;}
do                  { printf("token KW_DO: %s\n", yytext);
                      return KW_DO;}
else                { printf("token KW_ELSE: %s\n", yytext);
                      return KW_ELSE;}
for                 { printf("token KW_FOR: %s\n", yytext);
                      return KW_FOR;}
function            { printf("token KW_FUNCTION: %s\n", yytext);
                      return KW_FUNCTION;}
goto                { printf("token KW_GOTO: %s\n", yytext);
                      return KW_GOTO;}
if                  { printf("token KW_IF: %s\n", yytext);
                      return KW_IF;}
integer             { printf("token KW_INT: %s\n", yytext);
											yylval.crepr = strdup(yytext);
                      return KW_INT;}
var                 { printf("token KW_VAR: %s\n", yytext);
                      return KW_VAR;}
not                 { printf("token KW_NOT: %s\n", yytext);
                      return KW_NOT;}
of                  { printf("token KW_OF: %s\n", yytext);
                      return KW_OF;}
or                  { printf("token KW_OR: %s\n", yytext);
                      return KW_OR;}
while               { printf("token KW_WHILE: %s\n", yytext);
                      return KW_WHILE;}
procedure           { printf("token KW_PROCEDURE: %s\n", yytext);
                      return KW_PROCEDURE;}
real                { printf("token KW_REAL: %s\n", yytext);
											yylval.crepr = strdup(yytext);
                      return KW_REAL;}
repeat              { printf("token KW_REPEAT: %s\n", yytext);
                      return KW_REPEAT;}
to                  { printf("token KW_TO: %s\n", yytext);
                      return KW_TO;}
result              { printf("token KW_RESULT: %s\n", yytext);
                      return KW_RESULT;}
return              { printf("token KW_RETURN: %s\n", yytext);
                      return KW_RETURN;}
then                { printf("token KW_THEN: %s\n", yytext);
                      return KW_THEN;}
until               { printf("token KW_UNTIL: %s\n", yytext);
                      return KW_UNTIL;}
downto              { printf("token KW_DOWNTO: %s\n", yytext);
                      return KW_DOWNTO;}
type                { printf("token KW_TYPE: %s\n", yytext);
                      return KW_TYPE;}


"+"                 { printf("token OP_PLUS: %s\n", yytext);
                      yylval.crepr = strdup(yytext);
                      return OP_PLUS;}
"-"                 { printf("token OP_MINUS: %s\n", yytext);
                      return OP_MINUS;}
"*"                 { printf("token OP_MULT: %s\n", yytext);
                      return OP_MULT;}
"/"                 { printf("token OP_DIVISION: %s\n", yytext);
                      return OP_DIV;}
"mod"               { printf("token OP_MOD: %s\n", yytext);
                      return OP_MOD;}
"div"               { printf("token OP_DIV: %s\n", yytext);
                      return OP_DIV;}

";"	                { printf("token SEMICLN: %s\n", yytext);
                      return SEMICLN;}
":"	                { printf("token CLN: %s\n", yytext);
                      return CLN;}
"="	                { printf("token EQUAL: %s\n", yytext);
                      return EQUAL;}
"."	                { printf("token DOT: %s\n", yytext);
                      return DOT;}
","	                { printf("token COMMA: %s\n", yytext);
                      return COMMA;}
"["	                { printf("token HK_LEFT: %s\n", yytext);
                      return HK_LEFT;}
"]"	                { printf("token HK_RIGHT: %s\n", yytext);
                      return HK_RIGHT;}
"("	                { printf("token LEFT_PAR: %s\n", yytext);
                      return LEFT_PAR;}
")"	                { printf("token RIGHT_PAR: %s\n", yytext);
                      return RIGHT_PAR;}
"!"	                { printf("token EXCL_MARK: %s\n", yytext);
                      return EXCL_MARK;}
">"	                { printf("token RA_BRACK: %s\n", yytext);
                      return RA_BRACK;}
"<"	                { printf("token LA_BRACK: %s\n", yytext);
                      return LA_BRACK;}
">="                { printf("token RA_BRACK_E: %s\n", yytext);
                      return RA_BRACK_E;}
"<="                { printf("token LA_BRACK_E: %s\n", yytext);
                      return LA_BRACK_E;}
"<>"                { printf("token LRA_BRACK: %s\n", yytext);
                      return LRA_BRACK;}
true                { printf("token BOOL_TRUE: %s\n", yytext);
                      return BOOL_TRUE;}
false               { printf("token BOOL_FALSE: %s\n", yytext);
                      return BOOL_FALSE;}
"readString"        { printf("token RD_STR: %s\n", yytext);
                      return RD_STR;}
"readInteger"       { printf("token RD_INT: %s\n", yytext);
                      return RD_INT;}
"readReal"          { printf("token RD_REAL: %s\n", yytext);
                      return RD_REAL;}
"writeString"       { printf("token WR_STR: %s\n", yytext);
                      return WR_STR;}
"writeInteger"      { printf("token WR_INT: %s\n", yytext);
                      return WR_INT;}
"writeReal"         { printf("token WR_REAL: %s\n", yytext);
                      return WR_REAL;}



@defmacro[ \r\t]+       BEGIN(macro);
<macro>{IDS}  {
                /* Store macro name */
                char* name = strdup(yytext);
                char* def = NULL;
                size_t deflen = 0;
                char c;

                FILE* deff = open_memstream(&def, &deflen);

                while((c=input())!='\n')
                  if (c != '(' && c != ')')
                    fputc(c, deff);
                fclose(deff);

                if(!set_macro(name, def))
                  printf("lexer error: failed to define macro '%s'\n", name);
                BEGIN(INITIAL);
              };



{IDS}  		  {
				char* def = get_macro(yytext);
				if(def==NULL) {

					printf( "token IDENTIFIER: %s\n", yytext);
					yylval.crepr = strdup(yytext);
					return IDENTIFIER;
				}
				else {
					int i;
					for(i=strlen(def); i>0; i--) {
						unput(def[i-1]);
					}
				}
			  }

{POS_INT}           { printf( "token POS_INTEGER: %s\n", yytext);
                      yylval.crepr = strdup(yytext);
                      return POS_INTEGER;}

{POS_REAL}          {
  printf( "token POS_REAL: %s\n", yytext);
  yylval.crepr = strdup(yytext);
  return POS_REAL;
}

{CON_STR}          {
					printf( "token CONST_STRING: %s\n", yytext);
					yylval.crepr = strdup(yytext);
					return CONST_STRING;
}

{ASSIGNMENT}        {printf( "token ASSIGNMENT: %s\n", yytext);
                      return ASSIGNMENT;}

"(*"					BEGIN(comment);
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*)\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             ++line_num;
<comment>"*"+")"        BEGIN(INITIAL);
[ \r\t]					/* skip whitespace */
\n 						++line_num;
<<EOF>> 				return EOF;

.        { printf("lexical error: unrecognized literal '%s'\n", yytext); exit(1);}

%%

int set_macro(char* name, char* def)
{
	/* Check to see if macro already defined, and redefine it. */
	int i;
	for(i=0; i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0) {
			/* found ! */
			free(name);
			free(mactable[i][1]);
			mactable[i][1] = def;
			break;
		}
	}
	if(i<mactable_size)
		return 1;
	else if(mactable_size < MAXMACRO) {
		/* new entry */
		/*assert(i==mactable_size);*/
		mactable[i][0] = name;
		mactable[i][1] = def;
		mactable_size++;
		return 1;
	}
	else
		return 0;
}

char* get_macro(char* name)
{
  def_fix = 1;
	int i;
	for(i=0; i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0)
			return mactable[i][1];
	}
	return NULL;
}
