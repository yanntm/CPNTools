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
 * Module:       OGIntegerBounds.sml
 *
 * CPN Tools
 *)

structure CPN'OGIntegerBounds =
struct

local
    open CPN'OGGetIntegerBounds;
in
	
fun CPN'FillBlanks 0 = ""
  | CPN'FillBlanks CPN'n = " "^(CPN'FillBlanks(CPN'n-1))
    
fun CPN'PrintIntegerBounds ()
  = let
      val CPN'text_store = ref [] : string list ref
  in
      CPN'AvlTree.AvlApp 
	  (fn {plname = CPN'name,
	       upper = CPN'upper,
	       lower = CPN'lower}: CPN'OGRepIntegerPlace => 
	      (CPN'text_store := 
	       (CPN'name
		^(if (String.size CPN'name) >= 24 
		  then "\n     "^(CPN'FillBlanks 24)
		  else CPN'FillBlanks (24-(String.size CPN'name)))
		^CPN'upper
		^(CPN'FillBlanks(Int.max((11-(String.size(CPN'upper))),1)))
		^CPN'lower)::(!CPN'text_store); 
	       ()),
	      CPN'IntegerListPI);
	  (rev (!CPN'text_store))
  end
fun CPN'GetAndPrintBounds () = 
    ((CPN'IntegerBounds ());
     (OGSaveReport.GenerateHeading "Best Integer Bounds")
     ^(OGSaveReport.GenerateEntry "                        Upper      Lower"
     ^(concat (map OGSaveReport.GenerateEntry (CPN'PrintIntegerBounds ())))))
end
end (*struct*);

(* Setup reference in the main module *)
OGSaveReport.IntegerBounds := CPN'OGIntegerBounds.CPN'GetAndPrintBounds;
OGSaveReport.IntegerBoundsGen := true;

