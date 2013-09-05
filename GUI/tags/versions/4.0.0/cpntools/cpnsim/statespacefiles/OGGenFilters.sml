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
 * Module:       OGGenFilters
 *
 * Description:  For generation of node/arc descriptor templates
 *
 * CPN Tools
 *)


fun NodeFilterGen ()
  = let
      val CPN'store = ref [] : string list ref;
	  fun CPN'app CPN'st = CPN'store := CPN'st:: (!CPN'store);
  in
      CPN'app ("OGSet.NodeDescriptorOptions(\n      fn (CPN'n:Node) =>\n      (st_Node CPN'n)^"^
	       (if CPN'MonitorTable.model_is_timed()
	       then "\n      \" @ \"^CPN'Time.toString(CreationTime CPN'n)^"
	       else "")^"\":\\n\"");
      map (* for every place ... *)
	  (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
	      => CPN'AvlTree.AvlApp
		     (fn {plname="",...} => ()
		       | {plname=plname,...}
			 => (map 
				 (fn {instno=instno,...} =>
				     CPN'app ("\n      ^(st_Mark."^pgname^"'"^plname^" "^instno^" CPN'n)^\"\\n\""))
				 instlist;()),
		      pllist))
	  (!CPN'NetCapture.Net);       
	  CPN'app (");\n");
	  (concat (rev (!CPN'store)))
  end
      
fun ArcFilterGen () 
  = "\nOGSet.ArcDescriptorOptions(fn (CPN'a:Arc) =>\n (st_Arc CPN'a)^"^
    (if CPN'MonitorTable.model_is_timed()
     then "\n \" @ \"^CPN'Time.toString(OccurrenceTime CPN'a)^\n "
     else "")^"\" \"^(st_BE(ArcToBE CPN'a)));\n"

