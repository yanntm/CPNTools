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
#include <windows.h>
#include <tlhelp32.h>
#include <stdlib.h>

int killProcessByID(unsigned int PID) {
  HANDLE process;
  if ((process = OpenProcess(PROCESS_TERMINATE, 0, PID)) == NULL)
    return 1;
  if (!TerminateProcess(process, (unsigned) -1))
    return 1;
  return 0;
}

int killProcessList (char* processName) {
  PROCESSENTRY32 pe32;
  HANDLE hProcessSnap;
  BOOL rProcessFound;
  hProcessSnap=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (hProcessSnap == INVALID_HANDLE_VALUE)
    return 1;

  pe32.dwSize=sizeof(pe32);
  rProcessFound=Process32First(hProcessSnap,&pe32);
  
  //here the killing spree begins --- mua haa haa haa
  do 
    if (strcmp (processName, pe32.szExeFile) == 0) {
      //fprintf (stdout, "%s: %d\n", pe32.szExeFile, pe32.th32ProcessID);
      if (killProcessByID (pe32.th32ProcessID)) 
	return 2;
    }
  while (rProcessFound=Process32Next (hProcessSnap,&pe32));
  
  CloseHandle(hProcessSnap);
  
  return 0;
}

void KillThemAll(char* processName) {
  switch (killProcessList (processName)) {
  case 1: 
	fprintf(stderr, "killsimulator: Unable to get process list!");
	break;
  case 2:
	fprintf(stderr, "killsimulator: Undefined behaviour (nice hint $d)");
	break;
  }
}
