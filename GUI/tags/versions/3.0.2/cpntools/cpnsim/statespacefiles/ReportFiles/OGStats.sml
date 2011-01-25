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
(*
 * Module:       OGStats.sml
 *
 * Description:  Report statistics
 *
 * CPN Tools
 *)

structure CPN'Stats = 
struct
    
    fun GetStats()=
	(OGSaveReport.GenerateHeading "State Space")
	^(OGSaveReport.GenerateEntry ("Nodes:  "^Int.toString(NoOfNodes())))
	^(OGSaveReport.GenerateEntry ("Arcs:   "^Int.toString(NoOfArcs())))
	^(OGSaveReport.GenerateEntry ("Secs:   "^Int.toString(NoOfSecs())))
	^(OGSaveReport.GenerateEntry ("Status: "^(if EntireGraphCalculated() then "Full" else "Partial")))
	^(if SccGraphCalculated () 
	      then
		  (OGSaveReport.GenerateHeading "Scc Graph")
		  ^(OGSaveReport.GenerateEntry ("Nodes:  "^Int.toString(SccNoOfNodes())))
		  ^(OGSaveReport.GenerateEntry ("Arcs:   "^Int.toString(SccNoOfArcs())))
		  ^(OGSaveReport.GenerateEntry ("Secs:   "^Int.toString(SccNoOfSecs())))
	  else
	      "")
end (* struct Stats *);

(* Setup function in the main report module *)
OGSaveReport.Statistics := CPN'Stats.GetStats;
(* Indicate that statistics cide has been generated *)
OGSaveReport.StatisticsGen := true;






