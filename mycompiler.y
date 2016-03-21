%{
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include "cgen.h"

#define FILENAME "c_output.c"

extern int yylex(void);
extern int line_num;
extern int error;

int smpl_var_flg;
char *token;
char *state;
const char delimiter[] = " ";
char *proc_buffer;
char *var_buffer;

FILE *fp;


%}

%union
{
	char* crepr;
	char name[100];
}

%define parse.error verbose

%token <crepr> IDENTIFIER
%token <crepr> POS_INTEGER
%token <crepr> POS_REAL
%token <crepr> CONST_STRING

%token KW_PROGRAM
%token KW_BEGIN
%token KW_END
%token <crepr> KW_ARRAY
%token <crepr> KW_BOOLEAN
%token <crepr> KW_CHAR
%token KW_DO
%token KW_ELSE
%token KW_FOR
%token KW_FUNCTION
%token KW_GOTO
%token KW_IF
%token <crepr> KW_INT
%token <crepr> KW_VAR
%token <crepr> KW_OF
%token KW_OR
%token KW_WHILE
%token KW_PROCEDURE
%token <crepr> KW_REAL
%token KW_REPEAT
%token KW_TO
%token KW_RESULT
%token KW_RETURN
%token KW_THEN
%token KW_UNTIL
%token KW_DOWNTO
%token KW_TYPE

%left KW_AND
%right KW_NOT
%right EXCL_MARK

%left <crepr> OP_PLUS
%left OP_MINUS
%left OP_MULT
%left OP_DIVISION
%left OP_MOD
%left OP_DIV

%token <crepr> SEMICLN
%token <crepr> CLN
%left EQUAL
%token ASSIGNMENT

%left LA_BRACK
%left RA_BRACK
%left RA_BRACK_E
%left LA_BRACK_E
%left LRA_BRACK

%token BOOL_TRUE
%token BOOL_FALSE

%token DOT
%left COMMA

%token <crepr> HK_LEFT
%token <crepr> HK_RIGHT

%token RIGHT_PAR
%token LEFT_PAR

%right UMINUS
%right UPLUS
%left  MINUS
%left  PLUS
%right CAST
%right NOT
%left  FACTOR
%left  RELATION
%left  LOGIC_AND
%left  LOGIC_OR
%left  PAR_L
%right PAR_R

%token RD_STR
%token RD_INT
%token RD_REAL

%token WR_STR
%token WR_INT
%token WR_REAL



//%type<crepr> cmd_part
//%type<crepr> write_elem
%type<crepr> var_decl
%type<crepr> data_type
%type<crepr> ident
%type<crepr> decl_part
%type<crepr> header_jobs
%type<crepr> special_type
%type<crepr> special_type_aux
%type<crepr> basic_data_type
%type<crepr> hooks
%type<crepr> var_decl_aux
%type<crepr> proc_var_decl
%type<crepr> proc_header
%type<crepr> proc_header_conts
%type<crepr> proc_body_conts
%type<crepr> proc_body
%type<crepr> jobs
%type<crepr> procedure
%type<crepr> cmd_sep
%type<crepr> result_cmd
%type<crepr> expr
%type<crepr> expr_array
%type<crepr> hooks_custom
%type<crepr> assign_cmd
%type<crepr> if_stmt
%type<crepr> stmt_conts
%type<crepr> complex_cmds
%type<crepr> cmd_list
%type<crepr> for_stmt
%type<crepr> while_stmt
%type<crepr> repeat_stmt
//%type<crepr> label_stmt
%type<crepr> goto_stmt
%type<crepr> return_stmt
%type<crepr> func_body_conts
%type<crepr> func_body
%type<crepr> func_var_decl
%type<crepr> func_header_conts
%type<crepr> func_header
%type<crepr> function
%type<crepr> cmd_part
%type<crepr> proc_func
%type<crepr> proc_func_conts
%type<crepr> default_jobs
%type<crepr> read
%type<crepr> write
%type<crepr> read_str
%type<crepr> read_int
%type<crepr> write_str
%type<crepr> write_int
%type<crepr> write_real
%type<crepr> write_real_conts
%type<crepr> write_int_conts

%start program



%%

program: header header_jobs body pr_end
        ;

header : KW_PROGRAM IDENTIFIER SEMICLN {
  fp = fopen(FILENAME, "a");
  fprintf(fp, "/*program %s */\n\n", $2);
  fprintf(fp, "#include <stdio.h>\n");
  fprintf(fp, "#include <stdlib.h>\n\n");
  fclose(fp);
}
;

header_jobs : {asprintf(&$$, "%s", "");}
  | header_jobs decl_part {
    fp = fopen(FILENAME, "a");
    fprintf(fp, "%s%s", $1, $2);
    fclose(fp);
  }
  | header_jobs jobs {
    fp = fopen(FILENAME, "a");
    fprintf(fp, "%s%s", $1, $2);
    fclose(fp);
  }
;

jobs : procedure {
    fp = fopen(FILENAME, "a");
    asprintf(&$$, "%s", $1);
    fclose(fp);
  }
  |function {
    fp = fopen(FILENAME, "a");
    asprintf(&$$, "%s", $1);
    fclose(fp);
  }
;


body : KW_BEGIN cmd_part KW_END {
  fp = fopen(FILENAME, "a");
  fprintf(fp, "\nint main()\n{\n");
  fprintf(fp, "%s\n", $2);
  fprintf(fp, "}\n");
  fclose(fp);
}
;

pr_end : DOT {
  printf("\nThe input program is correct !!!\n");
}
;


decl_part : var_decl {$$ = $1;}
  | special_type {$$ = $1;}
;


/*
Commands
--------------------------------------------------------------------------------
*/

cmd_sep : complex_cmds SEMICLN {asprintf(&$$, "%s", $1);}
  | SEMICLN complex_cmds       {asprintf(&$$, "%s", $2);}
  | SEMICLN result_cmd         {asprintf(&$$, "%s;\n", $2);}
  | result_cmd                 {asprintf(&$$, "%s;\n", $1);}
  | assign_cmd                 {asprintf(&$$, "%s;\n", $1);}
  | SEMICLN assign_cmd         {asprintf(&$$, "%s;\n", $2);}
  | if_stmt                    {asprintf(&$$, "%s\n", $1);}
  | SEMICLN for_stmt           {asprintf(&$$, "%s\n%s", $1, $2);}
  | for_stmt                   {asprintf(&$$, "%s\n", $1);}
  | while_stmt                 {asprintf(&$$, "%s\n", $1);}
  | SEMICLN while_stmt         {asprintf(&$$, "%s\n%s", $1, $2);}
  | repeat_stmt                {asprintf(&$$, "%s\n", $1);}
  | goto_stmt                  {asprintf(&$$, "%s\n", $1);}
  | return_stmt                {asprintf(&$$, "%s;\n", $1);}
  | SEMICLN return_stmt        {asprintf(&$$, "%s;\n", $2);}
  | SEMICLN proc_func          {asprintf(&$$, "%s\n", $2);}
  | proc_func                  {asprintf(&$$, "%s\n", $1);}
  | SEMICLN default_jobs       {asprintf(&$$, "%s;\n", $2);}
  | default_jobs               {asprintf(&$$, "%s;\n", $1);}
  ;


stmt_conts : complex_cmds         {asprintf(&$$, "%s", $1);}
  | SEMICLN result_cmd            {asprintf(&$$, "%s;", $2);}
	| result_cmd                    {asprintf(&$$, "%s;", $1);}
  | assign_cmd                    {asprintf(&$$, "%s;", $1);}
  | SEMICLN assign_cmd            {asprintf(&$$, "%s;", $2);}
;

complex_cmds : KW_BEGIN cmd_list KW_END {
    asprintf(&$$, " {\n%s\n}\n", $2);
}
;

cmd_part:           {asprintf(&$$, "%s", "");}
  |cmd_part cmd_sep {asprintf(&$$, "%s%s", $1, $2);}
  |cmd_part jobs    {asprintf(&$$, "%s%s", $1, $2);}
;

cmd_list :                        {asprintf(&$$, "%s", "");}
  | cmd_list result_cmd           {asprintf(&$$, "%s\n%s;", $1, $2);}
  | cmd_list assign_cmd           {asprintf(&$$, "%s\n%s;", $1, $2);}
	| cmd_list SEMICLN result_cmd   {asprintf(&$$, "%s\n%s;", $1, $3);}
  | cmd_list SEMICLN assign_cmd   {asprintf(&$$, "%s\n%s;", $1, $3);}
  | cmd_list if_stmt              {asprintf(&$$, "%s\n%s", $1, $2);}
  | cmd_list SEMICLN for_stmt     {asprintf(&$$, "%s\n%s", $1, $3);}
  | cmd_list for_stmt             {asprintf(&$$, "%s\n%s", $1, $2);}
  | cmd_list SEMICLN while_stmt   {asprintf(&$$, "%s\n%s", $1, $3);}
  | cmd_list while_stmt           {asprintf(&$$, "%s\n%s", $1, $2);}
  | cmd_list repeat_stmt          {asprintf(&$$, "%s\n%s", $1, $2);}
  | cmd_list goto_stmt            {asprintf(&$$, "%s\n%s", $1, $2);}
  | cmd_list SEMICLN return_stmt  {asprintf(&$$, "%s\n%s;", $1, $3);}
  | cmd_list return_stmt          {asprintf(&$$, "%s\n%s;", $1, $2);}
  | cmd_list proc_func            {asprintf(&$$, "%s\n%s", $1, $2);}
  | cmd_list SEMICLN proc_func    {asprintf(&$$, "%s\n%s", $1, $3);}
  | cmd_list SEMICLN default_jobs {asprintf(&$$, "%s\n%s;", $1, $3);}
  | cmd_list default_jobs         {asprintf(&$$, "%s\n%s;", $1, $2);}
  ;/*| cmd_list label_stmt         {asprintf(&$$, "%s\n%s", $1, $2);}
  ;/*| cmd_list goto_stmt          {asprintf(&$$, "%s\n%s", $1, $2);}
  ;/*| cmd_list return_stmt
  | cmd_list proc_func
;*/

result_cmd : KW_RESULT ASSIGNMENT expr  {
  asprintf(&$$, "result = %s", $3);}
;

assign_cmd : IDENTIFIER ASSIGNMENT expr {asprintf(&$$, "%s = %s", $1, $3);}
;
/*
if_stmt : KW_IF expr KW_THEN stmt_conts {
    asprintf(&$$, "if (%s) {\n\t %s\n\t}\n", $2, $4);
  }
  | if_stmt KW_IF expr KW_THEN stmt_conts KW_ELSE stmt_conts {
    asprintf(&$$, "if (%s) \n\t %s\n else \n\t%s\n\t\n", $3, $5, $7);
  }
;
*/
if_stmt : KW_IF expr KW_THEN stmt_conts {
    asprintf(&$$, "if (%s) {\n%s\n}\n", $2, $4);
  }
  | KW_ELSE if_stmt {asprintf(&$$, "else %s", $2);}
  | KW_ELSE stmt_conts {asprintf(&$$, "else %s", $2);}
;

for_stmt : KW_FOR IDENTIFIER ASSIGNMENT expr KW_TO expr KW_DO stmt_conts {
    asprintf(&$$, "for (%s=%s; %s=%s; %s++)\n%s", $2, $4, $2, $6, $2, $8);
  }
  | KW_FOR IDENTIFIER ASSIGNMENT expr KW_DOWNTO expr KW_DO stmt_conts {
    asprintf(&$$, "for (%s=%s; %s=%s; %s--)\n%s", $2, $4, $2, $6, $2, $8);
  }
;

while_stmt : KW_WHILE expr KW_DO stmt_conts {
  asprintf(&$$, "while (%s)\n%s", $2, $4);
}
;

repeat_stmt : KW_REPEAT stmt_conts KW_UNTIL expr {
  asprintf(&$$, "do\n%s\n while (%s);\n", $2, $4);
}
;

/*label_stmt : IDENTIFIER CLN stmt_conts {asprintf(&$$, "label: %s", $3);}
;
*/
goto_stmt : KW_GOTO IDENTIFIER SEMICLN {asprintf(&$$, "goto %s;", $2);}
;

return_stmt : SEMICLN KW_RETURN {asprintf(&$$, "%s", "return");}
;

proc_func : IDENTIFIER LEFT_PAR proc_func_conts RIGHT_PAR {
  asprintf(&$$, "%s(%s);", $1, $3);
}
;

proc_func_conts :                      {asprintf(&$$, "%s", "");}
  | expr                               {asprintf(&$$, "%s", $1);}
  | proc_func_conts COMMA expr         {asprintf(&$$, "%s, %s", $1, $3);}
;

/*
Variables declarations
--------------------------------------------------------------------------------
*/

var_decl: KW_VAR var_decl_aux {$$ = $2;}
  | var_decl_aux              {$$ = $1;}
;


var_decl_aux : ident CLN data_type SEMICLN {

  if (smpl_var_flg == 0) {
    //fprintf(fp, "%s ", $3);
    //fprintf(fp, "%s;\n", $1);
    asprintf(&$$, "%s %s;\n", $3, $1);
  }
  else {
    token = (char*)malloc(strlen($3)*sizeof(char));
    var_buffer = (char*)malloc((strlen(token)+strlen($1))*sizeof(char));
    token = strtok($3, delimiter);

     asprintf(&var_buffer, "%s %s", token, $1);

    while( token != NULL ) {
      token = strtok(NULL, $3);
      if (token != NULL) {
         asprintf(&var_buffer, "%s%s", var_buffer, token);
      }
    }

     asprintf(&var_buffer, "%s%s", var_buffer, ";\n");

    asprintf(&$$, "%s", var_buffer);

    free(var_buffer);
    free(token);
  }
}
| ident CLN IDENTIFIER SEMICLN {asprintf(&$$, "%s %s", $3, $1);}

;

ident : ident COMMA IDENTIFIER {
    asprintf(&$$, "%s, %s", $1, $3);
  }
  | IDENTIFIER {
    $$ = $1;
  }
;

data_type : basic_data_type {$$ = $1;}
  | KW_ARRAY hooks KW_OF basic_data_type { // Array general template
    asprintf(&$$, "%s [%s]", $4,$2); smpl_var_flg = 1;
  }
  | KW_ARRAY KW_OF basic_data_type {
    asprintf(&$$, "%s %s", $3, "*");
  }
;

hooks : HK_LEFT POS_INTEGER HK_RIGHT {$$ = $2;}; // Single pair of hooks
    // Multiple pairs of hooks
  | hooks HK_LEFT POS_INTEGER HK_RIGHT {asprintf(&$$, "%s][%s", $1, $3);}
;

basic_data_type : KW_INT {asprintf(&$$, "%s", "int"); smpl_var_flg = 0;}
  | KW_CHAR              {$$ = $1; smpl_var_flg = 0;}
  | KW_BOOLEAN           {asprintf(&$$, "%s", "int"); smpl_var_flg = 0;}
  | KW_REAL              {asprintf(&$$, "%s", "double"); smpl_var_flg = 0;}
;

special_type : KW_TYPE special_type_aux {
    asprintf(&$$, "typedef %s;\n", $2);
  }
  | special_type_aux {
    asprintf(&$$, "typedef %s;\n", $1);
  }
;

special_type_aux : ident EQUAL data_type SEMICLN {
    asprintf(&$$, "%s %s", $3, $1);
  }
  | ident EQUAL KW_FUNCTION LEFT_PAR func_header_conts
    RIGHT_PAR CLN data_type SEMICLN {
    asprintf(&$$, "%s function(%s)", $8, $1);
  }
;



/*
procedure
--------------------------------------------------------------------------------
*/
procedure : proc_header proc_body {
  fp = fopen(FILENAME, "a");
  asprintf(&$$, "\n%s\n%s\n", $1, $2);
  fclose(fp);
}
;

proc_header : KW_PROCEDURE IDENTIFIER LEFT_PAR proc_header_conts
              RIGHT_PAR SEMICLN {
  asprintf(&$$, "\nvoid %s(%s)", $2, $4);
}
;

proc_header_conts : {asprintf(&$$, "%s", "");}
  | proc_header_conts SEMICLN proc_var_decl {
    asprintf(&$$, "%s, %s", $1, $3);
  }
  | proc_var_decl {asprintf(&$$, "%s", $1);}
;

proc_var_decl : ident CLN data_type {
	  //fp = fopen(FILENAME, "a");

    if (smpl_var_flg == 0) {
      asprintf(&$$, "%s %s", $3, $1);
    }
    else {
      token = (char*)malloc(strlen($3)*sizeof(char));
      proc_buffer = (char*)malloc((strlen(token)+strlen($1))*sizeof(char));
      token = strtok($3, delimiter);

      asprintf(&proc_buffer, "%s %s", token, $1);

      while( token != NULL ) {
        token = strtok(NULL, $3);
        if (token != NULL) {
          //fprintf(fp, "%s", token);
          asprintf(&proc_buffer, "%s%s", proc_buffer, token);
        }
      }
      //fprintf(fp, ";\n");
      asprintf(&$$, "%s", proc_buffer);
      free(proc_buffer);
      //free(aux_identifier);
      free(token);
    }
    //fclose(fp);
  }
  | ident CLN IDENTIFIER {asprintf(&$$, "%s %s", $3, $1);}
;


proc_body : proc_body_conts complex_cmds SEMICLN{
  asprintf(&$$, "{%s%s}\n", $1, $2);
}
;

proc_body_conts :             {asprintf(&$$, "%s", "");}
  | proc_body_conts decl_part {asprintf(&$$, "%s\n%s\n", $1, $2);}
  | proc_body_conts jobs      {asprintf(&$$, "%s\n%s\n", $1, $2);}
/*  | proc_body_conts cmd_sep   {asprintf(&$$, "%s %s", $1, $2);}*/
;


/*
function
--------------------------------------------------------------------------------
*/
function : func_header func_body {
  fp = fopen(FILENAME, "a");
  asprintf(&$$, "\n%s\n%s\n", $1, $2);
  fclose(fp);
}
;

func_header : KW_FUNCTION IDENTIFIER LEFT_PAR func_header_conts
              RIGHT_PAR CLN data_type SEMICLN {
  asprintf(&$$, "%s %s(%s)", $7, $2, $4);
}
;

func_header_conts :                         {asprintf(&$$, "%s", "");}
  | func_header_conts SEMICLN func_var_decl {asprintf(&$$, "%s, %s", $1, $3);}
  | func_var_decl                           {asprintf(&$$, "%s", $1);}
;

func_var_decl : ident CLN data_type {asprintf(&$$, "%s %s", $3, $1);}
  | ident CLN IDENTIFIER {asprintf(&$$, "%s %s", $3, $1);}

;

func_body : func_body_conts complex_cmds SEMICLN {
  asprintf(&$$, " {%s%s}\n", $1, $2);
}
;

func_body_conts :             {asprintf(&$$, "%s", "");}
  | func_body_conts decl_part {asprintf(&$$, "%s\n%s\n", $1, $2);}
  | func_body_conts jobs      {asprintf(&$$, "%s\n%s\n", $1, $2);}
/*  | func_body_conts cmd_sep   {asprintf(&$$, "%s %s", $1, $2);}*/
;


/*
Default functions
--------------------------------------------------------------------------------
*/
default_jobs : read  {asprintf(&$$, "%s", $1);}
  | write            {asprintf(&$$, "%s", $1);}
;

read : read_str {asprintf(&$$, "%s", $1);}
  | read_int    {asprintf(&$$, "%s", $1);}
;

write : write_str {asprintf(&$$, "%s", $1);}
  | write_int     {asprintf(&$$, "%s", $1);}
  | write_real    {asprintf(&$$, "%s", $1);}
;

read_str : RD_STR LEFT_PAR RIGHT_PAR {asprintf(&$$, "gets()");}
;

read_int : RD_INT LEFT_PAR RIGHT_PAR {asprintf(&$$, "atoi(gets())");}
;

write_str : WR_STR LEFT_PAR IDENTIFIER RIGHT_PAR {
    asprintf(&$$, "puts(%s)", $3);
  }
  | WR_STR LEFT_PAR CONST_STRING RIGHT_PAR {
    asprintf(&$$, "puts(%s)", $3);
  }
;

write_int : WR_INT LEFT_PAR write_int_conts RIGHT_PAR {
  asprintf(&$$, "printf(\"%s\", %s)", "%d", $3);
}
;

write_int_conts : KW_RESULT   {asprintf(&$$, "%s", "result");}
  | expr        {asprintf(&$$, "%s", $1);}
;

write_real : WR_REAL LEFT_PAR write_real_conts RIGHT_PAR {
  asprintf(&$$, "printf(\"%s\", %s)", "%g", $3);
}
;

write_real_conts : /*IDENTIFIER {asprintf(&$$, "%s", $1);}
  | POS_REAL {asprintf(&$$, "%s", $1);}*/
  expr {asprintf(&$$, "%s", $1);}
;
/*
Expressions
--------------------------------------------------------------------------------
*/

/*expressions :
               |expressions expr SEMICLN
		       ;
*//*
expr:		IDENTIFIER{}
		|POS_INTEGER{}
		|POS_REAL{}
		|KW_BOOLEAN{}
		|CONST_STRING{}
		|RD_INT{}
		|RD_REAL{}
		|RD_STR{}
		|LEFT_PAR  expr RIGHT_PAR{}
		|LEFT_PAR  basic_data_type RIGHT_PAR  expr {}
		|IDENTIFIER LEFT_PAR expr RIGHT_PAR{}
		|NOT expr {}
		|'!' expr {}
		|'+' expr %prec UPLUS{}
		|'-' expr %prec UMINUS{}
		|expr OP_DIV  expr {}
		|expr OP_MOD expr {}
		|expr OP_PLUS  expr {}
		|expr OP_MINUS  expr {}
		|expr EQUAL  expr {}
		|expr KW_AND expr {}
		|expr KW_OR expr {}
		|KW_RESULT {}
    |expr_array{}
;*/

expr : KW_NOT expr %prec NOT            {asprintf(&$$, "not(%s)", $2);}
  | EXCL_MARK expr %prec NOT            {asprintf(&$$, "!(%s)", $2);}
  | OP_MINUS expr %prec UMINUS          {asprintf(&$$, "-(%s)", $2);}
  | OP_PLUS expr %prec UPLUS            {asprintf(&$$, "+(%s)", $2);}
  | expr OP_PLUS expr %prec PLUS        {asprintf(&$$, "%s + %s", $1, $3);}
  | expr OP_MINUS expr %prec MINUS      {asprintf(&$$, "%s - %s", $1, $3);}
  | expr OP_DIV expr %prec FACTOR       {asprintf(&$$, "div(%s, %s)", $1, $3);}
  | expr OP_MULT expr %prec FACTOR      {asprintf(&$$, "%s * %s", $1, $3);}
  | expr OP_MOD expr  %prec FACTOR      {asprintf(&$$, "%s mod %s", $1, $3);}
  | expr OP_DIVISION expr %prec FACTOR  {asprintf(&$$, "%s / %s", $1, $3);}
  | expr EQUAL expr %prec RELATION      {asprintf(&$$, "%s == %s", $1, $3);}
  | expr LA_BRACK expr %prec RELATION   {asprintf(&$$, "%s < %s", $1, $3);}
  | expr RA_BRACK expr %prec RELATION   {asprintf(&$$, "%s > %s", $1, $3);}
  | expr LA_BRACK_E expr %prec RELATION {asprintf(&$$, "%s <= %s", $1, $3);}
  | expr RA_BRACK_E expr %prec RELATION {asprintf(&$$, "%s >= %s", $1, $3);}
  | expr LRA_BRACK expr %prec RELATION  {asprintf(&$$, "%s <> %s", $1, $3);}
  | expr KW_AND expr %prec LOGIC_AND    {asprintf(&$$, "%s && %s", $1, $3);}
  | LEFT_PAR data_type RIGHT_PAR expr %prec PAR_L {asprintf(&$$, "(%s)", $2);}
  | LEFT_PAR expr RIGHT_PAR %prec PAR_R           {asprintf(&$$, "(%s)", $2);}
  | IDENTIFIER                          {$$ = $1;}
  | POS_REAL                            {asprintf(&$$, "%s", $1);}
  | POS_INTEGER                         {$$ = $1;}
  | CONST_STRING                        {$$ = $1;}
  | BOOL_FALSE                          {asprintf(&$$, "%s", "0");}
  | BOOL_TRUE                           {asprintf(&$$, "%s", "1");}
  | expr_array                          {asprintf(&$$, "%s", $1);}
  | read_str                            {asprintf(&$$, "%s", $1);}
  | read_int                            {asprintf(&$$, "%s", $1);}
  | IDENTIFIER LEFT_PAR expr RIGHT_PAR  {asprintf(&$$, "%s(%s)", $1, $3);}
;

expr_array : IDENTIFIER hooks_custom   {asprintf(&$$, "%s %s", $1, $2);}
;

hooks_custom : HK_LEFT expr HK_RIGHT   {asprintf(&$$, "[%s]", $2);}
  | hooks_custom HK_LEFT expr HK_RIGHT {asprintf(&$$, "%s [%s]", $1, $3);}
;





%%

int main()
{
	yyparse();
}

int yyerror (char *s)
{

  fprintf (stderr, "%s in line: %d\n", s, line_num);
  return 1;
}
