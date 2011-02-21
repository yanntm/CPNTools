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
 * Module:       OGIntegerBoundsGen.sml
 *
 * Description:  
 *
 * CPN Tools
 *)

type CPN'OGRepIntegerPlace = {plname:string,upper:string,lower:string};

structure CPN'OGIntegerBoundsGen =
struct

    local
	open CPN'NetCapture;
	open CPN'CodeGenUtils;

    in
	fun gen_IntegerBoundsSeq () =
	    (
	     code_temp := "\n()) end(*struct*)\n";
 	     map
	     (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
	      => CPN'AvlTree.AvlApp
		  (fn {plname="",...} => ()
		    | {plname=plname, plmlno=plmlno,...}
		      => ( map
			  (fn {instno=instno,instmlno=instmlno,...}
			   => let
				  val CPN'plikey= plmlno^" "^instno
				  val CPN'colset = (#colset(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.PlaceInsts,CPN'plikey)))
				  val CPN'istimed = CPN'CSTable.is_timed CPN'colset
				  val CPN'key = pgname^"'"^plname^instno
				  val CPN'PI = "PI."^pgname^"'"^plname^" "^instno
				  val CPN'MPI = "("^(if CPN'istimed then "StripTime o " else "")^"(Mark."^pgname^"'"^plname^" "^instno
				  val CPN'IsAssignedPort = ((#plitype(CPN'AvlTree.AvlLookup (CPN'OGIdsGen.PlaceInsts,CPN'plikey))) 
							    =  CPN'OGIdsGen.assignedport)
			      in
                               if CPN'IsAssignedPort
                               then ()
			       else
				   code_temp := "\n(let val CPN'name = st_PI("^CPN'PI^") \n\
						\ in \n CPN'AvlTree.AvlInsert CPN'IntegerListPI (\""^CPN'key^"\",{plname = CPN'name,\
						\ upper = Int.toString(UpperInteger("^CPN'MPI^")))),lower = Int.toString(LowerInteger("^
						CPN'MPI^"))))}) end); "^(!code_temp)
			   end(*let*))
			  instlist; 
			  ()),pllist))
	     (!CPN'NetCapture.Net); 
	     code_temp := "structure CPN'OGGetIntegerBounds = \n\
			  \struct val CPN'IntegerListPI = CPN'AvlTree.AvlNew():CPN'OGRepIntegerPlace CPN'AvlTree.avltree; \n\
			  \fun CPN'IntegerBounds () = (CPN'AvlTree.AvlReset CPN'IntegerListPI;"^(!code_temp); 
	     ([!code_temp]))
    end
	
end (* struct CPN'OGIntegerBounds *);

CPN'Env.use_string (CPN'OGIntegerBoundsGen.gen_IntegerBoundsSeq ());
