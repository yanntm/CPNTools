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
#include <stdio.h>
#include <stdlib.h>

FILE *yyout;
extern FILE *yyin;

int
yywrap (void)
{
  return 1;
}

void
yyerror (char *s)
{
  extern int lineno;
  starttag("error");
  fprintf(yyout, s);
  closetag();
  yybegin(0);
}

/* 
 * Returns:
 *   0  if successful
 *   1  if parsing failed due to syntax errors
 *  -1  if filename is invalid
 */

char *xml = NULL;

char *
mlparse_getxml ()
{
  return xml;
}

void
mlparse_clearxml ()
{
  if (xml) free(xml);
}



int 
mlparse_parse (char *decl, char *tmppath)
{ int retval;
  char *infile;
  char *outfile;
  extern void resetBuffer();
  FILE *in, *out;
  long filesize;
  long read_bytes;
  
  /* Generate temporary file names... */
  infile = tempnam(tmppath, "PARIN");
  outfile = tempnam(tmppath, "PAOUT");

  /* Put declaration into infile. */
  in = fopen(infile, "w");
  fprintf(in, "%s", decl);
  fclose(in);
  
  /* Setup streams... */
  yyin = fopen(infile, "r");
  yyout = fopen(outfile, "w");
  if (stdin == NULL || stdout == NULL)
    {
      /* Filename invalid... */
      return -1;
    }

  fprintf(yyout, "<?xml version=\"1.0\"?>\n");
  fprintf(yyout, "<globbox>\n");
  retval = yyparse();
  while (closetag());
  fprintf(yyout, "</globbox>");
  resetBuffer();
  
  /* Close the streams... */
  fclose(yyin);
  fclose(yyout);
  
  /* Read the xml file from outfile. */
  out = fopen(outfile, "r");
  fseek(out, 0, SEEK_END);
  filesize = ftell(out);
  xml = calloc(1, filesize + 1);
  fseek(out, 0, SEEK_SET);
  read_bytes = fread(xml, 1, filesize, out);
  /* Bugs #537, #666
   * fread does inputconversion (\n\r -> \n), 
   * use read_bytes instead of filesize. */
  xml[read_bytes] = 0;
  fclose(out);

  /* Remove the temporary files. */
  unlink(outfile);
  unlink(infile);

  free(infile);
  free(outfile);

  return retval;
}
