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
#define YYERROR_VERBOSE

#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#include <malloc.h>
#endif

int escape (char *s);
extern int lineno;
int indent = 0;
/* needed to fix bug #563 */
extern int in_stringwithopt;
void starttag (char *s, int newline);
int closetag ();

typedef struct tag_s {
  char *tagname;
  struct tag_s *previous;
  int newline;
} tag_t;

tag_t *tagstack = NULL;

extern FILE *yyout;
%}


%union { char *string; }

%token tVAR tMSVAR tGLOBREF tUSE tCOLOR tMS tINVARIANT tCHANNEL
%token tERROR tDOTDOT 
%token tWITH tDECLARE tTIMED tUNIT tINT tBOOL
%token tREAL tSTRING tINDEX tPRODUCT tRECORD tLIST
%token tUNION tSUBSET tAND tBY tHACK

%token <string> tMLSEMI tMLDOTDOT tMLDECL tMLCOL tID 

%%
declarations   : /* empty */
                 { }
               | nedeclarations
;

nedeclarations : declaration nedeclarations
                 { }
               | declaration
                 { }
;

declaration : tVAR { starttag("var", 1); yybegin(12); } idlist ':' { starttag("type", 1); } id { closetag(); } msvarhack ';' { yybegin(0); }
              { closetag(); } 
            | tMSVAR { starttag("msvar", 1); yybegin(12); } idlist ':' { starttag("type", 1); } id { closetag(); } ';' { yybegin(0); }
              { closetag(); } 
            | tGLOBREF { starttag("globref", 1); yybegin(12); } id '=' mlsemi { yybegin(0); }
              { closetag(); }
            | tUSE { starttag("use", 1); yybegin(12); } mlsemi { yybegin(0); }
              { closetag(); }
            | tCOLOR { starttag("color", 1); yybegin(12); } id '=' csspec declaretimedopt ';' { yybegin(0); }
              { closetag(); }
            | tINVARIANT { starttag("invariant", 1); yybegin(12); } name ':' { starttag("type", 1); } id { closetag(); } ';' { yybegin(0); }
            | tCHANNEL { starttag("channel", 1); yybegin(12); } name ':' id ';' { yybegin(0); }
              { closetag(); }
	    | mldecl
;

msvarhack: /* empty */
           { }
         | tMS 
           { starttag("msvarhack", 1); closetag(); }
;

idlist : id ',' idlist
         { }
       | id
         { }
;

mlsemi : { resetBuffer(); yybegin(1); } tMLSEMI
         { starttag("ml", 0);
           escape($2);
           closetag(); }
;

mldotdot : { resetBuffer(); yybegin(4); } tMLDOTDOT
           { starttag("ml", 0);
             escape($2);
             closetag(); }
;

mlcol : { resetBuffer(); yybegin(8); } tMLCOL
        { starttag("ml", 0);
          escape($2);
          closetag(); }
;

mldecl : tMLDECL
         { starttag("ml", 0);
           escape($1);
           closetag(); }
;

id : { yybegin(7); } tID
     { starttag("id", 0); fprintf(yyout, $2); closetag(); }
;

name : { yybegin(7); } tID
     { starttag("name", 0); fprintf(yyout, $2); closetag(); }
;

csspec : tUNIT { starttag("unit", 1); } withunitopt
         { closetag(); } 
       | tBOOL { starttag("bool", 1); } withboolopt
         { closetag(); }
       | tINT { starttag("int", 1); } withintopt
         { closetag(); } 
       | tREAL { starttag("real", 1); } withrealopt
         { closetag(); }
       | tSTRING { starttag("string", 1); } withstringopt
         { closetag(); }
       | tWITH { starttag("enum", 1); } enumidlist
         { closetag(); }
       | tINDEX { starttag("index", 1); } id tWITH mldotdot mlcol
         { closetag(); }
       | tPRODUCT { starttag("product", 1); } prodcslist
         { closetag(); }
       | tRECORD { starttag("record", 1); } recfieldlist
         { closetag(); }
       | tLIST { starttag("list", 1); } id withlistopt
         { closetag(); }
       | tUNION { starttag("union", 1); } unionfieldlist
         { closetag(); }
       | tSUBSET { starttag("subset", 1); } id subsetspec
         { closetag(); }
       | { starttag("alias", 1); } tHACK id
         { closetag(); }
;

withunitopt : /* empty */
              { }
            | tWITH { starttag("with", 1); } id
              { closetag(); } 
;

withboolopt : /* empty */
              { } 
            | tWITH { starttag("with", 1); } '(' id ',' id ')'
              { closetag(); } 
;

withintopt : /* empty */
             { }
           | tWITH { starttag("with", 1); } mldotdot mlcol
             { closetag(); } 
;

withrealopt : /* empty */
              { }
            | tWITH { starttag("with", 1); } mldotdot mlcol
              { closetag(); }
;

withstringopt : /* empty */
                { }
              | tWITH { starttag("with", 1); } mldotdot 
                /* in the string case there is an extra keyword: and 
		 * See bug #563 for details. */
                { in_stringwithopt = 1; } mlcol { in_stringwithopt = 0; }
                withstringlenopt
                { closetag(); }
;

withstringlenopt : /* empty */
                   { }
                 | tAND { starttag("and", 1); } mldotdot mlcol
                   { closetag(); }
;

enumidlist : enumidlist '|' id
             { }
           | id
             { }
;

prodcslist : prodcslist '*' id
             { }
           | id
             { }
;

recfieldlist : recfieldlist '*' recfield
               { }
             | recfield
               { }
;

recfield : { starttag("recordfield", 1); } id ':' id
           { closetag(); }
;

withlistopt : /* empty */
              { }
            | tWITH { starttag("with", 1); } mldotdot mlcol
              { closetag(); }
;

unionfieldlist : unionfieldlist '+' { starttag("unionfield", 1); } unionfield
                 { closetag(); }
               | { starttag("unionfield", 1); } unionfield
                 { closetag(); }
;

unionfield : id 
             { }
           | id ':' { starttag("type", 1); } id
             { closetag(); }
;

subsetspec : tBY { starttag("by", 1); } mlcol
             { closetag(); }
           | tWITH { starttag("with", 1); } mlcol
             { closetag(); }
;

declaretimedopt : /* empty */
           | declare
		   | timed
		   | timed declare
		   | declare timed
;

declare : tDECLARE { starttag("declare", 1); } idlist
	     { closetag(); }
;

timed : tTIMED
        { starttag("timed", 0); closetag(); }
;

%%
int
escape (char *s)
{
  if (s) {
    while (*s) {
      switch (*s) {
        case '&':
          fprintf(yyout, "&amp;");
          break;
        case '<':
          fprintf(yyout, "&lt;");
          break;
        case '>':
          fprintf(yyout, "&gt;");
          break;
        case '\'':
          fprintf(yyout, "&apos;");
          break;
        case '\"':
          fprintf(yyout, "&quot;");
          break;
        default: 
          fprintf(yyout, "%c", *s);
          break;
      }
      s++;
    }
  }
  else {
	yyerror("no string found");
  }	
  return 0;
}	

void
indent_fill ()
{
  int i;
  for (i = 0; i < indent; i++)
    fprintf(yyout, "  ");
}

void
starttag (char *s, int newline)
{
  tag_t *t = malloc(sizeof(tag_t));
  t->tagname = s;
  t->previous = tagstack;
  t->newline = newline;
  tagstack = t;
  indent_fill();
  fprintf(yyout, "<%s linenumber=\"%d\">%s", s, lineno, newline ? "\n" : "");
  indent++;
}

int
closetag ()
{
  tag_t *t = tagstack;
  if (tagstack == NULL) return 0;
  indent--;
  if (tagstack->newline) indent_fill();
  fprintf(yyout, "</%s>\n", tagstack->tagname);
  tagstack = tagstack->previous;
  free(t);
  return 1;
}

