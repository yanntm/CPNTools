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
//These dll's are needed, until we get static linking
//
//DOMSupport.dll
//XPathCAPI.dll
//XalanSourceTree.dll
//PlatformSupport.dll
//XSLT.dll
//XalanTransformer.dll
//XMLSupport.dll
//XalanDOM.dll
//XercesParserLiaison.dll
//XPath.dll
//XalanExtensions.dll
//xerces-c_1_6_0.dll

#include <XPathCAPI/XPathCAPI.h>
#include <XalanTransformer/XalanCAPI.h>
#define XALAN_API_SUCCESS 0

#include <windows.h>    // includes basic windows functionality
#include <commdlg.h>    // includes common dialog functionality
#include <dlgs.h>       // includes common dialog template defines
#include <cderr.h>      // includes the common dialog error codes
#include <assert.h>
#include <malloc.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <direct.h>     //getcwd
#include <stdarg.h>
#include <tchar.h>      // provides _tsearchenv()
#include "converter.h"  // includes application-specific information

extern 	void setUseValidation(int fValue);

const char szmsgSHAREVIOLATION[] = SHAREVISTRING;  // string for sharing violation
const char szmsgFILEOK[]         = FILEOKSTRING;   // string for OK button

const char szFilterString[]      = "CPNet files (*.cpn; *.xml)\0*.cpn;*.xml\0All files (*.*)\0*.*\0";

UINT cdmsgShareViolation = 0;  // identifier from RegisterWindowMessage
UINT cdmsgFileOK         = 0;  // identifier from RegisterWindowMessage
UINT cdmsgHelp           = 0;  // identifier from RegisterWindowMessage

#define NOCLASH 0
#define OVERWRITE 1
#define NOOVERWRITE 2
#define FILE_ERROR 3
int overwrite = NOCLASH;

int srcFormat = -1;
int targetFormat = 2;

converter_struct versions[] = {{0,"//generator/@tool[contains(.,'Design/CPN')] or //generator[@format=0]","0to1.xsl",NULL,".xml","<!DOCTYPE workspaceElements SYSTEM \"cpnet.dtd\">"},
	{1,"(globbox and globdecl) or //generator[@format=1] or /comment()[position()=1 and contains(.,'Build:')]","1to2.xsl","1to0.xsl",".xml",""},
	{2,"(//generator/@tool[contains(.,'CPN Tools')] and not(//generator/@format)) or //generator[@format=2]",NULL,"2to1.xsl",".cpn","<!DOCTYPE workspaceElements PUBLIC \"-//CPN//DTD CPNXML 1.0//EN\" \"http://www.daimi.au.dk/~cpntools/bin/dtd/2/cpn.dtd\">"}};
	int number_of_versions = 3;

//#define DEBUG

#ifdef DEBUG
	FILE *debug_out = NULL;
	void DEBUGPRINT(char * text, ...) {
		va_list va;
		char buffer[500];
		if (debug_out == NULL) debug_out = fopen("c:\\debug.out","w+");
		va_start(va,text);
		vsprintf(buffer, text, va);
		va_end(va);
		fprintf(debug_out,buffer);
	}
#else
void DEBUGPRINT(char * text, ...) {}
#endif


FILE *source;

TCHAR srcFile[MAX_PATH] = "\0";
TCHAR destFile[MAX_PATH] = "\0";
TCHAR tempFile1[MAX_PATH] = "\0";
TCHAR tempFile2[MAX_PATH] = "\0";
TCHAR workingdir[MAX_PATH] = "\0";
TCHAR progpath[MAX_PATH] = "\0";
TCHAR progdrive[_MAX_DRIVE] = "\0";
TCHAR progdir[_MAX_DIR] = "\0";
TCHAR progname[_MAX_FNAME] = "\0";
TCHAR progext[_MAX_EXT] = "\0";

struct stat buf;

int WINAPI WinMain(HINSTANCE hInst,
		HINSTANCE hPreInst,
		LPSTR lpszCmdLine,
		int nCmdShow) {
	//The common dialogbox
	OPENFILENAME OpenFileName;
	//The result of XPath queries/Xalan transforms, and other intermediate results
	int theResult = 0;
	//handle for Xalan
	XalanHandle theTransformer;
	LPTSTR progpath = GetCommandLine();
	LPTSTR cmdline_ptr = strstr(progpath, "converter.exe");
	cmdline_ptr[0] = '\0';
    //windows likes to quote the path
	while (progpath[0] == '"') progpath++; 
	//Debugging output
	getcwd(workingdir,MAX_PATH);
	DEBUGPRINT("cwd: %s\narg: %s\n",workingdir,lpszCmdLine);
	DEBUGPRINT("progpath: %s\n",progpath);
	//Check if we were passed a filename
	if(strlen(lpszCmdLine)>0) {
		strcpy(srcFile,lpszCmdLine);
	}
	//Else ask for one
	else {
		strcpy( srcFile, "");
		OpenFileName.lStructSize       = sizeof(OPENFILENAME);
		OpenFileName.hwndOwner         = NULL;
		OpenFileName.hInstance         = hInst;
		OpenFileName.lpstrFilter       = szFilterString;
		OpenFileName.lpstrCustomFilter = NULL;
		OpenFileName.nMaxCustFilter    = 0;
		OpenFileName.nFilterIndex      = 0;
		OpenFileName.lpstrFile         = srcFile;
		OpenFileName.nMaxFile          = sizeof(srcFile);
		OpenFileName.lpstrFileTitle    = NULL;
		OpenFileName.nMaxFileTitle     = 0;
		OpenFileName.lpstrInitialDir   = NULL;
		OpenFileName.lpstrTitle        = "Select source file";
		OpenFileName.nFileOffset       = 0;
		OpenFileName.nFileExtension    = 0;
		OpenFileName.lpstrDefExt       = NULL;
		OpenFileName.lCustData         = 0;
		OpenFileName.lpfnHook          = ConverterDlgProc;
		OpenFileName.lpTemplateName    = MAKEINTRESOURCE(IDD_CONVERTER);
		OpenFileName.Flags             = OFN_EXPLORER | OFN_ENABLEHOOK; // | OFN_ENABLETEMPLATE;

		if (GetOpenFileName(&OpenFileName)) {
			DEBUGPRINT("open dialog\n");
		}
		else {
			DEBUGPRINT("skidt 1\n");
			ProcessCDError(CommDlgExtendedError(), NULL );
			return 1;
		}
	}
	//Check the given file
	if(stat(srcFile, &buf)!=0) {
		//popup Dialog, stating that destFile cannot be read
		MessageBox(NULL, "The file does not exist!", "File error!", MB_OK);
		DEBUGPRINT("skidt 3\n");
		return 3;
	}
	else {
		source = fopen(srcFile,"r");
		if (source) {
			DEBUGPRINT("opened file\n");
			fclose(source);
		}
		else {
			MessageBox(NULL, "The file cannot be read!", "File error!", MB_OK);
			DEBUGPRINT("skidt 4\n");
			return 4;
		}
	}

	//Make the path absolute
	_fullpath(srcFile,srcFile,MAX_PATH);
	DEBUGPRINT("abs src: %s\n",srcFile);

	chdir(progpath);
	getcwd(workingdir,MAX_PATH);
	DEBUGPRINT("cwd: %s\n",workingdir);

	//Now it is time to check the source file
	theResult = XalanXPathAPIInitialize();
	if (theResult != XALAN_XPATH_API_SUCCESS) {
		DEBUGPRINT( "Unable to initialize the API.  Error code was %d.\n", theResult);
	}
	else {
		XalanXPathEvaluatorHandle theXalanHandle;
		theResult = XalanCreateXPathEvaluator(&theXalanHandle);
		if (theResult != XALAN_XPATH_API_SUCCESS) {
			DEBUGPRINT( "Error creating evaluator.  Error code was %d.\n", theResult);
		}
		else {
			int current_version;
			DEBUGPRINT("Check version...\n");
			for (current_version = 0; (current_version < number_of_versions) && (srcFormat == -1);current_version++) {
				int theBoolean = 0;
				DEBUGPRINT("ver: %d\n",current_version);
				theResult = EvaluateXPath(theXalanHandle, srcFile, versions[current_version].xpath, &theBoolean);
				if (theResult == XALAN_XPATH_API_SUCCESS) {
					DEBUGPRINT("The result of the expression '%s' was '%s'.\n", versions[current_version].xpath, theBoolean == 0 ? "false" : "true");
					if (theBoolean &&(srcFormat == -1)) {
						srcFormat = versions[current_version].index;
					}
				}
				else {
					DEBUGPRINT( "Error evaluating.  Error code was %d.\n", theResult);
				}
			}
			theResult = XalanDestroyXPathEvaluator(theXalanHandle);
			if (theResult != XALAN_XPATH_API_SUCCESS) {
				DEBUGPRINT( "Error destroying evaluator.  Error code was %d.\n", theResult);
			}
		}
		theResult = XalanXPathAPITerminate();
		if (theResult != XALAN_XPATH_API_SUCCESS) {
			DEBUGPRINT( "Error terminating the API.  Error code was %d.\n", theResult);
		}
	}
	if (srcFormat == -1) {
		MessageBox(NULL, "The file format cannot be determined.\nTherefore the file cannot be converted.", "File format error!", MB_OK);
		return 17;
	}

	//Make a name for the destination file
	strcpy( destFile, srcFile);


	theResult = 0;
	if(srcFormat < targetFormat) {
		theResult = -1;
	}
	else if(srcFormat > targetFormat) {
		theResult = 1;
	}

	//If the filename ends in .xml/.cpn it should be changed
	if(strcmp(destFile+(strlen(destFile)-4),versions[targetFormat+theResult].extension)==0) {
		strcpy(destFile+(strlen(destFile)-4),versions[targetFormat].extension);
	}
	//If it does not end in .cpn/.xml it should have .cpn/.xml appended 
	else if(strcmp(destFile+(strlen(destFile)-4),versions[targetFormat].extension)!=0) {
		if(strlen(destFile) < (MAX_PATH-4)) {
			strcpy(destFile+(strlen(destFile)),versions[targetFormat].extension);
		}
		else {
			MessageBox(NULL, "Extension cannot be added!\nSelect filename manually.", "File error!", MB_OK);
			overwrite = NOOVERWRITE;
		}
	}

	//If there is a file of the new name we ask for a name
	if((overwrite != NOOVERWRITE) && (stat(destFile, &buf)!=-1)) {
		DialogBox(hInst,MAKEINTRESOURCE(IDD_OVERWRITE),NULL,(DLGPROC)Overwrite);
	}
	else {
		source = fopen(destFile,"w");
		if (source) {
			fclose(source);
		}
		else {
			overwrite = FILE_ERROR;
		}
	}
	if((overwrite == NOOVERWRITE) || (overwrite == FILE_ERROR)) {
		strcpy( destFile, "");
		OpenFileName.lStructSize       = sizeof(OPENFILENAME);
		OpenFileName.hwndOwner         = NULL;
		OpenFileName.hInstance         = hInst;
		OpenFileName.lpstrFilter       = szFilterString;
		OpenFileName.lpstrCustomFilter = NULL;
		OpenFileName.nMaxCustFilter    = 0;
		OpenFileName.nFilterIndex      = 0;
		OpenFileName.lpstrFile         = destFile;
		OpenFileName.nMaxFile          = sizeof(destFile);
		OpenFileName.lpstrFileTitle    = NULL;
		OpenFileName.nMaxFileTitle     = 0;
		OpenFileName.lpstrInitialDir   = NULL;
		OpenFileName.lpstrTitle        = "Select destination file";
		OpenFileName.nFileOffset       = 0;
		OpenFileName.nFileExtension    = 0;
		OpenFileName.lpstrDefExt       = NULL;
		OpenFileName.lCustData         = 0;
		OpenFileName.lpfnHook          = ConverterDlgProc;
		OpenFileName.lpTemplateName    = MAKEINTRESOURCE(IDD_CONVERTER);
		OpenFileName.Flags             = OFN_EXPLORER | OFN_ENABLEHOOK;

		if (GetSaveFileName(&OpenFileName)) {
			DEBUGPRINT("save dialog\n");
		}
		else {
			DEBUGPRINT("skidt 2\n");
			ProcessCDError(CommDlgExtendedError(), NULL );
			return 2;
		}
	}

	//Make the path absolute
	_fullpath(destFile,destFile,MAX_PATH);
	DEBUGPRINT("abs dest: %s\n",destFile);

	//Now we have a srcFile, and a destFile, the fun begins
	DEBUGPRINT("%s -> %s\n",srcFile,destFile);

	chdir(progpath);
	getcwd(workingdir,MAX_PATH);
	DEBUGPRINT("cwd: %s\n",workingdir);

	//initialize
	XalanInitialize();
	DEBUGPRINT("initialized Xalan\n");
	theTransformer = CreateXalanTransformer();
	DEBUGPRINT("Created a transformer\n");
	//place the source filename in tempFile2, so the first swap will bring it to tempFile1
	strcpy(tempFile2, srcFile);

	//Run the transformations as a pipeline
	if (targetFormat > srcFormat) {
		while (targetFormat > srcFormat) {
			TCHAR xslfile[MAX_PATH] = "\0";
			swapTempFiles();
			if (strlen(versions[srcFormat].dtd)) {
				removeDTD();
			}
			sprintf(xslfile,"%s%s",progpath,versions[srcFormat].up);

			chdir(progpath);
			getcwd(workingdir,MAX_PATH);
			DEBUGPRINT("cwd: %s\n",workingdir);

			theResult = XalanTransformToFile( tempFile1, xslfile, tempFile2,theTransformer);
			if (theResult != XALAN_API_SUCCESS) {
				DEBUGPRINT( "Error transforming '%s' -(%s)-> '%s'.  Error code was %d.\n", tempFile1, xslfile, tempFile2, theResult);
				DEBUGPRINT("%s\n",XalanGetLastError(theTransformer));
				assert(1==2);
			}			
			else {
				DEBUGPRINT( "Transformed '%s' -(%s)-> '%s'.\n", tempFile1, xslfile, tempFile2);
			}			
			srcFormat++;
		}
	}

	//Files need to be removed, moved and stuff
	if (strcmp(tempFile2,destFile)!=0) {
		DEBUGPRINT("move files ('%s' => '%s'\n",tempFile2,destFile);
		moveFile(tempFile2,destFile);

	}

	if ((strcmp(tempFile1,srcFile)!=0) && strlen(tempFile1)) {
		DEBUGPRINT("Remove '%s'\n",tempFile1);
		unlink(tempFile1);

	}

	//Terminate the transformer
	DeleteXalanTransformer(theTransformer);
	XalanTerminate();

	return 0;
}

int moveFile(char *src, char *dst)
{
	char buf[4096];
	int r;
	FILE *src_f,*dst_f;

	src_f = fopen(src,"r");
	dst_f = fopen(dst,"w");

	if (!(src_f && dst_f)) {
		DEBUGPRINT("Shit, files not opened for copying\n");
		return 0;
	}
	while ((r=fread(buf,sizeof(char),4096,src_f))>0) {
		int i;
		for (i=0;i<r;) {
			int w=fwrite(buf+i,sizeof(char),r-i,dst_f);
			assert(w>0);
			i+=w;
		}
	}
	fclose(src_f);
	fclose(dst_f);
	unlink(src);
	return 1;
}

/* This function is an ugly hack to hide the dtd from xerces, which seems
 * to insist on using it, even if it cannot be found */
void removeDTD(void)
{
	char buf[4096];
	int r,dtd=0;
	FILE *src_f,*dst_f;
	src_f = fopen(tempFile1,"r");
	dst_f = fopen(tempFile2,"w");

	if (!(src_f && dst_f)) {
		DEBUGPRINT("Shit, files not opened for copying\n");
	}
	while ((r=fread(buf,sizeof(char),4096,src_f))>0) {
		int i;
		if (!dtd) {
			for (i=0;i<r;i++) {
				if (0==strncmp(buf+i,versions[srcFormat].dtd,(strlen(versions[srcFormat].dtd) < ((size_t) r))?strlen(versions[srcFormat].dtd):r)) {
					if (strlen(versions[srcFormat].dtd) < ((size_t) r)) {
						int w;
						i = i + strlen(versions[srcFormat].dtd);
						w=fwrite(buf+i,sizeof(char),r-i,dst_f);
						assert(w>=0);
						i+=w;
						dtd = 1;
					} else {
						//The case of the dtd being encountered on a buffer boundry is not handled
						assert(42==17);
					}
				} else {
					int w=fwrite(buf+i,sizeof(char),1,dst_f);
					assert(w==1);
				}
			}
		} else {
			i = 0;
		}
		while (i<r) {
			int w=fwrite(buf+i,sizeof(char),r-i,dst_f);
			assert(w>0);
			i+=w;
		}
	}
	fclose(src_f);
	fclose(dst_f);
	swapTempFiles();
}

void swapTempFiles(void) {
	if ((strcmp(tempFile1,"\0") != 0) && (strcmp(tempFile1,srcFile) != 0)) {
		//this is a temporary file, which we are done with, delete it
		DEBUGPRINT("Deleted '%s'\n",tempFile1);
		unlink(tempFile1);
	}
	strcpy(tempFile1, tempFile2);
	tmpnam(tempFile2);
	DEBUGPRINT("Swapped files (now: tempFile1: '%s' tempFile2: '%s')\n",tempFile1,tempFile2);
}

//
//   FUNCTION: ConverterDlgProc( HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
//
//  PURPOSE:  Processes messages for the File Open common dialog box.
//
typedef struct tagDlgCtrls {
	int ctrlId;
	int def;
	char str[25];
	char opt[5];
} DlgCtrls;

DlgCtrls dlgctrls[] = {
	{ IDC_COMBO1, FALSE, "Design/CPN", "..." },
	{ IDC_COMBO1, TRUE, "CPN Tools", "..."  },
	{ 0, 0}  // End Of List
};

BOOL CALLBACK ConverterDlgProc(HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	int i, index;
	switch (uMsg)
	{
		case WM_INITDIALOG:
			// Save off the long pointer to the OPENFILENAME structure.
			SetWindowLong(hDlg, DWL_USER, lParam);
			i = 0;
			while (dlgctrls[i].ctrlId) {
				index = SendDlgItemMessage (hDlg, IDC_COMBO1, CB_ADDSTRING, 0, (DWORD)(LPSTR)dlgctrls[i].str);
				SendDlgItemMessage (hDlg, IDC_COMBO1, CB_SETITEMDATA, index, i);
				if (dlgctrls[i].def) {
					SendDlgItemMessage (hDlg, IDC_COMBO1, CB_SETCURSEL, index, 0);
				}
				i++;
			}
			break;

		case WM_DESTROY:
			{
				LPOPENFILENAME lpOFN = (LPOPENFILENAME)GetWindowLong(hDlg, DWL_USER);
			}
			break;

		case WM_NOTIFY:
			//Do nothing

		default:
			if (uMsg == cdmsgFileOK)
			{
				SetDlgItemText(hDlg, IDE_SELECTED, ((LPOPENFILENAME)lParam)->lpstrFile);
				if (MessageBox(hDlg, "Got the OK button message.\n\nShould I open it?", "Converter Test", MB_YESNO)
						== IDNO)
				{
					SetWindowLong(hDlg, DWL_MSGRESULT, 1L);
				}
				break;
			}
			else if (uMsg == cdmsgShareViolation)
			{
				SetDlgItemText(hDlg, IDE_SELECTED, (LPSTR)lParam);
				MessageBox(hDlg, "Got a sharing violation message.", "Converter Test", MB_OK);
				break;
			}
			return FALSE;
	}
	return TRUE;
}

BOOL APIENTRY Overwrite( HWND hDlg, UINT message, UINT wParam, LONG lParam)
{
	switch (message)
	{
		case WM_INITDIALOG:
			SetDlgItemText(hDlg, IDC_FILE, destFile);                
			return (TRUE);

		case WM_COMMAND:                      
			if (LOWORD(wParam) == IDYES)
			{
				overwrite = OVERWRITE;
				EndDialog(hDlg, TRUE);        
				return TRUE;
			}
			else if (LOWORD(wParam) == IDNO) 
			{
				overwrite = NOOVERWRITE;
				EndDialog(hDlg, TRUE);        
				return TRUE;
			}
			break;
	}
	return FALSE;                           

}

//
//  FUNCTION: ProcessCDError(DWORD) 
//
//  PURPOSE: Processes errors from the common dialog functions.
//
//  COMMENTS:
//
//        This function is called whenever a common dialog function
//        fails.  The CommonDialogExtendedError() value is passed to
//        the function which maps the error value to a string table.
//        The string is loaded and displayed for the user. 
//
//
void ProcessCDError(DWORD dwErrorCode, HWND hWnd)
{
	WORD  wStringID;
	TCHAR  buf[MAX_PATH];

	switch(dwErrorCode)
	{
		case CDERR_DIALOGFAILURE:   wStringID=IDS_DIALOGFAILURE;   break;
		case CDERR_STRUCTSIZE:      wStringID=IDS_STRUCTSIZE;      break;
		case CDERR_INITIALIZATION:  wStringID=IDS_INITIALIZATION;  break;
		case CDERR_NOTEMPLATE:      wStringID=IDS_NOTEMPLATE;      break;
		case CDERR_NOHINSTANCE:     wStringID=IDS_NOHINSTANCE;     break;
		case CDERR_LOADSTRFAILURE:  wStringID=IDS_LOADSTRFAILURE;  break;
		case CDERR_FINDRESFAILURE:  wStringID=IDS_FINDRESFAILURE;  break;
		case CDERR_LOADRESFAILURE:  wStringID=IDS_LOADRESFAILURE;  break;
		case CDERR_LOCKRESFAILURE:  wStringID=IDS_LOCKRESFAILURE;  break;
		case CDERR_MEMALLOCFAILURE: wStringID=IDS_MEMALLOCFAILURE; break;
		case CDERR_MEMLOCKFAILURE:  wStringID=IDS_MEMLOCKFAILURE;  break;
		case CDERR_NOHOOK:          wStringID=IDS_NOHOOK;          break;
		case PDERR_SETUPFAILURE:    wStringID=IDS_SETUPFAILURE;    break;
		case PDERR_PARSEFAILURE:    wStringID=IDS_PARSEFAILURE;    break;
		case PDERR_RETDEFFAILURE:   wStringID=IDS_RETDEFFAILURE;   break;
		case PDERR_LOADDRVFAILURE:  wStringID=IDS_LOADDRVFAILURE;  break;
		case PDERR_GETDEVMODEFAIL:  wStringID=IDS_GETDEVMODEFAIL;  break;
		case PDERR_INITFAILURE:     wStringID=IDS_INITFAILURE;     break;
		case PDERR_NODEVICES:       wStringID=IDS_NODEVICES;       break;
		case PDERR_NODEFAULTPRN:    wStringID=IDS_NODEFAULTPRN;    break;
		case PDERR_DNDMMISMATCH:    wStringID=IDS_DNDMMISMATCH;    break;
		case PDERR_CREATEICFAILURE: wStringID=IDS_CREATEICFAILURE; break;
		case PDERR_PRINTERNOTFOUND: wStringID=IDS_PRINTERNOTFOUND; break;
		case CFERR_NOFONTS:         wStringID=IDS_NOFONTS;         break;
		case FNERR_SUBCLASSFAILURE: wStringID=IDS_SUBCLASSFAILURE; break;
		case FNERR_INVALIDFILENAME: wStringID=IDS_INVALIDFILENAME; break;
		case FNERR_BUFFERTOOSMALL:  wStringID=IDS_BUFFERTOOSMALL;  break;

		case 0:   //User may have hit CANCEL or we got a *very* random error
						    return;

		default:
						    wStringID=IDS_UNKNOWNERROR;
	}

	LoadString(NULL, wStringID, buf, sizeof(buf));
	MessageBox(hWnd, buf, NULL, MB_OK);
	return;
}


int CreateXPath(XalanXPathEvaluatorHandle theXalanHandle,
		const char*	theXPathExpression,
		XalanXPathHandle* theXPathHandle) {
	int theResult = 0;

	assert(theXalanHandle);
	assert(theXPathHandle);

	theResult = XalanCreateXPath(theXalanHandle, theXPathExpression, 0, theXPathHandle);

	if (theResult != XALAN_XPATH_API_SUCCESS) {
		fprintf(stderr, "Error creating XPath.  Error code was %d.\n", theResult);
	}

	return theResult;
}



int DestroyXPath(XalanXPathEvaluatorHandle theXalanHandle,
		XalanXPathHandle theXPathHandle) {
	int theResult = 0;

	theResult = XalanDestroyXPath(theXalanHandle, theXPathHandle);

	if (theResult != XALAN_XPATH_API_SUCCESS) {
		fprintf(stderr, "Error creating XPath.  Error code was %d.\n", theResult);
	}

	return theResult;
}



char* XReadFile(const char* theXMLFileName) {
	char*	theBuffer = 0;
	FILE*	theFile = fopen(theXMLFileName, "rb");

	if (theFile == 0) {
		fprintf(stderr, "Unable to open input file %s\n", theXMLFileName);
	}
	else {
		fseek(theFile, 0, SEEK_END);

		{
			const int	theSize = ftell(theFile);

			if (theSize == -1) {
				fprintf(stderr, "Unable to determine the size of the input file\n");
			}
			else {
				fseek(theFile, SEEK_SET, 0);

				theBuffer = (char*)malloc(theSize + 1);

				if (theBuffer == 0) {
					fprintf(stderr, "Unable to allocate enough memory.  The input file size is %d\n", theSize);
				}
				else {
					fread(theBuffer, 1, theSize, theFile);

					theBuffer[theSize] = '\0';
				}
			}
		}
	}

	return theBuffer;
}



int EvaluateXPath(XalanXPathEvaluatorHandle theXalanHandle,
		const char* theXMLFileName,
		const char* theXPathExpression,
		int* theBoolean) {
	XalanXPathHandle theXPathHandle;

	int theResult = CreateXPath(theXalanHandle, theXPathExpression, &theXPathHandle);

	if (theResult == XALAN_XPATH_API_SUCCESS) {
		char* theBuffer = XReadFile(theXMLFileName);

		if (theBuffer != NULL) {
			theResult = XalanEvaluateXPathAsBoolean(theXalanHandle, theXPathHandle, theBuffer, theBoolean);

			if (theResult != XALAN_XPATH_API_SUCCESS) {
				fprintf(stderr, "Unable to evaluate XPath expression.  Error code was %d.\n", theResult);
			}

			free(theBuffer);
		}

		DestroyXPath(theXalanHandle, theXPathHandle);
	}

	return theResult;
}
