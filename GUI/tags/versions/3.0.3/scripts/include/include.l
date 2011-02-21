%{
#include <string.h>

typedef enum state_t {body, origin, include, andet} state_t;
static state_t state = andet;
extern char *myname;
extern FILE *bodyfile, *originfile, *includefile;
extern char *path;

void hack(void){
  BEGIN(INITIAL);
}

%}

%x comment
%x done
%%

[Oo][Rr][Ii][Gg][Ii][Nn]      state = origin;
[Bb][Oo][Dd][Yy]              state = body;
[Ii][Nn][Cc][Ll][Uu][Dd][Ee]  state = include;

'[^']*'                       {yytext[strlen(yytext)-1] = '\0';
                               yytext++;
                               switch(state){
                                case origin:
					    if (yytext[0]-'~')
                                    fprintf(originfile, "%s\n%s/%s\n", myname, path, yytext);
					    else
                                    fprintf(originfile, "%s\n%s\n", myname, yytext);
                                  break;
                                case include:
					    if (yytext[0]-'~')
                                    fprintf(includefile, "%s\n%s/%s\n", myname, path, yytext);
					    else
                                    fprintf(includefile, "%s\n%s\n", myname, yytext);
                                  break;
                                case body:
					    if (yytext[0]-'~')
                                    fprintf(bodyfile, "%s\n%s/%s\n", myname, path, yytext);
					    else
                                    fprintf(bodyfile, "%s\n%s\n", myname, yytext);
                                  break;
                                case andet:
                                  break;
                               }
                              }

";"                           state = andet;

\(\*[^*]*                     BEGIN(comment);

--                            BEGIN(done);

<comment>[^*]*                /*ib*/;
<comment>.                    /*ib*/;
<comment>\*\)                 BEGIN(INITIAL);
<done,INITIAL>.               /*Hurra*/;
<done,INITIAL>\n              /*Hurra*/;
%%
