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
#line 197 "mlparse.tab.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 210 "mlparse.tab.c"

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
#define YYFINAL  22
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   162

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  45
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  84
/* YYNRULES -- Number of rules.  */
#define YYNRULES  125
/* YYNRULES -- Number of states.  */
#define YYNSTATES  190

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   290

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      40,    41,    43,    44,    39,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    36,    37,
       2,    38,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,    42,     2,     2,     2,     2,     2,
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
      35
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     4,     6,     9,    11,    12,    13,    14,
      15,    26,    27,    28,    29,    30,    40,    41,    42,    49,
      50,    51,    56,    57,    58,    67,    68,    69,    70,    79,
      80,    81,    89,    90,    94,    96,    97,    99,   103,   105,
     106,   109,   110,   113,   114,   117,   119,   120,   123,   124,
     127,   128,   132,   133,   137,   138,   142,   143,   147,   148,
     152,   153,   157,   158,   165,   166,   170,   171,   175,   176,
     181,   182,   186,   187,   192,   193,   197,   198,   199,   203,
     204,   205,   213,   214,   215,   220,   221,   222,   227,   228,
     229,   230,   231,   239,   240,   241,   246,   250,   252,   256,
     258,   262,   264,   265,   270,   271,   272,   277,   278,   283,
     284,   287,   289,   290,   295,   296,   300,   301,   305,   306,
     308,   310,   313,   316,   317,   321
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
      46,     0,    -1,    -1,    47,    -1,    48,    47,    -1,    48,
      -1,    -1,    -1,    -1,    -1,     3,    49,    70,    36,    50,
      78,    51,    69,    37,    52,    -1,    -1,    -1,    -1,    -1,
       4,    53,    70,    36,    54,    78,    55,    37,    56,    -1,
      -1,    -1,     5,    57,    78,    38,    71,    58,    -1,    -1,
      -1,     6,    59,    71,    60,    -1,    -1,    -1,     7,    61,
      78,    38,    82,   125,    37,    62,    -1,    -1,    -1,    -1,
       9,    63,    80,    36,    64,    78,    65,    37,    -1,    -1,
      -1,    10,    66,    80,    36,    78,    37,    67,    -1,    -1,
      11,    68,    37,    -1,    77,    -1,    -1,     8,    -1,    78,
      39,    70,    -1,    78,    -1,    -1,    72,    31,    -1,    -1,
      74,    32,    -1,    -1,    76,    34,    -1,    33,    -1,    -1,
      79,    35,    -1,    -1,    81,    35,    -1,    -1,    17,    83,
      96,    -1,    -1,    19,    84,    98,    -1,    -1,    18,    85,
     100,    -1,    -1,    20,    86,   102,    -1,    -1,    21,    87,
     104,    -1,    -1,    14,    88,   110,    -1,    -1,    22,    89,
      78,    14,    73,    75,    -1,    -1,    23,    90,   111,    -1,
      -1,    24,    91,   112,    -1,    -1,    25,    92,    78,   115,
      -1,    -1,    26,    93,   117,    -1,    -1,    27,    94,    78,
     122,    -1,    -1,    95,    30,    78,    -1,    -1,    -1,    14,
      97,    78,    -1,    -1,    -1,    14,    99,    40,    78,    39,
      78,    41,    -1,    -1,    -1,    14,   101,    73,    75,    -1,
      -1,    -1,    14,   103,    73,    75,    -1,    -1,    -1,    -1,
      -1,    14,   105,    73,   106,    75,   107,   108,    -1,    -1,
      -1,    28,   109,    73,    75,    -1,   110,    42,    78,    -1,
      78,    -1,   111,    43,    78,    -1,    78,    -1,   112,    43,
     113,    -1,   113,    -1,    -1,   114,    78,    36,    78,    -1,
      -1,    -1,    14,   116,    73,    75,    -1,    -1,   117,    44,
     118,   120,    -1,    -1,   119,   120,    -1,    78,    -1,    -1,
      78,    36,   121,    78,    -1,    -1,    29,   123,    75,    -1,
      -1,    14,   124,    75,    -1,    -1,   126,    -1,   128,    -1,
     128,   126,    -1,   126,   128,    -1,    -1,    15,   127,    70,
      -1,    16,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,    68,    68,    69,    72,    74,    78,    78,    78,    78,
      78,    80,    80,    80,    80,    80,    82,    82,    82,    84,
      84,    84,    86,    86,    86,    88,    88,    88,    88,    89,
      89,    89,    91,    91,    93,    97,    98,   102,   104,   108,
     108,   114,   114,   120,   120,   126,   132,   132,   136,   136,
     140,   140,   142,   142,   144,   144,   146,   146,   148,   148,
     150,   150,   152,   152,   154,   154,   156,   156,   158,   158,
     160,   160,   162,   162,   164,   164,   169,   170,   170,   175,
     176,   176,   181,   182,   182,   187,   188,   188,   193,   194,
     197,   197,   194,   203,   204,   204,   208,   210,   214,   216,
     220,   222,   226,   226,   231,   232,   232,   236,   236,   238,
     238,   242,   244,   244,   248,   248,   250,   250,   254,   255,
     256,   257,   258,   261,   261,   265
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "tVAR", "tMSVAR", "tGLOBREF", "tUSE",
  "tCOLOR", "tMS", "tINVARIANT", "tCHANNEL", "tBRITNEY", "tERROR",
  "tDOTDOT", "tWITH", "tDECLARE", "tTIMED", "tUNIT", "tINT", "tBOOL",
  "tREAL", "tSTRING", "tINDEX", "tPRODUCT", "tRECORD", "tLIST", "tUNION",
  "tSUBSET", "tAND", "tBY", "tHACK", "tMLSEMI", "tMLDOTDOT", "tMLDECL",
  "tMLCOL", "tID", "':'", "';'", "'='", "','", "'('", "')'", "'|'", "'*'",
  "'+'", "$accept", "declarations", "nedeclarations", "declaration", "@1",
  "@2", "@3", "@4", "@5", "@6", "@7", "@8", "@9", "@10", "@11", "@12",
  "@13", "@14", "@15", "@16", "@17", "@18", "@19", "@20", "msvarhack",
  "idlist", "mlsemi", "@21", "mldotdot", "@22", "mlcol", "@23", "mldecl",
  "id", "@24", "name", "@25", "csspec", "@26", "@27", "@28", "@29", "@30",
  "@31", "@32", "@33", "@34", "@35", "@36", "@37", "@38", "withunitopt",
  "@39", "withboolopt", "@40", "withintopt", "@41", "withrealopt", "@42",
  "withstringopt", "@43", "@44", "@45", "withstringlenopt", "@46",
  "enumidlist", "prodcslist", "recfieldlist", "recfield", "@47",
  "withlistopt", "@48", "unionfieldlist", "@49", "@50", "unionfield",
  "@51", "subsetspec", "@52", "@53", "declaretimedopt", "declare", "@54",
  "timed", 0
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
     285,   286,   287,   288,   289,   290,    58,    59,    61,    44,
      40,    41,   124,    42,    43
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    45,    46,    46,    47,    47,    49,    50,    51,    52,
      48,    53,    54,    55,    56,    48,    57,    58,    48,    59,
      60,    48,    61,    62,    48,    63,    64,    65,    48,    66,
      67,    48,    68,    48,    48,    69,    69,    70,    70,    72,
      71,    74,    73,    76,    75,    77,    79,    78,    81,    80,
      83,    82,    84,    82,    85,    82,    86,    82,    87,    82,
      88,    82,    89,    82,    90,    82,    91,    82,    92,    82,
      93,    82,    94,    82,    95,    82,    96,    97,    96,    98,
      99,    98,   100,   101,   100,   102,   103,   102,   104,   105,
     106,   107,   104,   108,   109,   108,   110,   110,   111,   111,
     112,   112,   114,   113,   115,   116,   115,   118,   117,   119,
     117,   120,   121,   120,   123,   122,   124,   122,   125,   125,
     125,   125,   125,   127,   126,   128
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     1,     2,     1,     0,     0,     0,     0,
      10,     0,     0,     0,     0,     9,     0,     0,     6,     0,
       0,     4,     0,     0,     8,     0,     0,     0,     8,     0,
       0,     7,     0,     3,     1,     0,     1,     3,     1,     0,
       2,     0,     2,     0,     2,     1,     0,     2,     0,     2,
       0,     3,     0,     3,     0,     3,     0,     3,     0,     3,
       0,     3,     0,     6,     0,     3,     0,     3,     0,     4,
       0,     3,     0,     4,     0,     3,     0,     0,     3,     0,
       0,     7,     0,     0,     4,     0,     0,     4,     0,     0,
       0,     0,     7,     0,     0,     4,     3,     1,     3,     1,
       3,     1,     0,     4,     0,     0,     4,     0,     4,     0,
       2,     1,     0,     4,     0,     3,     0,     3,     0,     1,
       1,     2,     2,     0,     3,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     6,    11,    16,    19,    22,    25,    29,    32,    45,
       0,     3,     5,    34,    46,    46,    46,    39,    46,    48,
      48,     0,     1,     4,     0,    38,     0,     0,     0,    20,
       0,     0,     0,     0,     0,    33,     7,    46,    47,    12,
      39,    21,    40,    74,    26,    49,    46,    46,    37,    46,
      17,    60,    50,    54,    52,    56,    58,    62,    64,    66,
      68,    70,    72,   118,     0,    46,     0,     8,    13,    18,
      46,    76,    82,    79,    85,    88,    46,    46,   102,    46,
     109,    46,   123,   125,     0,   119,   120,    46,    27,    30,
      35,     0,    97,    61,    77,    51,    83,    55,    80,    53,
      86,    57,    89,    59,     0,    99,    65,    67,   101,    46,
     104,    71,    46,     0,    46,    23,   122,   121,    75,     0,
      31,    36,     0,    14,    46,    46,    41,     0,    41,    41,
      41,    46,   102,     0,   105,    69,   107,   111,   110,   116,
     114,    73,   124,    24,    28,     9,    15,    96,    78,    43,
       0,    46,    43,    90,    43,    98,   100,    46,    41,    46,
     112,    43,    43,    10,    84,     0,    42,     0,    87,    43,
      63,   103,    43,   108,    46,   117,   115,    44,    46,    91,
     106,   113,     0,    93,    81,    94,    92,    41,    43,    95
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,    10,    11,    12,    14,    47,    90,   163,    15,    49,
      91,   146,    16,    69,    17,    41,    18,   143,    19,    65,
     119,    20,   120,    21,   122,    24,    29,    30,   149,   150,
     164,   165,    13,    25,    26,    32,    33,    63,    71,    73,
      72,    74,    75,    70,    76,    77,    78,    79,    80,    81,
      64,    95,   125,    99,   127,    97,   126,   101,   128,   103,
     129,   169,   183,   186,   187,    93,   106,   107,   108,   109,
     135,   158,   111,   159,   112,   138,   174,   141,   162,   161,
      84,    85,   114,    86
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -145
static const yytype_int16 yypact[] =
{
      36,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
       3,  -145,    36,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,   -28,  -145,  -145,   -23,   -25,   -20,   -15,   -22,  -145,
     -11,   -12,    -9,   -13,    -7,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,    56,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,    -4,    -6,  -145,    -5,  -145,  -145,  -145,
    -145,    20,    22,    23,    24,    34,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,    13,    35,    37,  -145,  -145,  -145,
      45,    18,  -145,    14,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,    43,  -145,    15,    16,  -145,  -145,
      48,    28,  -145,   -10,  -145,  -145,  -145,  -145,  -145,    29,
    -145,  -145,    30,  -145,  -145,  -145,  -145,    44,  -145,  -145,
    -145,  -145,  -145,    32,  -145,  -145,  -145,    49,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
      54,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,    53,  -145,    50,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,    47,    62,  -145,  -145,  -145,  -145,  -145,  -145
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -145,  -145,    79,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,   -14,    52,  -145,  -123,  -145,
    -144,  -145,  -145,   -16,  -145,    74,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,
    -145,  -145,  -145,  -145,  -145,  -145,  -145,  -145,   -37,  -145,
    -145,  -145,  -145,  -145,  -145,   -62,  -145,  -145,  -145,  -145,
    -145,    12,  -145,    17
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      28,    27,    31,    22,   139,   152,   153,   154,   168,    35,
     170,    82,    83,    36,    37,    38,    40,   175,   176,   140,
      42,    39,    45,    48,    87,   179,    43,    44,   180,    46,
      66,    67,    89,    68,    94,   172,    96,    98,   100,     1,
       2,     3,     4,     5,   189,     6,     7,     8,   102,    88,
     115,    83,    82,   121,    92,   123,   124,   130,   131,   132,
     104,   105,   134,   110,   188,   113,   144,   145,   157,     9,
      51,   118,   136,    52,    53,    54,    55,    56,    57,    58,
      59,    60,    61,    62,   151,   160,   166,   177,   184,   178,
     185,    23,    50,   133,    34,   156,   137,   173,   117,     0,
     142,     0,   116,     0,     0,     0,     0,     0,   147,   148,
       0,     0,     0,     0,     0,   155,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   167,     0,     0,     0,     0,
       0,   171,     0,   137,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   181,     0,
       0,     0,   182
};

static const yytype_int16 yycheck[] =
{
      16,    15,    18,     0,    14,   128,   129,   130,   152,    37,
     154,    15,    16,    36,    39,    35,    38,   161,   162,    29,
      31,    36,    35,    37,    30,   169,    38,    36,   172,    36,
      46,    47,    37,    49,    14,   158,    14,    14,    14,     3,
       4,     5,     6,     7,   188,     9,    10,    11,    14,    65,
      37,    16,    15,     8,    70,    37,    42,    14,    43,    43,
      76,    77,    14,    79,   187,    81,    37,    37,    36,    33,
      14,    87,    44,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    40,    36,    32,    34,    41,    39,
      28,    12,    40,   109,    20,   132,   112,   159,    86,    -1,
     114,    -1,    85,    -1,    -1,    -1,    -1,    -1,   124,   125,
      -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   151,    -1,    -1,    -1,    -1,
      -1,   157,    -1,   159,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   174,    -1,
      -1,    -1,   178
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     3,     4,     5,     6,     7,     9,    10,    11,    33,
      46,    47,    48,    77,    49,    53,    57,    59,    61,    63,
      66,    68,     0,    47,    70,    78,    79,    70,    78,    71,
      72,    78,    80,    81,    80,    37,    36,    39,    35,    36,
      38,    60,    31,    38,    36,    35,    36,    50,    70,    54,
      71,    14,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    82,    95,    64,    78,    78,    78,    58,
      88,    83,    85,    84,    86,    87,    89,    90,    91,    92,
      93,    94,    15,    16,   125,   126,   128,    30,    78,    37,
      51,    55,    78,   110,    14,    96,    14,   100,    14,    98,
      14,   102,    14,   104,    78,    78,   111,   112,   113,   114,
      78,   117,   119,    78,   127,    37,   128,   126,    78,    65,
      67,     8,    69,    37,    42,    97,   101,    99,   103,   105,
      14,    43,    43,    78,    14,   115,    44,    78,   120,    14,
      29,   122,    70,    62,    37,    37,    56,    78,    78,    73,
      74,    40,    73,    73,    73,    78,   113,    36,   116,   118,
      36,   124,   123,    52,    75,    76,    32,    78,    75,   106,
      75,    78,    73,   120,   121,    75,    75,    34,    39,    75,
      75,    78,    78,   107,    41,    28,   108,   109,    73,    75
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

  case 32:
#line 91 "mlparse.y"
    { starttag("ml", 0); fprintf(yyout, "val answer = 42"); closetag(); ;}
    break;

  case 33:
#line 91 "mlparse.y"
    { yybegin(0); ;}
    break;

  case 35:
#line 97 "mlparse.y"
    { ;}
    break;

  case 36:
#line 99 "mlparse.y"
    { starttag("msvarhack", 1); closetag(); ;}
    break;

  case 37:
#line 103 "mlparse.y"
    { ;}
    break;

  case 38:
#line 105 "mlparse.y"
    { ;}
    break;

  case 39:
#line 108 "mlparse.y"
    { resetBuffer(); yybegin(1); ;}
    break;

  case 40:
#line 109 "mlparse.y"
    { starttag("ml", 0);
           escape((yyvsp[(2) - (2)].string));
           closetag(); ;}
    break;

  case 41:
#line 114 "mlparse.y"
    { resetBuffer(); yybegin(4); ;}
    break;

  case 42:
#line 115 "mlparse.y"
    { starttag("ml", 0);
             escape((yyvsp[(2) - (2)].string));
             closetag(); ;}
    break;

  case 43:
#line 120 "mlparse.y"
    { resetBuffer(); yybegin(8); ;}
    break;

  case 44:
#line 121 "mlparse.y"
    { starttag("ml", 0);
          escape((yyvsp[(2) - (2)].string));
          closetag(); ;}
    break;

  case 45:
#line 127 "mlparse.y"
    { starttag("ml", 0);
           escape((yyvsp[(1) - (1)].string));
           closetag(); ;}
    break;

  case 46:
#line 132 "mlparse.y"
    { yybegin(7); ;}
    break;

  case 47:
#line 133 "mlparse.y"
    { starttag("id", 0); fprintf(yyout, (yyvsp[(2) - (2)].string)); closetag(); ;}
    break;

  case 48:
#line 136 "mlparse.y"
    { yybegin(7); ;}
    break;

  case 49:
#line 137 "mlparse.y"
    { starttag("name", 0); fprintf(yyout, (yyvsp[(2) - (2)].string)); closetag(); ;}
    break;

  case 50:
#line 140 "mlparse.y"
    { starttag("unit", 1); ;}
    break;

  case 51:
#line 141 "mlparse.y"
    { closetag(); ;}
    break;

  case 52:
#line 142 "mlparse.y"
    { starttag("bool", 1); ;}
    break;

  case 53:
#line 143 "mlparse.y"
    { closetag(); ;}
    break;

  case 54:
#line 144 "mlparse.y"
    { starttag("int", 1); ;}
    break;

  case 55:
#line 145 "mlparse.y"
    { closetag(); ;}
    break;

  case 56:
#line 146 "mlparse.y"
    { starttag("real", 1); ;}
    break;

  case 57:
#line 147 "mlparse.y"
    { closetag(); ;}
    break;

  case 58:
#line 148 "mlparse.y"
    { starttag("string", 1); ;}
    break;

  case 59:
#line 149 "mlparse.y"
    { closetag(); ;}
    break;

  case 60:
#line 150 "mlparse.y"
    { starttag("enum", 1); ;}
    break;

  case 61:
#line 151 "mlparse.y"
    { closetag(); ;}
    break;

  case 62:
#line 152 "mlparse.y"
    { starttag("index", 1); ;}
    break;

  case 63:
#line 153 "mlparse.y"
    { closetag(); ;}
    break;

  case 64:
#line 154 "mlparse.y"
    { starttag("product", 1); ;}
    break;

  case 65:
#line 155 "mlparse.y"
    { closetag(); ;}
    break;

  case 66:
#line 156 "mlparse.y"
    { starttag("record", 1); ;}
    break;

  case 67:
#line 157 "mlparse.y"
    { closetag(); ;}
    break;

  case 68:
#line 158 "mlparse.y"
    { starttag("list", 1); ;}
    break;

  case 69:
#line 159 "mlparse.y"
    { closetag(); ;}
    break;

  case 70:
#line 160 "mlparse.y"
    { starttag("union", 1); ;}
    break;

  case 71:
#line 161 "mlparse.y"
    { closetag(); ;}
    break;

  case 72:
#line 162 "mlparse.y"
    { starttag("subset", 1); ;}
    break;

  case 73:
#line 163 "mlparse.y"
    { closetag(); ;}
    break;

  case 74:
#line 164 "mlparse.y"
    { starttag("alias", 1); ;}
    break;

  case 75:
#line 165 "mlparse.y"
    { closetag(); ;}
    break;

  case 76:
#line 169 "mlparse.y"
    { ;}
    break;

  case 77:
#line 170 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 78:
#line 171 "mlparse.y"
    { closetag(); ;}
    break;

  case 79:
#line 175 "mlparse.y"
    { ;}
    break;

  case 80:
#line 176 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 81:
#line 177 "mlparse.y"
    { closetag(); ;}
    break;

  case 82:
#line 181 "mlparse.y"
    { ;}
    break;

  case 83:
#line 182 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 84:
#line 183 "mlparse.y"
    { closetag(); ;}
    break;

  case 85:
#line 187 "mlparse.y"
    { ;}
    break;

  case 86:
#line 188 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 87:
#line 189 "mlparse.y"
    { closetag(); ;}
    break;

  case 88:
#line 193 "mlparse.y"
    { ;}
    break;

  case 89:
#line 194 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 90:
#line 197 "mlparse.y"
    { in_stringwithopt = 1; ;}
    break;

  case 91:
#line 197 "mlparse.y"
    { in_stringwithopt = 0; ;}
    break;

  case 92:
#line 199 "mlparse.y"
    { closetag(); ;}
    break;

  case 93:
#line 203 "mlparse.y"
    { ;}
    break;

  case 94:
#line 204 "mlparse.y"
    { starttag("and", 1); ;}
    break;

  case 95:
#line 205 "mlparse.y"
    { closetag(); ;}
    break;

  case 96:
#line 209 "mlparse.y"
    { ;}
    break;

  case 97:
#line 211 "mlparse.y"
    { ;}
    break;

  case 98:
#line 215 "mlparse.y"
    { ;}
    break;

  case 99:
#line 217 "mlparse.y"
    { ;}
    break;

  case 100:
#line 221 "mlparse.y"
    { ;}
    break;

  case 101:
#line 223 "mlparse.y"
    { ;}
    break;

  case 102:
#line 226 "mlparse.y"
    { starttag("recordfield", 1); ;}
    break;

  case 103:
#line 227 "mlparse.y"
    { closetag(); ;}
    break;

  case 104:
#line 231 "mlparse.y"
    { ;}
    break;

  case 105:
#line 232 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 106:
#line 233 "mlparse.y"
    { closetag(); ;}
    break;

  case 107:
#line 236 "mlparse.y"
    { starttag("unionfield", 1); ;}
    break;

  case 108:
#line 237 "mlparse.y"
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
#line 243 "mlparse.y"
    { ;}
    break;

  case 112:
#line 244 "mlparse.y"
    { starttag("type", 1); ;}
    break;

  case 113:
#line 245 "mlparse.y"
    { closetag(); ;}
    break;

  case 114:
#line 248 "mlparse.y"
    { starttag("by", 1); ;}
    break;

  case 115:
#line 249 "mlparse.y"
    { closetag(); ;}
    break;

  case 116:
#line 250 "mlparse.y"
    { starttag("with", 1); ;}
    break;

  case 117:
#line 251 "mlparse.y"
    { closetag(); ;}
    break;

  case 123:
#line 261 "mlparse.y"
    { starttag("declare", 1); ;}
    break;

  case 124:
#line 262 "mlparse.y"
    { closetag(); ;}
    break;

  case 125:
#line 266 "mlparse.y"
    { starttag("timed", 0); closetag(); ;}
    break;


/* Line 1267 of yacc.c.  */
#line 2188 "mlparse.tab.c"
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


#line 269 "mlparse.y"

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


