
# line 2 "gram.y"
/*
 * Revision Control Information
 *
 * $Source$
 * $Author$
 * $Revision$
 * $Date$
 *
 */
#include "reductio.h"
extern char yytext[];
# define DOT_I 257
# define DOT_O 258
# define DOT_S 259
# define DOT_R 260
# define DOT_P 261
# define DOT_E 262
# define NAME 263
# define CUBE 264
# define NUM 265
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 28
# define YYLAST 44
short yyact[]={

  24,  23,  22,  21,  19,  18,  17,  16,  31,  37,
  28,   9,  10,  12,  11,  13,  28,  26,  35,  33,
  20,   3,  36,  34,  15,  32,  27,   8,   7,   6,
   5,   4,  29,  25,  14,   2,   1,   0,   0,   0,
   0,   0,   0,  30 };
short yypact[]={

-246,-1000,-246,-1000,-1000,-1000,-1000,-1000,-1000,-258,
-260,-243,-262,-264,-248,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-254,-1000,-244,-1000,-1000,
-1000,-1000,-245,-1000,-255,-1000,-1000,-1000 };
short yypgo[]={

   0,  36,  35,  34,  33,  32,  21,  31,  30,  29,
  28,  27,  17,  26,  25,  23,  22 };
short yyr1[]={

   0,   3,   1,   2,   2,   6,   6,   6,   6,   6,
   4,   4,   7,   7,   8,   8,   9,  10,  10,  11,
  11,   5,   5,  12,  13,  16,  14,  15 };
short yyr2[]={

   0,   0,   4,   1,   2,   1,   1,   1,   1,   1,
   1,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   1,   0,   4,   1,   1,   1,   1 };
short yychk[]={

-1000,  -1,  -2,  -6,  -7,  -8,  -9, -10, -11, 257,
 258, 260, 259, 261,  -3,  -6, 265, 264, 265, 264,
 263, 265, 264, 265, 264,  -4, -12, -13, 264,  -5,
 -12, 262, -14, 263, -15, 263, -16, 264 };
short yydef[]={

   0,  -2,   1,   3,   5,   6,   7,   8,   9,   0,
   0,   0,   0,   0,   0,   4,  12,  13,  14,  15,
  16,  17,  18,  19,  20,  22,  10,   0,  24,   2,
  11,  21,   0,  26,   0,  27,  23,  25 };
#ifndef lint
static char yaccpar_sccsid[] = "@(#)yaccpar	4.1	(Berkeley)	2/11/83";
#endif

#
# define YYFLAG -1000
# define YYERROR goto yyerrlab
# define YYACCEPT return(0)
# define YYABORT return(1)

/*	parser for yacc output	*/

#ifdef YYDEBUG
int yydebug = 0; /* 1 for debugging */
#endif
YYSTYPE yyv[YYMAXDEPTH]; /* where the values are stored */
int yychar = -1; /* current input token number */
int yynerrs = 0;  /* number of errors */
short yyerrflag = 0;  /* error recovery flag */

yyparse() {

	short yys[YYMAXDEPTH];
	short yyj, yym;
	register YYSTYPE *yypvt;
	register short yystate, *yyps, yyn;
	register YYSTYPE *yypv;
	register short *yyxi;

	yystate = 0;
	yychar = -1;
	yynerrs = 0;
	yyerrflag = 0;
	yyps= &yys[-1];
	yypv= &yyv[-1];

 yystack:    /* put a state and value onto the stack */

#ifdef YYDEBUG
	if( yydebug  ) printf( "state %d, char 0%o\n", yystate, yychar );
#endif
		if( ++yyps> &yys[YYMAXDEPTH] ) { yyerror( "yacc stack overflow" ); return(1); }
		*yyps = yystate;
		++yypv;
		*yypv = yyval;

 yynewstate:

	yyn = yypact[yystate];

	if( yyn<= YYFLAG ) goto yydefault; /* simple state */

	if( yychar<0 ) if( (yychar=yylex())<0 ) yychar=0;
	if( (yyn += yychar)<0 || yyn >= YYLAST ) goto yydefault;

	if( yychk[ yyn=yyact[ yyn ] ] == yychar ){ /* valid shift */
		yychar = -1;
		yyval = yylval;
		yystate = yyn;
		if( yyerrflag > 0 ) --yyerrflag;
		goto yystack;
		}

 yydefault:
	/* default state action */

	if( (yyn=yydef[yystate]) == -2 ) {
		if( yychar<0 ) if( (yychar=yylex())<0 ) yychar = 0;
		/* look through exception table */

		for( yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate) ; yyxi += 2 ) ; /* VOID */

		while( *(yyxi+=2) >= 0 ){
			if( *yyxi == yychar ) break;
			}
		if( (yyn = yyxi[1]) < 0 ) return(0);   /* accept */
		}

	if( yyn == 0 ){ /* error */
		/* error ... attempt to resume parsing */

		switch( yyerrflag ){

		case 0:   /* brand new error */

			yyerror( "syntax error" );
		yyerrlab:
			++yynerrs;

		case 1:
		case 2: /* incompletely recovered error ... try again */

			yyerrflag = 3;

			/* find a state where "error" is a legal shift action */

			while ( yyps >= yys ) {
			   yyn = yypact[*yyps] + YYERRCODE;
			   if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ){
			      yystate = yyact[yyn];  /* simulate a shift of "error" */
			      goto yystack;
			      }
			   yyn = yypact[*yyps];

			   /* the current yyps has no shift onn "error", pop stack */

#ifdef YYDEBUG
			   if( yydebug ) printf( "error recovery pops state %d, uncovers %d\n", *yyps, yyps[-1] );
#endif
			   --yyps;
			   --yypv;
			   }

			/* there is no state on the stack with an error shift ... abort */

	yyabort:
			return(1);


		case 3:  /* no shift yet; clobber input char */

#ifdef YYDEBUG
			if( yydebug ) printf( "error recovery discards char %d\n", yychar );
#endif

			if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */
			yychar = -1;
			goto yynewstate;   /* try again in the same state */

			}

		}

	/* reduction by production yyn */

#ifdef YYDEBUG
		if( yydebug ) printf("reduce %d\n",yyn);
#endif
		yyps -= yyr2[yyn];
		yypvt = yypv;
		yypv -= yyr2[yyn];
		yyval = yypv[1];
		yym=yyn;
			/* consult goto table to find next state */
		yyn = yyr1[yyn];
		yyj = yypgo[yyn] + *yyps + 1;
		if( yyj>=YYLAST || yychk[ yystate = yyact[yyj] ] != -yyn ) yystate = yyact[yypgo[yyn]];
		switch(yym){
			
case 1:
# line 22 "gram.y"
{
		type = MEALY;
	} break;
case 12:
# line 44 "gram.y"
{
			nis = atoi (yytext);
		} break;
case 13:
# line 48 "gram.y"
{
			nis = atoi (yytext);
		} break;
case 14:
# line 54 "gram.y"
{
			nos = atoi (yytext);
		} break;
case 15:
# line 58 "gram.y"
{
			nos = atoi (yytext);
		} break;
case 16:
# line 64 "gram.y"
{
			strcpy (startstate, yytext);
		} break;
case 23:
# line 82 "gram.y"
{
			mealy ();
		} break;
case 24:
# line 87 "gram.y"
{
			strcpy (lastin, yytext);
		} break;
case 25:
# line 93 "gram.y"
{
			strcpy (lastout, yytext);
		} break;
case 26:
# line 99 "gram.y"
{
			strcpy (laststate, yytext);
		} break;
case 27:
# line 105 "gram.y"
{
			strcpy (lastnext, yytext);
		} break; 
		}
		goto yystack;  /* stack new state and value */

	}
