/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



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




/* Copy the first part of user declarations.  */
#line 26 "mlparse.y"

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


/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 56 "mlparse.y"
{ char *string; }
/* Line 193 of yacc.c.  */
#line 199 "mlparse.tab.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 212 "mlparse.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  20
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   165

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  46
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  85
/* YYNRULES -- Number of rules.  */
#define YYNRULES  127
/* YYNRULES -- Number of states.  */
#define YYNSTATES  192

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   291

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      41,    42,    44,    45,    40,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    37,    38,
       2,    39,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,    43,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     4,     6,     9,    11,    12,    13,    14,
      15,    26,    27,    28,    29,    30,    40,    41,    42,    49,
      50,    51,    56,    57,    58,    67,    68,    69,    70,    79,
      80,    81,    89,    91,    92,    94,    98,   100,   101,   104,
     105,   108,   109,   112,   114,   115,   118,   119,   122,   123,
     127,   128,   132,   133,   137,   138,   142,   143,   146,   147,
     151,   152,   156,   157,   161,   162,   169,   170,   174,   175,
     179,   180,   185,   186,   190,   191,   196,   197,   201,   202,
     203,   207,   208,   209,   217,   218,   219,   224,   225,   226,
     231,   232,   233,   234,   235,   243,   244,   245,   250,   254,
     256,   260,   262,   266,   268,   269,   274,   275,   276,   281,
     282,   287,   288,   291,   293,   294,   299,   300,   304,   305,
     309,   310,   312,   314,   317,   320,   321,   325
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
      47,     0,    -1,    -1,    48,    -1,    49,    48,    -1,    49,
      -1,    -1,    -1,    -1,    -1,     3,    50,    70,    37,    51,
      78,    52,    69,    38,    53,    -1,    -1,    -1,    -1,    -1,
       4,    54,    70,    37,    55,    78,    56,    38,    57,    -1,
      -1,    -1,     5,    58,    78,    39,    71,    59,    -1,    -1,
      -1,     6,    60,    71,    61,    -1,    -1,    -1,     7,    62,
      78,    39,    82,   127,    38,    63,    -1,    -1,    -1,    -1,
       9,    64,    80,    37,    65,    78,    66,    38,    -1,    -1,
      -1,    10,    67,    80,    37,    78,    38,    68,    -1,    77,
      -1,    -1,     8,    -1,    78,    40,    70,    -1,    78,    -1,
      -1,    72,    32,    -1,    -1,    74,    33,    -1,    -1,    76,
      35,    -1,    34,    -1,    -1,    79,    36,    -1,    -1,    81,
      36,    -1,    -1,    16,    83,    98,    -1,    -1,    18,    84,
     100,    -1,    -1,    17,    85,   102,    -1,    -1,    20,    86,
     102,    -1,    -1,    19,    87,    -1,    -1,    21,    88,   104,
      -1,    -1,    22,    89,   106,    -1,    -1,    13,    90,   112,
      -1,    -1,    23,    91,    78,    13,    73,    75,    -1,    -1,
      24,    92,   113,    -1,    -1,    25,    93,   114,    -1,    -1,
      26,    94,    78,   117,    -1,    -1,    27,    95,   119,    -1,
      -1,    28,    96,    78,   124,    -1,    -1,    97,    31,    78,
      -1,    -1,    -1,    13,    99,    78,    -1,    -1,    -1,    13,
     101,    41,    78,    40,    78,    42,    -1,    -1,    -1,    13,
     103,    73,    75,    -1,    -1,    -1,    13,   105,    73,    75,
      -1,    -1,    -1,    -1,    -1,    13,   107,    73,   108,    75,
     109,   110,    -1,    -1,    -1,    29,   111,    73,    75,    -1,
     112,    43,    78,    -1,    78,    -1,   113,    44,    78,    -1,
      78,    -1,   114,    44,   115,    -1,   115,    -1,    -1,   116,
      78,    37,    78,    -1,    -1,    -1,    13,   118,    73,    75,
      -1,    -1,   119,    45,   120,   122,    -1,    -1,   121,   122,
      -1,    78,    -1,    -1,    78,    37,   123,    78,    -1,    -1,
      30,   125,    75,    -1,    -1,    13,   126,    75,    -1,    -1,
     128,    -1,   130,    -1,   130,   128,    -1,   128,   130,    -1,
      -1,    14,   129,    70,    -1,    15,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,    68,    68,    69,    72,    74,    78,    78,    78,    78,
      78,    80,    80,    80,    80,    80,    82,    82,    82,    84,
      84,    84,    86,    86,    86,    88,    88,    88,    88,    89,
      89,    89,    91,    95,    96,   100,   102,   106,   106,   112,
     112,   118,   118,   124,   130,   130,   134,   134,   138,   138,
     140,   140,   142,   142,   144,   144,   146,   146,   148,   148,
     150,   150,   152,   152,   154,   154,   156,   156,   158,   158,
     160,   160,   162,   162,   164,   164,   166,   166,   171,   172,
     172,   177,   178,   178,   183,   184,   184,   189,   190,   190,
     195,   196,   199,   199,   196,   205,   206,   206,   210,   212,
     216,   218,   222,   224,   228,   228,   233,   234,   234,   238,
     238,   240,   240,   244,   246,   246,   250,   250,   252,   252,
     256,   257,   258,   259,   260,   263,   263,   267
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "tVAR", "tMSVAR", "tGLOBREF", "tUSE",
  "tCOLOR", "tMS", "tINVARIANT", "tCHANNEL", "tERROR", "tDOTDOT", "tWITH",
  "tDECLARE", "tTIMED", "tUNIT", "tINT", "tBOOL", "tTIME", "tINTINF",
  "tREAL", "tSTRING", "tINDEX", "tPRODUCT", "tRECORD", "tLIST", "tUNION",
  "tSUBSET", "tAND", "tBY", "tHACK", "tMLSEMI", "tMLDOTDOT", "tMLDECL",
  "tMLCOL", "tID", "':'", "';'", "'='", "','", "'('", "')'", "'|'", "'*'",
  "'+'", "$accept", "declarations", "nedeclarations", "declaration", "@1",
  "@2", "@3", "@4", "@5", "@6", "@7", "@8", "@9", "@10", "@11", "@12",
  "@13", "@14", "@15", "@16", "@17", "@18", "@19", "msvarhack", "idlist",
  "mlsemi", "@20", "mldotdot", "@21", "mlcol", "@22", "mldecl", "id",
  "@23", "name", "@24", "csspec", "@25", "@26", "@27", "@28", "@29", "@30",
  "@31", "@32", "@33", "@34", "@35", "@36", "@37", "@38", "@39",
  "withunitopt", "@40", "withboolopt", "@41", "withintopt", "@42",
  "withrealopt", "@43", "withstringopt", "@44", "@45", "@46",
  "withstringlenopt", "@47", "enumidlist", "prodcslist", "recfieldlist",
  "recfield", "@48", "withlistopt", "@49", "unionfieldlist", "@50", "@51",
  "unionfield", "@52", "subsetspec", "@53", "@54", "declaretimedopt",
  "declare", "@55", "timed", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,    58,    59,    61,
      44,    40,    41,   124,    42,    43
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    46,    47,    47,    48,    48,    50,    51,    52,    53,
      49,    54,    55,    56,    57,    49,    58,    59,    49,    60,
      61,    49,    62,    63,    49,    64,    65,    66,    49,    67,
      68,    49,    49,    69,    69,    70,    70,    72,    71,    74,
      73,    76,    75,    77,    79,    78,    81,    80,    83,    82,
      84,    82,    85,    82,    86,    82,    87,    82,    88,    82,
      89,    82,    90,    82,    91,    82,    92,    82,    93,    82,
      94,    82,    95,    82,    96,    82,    97,    82,    98,    99,
      98,   100,   101,   100,   102,   103,   102,   104,   105,   104,
     106,   107,   108,   109,   106,   110,   111,   110,   112,   112,
     113,   113,   114,   114,   116,   115,   117,   118,   117,   120,
     119,   121,   119,   122,   123,   122,   125,   124,   126,   124,
     127,   127,   127,   127,   127,   129,   128,   130
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     1,     2,     1,     0,     0,     0,     0,
      10,     0,     0,     0,     0,     9,     0,     0,     6,     0,
       0,     4,     0,     0,     8,     0,     0,     0,     8,     0,
       0,     7,     1,     0,     1,     3,     1,     0,     2,     0,
       2,     0,     2,     1,     0,     2,     0,     2,     0,     3,
       0,     3,     0,     3,     0,     3,     0,     2,     0,     3,
       0,     3,     0,     3,     0,     6,     0,     3,     0,     3,
       0,     4,     0,     3,     0,     4,     0,     3,     0,     0,
       3,     0,     0,     7,     0,     0,     4,     0,     0,     4,
       0,     0,     0,     0,     7,     0,     0,     4,     3,     1,
       3,     1,     3,     1,     0,     4,     0,     0,     4,     0,
       4,     0,     2,     1,     0,     4,     0,     3,     0,     3,
       0,     1,     1,     2,     2,     0,     3,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     6,    11,    16,    19,    22,    25,    29,    43,     0,
       3,     5,    32,    44,    44,    44,    37,    44,    46,    46,
       1,     4,     0,    36,     0,     0,     0,    20,     0,     0,
       0,     0,     0,     7,    44,    45,    12,    37,    21,    38,
      76,    26,    47,    44,    44,    35,    44,    17,    62,    48,
      52,    50,    56,    54,    58,    60,    64,    66,    68,    70,
      72,    74,   120,     0,    44,     0,     8,    13,    18,    44,
      78,    84,    81,    57,    84,    87,    90,    44,    44,   104,
      44,   111,    44,   125,   127,     0,   121,   122,    44,    27,
      30,    33,     0,    99,    63,    79,    49,    85,    53,    82,
      51,    55,    88,    59,    91,    61,     0,   101,    67,    69,
     103,    44,   106,    73,    44,     0,    44,    23,   124,   123,
      77,     0,    31,    34,     0,    14,    44,    44,    39,     0,
      39,    39,    39,    44,   104,     0,   107,    71,   109,   113,
     112,   118,   116,    75,   126,    24,    28,     9,    15,    98,
      80,    41,     0,    44,    41,    92,    41,   100,   102,    44,
      39,    44,   114,    41,    41,    10,    86,     0,    40,     0,
      89,    41,    65,   105,    41,   110,    44,   119,   117,    42,
      44,    93,   108,   115,     0,    95,    83,    96,    94,    39,
      41,    97
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     9,    10,    11,    13,    44,    91,   165,    14,    46,
      92,   148,    15,    68,    16,    38,    17,   145,    18,    64,
     121,    19,   122,   124,    22,    27,    28,   151,   152,   166,
     167,    12,    23,    24,    30,    31,    62,    70,    72,    71,
      74,    73,    75,    76,    69,    77,    78,    79,    80,    81,
      82,    63,    96,   127,   100,   129,    98,   128,   103,   130,
     105,   131,   171,   185,   188,   189,    94,   108,   109,   110,
     111,   137,   160,   113,   161,   114,   140,   176,   143,   164,
     163,    85,    86,   116,    87
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -145
static const yytype_int16 yypact[] =
{
      34,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,     9,
    -145,    34,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,   -26,   -27,   -22,   -21,   -24,  -145,   -14,   -17,
     -20,   -12,    -4,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
      58,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,   -11,    -8,  -145,    -6,  -145,  -145,  -145,  -145,
      13,    21,    23,  -145,    21,    29,    32,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,    10,    35,    33,  -145,  -145,
    -145,    43,    14,  -145,    12,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,    40,  -145,    15,    16,
    -145,  -145,    44,    11,  -145,    -5,  -145,  -145,  -145,  -145,
    -145,    20,  -145,  -145,    28,  -145,  -145,  -145,  -145,    31,
    -145,  -145,  -145,  -145,  -145,    24,  -145,  -145,  -145,    50,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,    36,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,    53,  -145,    30,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,    47,    61,  -145,  -145,  -145,  -145,
    -145,  -145
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -145,  -145,    80,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,   -13,    55,  -145,  -125,  -145,  -144,
    -145,  -145,   -15,  -145,    74,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,    26,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,   -40,
    -145,  -145,  -145,  -145,  -145,  -145,   -66,  -145,  -145,  -145,
    -145,  -145,    17,  -145,    19
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      26,    25,    29,    83,    84,   154,   155,   156,   141,    20,
     170,    33,   172,    34,    35,    37,    36,    41,    39,   177,
     178,    45,    40,    88,    42,   142,    95,   181,    65,    66,
     182,    67,    90,    43,    97,   174,    99,     1,     2,     3,
       4,     5,   102,     6,     7,   104,   191,    83,   117,    89,
      84,   123,   125,   132,    93,   126,   138,   136,   146,   133,
     134,   159,   106,   107,   190,   112,   147,   115,     8,   168,
     180,    48,   153,   120,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,   162,   179,   186,
     187,    21,    47,    32,   158,   175,   135,     0,     0,   139,
     101,     0,     0,   144,   119,   118,     0,     0,     0,     0,
       0,   149,   150,     0,     0,     0,     0,     0,   157,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   169,     0,
       0,     0,     0,     0,   173,     0,   139,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   183,     0,     0,     0,   184
};

static const yytype_int16 yycheck[] =
{
      15,    14,    17,    14,    15,   130,   131,   132,    13,     0,
     154,    37,   156,    40,    36,    39,    37,    37,    32,   163,
     164,    34,    39,    31,    36,    30,    13,   171,    43,    44,
     174,    46,    38,    37,    13,   160,    13,     3,     4,     5,
       6,     7,    13,     9,    10,    13,   190,    14,    38,    64,
      15,     8,    38,    13,    69,    43,    45,    13,    38,    44,
      44,    37,    77,    78,   189,    80,    38,    82,    34,    33,
      40,    13,    41,    88,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    37,    35,    42,
      29,    11,    37,    19,   134,   161,   111,    -1,    -1,   114,
      74,    -1,    -1,   116,    87,    86,    -1,    -1,    -1,    -1,
      -1,   126,   127,    -1,    -1,    -1,    -1,    -1,   133,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   153,    -1,
      -1,    -1,    -1,    -1,   159,    -1,   161,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   176,    -1,    -1,    -1,   180
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     3,     4,     5,     6,     7,     9,    10,    34,    47,
      48,    49,    77,    50,    54,    58,    60,    62,    64,    67,
       0,    48,    70,    78,    79,    70,    78,    71,    72,    78,
      80,    81,    80,    37,    40,    36,    37,    39,    61,    32,
      39,    37,    36,    37,    51,    70,    55,    71,    13,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    82,    97,    65,    78,    78,    78,    59,    90,
      83,    85,    84,    87,    86,    88,    89,    91,    92,    93,
      94,    95,    96,    14,    15,   127,   128,   130,    31,    78,
      38,    52,    56,    78,   112,    13,    98,    13,   102,    13,
     100,   102,    13,   104,    13,   106,    78,    78,   113,   114,
     115,   116,    78,   119,   121,    78,   129,    38,   130,   128,
      78,    66,    68,     8,    69,    38,    43,    99,   103,   101,
     105,   107,    13,    44,    44,    78,    13,   117,    45,    78,
     122,    13,    30,   124,    70,    63,    38,    38,    57,    78,
      78,    73,    74,    41,    73,    73,    73,    78,   115,    37,
     118,   120,    37,   126,   125,    53,    75,    76,    33,    78,
      75,   108,    75,    78,    73,   122,   123,    75,    75,    35,
      40,    75,    75,    78,    78,   109,    42,    29,   110,   111,
      73,    75
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 68 "mlparse.y"
    { ;}
    break;

  case 4:
#line 73 "mlparse.y"
    { ;}
    break;

  case 5:
#line 75 "mlparse.y"
    { ;}
    break;

  case 6:
#line 78 "mlparse.y"
    { starttag("var", 1); yybegin(12); ;}
    break;

  case 7:
#line 78 "mlparse.y"
    { starttag("type", 1); ;}
    break;

  case 8:
#line 78 "mlparse.y"
    { closetag(); ;}
    break;

  case 9:
#line 78 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 10:
#line 79 "mlparse.y"
    { closetag(); ;}
    break;

  case 11:
#line 80 "mlparse.y"
    { starttag("msvar", 1); yybegin(12); ;}
    break;

  case 12:
#line 80 "mlparse.y"
    { starttag("type", 1); ;}
    break;

  case 13:
#line 80 "mlparse.y"
    { closetag(); ;}
    break;

  case 14:
#line 80 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 15:
#line 81 "mlparse.y"
    { closetag(); ;}
    break;

  case 16:
#line 82 "mlparse.y"
    { starttag("globref", 1); yybegin(12); ;}
    break;

  case 17:
#line 82 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 18:
#line 83 "mlparse.y"
    { closetag(); ;}
    break;

  case 19:
#line 84 "mlparse.y"
    { starttag("use", 1); yybegin(12); ;}
    break;

  case 20:
#line 84 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 21:
#line 85 "mlparse.y"
    { closetag(); ;}
    break;

  case 22:
#line 86 "mlparse.y"
    { starttag("color", 1); yybegin(12); ;}
    break;

  case 23:
#line 86 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 24:
#line 87 "mlparse.y"
    { closetag(); ;}
    break;

  case 25:
#line 88 "mlparse.y"
    { starttag("invariant", 1); yybegin(12); ;}
    break;

  case 26:
#line 88 "mlparse.y"
    { starttag("type", 1); ;}
    break;

  case 27:
#line 88 "mlparse.y"
    { closetag(); ;}
    break;

  case 28:
#line 88 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 29:
#line 89 "mlparse.y"
    { starttag("channel", 1); yybegin(12); ;}
    break;

  case 30:
#line 89 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 31:
#line 90 "mlparse.y"
    { closetag(); ;}
    break;

  case 33:
#line 95 "mlparse.y"
    { ;}
    break;

  case 34:
#line 97 "mlparse.y"
    { starttag("msvarhack", 1); closetag(); ;}
    break;

  case 35:
#line 101 "mlparse.y"
    { ;}
    break;

  case 36:
#line 103 "mlparse.y"
    { ;}
    break;

  case 37:
#line 106 "mlparse.y"
    { resetBuffer(); yybegin(1); ;}
    break;

  case 38:
#line 107 "mlparse.y"
    { starttag("ml", 0);
           escape((yyvsp[(2) - (2)].string));
           closetag(); ;}
    break;

  case 39:
#line 112 "mlparse.y"
    { resetBuffer(); yybegin(4); ;}
    break;

  case 40:
#line 113 "mlparse.y"
    { starttag("ml", 0);
             escape((yyvsp[(2) - (2)].string));
             closetag(); ;}
    break;

  case 41:
#line 118 "mlparse.y"
    { resetBuffer(); yybegin(8); ;}
    break;

  case 42:
#line 119 "mlparse.y"
    { starttag("ml", 0);
          escape((yyvsp[(2) - (2)].string));
          closetag(); ;}
    break;

  case 43:
#line 125 "mlparse.y"
    { starttag("ml", 0);
           escape((yyvsp[(1) - (1)].string));
           closetag(); ;}
    break;

  case 44:
#line 130 "mlparse.y"
    { yybegin(7); ;}
    break;

  case 45:
#line 131 "mlparse.y"
    { starttag("id", 0); fprintf(yyout, (yyvsp[(2) - (2)].string)); closetag(); ;}
    break;

  case 46:
#line 134 "mlparse.y"
    { yybegin(7); ;}
    break;

  case 47:
#line 135 "mlparse.y"
    { starttag("name", 0); fprintf(yyout, (yyvsp[(2) - (2)].string)); closetag(); ;}
    break;

  case 48:
#line 138 "mlparse.y"
    { starttag("unit", 1); ;}
    break;

  case 49:
#line 139 "mlparse.y"
    { closetag(); ;}
    break;

  case 50:
#line 140 "mlparse.y"
    { starttag("bool", 1); ;}
    break;

  case 51:
#line 141 "mlparse.y"
    { closetag(); ;}
    break;

  case 52:
#line 142 "mlparse.y"
    { starttag("int", 1); ;}
    break;

  case 53:
#line 143 "mlparse.y"
    { closetag(); ;}
    break;

  case 54:
#line 144 "mlparse.y"
    { starttag("intinf", 1); ;}
    break;

  case 55:
#line 145 "mlparse.y"
    { closetag(); ;}
    break;

  case 56:
#line 146 "mlparse.y"
    { starttag("time", 1); ;}
    break;

  case 57:
#line 147 "mlparse.y"
    { closetag(); ;}
    break;

  case 58:
#line 148 "mlparse.y"
    { starttag("real", 1); ;}
    break;

  case 59:
#line 149 "mlparse.y"
    { closetag(); ;}
    break;

  case 60:
#line 150 "mlparse.y"
    { starttag("string", 1); ;}
    break;

  case 61:
#line 151 "mlparse.y"
    { closetag(); ;}
    break;

  case 62:
#line 152 "mlparse.y"
    { starttag("enum", 1); ;}
    break;

  case 63:
#line 153 "mlparse.y"
    { closetag(); ;}
    break;

  case 64:
#line 154 "mlparse.y"
    { starttag("index", 1); ;}
    break;

  case 65:
#line 155 "mlparse.y"
    { closetag(); ;}
    break;

  case 66:
#line 156 "mlparse.y"
    { starttag("product", 1); ;}
    break;

  case 67:
#line 157 "mlparse.y"
    { closetag(); ;}
    break;

  case 68:
#line 158 "mlparse.y"
    { starttag("record", 1); ;}
    break;

  case 69:
#line 159 "mlparse.y"
    { closetag(); ;}
    break;

  case 70:
#line 160 "mlparse.y"
    { starttag("list", 1); ;}
    break;

  case 71:
#line 161 "mlparse.y"
    { closetag(); ;}
    break;

  case 72:
#line 162 "mlparse.y"
    { starttag("union", 1); ;}
    break;

  case 73:
#line 163 "mlparse.y"
    { closetag(); ;}
    break;

  case 74:
#line 164 "mlparse.y"
    { starttag("subset", 1); ;}
    break;

  case 75:
#line 165 "mlparse.y"
    { closetag(); ;}
    break;

  case 76:
#line 166 "mlparse.y"
    { starttag("alias", 1); ;}
    break;

  case 77:
#line 167 "mlparse.y"
    { closetag(); ;}
    break;

  case 78:
#line 171 "mlparse.y"
    { ;}
    break;

  case 79:
#line 172 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 80:
#line 173 "mlparse.y"
    { closetag(); ;}
    break;

  case 81:
#line 177 "mlparse.y"
    { ;}
    break;

  case 82:
#line 178 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 83:
#line 179 "mlparse.y"
    { closetag(); ;}
    break;

  case 84:
#line 183 "mlparse.y"
    { ;}
    break;

  case 85:
#line 184 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 86:
#line 185 "mlparse.y"
    { closetag(); ;}
    break;

  case 87:
#line 189 "mlparse.y"
    { ;}
    break;

  case 88:
#line 190 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 89:
#line 191 "mlparse.y"
    { closetag(); ;}
    break;

  case 90:
#line 195 "mlparse.y"
    { ;}
    break;

  case 91:
#line 196 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 92:
#line 199 "mlparse.y"
    { in_stringwithopt = 1; ;}
    break;

  case 93:
#line 199 "mlparse.y"
    { in_stringwithopt = 0; ;}
    break;

  case 94:
#line 201 "mlparse.y"
    { closetag(); ;}
    break;

  case 95:
#line 205 "mlparse.y"
    { ;}
    break;

  case 96:
#line 206 "mlparse.y"
    { starttag("and", 1); ;}
    break;

  case 97:
#line 207 "mlparse.y"
    { closetag(); ;}
    break;

  case 98:
#line 211 "mlparse.y"
    { ;}
    break;

  case 99:
#line 213 "mlparse.y"
    { ;}
    break;

  case 100:
#line 217 "mlparse.y"
    { ;}
    break;

  case 101:
#line 219 "mlparse.y"
    { ;}
    break;

  case 102:
#line 223 "mlparse.y"
    { ;}
    break;

  case 103:
#line 225 "mlparse.y"
    { ;}
    break;

  case 104:
#line 228 "mlparse.y"
    { starttag("recordfield", 1); ;}
    break;

  case 105:
#line 229 "mlparse.y"
    { closetag(); ;}
    break;

  case 106:
#line 233 "mlparse.y"
    { ;}
    break;

  case 107:
#line 234 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 108:
#line 235 "mlparse.y"
    { closetag(); ;}
    break;

  case 109:
#line 238 "mlparse.y"
    { starttag("unionfield", 1); ;}
    break;

  case 110:
#line 239 "mlparse.y"
    { closetag(); ;}
    break;

  case 111:
#line 240 "mlparse.y"
    { starttag("unionfield", 1); ;}
    break;

  case 112:
#line 241 "mlparse.y"
    { closetag(); ;}
    break;

  case 113:
#line 245 "mlparse.y"
    { ;}
    break;

  case 114:
#line 246 "mlparse.y"
    { starttag("type", 1); ;}
    break;

  case 115:
#line 247 "mlparse.y"
    { closetag(); ;}
    break;

  case 116:
#line 250 "mlparse.y"
    { starttag("by", 1); ;}
    break;

  case 117:
#line 251 "mlparse.y"
    { closetag(); ;}
    break;

  case 118:
#line 252 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 119:
#line 253 "mlparse.y"
    { closetag(); ;}
    break;

  case 125:
#line 263 "mlparse.y"
    { starttag("declare", 1); ;}
    break;

  case 126:
#line 264 "mlparse.y"
    { closetag(); ;}
    break;

  case 127:
#line 268 "mlparse.y"
    { starttag("timed", 0); closetag(); ;}
    break;


/* Line 1267 of yacc.c.  */
#line 2203 "mlparse.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 271 "mlparse.y"

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


