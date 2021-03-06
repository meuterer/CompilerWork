/* File:  scanner.l
 * ----------------
 * Lex inupt file to generate the scanner for the compiler.
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"
#include <stdlib.h>

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides
int linenum = 1;
int columnnum = 1;
/* Global variable: yylloc
 * -----------------------
1 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

/* Macro: YY_USER_ACTION
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction();
static void PrintStuff();
#define YY_PRINT_STUFF PrintStuff();
#define YY_USER_ACTION DoBeforeEachAction();

%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later.
  */
boolcons       ((true|false))
digit         (([0-9]))
hexdigit      (([0-9a-fA-F]))
hexstart      ((0[xX]))
letter        ([a-zA-Z])
identifier    ({letter}({letter}|_|{digit})*)
gt            ([>])
gte           (>=)
lt            ([<])
lte           (<=)
eq            (==)
ne            (!=)
and           (\&\&)
or            (\|\|)
whitespace    ([ \t])
newline       ([\n])
stringcons    (\"([^"\n])*(\"|\n))
punctuation   ([%\+\-\*\/\{\}\(\)\;\.\[\]<>=,!])
double        {digit}+\.{digit}*([Ee][\+\-]?{digit}+)*
hexnumber    {hexstart}{hexdigit}+
intcons      {digit}+
%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section.
  */
{gte}     {return(T_GreaterEqual);}
{lte}     {return(T_LessEqual);}
{eq}      {return(T_Equal);}
{punctuation} {return(yytext[0]);}
{and}       {return(T_And);}
{or}        {return(T_Or);}
{ne}        {return(T_NotEqual);}
if      {return(T_If);}
void    {return(T_Void);}
string  {return(T_String);}
this    {return(T_This);}
while   {return(T_While);}
break   {return(T_Break);}
int     {return(T_Int);}
class   {return(T_Class);}
extends {return(T_Extends);}
New     {return(T_New);}
NewArray {return(T_NewArray);}
else     {return(T_Else);}
implements {return(T_Implements);}
interface  {return(T_Interface);}
double     {return(T_Double);}
bool       {return(T_Bool);}
null       {return(T_Null);}
for        {return(T_For);}
return     {return(T_Return);}
true  {yylval.boolConstant = 1; return(T_BoolConstant);}
false {yylval.boolConstant=0;return(T_BoolConstant);}
{stringcons} { if(yytext[strlen(yytext)-1]!= '"')
               {
                  ReportError::UntermString(&yylloc,yytext);
               } else {
                  yylval.stringConstant=strdup(yytext);
                  return(T_StringConstant);}}
{intcons}     {yylval.integerConstant=strtol(yytext,NULL,10);return(T_IntConstant);}
{hexnumber}     {yylval.integerConstant=strtol(yytext,NULL,16);return(T_IntConstant);}
{identifier}      { if (strlen(yytext)>31)
                        {ReportError::LongIdentifier(&yylloc,yytext);
                         }
                   strncpy(yylval.identifier,yytext,31);
                   yylval.identifier[31]='\0';
                   return(T_Identifier);
                   }
{double}         {yylval.doubleConstant = atof(yytext);
                 return(T_DoubleConstant);}
{newline} {columnnum = 1;linenum++;}
{whitespace} {;}
.          {ReportError::UnrecogChar(&yylloc,yytext[0]);}
%%
/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated lex.yy.c file.
 * This section is where you put definitions of helper functions.
 */


/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = false;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
yylloc.first_line = yylloc.last_line = linenum;
yylloc.first_column = columnnum;
yylloc.last_column = columnnum + yyleng-1;
columnnum += yyleng;
}
