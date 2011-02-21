########################################################################
# CPN Tools                                                            #
# Copyright 2010-2011 AIS Group, Eindhoven University of Technology    #
#                                                                      #
# CPN Tools is originally developed by the CPN Group at Aarhus         #
# University from 2000 to 2010. The main architects behind the tool    #
# are Kurt Jensen, Soren Christensen, Lars M. Kristensen, and Michael  #
# Westergaard.  From the autumn of 2010, CPN Tools is transferred to   #
# the AIS group, Eindhoven University of Technology, The Netherlands.  #
#                                                                      #
# This file is part of CPN Tools.                                      #
#                                                                      #
# CPN Tools is free software: you can redistribute it and/or modify    #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation, either version 2 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# CPN Tools is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with CPN Tools.  If not, see <http://www.gnu.org/licenses/>.   #
########################################################################
# Nmake macros for building Windows 32-Bit apps

XALAN="c:\Program Files\xml\xml-xalan\c\Build\Win32\VC6\Release\XalanTransform"

TARGETOS=WIN95
APPVER=4.0
xpathlibs="C:\Program Files\xml\xml-xalan\c\Build\Win32\VC6\Release\XPathCAPI.lib"
xalanlibs="C:\Program Files\xml\xml-xalan\c\Build\Win32\VC6\Release\XalanTransformer.lib"

!include <win32.mak>

all: converter.exe xslt

xslt: 1to2.xsl 0to1.xsl 2to1.xsl 1to0.xsl

# Update the resource if necessary

converter.res: converter.rc converter.h resource.h
    $(rc) $(rcflags) $(rcvars) converter.rc

# Update the object file if necessary

converter.obj: converter.c converter.h
    $(cc) $(cflags) $(cvars) $(cdebug) converter.c

# Update the executable file if necessary, and if so, add the resource back in.

converter.exe: converter.obj converter.res
    $(link) $(linkdebug) $(guiflags) -out:converter.exe converter.obj converter.res $(guilibs) $(xpathlibs) $(xalanlibs)

1to2.xsl: 1to2.source.xsl
    $(XALAN) 1to2.source.xsl loop-compiler.xslt 1to2.xsl

0to1.xsl: 0to1.source.xsl
    $(XALAN) 0to1.source.xsl loop-compiler.xslt 0to1.xsl

2to1.xsl: 2to1.source.xsl
    $(XALAN) 2to1.source.xsl loop-compiler.xslt 2to1.xsl

1to0.xsl: 1to0.source.xsl
    $(XALAN) 1to0.source.xsl loop-compiler.xslt 1to0.xsl

install: all install-xslt
    copy /y converter.exe ..\executable\converter.exe
    copy /y ..\..\DTD\2\cpn.dtd ..\executable\cpn.dtd
    copy /y ..\..\DTD\0\cpnet.dtd ..\executable\cpnet.dtd

install-xslt: xslt
    copy /y 1to2.xsl ..\executable\1to2.xsl
    copy /y 0to1.xsl ..\executable\0to1.xsl
    copy /y 2to1.xsl ..\executable\2to1.xsl
    copy /y 1to0.xsl ..\executable\1to0.xsl

clean:
    del 1to2.xsl 0to1.xsl 2to1.xsl 1to0.xsl
    del converter.exe converter.obj converter.res
