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
 * Module:       OGDelete
 *
 * Description:  For deleting a state space
 * 
 * CPN Tools
 *)


(* --- Delete the current state space --- *)
structure CPN'OGGlobTablesReset =
struct
    
local

open CPN'CodeGenUtils;
  
 fun gen_recsearchtree(recname,_)
    = code_storage:= ("CPN'RecSearchTree.Reset(CPN'"^recname^"'recs);\n")
                       ::(!code_storage)

  fun gen_mssreset [] = ()
    | gen_mssreset ((CPN'name,_)::CPN'xs) = 
      (code_storage := (("CPN'"^CPN'name^"'mss.Reset ();\n"))::(!code_storage);
       gen_mssreset CPN'xs)
in

fun gen () =
  
 (
 code_storage:=[];

 CPN'AvlTree.AvlAppKey(gen_recsearchtree, CPN'OGIdsGen.DataRecFields);

  ["fun DeleteStateSpace() = (\n"]^^
 (!code_storage)^^[
 
      if CPN'Time.name <> "unit"
      then ("CPN'TimeListsTree.Reset CPN'TimeListTree;\n")

      else "();\n",
 
	 "CPN'RecSearchTree.Reset CPN'State'recs;\n",
	 "CPN'AvlTree.AvlReset CPN'OGArcs;\n",
	 "CPN'AvlTree.AvlReset CPN'OGNodes;\n",
	 "CPN'BindSearchTree.Reset CPN'Binds;\n",
	 "CPN'OGNodeSel.NextNodeNum:=0;\n",
	 "CPN'OGNodeSel.NextArcNum:=0;\n",
	 "CPN'OGNodeSel.InitList();\n",
	 "OGSimStatetoOG();\n",
		   "());\n"]

  )

end(*local*)

end(*struct*);

(* --- generate the delete function --- *)
CPN'Env.use_string [concat (CPN'OGGlobTablesReset.gen ())];
