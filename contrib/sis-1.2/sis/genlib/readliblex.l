%{
/* file @(#)readliblex.l	1.1                      */
/* last modified on 5/29/91 at 12:35:32   */
#undef input
#undef unput
#ifdef FLEX_SCANNER
#undef YY_INPUT
#define YY_INPUT(buf,result,max) (result = genlib_input(buf, max))
#endif
/*alnum			[-A-Za-z0-9_.<>$%^&|{}[\]:,?/@]*/
%}

blank			[ \n\t]
alnum			[-A-Za-z0-9_]
mant1			([0-9]+\.?[0-9]*)
mant2			([0-9]*\.[0-9]+)
exp			([eE][-+]?[0-9]+)
float			([-+]?({mant1}|{mant2}){exp}?)

%%

\"[^"]+\"		{ 
   			    int i;
			    yytext[yyleng-1] = '\0';
			    for(i = 0; i < yyleng; i++) yytext[i] = yytext[i+1];
			    yyleng -= 2;
			    return IDENTIFIER; 
			}

"("			{ return LPAREN; }
")"			{ return RPAREN; }
";"			{ return SEMI; }
"="			{ return ASSIGN; }
"!"			{ return OPR_NOT; }
"'"			{ return OPR_NOT_POST; }
"+"			{ return OPR_OR; }
"*"			{ return OPR_AND; }

GATE			{ return GATE; }
PIN			{ return PIN; }
LATCH			{ return LATCH; }
CONTROL                 { return CONTROL; }
CONSTRAINT              { return CONSTRAINT; }
SEQ			{ return SEQ; }
"CONST0"		{ return CONST0; }
"CONST1"		{ return CONST1; }
{float}{blank}		{ return REAL;}
{alnum}+		{ return IDENTIFIER; }
{blank}+		;
#.*			; 		/* comments */

.			{ yyerror("bad character"); }

%%
