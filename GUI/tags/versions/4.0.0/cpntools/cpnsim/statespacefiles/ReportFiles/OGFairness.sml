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

	fun CPN'Distribute (CPN'ti, (CPN'Impartial, CPN'Fair, CPN'Just, CPN'None)) =
	    case (TIsFairness [CPN'ti])
	      of Impartial => (CPN'ti::CPN'Impartial, CPN'Fair, CPN'Just, CPN'None)
	       | Fair => (CPN'Impartial, CPN'ti::CPN'Fair, CPN'Just, CPN'None)
	       | Just => (CPN'Impartial, CPN'Fair, CPN'ti::CPN'Just, CPN'None)
	       | No_Fairness => (CPN'Impartial, CPN'Fair, CPN'Just, CPN'ti::CPN'None)

        val (CPN'Impartial, CPN'Fair, CPN'Just, CPN'None) =
	    List.foldl CPN'Distribute ([], [], [], []) (TI.All)
	fun CPN'PrepareEntries [] = ["None"]
	  | CPN'PrepareEntries CPN'tis = ListMergeSort.sort (fn (CPN'a, CPN'b) => CPN'a > CPN'b) (List.map st_TI CPN'tis)
				      
    in
	if (length (PredAllSccs (fn CPN'n => not(SccTrivial CPN'n))) = 0)
	  then OGSaveReport.GenerateEntry "No infinite occurrence sequences." 
	  else
           String.concat [
	         OGSaveReport.GenerateHeading "Impartial Transition Instances",
	         String.concat (List.map OGSaveReport.GenerateEntry (CPN'PrepareEntries CPN'Impartial)),
	         OGSaveReport.GenerateHeading "Fair Transition Instances",
	         String.concat (List.map OGSaveReport.GenerateEntry (CPN'PrepareEntries CPN'Fair)),
	         OGSaveReport.GenerateHeading "Just Transition Instances",
	         String.concat (List.map OGSaveReport.GenerateEntry (CPN'PrepareEntries CPN'Just)),
	         OGSaveReport.GenerateHeading "Transition Instances with No Fairness",
	         String.concat (List.map OGSaveReport.GenerateEntry (CPN'PrepareEntries CPN'None))]
	end
    
    
end (* struct CPN'OGLiveTIs *);

(* Setup reference in the main module *)
OGSaveReport.FairnessProperties := CPN'OGFairness.CPN'Fairness;
OGSaveReport.FairnessGen := true;

