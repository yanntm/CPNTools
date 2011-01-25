(************************************************************************)
(* CPN Tools                                                            *)
(* Copyright 2010-2011 AIS Group, Eindhoven University of Technology    *)
(*                                                                      *)
(* CPN Tools is originally developed by the CPN Group at Aarhus         *)
(* University from 2000 to 2010. The main architects behind the tool    *)
(* are Kurt Jensen, Soren Christensen, Lars M. Kristensen, and Michael  *)
(* Westergaard.  From the autumn of 2010, CPN Tools is transferred to   *)
(* the AIS group, Eindhoven University of Technology, The Netherlands.  *)
(*                                                                      *)
(* This file is part of CPN Tools.                                      *)
(*                                                                      *)
(* CPN Tools is free software: you can redistribute it and/or modify    *)
(* it under the terms of the GNU General Public License as published by *)
(* the Free Software Foundation, either version 2 of the License, or    *)
(* (at your option) any later version.                                  *)
(*                                                                      *)
(* CPN Tools is distributed in the hope that it will be useful,         *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of       *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        *)
(* GNU General Public License for more details.                         *)
(*                                                                      *)
(* You should have received a copy of the GNU General Public License    *)
(* along with CPN Tools.  If not, see <http://www.gnu.org/licenses/>.   *)
(************************************************************************)
(* Switch to state space tool - part 5 *)

structure CPN'RecSearchTree = 
CPN'OGRECSTORAGE (struct
                  type OGrectype=CPN'OGrec
                  val IsRecEq=CPN'OGDataRecIsEq
		  val NoRec=CPN'NoRec
                  end);
                             
structure CPN'BindSearchTree = 
CPN'OGBINDSTORAGE (struct
                   type OGbindtype=CPN'Binding
                   val emptybind=CPN'BRTT000000:OGbindtype
                   fun bindeq(CPN'b1,CPN'b2) = CPN'b1=CPN'b2
		   end);
	  
CPN'Env.use_string(CPN'OGGlobTablesGen.gen());   

use (ogpath^"OGStopLimitCrit.sml");   
use (ogpath^"OGEnabData.sml");
(*use (ogpath^"OGTimeEnabDataGen.sml");*)
