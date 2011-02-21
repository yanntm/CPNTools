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
 * Module:       OGTime
 *
 * Description:  Utility Function used to handle occurrence graphs with time.
 *
 * CPN Tools
 * 
 *)


exception NonexistingArc

fun CPN'OccurenceTimeGen () = 
    (if (CPN'Time.name <> "unit")
	 then "fun OccurrenceTime CPN'a = (CreationTime (DestNode CPN'a) handle  ExcAvlLookup => raise NonexistingArc)"
     else
	 "");

CPN'Env.use_string ([(CPN'OccurenceTimeGen ())]);

fun CPN'StripTimeGen () =
    (if (CPN'Time.name <> "unit")
	 then "val StripTime = TMS.ms;"
     else
	 "fun StripTime CPN'ms = CPN'ms"); 

CPN'Env.use_string([(CPN'StripTimeGen ())]);

(* This function is used to generate the function EqualUnTimed *)

    local
        open CPN'NetCapture;
        open CPN'CodeGenUtils;

    in        
	fun CPN'gen_EqualUntimed () =
            (
             code_temp := "true)\n";
             map
             (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
              => CPN'AvlTree.AvlApp
                  (fn {plname="",...} => ()
                    | {plname=plname, plmlno=plmlno,...}
                      => if CPN'PlaceTable.is_kind_group plmlno then () else
			 (map
                              (fn {instno=instno,instmlno=instmlno}
				  => (
				      let 
					  val CPN'plikey=plmlno^" "^instno
					  val CPN'colset = (#colset(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.PlaceInsts,CPN'plikey)))
					  val CPN'istimed = CPN'CSTable.is_timed CPN'colset
				      in
					  code_temp := "(("^(if CPN'istimed then "StripTime " else "")^
						       "(Mark."^pgname^"'"^plname^" "^instno^" CPN'n1)) == ("^
						       (if CPN'istimed then "StripTime" else "")^"(Mark."^pgname^"'"^plname^" "^instno^
						       " CPN'n2))) andalso \n"^(!code_temp)
				      end))
                              instlist; 
                              ()),pllist))
             (!CPN'NetCapture.Net); 
	     
	     code_temp := "fun EqualUntimed (CPN'n1,CPN'n2) = \n("^(!code_temp); 
             ([!code_temp]))
    end;

(* Generate the functions *)
CPN'Env.use_string(CPN'gen_EqualUntimed());   

fun EqualsUntimed CPN'm = PredAllNodes(fn CPN'n => (EqualUntimed (CPN'm,CPN'n)))
