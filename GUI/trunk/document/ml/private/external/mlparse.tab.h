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
     tBRITNEY = 266,
     tERROR = 267,
     tDOTDOT = 268,
     tWITH = 269,
     tDECLARE = 270,
     tTIMED = 271,
     tUNIT = 272,
     tINT = 273,
     tBOOL = 274,
     tREAL = 275,
     tSTRING = 276,
     tINDEX = 277,
     tPRODUCT = 278,
     tRECORD = 279,
     tLIST = 280,
     tUNION = 281,
     tSUBSET = 282,
     tAND = 283,
     tBY = 284,
     tHACK = 285,
     tMLSEMI = 286,
     tMLDOTDOT = 287,
     tMLDECL = 288,
     tMLCOL = 289,
     tID = 290
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
#define tBRITNEY 266
#define tERROR 267
#define tDOTDOT 268
#define tWITH 269
#define tDECLARE 270
#define tTIMED 271
#define tUNIT 272
#define tINT 273
#define tBOOL 274
#define tREAL 275
#define tSTRING 276
#define tINDEX 277
#define tPRODUCT 278
#define tRECORD 279
#define tLIST 280
#define tUNION 281
#define tSUBSET 282
#define tAND 283
#define tBY 284
#define tHACK 285
#define tMLSEMI 286
#define tMLDOTDOT 287
#define tMLDECL 288
#define tMLCOL 289
#define tID 290




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 56 "mlparse.y"
{ char *string; }
/* Line 1529 of yacc.c.  */
#line 121 "mlparse.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

