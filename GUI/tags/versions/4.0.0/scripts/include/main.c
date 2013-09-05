#include <stdio.h>
#include <string.h>

void yylex();
void hack();

FILE *bodyfile, *originfile, *includefile;
char *myname, *path;

int main(int argc, char **argv){
  int i,j;
  
  bodyfile = fopen("bodyfile", "w");
  originfile = fopen("originfile", "w");
  includefile = fopen("includefile", "w");
  
  for(i=1; i<argc; i++){
    hack();
    myname = argv[i];
    path=strdup(myname);
    for (j=strlen(path)-1;((j>0) && (path[j]-'/'));j--);
    path[j]='\0';
    freopen(argv[i],"r",stdin);
    yylex();
  }
  
  fclose(bodyfile);
  fclose(originfile);
  fclose(includefile);
}
