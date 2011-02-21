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
 * Module:       OGDead.sml
 *
 * Description:  Report of the home properties functions
 *
 * CPN Tools
 *)

structure CPN'OGDead =
struct

fun DeadMarkings () = 
    let
	val CPN'hml = (ListDeadMarkings ())
	(* if we only have 5 or less home markings sort them *)
	val CPN'nohm = (length CPN'hml)
		       
	val CPN'all = (CPN'nohm = (NoOfNodes ()))
	val CPN'lt5 = (length CPN'hml <= 5)
	val CPN'none = (CPN'nohm = 0)
		    
	fun CPN'Print [] CPN'n = "" (* None will be printed *)
	  | CPN'Print (CPN'el1::(CPN'el2::CPN'rest)) 5 = 
	    mkst_Node(CPN'el1)^",...]"
	  | CPN'Print (CPN'el1::(CPN'el2::CPN'rest)) CPN'n = 
	    mkst_Node(CPN'el1)^","^(CPN'Print (CPN'el2::CPN'rest) (CPN'n+1))
	  | CPN'Print (CPN'el1::CPN'rest) CPN'n = 
	    mkst_Node(CPN'el1)^(CPN'Print CPN'rest (CPN'n+1))	

	fun CPN'SortAndPrint CPN'lst = 
	    let
		(* Simple bobble-sort - since we only have 5 elements *)
		fun CPN'sort CPN'lst = 
		    let
			fun CPN'insert [] CPN'el = CPN'el::[]
			  | CPN'insert ((CPN'el1:int)::CPN'l) (CPN'el2:int) =
			    if (CPN'el1 < CPN'el2)
			    then CPN'el1::(CPN'insert CPN'l CPN'el2)
			    else
				(CPN'el2::(CPN'el1::CPN'l))
				
			fun CPN'sort' [] CPN'nl = CPN'nl
			  | CPN'sort' (CPN'el::CPN'tl) CPN'nl =
			    CPN'sort' CPN'tl (CPN'insert CPN'nl CPN'el) 
		    in
			CPN'sort' CPN'lst [] 
		    end
			
			
	    in
		"["^(CPN'Print (CPN'sort CPN'lst) 1)^"]"
	    end
		
	fun PrintDeadMarkings CPN'l =
	    if CPN'all 
	    then "All"
	    else
		(if CPN'none
		 then
		     "None"
		 else
		     (if CPN'lt5
		      then
			  (CPN'SortAndPrint CPN'l)
		      else
			  Int.toString(length(CPN'l))^" ["^CPN'Print CPN'l 1))
    in
      (OGSaveReport.GenerateHeading "Dead Markings")
	^(OGSaveReport.GenerateEntry (PrintDeadMarkings (CPN'hml)))
    end
	
end (* struct CPN'OGDead *);

(* Setup reference in the main module *)
OGSaveReport.DeadMarkings := CPN'OGDead.DeadMarkings;
OGSaveReport.DeadMarkingsGen := true;
