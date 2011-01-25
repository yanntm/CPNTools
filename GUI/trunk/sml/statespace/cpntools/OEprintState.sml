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

fun gen_printState ()
  = let
      val CPN'store = ref [] : string list ref;
	  fun CPN'app CPN'st = CPN'store := CPN'st:: (!CPN'store);
  in
      CPN'app ("fun printState"
	       ^" CPN'n  = "
	       ^"\n"
	       ^"(\"\"");

      map
	  (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
	      => CPN'AvlTree.AvlApp
		 (fn {plname="",...} => ()
		   | {plname, plmlno,port,...}
		     => (map 
			     (fn {instno=instno,...} =>
				 let
				     val CPN'plikey    = plmlno^" "^instno
				 in
				     if   port
				     then ()
				     else CPN'app ("^"
						   ^"\n"
						   ^"(st_OEMark."
						   ^pgname^"'"
						   ^plname^" "^instno^" CPN'n)\n")
				 end)
			     instlist;()),
		  pllist))
	  (!CPN'NetCapture.Net);       
	  CPN'app (");\n");
	  (rev (!CPN'store))
  end
