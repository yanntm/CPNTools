package org.cpntools.algorithms.translator;

import java_cup.runtime.*;
import static org.cpntools.algorithms.translator.ParserSym.*;
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
WhiteSpace				= [ \t\f]

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
	"boolean"					{ return symbol(BOOL); }
	"Boolean"					{ return symbol(BOOL); }
	"bool"					{ return symbol(BOOL); }
	"BOOL"					{ return symbol(BOOL); }
	"Bool"					{ return symbol(BOOL); }
	"integer"					{ return symbol(INT); }
	"Integer"					{ return symbol(INT); }
	"int"						{ return symbol(INT); }
	"INT"						{ return symbol(INT); }
	"Int"						{ return symbol(INT); }
	"not"						{ return symbol(NOT); }
	"lock"					{ return symbol(LOCK); }
	"unlock"					{ return symbol(UNLOCK); }
	"while"					{ return symbol(WHILE); }
	"endwhile"					{ return symbol(ENDWHILE); }
	"do"						{ return symbol(DO); }
	"for"						{ return symbol(FOR); }
	"endfor"					{ return symbol(ENDFOR); }
	"all"						{ return symbol(ALL); }
	"proc"					{ return symbol(PROC); }
	"endproc"					{ return symbol(ENDPROC); }
	"is"						{ return symbol(IS); }
	"in"						{ return symbol(IN); }
	"if"						{ return symbol(IF); }
	"endif"					{ return symbol(ENDIF); }
	"then"					{ return symbol(THEN); }
	"repeat"					{ return symbol(REPEAT); }
	"until"					{ return symbol(UNTIL); }
	"return"					{ return symbol(RETURN); }
	"("						{ return symbol(LPAREN); }
	")"						{ return symbol(RPAREN); }
	","						{ return symbol(COMMA); }
	":="						{ return symbol(ASSIGN); }
	"||"						{ return symbol(PARALLEL); }
	"."						{ return symbol(DOT); }
	{LineTerminator}				{ return symbol(NEWLINE); }
	[a-zA-Z_$][a-zA-Z0-9_]*			{ return symbol(ID, yytext()); }
	
	/* comments */
	{Comment		}			{ /* ignore */ }

	/* whitespace */
	{WhiteSpace}				{ /* ignore */ }
}

/* error fallback */
.							{ return symbol(CHAR, yytext()); }