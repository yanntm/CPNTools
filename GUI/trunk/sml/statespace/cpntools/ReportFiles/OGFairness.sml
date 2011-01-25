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
 * Module:       OGFairness.sml
 *
 * CPN Tools
 *)

structure CPN'OGFairness = 
struct

fun CPN'Fairness () =
    let
	val CPN'TIsList = CPN'AvlTree.AvlNew():string CPN'AvlTree.avltree
	val CPN'text_store = ref [] : string list ref
				      
	(* Insert in list which ensures that the output respect *)
	(* users settings for st_TI *)
				      
	fun CPN'FillBlanks 0 = ""
	  | CPN'FillBlanks CPN'n = " "^(CPN'FillBlanks(CPN'n-1))
				   
	fun CPN'FairnessToString Impartial = "Impartial"
	  | CPN'FairnessToString Fair = "Fair"
	  | CPN'FairnessToString Just = "Just"
	  | CPN'FairnessToString No_Fairness = "No Fairness"

	fun CPN'BuildTIsList [] = ()
	  | CPN'BuildTIsList (CPN'el::CPN'tl) =
	    ((CPN'AvlTree.AvlInsert 
		  CPN'TIsList 
		  ((st_TI CPN'el),
		   ("  "^(st_TI CPN'el)^
		    (if (String.size (st_TI CPN'el) >= 23)
		     then "\n  "^(CPN'FillBlanks 23)
		     else CPN'FillBlanks (23-(String.size(st_TI CPN'el))))^
		    (CPN'FairnessToString(TIsFairness [CPN'el])))));
	     CPN'BuildTIsList CPN'tl)
	val _ = (CPN'BuildTIsList TI.All)
    in
	"\n\n Fairness Properties\n------------------------------------------------------------------------"
	^(if (length (PredAllSccs (fn CPN'n => not(SccTrivial CPN'n))) = 0)
	  then "\n  No infinite occurrence sequences.\n" 
	  else
	      (CPN'AvlTree.AvlApp (fn CPN'text => 
				      (CPN'text_store := (CPN'text)::"\n"::(!CPN'text_store)),CPN'TIsList);
	       (concat (rev (!CPN'text_store)))^"\n"))
	end
    
    
end (* struct CPN'OGLiveTIs *);

(* Setup reference in the main module *)
OGSaveReport.FairnessProperties := CPN'OGFairness.CPN'Fairness;
OGSaveReport.FairnessGen := true;

