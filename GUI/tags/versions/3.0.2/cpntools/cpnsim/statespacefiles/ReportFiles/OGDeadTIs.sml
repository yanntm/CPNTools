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
 * Module:       OGDeadTIs.sml
 *
 * Description:  Report of the liveness properties functions
 *
 * CPN Tools
 *)

structure CPN'OGDeadTIs =
struct

fun DeadTransitions () =
    let
	val CPN'DeadTIsList = CPN'AvlTree.AvlNew():string CPN'AvlTree.avltree
	val CPN'DeadTIs = (ListDeadTIs ())
	val CPN'text_store = ref [] : string list ref

	(* Insert in list which ensures that the output respect *)
	(* users settings for st_TI *)
				      
	fun CPN'BuildDeadTIsList [] = ()
	  | CPN'BuildDeadTIsList (CPN'el::CPN'tl) =
	    ((CPN'AvlTree.AvlInsert CPN'DeadTIsList ((st_TI CPN'el),(st_TI CPN'el)));
	     CPN'BuildDeadTIsList CPN'tl)

	val _ = (CPN'BuildDeadTIsList CPN'DeadTIs)
    in
      (OGSaveReport.GenerateHeading "Dead Transition Instances")
	^(if (length (TI.All) = length (CPN'DeadTIs))
	  then
	      OGSaveReport.GenerateEntry "All"
	  else
	      (if (length (CPN'DeadTIs) = 0)
	       then 
		   OGSaveReport.GenerateEntry "None"
	       else
		   (
		    CPN'AvlTree.AvlApp (fn CPN'name => 
					   (CPN'text_store := (CPN'name)::(!CPN'text_store)),CPN'DeadTIsList);
		    (concat (map OGSaveReport.GenerateEntry (rev (!CPN'text_store)))))))
    end

end (* struct CPN'OGLiveTIs *);

(* Setup reference in the main module *)
OGSaveReport.DeadTIs := CPN'OGDeadTIs.DeadTransitions;
OGSaveReport.DeadTIsGen := true;
