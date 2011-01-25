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
 * Module:       OGMultiSetBounds.sml
 *
 * CPN Tools
 *)

structure CPN'OGMultiSetBounds =
struct

local
    open CPN'OGGetMultiSetBounds
in
	
fun CPN'FillBlanks 0 = ""
  | CPN'FillBlanks CPN'n = " "^(CPN'FillBlanks(CPN'n-1))
			   
			   
fun CPN'PrintLowerBounds ()
  = let
      val CPN'text_store = ref [] : string list ref
  in
      CPN'AvlTree.AvlApp 
	  (fn {plname = CPN'name,
	       upper = CPN'upper,
	       lower = CPN'lower}: CPN'OGRepMultiSetPlace => 
	      (CPN'text_store := 
	       (CPN'name
		^(if (String.size CPN'name) >= 20
		  then "\n     "^(CPN'FillBlanks 20)
		  else CPN'FillBlanks (20-(String.size CPN'name)))
		^CPN'lower)::(!CPN'text_store); 
	       ()),
	      CPN'MultiSetListPI);
	  (rev (!CPN'text_store))
  end

fun CPN'PrintUpperBounds ()
  = let
      val CPN'text_store = ref [] : string list ref
  in
      CPN'AvlTree.AvlApp 
	  (fn {plname = CPN'name,
	       upper = CPN'upper,
	       lower = CPN'lower}:CPN'OGRepMultiSetPlace => 
	      (CPN'text_store := 
	       (CPN'name
		^(if (String.size CPN'name) >= 20
		  then "\n     "^(CPN'FillBlanks 20)
		  else CPN'FillBlanks (20-(String.size CPN'name)))
		^CPN'upper)::(!CPN'text_store); 
	       ()),
	      CPN'MultiSetListPI);
	  (rev (!CPN'text_store))
  end
      
fun CPN'GetAndPrintBounds () = 
    ((CPN'MultiSetBounds ());
     (OGSaveReport.GenerateHeading "Best Upper Multi-set Bounds")
     ^(concat (map OGSaveReport.GenerateEntry (CPN'PrintUpperBounds ())))
     ^(OGSaveReport.GenerateHeading "Best Lower Multi-set Bounds")
     ^(concat (map OGSaveReport.GenerateEntry (CPN'PrintLowerBounds ()))))

end
end (*struct*);

(* generate code *)

(* Setup reference in the main module *)
OGSaveReport.MultiSetBounds := CPN'OGMultiSetBounds.CPN'GetAndPrintBounds;
OGSaveReport.MultiSetBoundsGen := true;

