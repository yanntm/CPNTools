package org.cpntools.grader.model.btl.parser;

import java_cup.runtime.*;
import static org.cpntools.grader.model.btl.parser.ParserSym.*;
import java.io.IOException;

%%

%class Scanner
%cup
%unicode
%line
%column
%public

%{

	private Symbol symbol(int type) {
		return new Symbol(type, yyline, yycolumn);
	}

	private Symbol symbol(int type, Object value) {
		return new Symbol(type, yyline, yycolumn, value);
	}
%}

LineTerminator			= \r|\n|\r\n
InputCharacter			= [^\r\n]
WhiteSpace				= {LineTerminator} | [ \t\f]

/* comments */
Comment					= {TraditionalComment}
						| {EndOfLineComment}
						| {DocumentationComment}

TraditionalComment		= "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment		= "//" {InputCharacter}* {LineTerminator}
DocumentationComment	= "/**" {CommentContent} "*"+ "/"
CommentContent          = ( [^*] | \*+ [^/*] )*

%%

<YYINITIAL>{
	"<"[a-zA-Z_][a-zA-Z0-9_]*">"	{ String result = yytext(); return symbol(VAR, result.substring(1, result.length() - 1)); }
 	"("					{ return symbol(LPAREN); }
	")"					{ return symbol(RPAREN); }
	"{"					{ return symbol(LPAREN2); }
	"}"					{ return symbol(RPAREN2); }
	"["					{ return symbol(LPAREN3); }
	"]"					{ return symbol(RPAREN3); }
	"||"					{ return symbol(BAR); }
	"|"					{ return symbol(BAR); }
	"->"					{ return symbol(NEXT); }
	"=>"					{ return symbol(GUARD); }
	"-->"					{ return symbol(STEP); }
	"==>"					{ return symbol(GUARDSTEP); }
	"--->"				{ return symbol(FINALLY); }
	"===>"				{ return symbol(FINALLYGUARD); }
	"!"					{ return symbol(NOT); }
	"*"					{ return symbol(STAR); }
	"+"					{ return symbol(PLUS); }
	"-"					{ return symbol(MINUS); }
	"&&"					{ return symbol(AND); }
	"&"					{ return symbol(AND); }
	"@"					{ return symbol(ALWAYS); }
	"<"					{ return symbol(LESS); }
	">"					{ return symbol(GREATER); }
	"<="					{ return symbol(LEQ); }
	">="					{ return symbol(GEQ); }
	":="					{ return symbol(ASSIGN); }
	"+="					{ return symbol(ADD); }
	"="					{ return symbol(EQUAL); }
	"=="					{ return symbol(EQUAL); }
	"true"				{ return symbol(TRUE); }
	"false"				{ return symbol(FALSE); }
	"failure"				{ return symbol(FAILURE); }
	"new"					{ return symbol(NEW); }
	"bind"				{ return symbol(BIND); }
	"time"				{ return symbol(TIME); }
	","					{ return symbol(COMMA); }
	[1-9][0-9]*|0			{ return symbol(NUMBER, Integer.valueOf(yytext())); }
	[\"][^\"]*(\\[\"][^\"]*)*[\"]	{ String result = yytext(); return symbol(ID, result.substring(1, result.length() - 1).replaceAll("\\\\\"", "\"")); } 
	[a-zA-Z_][a-zA-Z0-9_]*		{ return symbol(ID, yytext()); }
	"."					{ return symbol(DOT); }

	/* comments */
	{Comment}				{ /* ignore */ }
	/* whitespace */
	{WhiteSpace}			{ /* ignore */ }
}

/* error fallback */
.|\n					{ throw new IOException("Illegal character <" + yytext() + "> at line " + yyline + ", position " + yycolumn); }