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
//---------------------------------------------------------------------------
//	converter.h
//---------------------------------------------------------------------------

#ifndef STRICT
#define STRICT
#endif

#ifdef	RC_INVOKED
#include <winuser.h>
#else	// RC_INVOKED
#include <windows.h>
#endif	// RC_INVOKED
#include "resource.h"

// window ids
#define ID_EDITCHILD		500

// string constants

#define IDS_DIALOGFAILURE     1
#define IDS_STRUCTSIZE        2
#define IDS_INITIALIZATION    3
#define IDS_NOTEMPLATE        4
#define IDS_NOHINSTANCE       5
#define IDS_LOADSTRFAILURE    6
#define IDS_FINDRESFAILURE    7
#define IDS_LOADRESFAILURE    8
#define IDS_LOCKRESFAILURE    9
#define IDS_MEMALLOCFAILURE  10
#define IDS_MEMLOCKFAILURE   11
#define IDS_NOHOOK           12
#define IDS_SETUPFAILURE     13
#define IDS_PARSEFAILURE     14
#define IDS_RETDEFFAILURE    15
#define IDS_LOADDRVFAILURE   16
#define IDS_GETDEVMODEFAIL   17
#define IDS_INITFAILURE      18
#define IDS_NODEVICES        19
#define IDS_NODEFAULTPRN     20
#define IDS_DNDMMISMATCH     21
#define IDS_CREATEICFAILURE  22
#define IDS_PRINTERNOTFOUND  23
#define IDS_NOFONTS          24
#define IDS_SUBCLASSFAILURE  25
#define IDS_INVALIDFILENAME  26
#define IDS_BUFFERTOOSMALL   27
#define IDS_FILTERSTRING     28
#define IDS_UNKNOWNERROR     29

// constants

#define MAX_PATH             260

typedef struct cpn_converter {
  //the number
  int index;
  //the identifying xpath
  char *xpath;
  //xsl-file to upgrade this format to next
  char *up;
  //xsl-file to downgrade this format to previous
  char *down;
  //extension
  char *extension;
  //the dtd string, hack to allow us to remove it
  char *dtd;
} converter_struct;
	


// Function prototypes

// procs
long APIENTRY MainWndProc(HWND, UINT, UINT, LONG);
BOOL APIENTRY Overwrite(HWND, UINT, UINT, LONG);
BOOL CALLBACK ConverterDlgProc(HWND, UINT, WPARAM, LPARAM);

//functions
void ProcessCDError(DWORD, HWND);

#include <XPathCAPI/XPathCAPI.h>

int moveFile(char *src, char *dst);
void removeDTD(void);
void swapTempFiles(void);
int EvaluateXPath(XalanXPathEvaluatorHandle theXalanHandle,
		  const char* theXMLFileName,
		  const char* theXPathExpression,
		  int* theBoolean);
char* XReadFile(const char* theXMLFileName);
int DestroyXPath(XalanXPathEvaluatorHandle theXalanHandle,
		 XalanXPathHandle theXPathHandle);
int CreateXPath(XalanXPathEvaluatorHandle theXalanHandle,
		const char*	theXPathExpression,
		XalanXPathHandle* theXPathHandle);
