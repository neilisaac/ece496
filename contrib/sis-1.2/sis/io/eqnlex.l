%{
#undef input
#undef unput
#ifdef FLEX_SCANNER
#undef YY_INPUT
#define YY_INPUT(buf,result,max) (result = eqn_input(buf, max))
#endif
%}

blank			[ \n\t]

alpha			[A-Za-z]
alnum			[A-Za-z0-9_.,<>$%[\]:~/-]

%%

({alnum}*) { 
			    if (strcmp(yytext, "0") == 0) {
				return CONST_ZERO;
			    } else if(strcmp(yytext, "1") == 0) {
				return CONST_ONE;
			    } else if (strcmp(yytext, "NAME") == 0) {
				return NAME;
			    } else if (strcmp(yytext, "INORDER") == 0) {
				return INORDER;
			    } else if (strcmp(yytext, "OUTORDER") == 0) {
				return OUTORDER;
			    } else if (strcmp(yytext, "END") == 0) {
				return END;
			    } else {
				return IDENTIFIER; 
			    }
			}


\"[^"]+\"		{ 
   			    int i;

			    yytext[yyleng-1] = '\0';
			    for(i = 0; i < yyleng; i++) {
				yytext[i] = yytext[i+1];
			    }
			    yyleng -= 2;
			    return IDENTIFIER; 
			}
"("			{ return LPAREN; }
")"			{ return RPAREN; }
";"			{ return SEMI; }
"="			{ return ASSIGN; }

"!"			{ return OPR_NOT; }
"'"			{ return OPR_NOT_POST; }
"=="			{ return OPR_XNOR; }
"!="			{ return OPR_XOR; }
"^"			{ return OPR_XOR; }
"&"			{ return OPR_AND; }
"|"			{ return OPR_OR; }
"*"			{ return OPR_AND; }
"+"			{ return OPR_OR; }

{blank}+		;
#.*			; 		/* comments */
.			{ yyerror("bad character"); }

%%

