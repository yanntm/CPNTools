/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     tVAR = 258,
     tMSVAR = 259,
     tGLOBREF = 260,
     tUSE = 261,
     tCOLOR = 262,
     tMS = 263,
     tINVARIANT = 264,
     tCHANNEL = 265,
     tERROR = 266,
     tDOTDOT = 267,
     tWITH = 268,
     tDECLARE = 269,
     tTIMED = 270,
     tUNIT = 271,
     tINT = 272,
     tBOOL = 273,
     tTIME = 274,
     tINTINF = 275,
     tREAL = 276,
     tSTRING = 277,
     tINDEX = 278,
     tPRODUCT = 279,
     tRECORD = 280,
     tLIST = 281,
     tUNION = 282,
     tSUBSET = 283,
     tAND = 284,
     tBY = 285,
     tHACK = 286,
     tMLSEMI = 287,
     tMLDOTDOT = 288,
     tMLDECL = 289,
     tMLCOL = 290,
     tID = 291
   };
#endif
/* Tokens.  */
#define tVAR 258
#define tMSVAR 259
#define tGLOBREF 260
#define tUSE 261
#define tCOLOR 262
#define tMS 263
#define tINVARIANT 264
#define tCHANNEL 265
#define tERROR 266
#define tDOTDOT 267
#define tWITH 268
#define tDECLARE 269
#define tTIMED 270
#define tUNIT 271
#define tINT 272
#define tBOOL 273
#define tTIME 274
#define tINTINF 275
#define tREAL 276
#define tSTRING 277
#define tINDEX 278
#define tPRODUCT 279
#define tRECORD 280
#define tLIST 281
#define tUNION 282
#define tSUBSET 283
#define tAND 284
#define tBY 285
#define tHACK 286
#define tMLSEMI 287
#define tMLDOTDOT 288
#define tMLDECL 289
#define tMLCOL 290
#define tID 291




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 56 "mlparse.y"
{ char *string; }
/* Line 1529 of yacc.c.  */
#line 123 "mlparse.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

