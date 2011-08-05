/************************************************************************/
/* CPN Tools                                                            */
/* Copyright 2010-2011 AIS Group, Eindhoven University of Technology    */
/*                                                                      */
/* CPN Tools is originally developed by the CPN Group at Aarhus         */
/* University from 2000 to 2010. The main architects behind the tool    */
/* are Kurt Jensen, Soren Christensen, Lars M. Kristensen, and Michael  */
/* Westergaard.  From the autumn of 2010, CPN Tools is transferred to   */
/* the AIS group, Eindhoven University of Technology, The Netherlands.  */
/*                                                                      */
/* This file is part of CPN Tools.                                      */
/*                                                                      */
/* CPN Tools is free software: you can redistribute it and/or modify    */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation, either version 2 of the License, or    */
/* (at your option) any later version.                                  */
/*                                                                      */
/* CPN Tools is distributed in the hope that it will be useful,         */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        */
/* GNU General Public License for more details.                         */
/*                                                                      */
/* You should have received a copy of the GNU General Public License    */
/* along with CPN Tools.  If not, see <http://www.gnu.org/licenses/>.   */
/************************************************************************/
%{
#include "mlparse.tab.h"
#include <stdlib.h>

/* needed to fix bug #563 */
int in_stringwithopt = 0;
int parenlevel = 0;
char *buffer = NULL;
int buflen = 0;
int bufpos = 0;
int oldstate = 0;
int commentNesting = 0;
int commentOldState = 0;

int lineno = 1;

void addtoBuffer (char *s);
void resetBuffer ();
%}

%x MLSEMI MLSEMICONTENTS MLSEMIPAREN
%x MLDOTDOT MLDOTDOTCONTENTS MLDOTDOTPAREN
%x MLID 
%x MLCOL MLCOLCONTENTS MLCOLPAREN

%x MLDECL
%x MISC COMMENT MLCOMMENT

%%
[ \t]+				/* ignore */
\n				lineno++;

var				return tVAR;
channel			return tCHANNEL;
msvar				return tMSVAR;
globref				return tGLOBREF;
use				return tUSE; 
colset				return tCOLOR;
color                           return tCOLOR;
sort                            return tCOLOR;
invariant			return tINVARIANT;

.				{ yyless(0); resetBuffer(); BEGIN(MLDECL); }

<COMMENT>\n			lineno++;
<COMMENT>.			/* ignore */
<COMMENT>"(*"			commentNesting++;
<COMMENT>"*)"			{ if (--commentNesting == 0) {
                                    BEGIN(commentOldState); 
                                  }
                                }
<COMMENT><<EOF>> {BEGIN(commentOldState); }

<MLCOMMENT>\n			{ lineno++; addtoBuffer(yytext); }
<MLCOMMENT>.			addtoBuffer(yytext);
<MLCOMMENT>"(*"			addtoBuffer("(*"); commentNesting++;
<MLCOMMENT>"*)"			{ addtoBuffer("*)");
                                  if (--commentNesting == 0) {
                                    BEGIN(commentOldState); 
                                  }
                                }
<MLCOMMENT><<EOF>> {BEGIN(commentOldState); }
<INITIAL,MISC,MLSEMI,MLDOTDOT,MLID,MLCOL>"(*"	{ commentNesting++; commentOldState = YYSTATE; BEGIN(COMMENT); }
<MLDECL,MLSEMICONTENTS,MLSEMIPAREN,MLDOTDOTCONTENTS,MLDOTDOTPAREN,MLCOLCONTENTS,MLCOLPAREN>"(*" { addtoBuffer("(*"); commentNesting++; commentOldState = YYSTATE; BEGIN(MLCOMMENT); }

<MISC>[ \t]+			/* ignore */
<MISC>\n			lineno++;
<MISC>with			return tWITH;
<MISC>declare			return tDECLARE;
<MISC>ms			return tMS;
<MISC>timed			return tTIMED;
<MISC>int			return tINT;
<MISC>bool		        return tBOOL;
<MISC>unit			return tUNIT;
<MISC>real                 	return tREAL;
<MISC>string 			return tSTRING;
<MISC>index			return tINDEX;
<MISC>product			return tPRODUCT;
<MISC>record			return tRECORD;
<MISC>list		 	return tLIST;
<MISC>union			return tUNION;
<MISC>subset		        return tSUBSET;
<MISC>and			return tAND;
<MISC>by			return tBY;
<MISC>"+"			return '+';
<MISC>"|"			return '|';
<MISC>"*"			return '*';
<MISC>"("			return '(';
<MISC>")"			return ')';
<MISC>"="			return '=';
<MISC>":"			return ':';
<MISC>";"			return ';';
<MISC>","			return ',';
<MISC>".."			return tDOTDOT;
<MISC>[a-zA-Z_][a-zA-Z0-9_']*	{ yyless(0); return tHACK; }

<MLSEMI>[ \t]+			/* ignore */
<MLSEMI>\n			lineno++;
<MLSEMI>[^ \t\n]		{ yyless(0); BEGIN(MLSEMICONTENTS); }

<MLSEMICONTENTS>"\"[^\"]*\""    addtoBuffer(yytext);
<MLSEMICONTENTS>[^;()]+		addtoBuffer(yytext);
<MLSEMICONTENTS>"("		{ addtoBuffer("("); parenlevel++; BEGIN(MLSEMIPAREN); }
<MLSEMICONTENTS>")"		return tERROR;
<MLSEMICONTENTS>";"		{ BEGIN(oldstate); yylval.string = buffer; return tMLSEMI; }

<MLSEMIPAREN>[^()]+		addtoBuffer(yytext);
<MLSEMIPAREN>"("		addtoBuffer("("); parenlevel++;			
<MLSEMIPAREN>")"		{ addtoBuffer(")");
                                  if (--parenlevel == 0) {
                                    BEGIN(MLSEMICONTENTS);
                                  }
                                }

<MLDOTDOT>[ \t]+		/* ignore */
<MLDOTDOT>\n			lineno++;
<MLDOTDOT>[^ \t\n]		{ yyless(0); BEGIN(MLDOTDOTCONTENTS); }

<MLDOTDOTCONTENTS>[^()]		addtoBuffer(yytext);
<MLDOTDOTCONTENTS>"\""[^"\""\n]*"\"" addtoBuffer(yytext);
<MLDOTDOTCONTENTS>"("		{ addtoBuffer("("); parenlevel++; BEGIN(MLDOTDOTPAREN); }
<MLDOTDOTCONTENTS>")"		return tERROR;
<MLDOTDOTCONTENTS>".."		{ BEGIN(oldstate); yylval.string = buffer; return tMLDOTDOT; }

<MLDOTDOTPAREN>[^()]+		addtoBuffer(yytext);
<MLDOTDOTPAREN>"("		addtoBuffer("("); parenlevel++;			
<MLDOTDOTPAREN>")"		{ addtoBuffer(")");
                                  if (--parenlevel == 0) {
                                    BEGIN(MLDOTDOTCONTENTS);
                                  }
                                }

<MLCOL>[ \t]+			/* ignore */
<MLCOL>\n			lineno++;
<MLCOL>[^ \t\n]			{ yyless(0); BEGIN(MLCOLCONTENTS); }

<MLCOLCONTENTS>[^;()]		addtoBuffer(yytext);
<MLCOLCONTENTS>"\""[^"\""]*"\"" addtoBuffer(yytext);
<MLCOLCONTENTS>"("		{ addtoBuffer("("); parenlevel++; BEGIN(MLCOLPAREN); }
<MLCOLCONTENTS>")"		return tERROR;
<MLCOLCONTENTS>";"|"declare"|"timed"	{ yyless(0); BEGIN(oldstate); yylval.string = buffer; return tMLCOL; }
<MLCOLCONTENTS>"and"	        { /* in the string case there is an extra keyword: and 
                                   * See bug #563 for details. */
                                  if (in_stringwithopt) {
                                    yyless(0); 
                                    BEGIN(oldstate); 
                                    yylval.string = buffer; 
                                    return tMLCOL; 
                                  } else {
                                    addtoBuffer(yytext);
                                  }
                                }

<MLCOLPAREN>[^()]+		addtoBuffer(yytext);
<MLCOLPAREN>"("			addtoBuffer("("); parenlevel++;			
<MLCOLPAREN>")"			{ addtoBuffer(")");
                                  if (--parenlevel == 0) {
                                    BEGIN(MLCOLCONTENTS);
                                  }
                                }

<MLID>[ \t]+			/* ignore */
<MLID>\n			lineno++;
<MLID>[_a-zA-Z][_a-zA-Z0-9']* 	BEGIN(oldstate); yylval.string = yytext; return tID;

<MLDECL>.					addtoBuffer(yytext);
<MLDECL>\n					{ lineno++; addtoBuffer(yytext); }
<MLDECL>"\""[^"\""]*"\"" 			addtoBuffer(yytext);
<MLDECL>"var"|"msvar"|"colset"|"color"|"globref"|"use"|"invariant" 	{ yyless(0); BEGIN(0); yylval.string = buffer; return tMLDECL; }
<MLDECL>[_a-zA-Z][_a-zA-Z0-9']*                 addtoBuffer(yytext);
<MLDECL><<EOF>>					{ BEGIN(0); addtoBuffer(yytext); yylval.string = buffer; return tMLDECL; }
<*>.                            return tERROR;

%%

void
yybegin (int s)
{
  oldstate = YYSTATE;
  BEGIN(s);
}

void
resetBuffer ()
{
  if (buffer)
    free(buffer);
  buffer = NULL;
  buflen = 0;
  bufpos = 0;
}

void
addtoBuffer (char *s)
{
  if (!buffer) {
    bufpos = 0;
    buflen = strlen(s) + 1;
    buffer = malloc(buflen);
   }
  if ((buflen - bufpos) < (strlen(s) + 1)) {
    buflen = buflen * 2 + strlen(s) + 1;
    buffer = realloc(buffer, buflen);
  }
  strcpy(&buffer[bufpos],s);
  bufpos += strlen(s);
}
