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

fun MarkEquivDefaultGen ()
    = let
	  val CPN'store = ref [] : string list ref;
	  fun CPN'app CPN'st = CPN'store := CPN'st:: (!CPN'store);
      in
	  CPN'app "fun CPN'DefaultEquivMark (CPN'n1,CPN'n2) = ((\n";

	  map
          (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
             => CPN'AvlTree.AvlApp
	       (fn {plname="",...} => ()
		 | {plname, plmlno,port,...}
		   => (map 
		       (fn {instno,instmlno} =>
			(let
			     val CPN'plikey    = plmlno^" "^instno
			     val CPN'pliinfo   = (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.PlaceInsts,CPN'plikey))
			     val CPN'colset    = (#colset CPN'pliinfo)
			 in
			     if port
				 then ()
			     else
				 (if (CPN'CSTable.is_timed CPN'colset)
				      then
					  CPN'app ("(case (CPN'TMS.tsub(OEMark."
						   ^pgname^"'"^plname^
						   " "^instno^" CPN'n1,OEMark."
						   ^pgname^"'"^plname^" "^instno^
						   " CPN'n2)) of tempty => true | _ => false) andalso\n")
				  else
				      CPN'app ("(OEMark."^pgname^"'"^plname^
					       " "^instno^" CPN'n1 == OEMark."
					       ^pgname^"'"^plname^" "^instno^
					       " CPN'n2) andalso\n"))
			 end))
		       instlist;()),
		       pllist))
	  (!CPN'NetCapture.Net);     
	  CPN'app (if (CPN'Time.name = "unit")
		   then
		       "true));\n"
		   else
		       "(StateCreationTime CPN'n1) = (StateCreationTime CPN'n2)\n"^
		       ")\nhandle CPN'IllegalMultiSetSubtr => false);\n");
	  CPN'app ("(*OESet.EquivMark(CPN'DefaultEquivMark);*)\n");
	  List.concat [rev (!CPN'store)]
      end
