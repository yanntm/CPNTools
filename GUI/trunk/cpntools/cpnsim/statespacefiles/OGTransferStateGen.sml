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
 * Module:       OGTransferStateGen
 *
 * Description:  Transferring states from simulator to OG and vice versa
 *
 * CPN Tools
 *)

(* 
 * Module: For creating a function mapping the marking of a given OG node
 * into the simulator, and a function mapping the current state of the
 * simulator into an OG node (finding it if it already exists, creating a
 * new if it doesn't.)
 *) 

structure CPN'OGTransferStateGen =
struct

local
    
open CPN'CodeGenUtils;

in

fun gen () =

(
 code_temp:= "val OGStatetoSim = CPN'OGToSimData.copy;\n"^
               "fun OGSimStatetoOG()\n"^
               "=let\n"^
               "val creationtime = time()\n"^
                 "val staterec\n"^
                    "=CPN'OGState{\n";
 
 map
  (fn {instlist = instlist,pgmlno = pgmlno,...}
     =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
         (* check that record is used - otherwise an exception is rasied *)
         map
         (fn {instno=instno,instmlno=instmlno,...}
            => code_temp:=(!code_temp)^(
                "pg"^pgmlno^"'"^instno^"="^
                  "CPN'OGstore_pg"^pgmlno^"(creationtime, "^instno^"),\n"))
         instlist) handle CPN'AvlTree.ExcAvlLookup => [])
 (!CPN'NetCapture.Net);
                          
                                               
 (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields,"pgglobfus");
  code_temp:=(!code_temp)^"pgglobfus=CPN'OGstore_pgglobfus(creationtime),\n")
 handle CPN'AvlTree.ExcAvlLookup =>();
 
 if (CPN'Time.name <> "unit")
 then
     code_temp:=(!code_temp)^"creationtime=creationtime,\n"
 else
     (); 
 
 [!code_temp^
  "owner=ref(ref(CPN'OGnode(\n"^
          "{no=0,\n"^
            "state=ref(CPN'NoRec),\n"^
            "succlist=ref[],\n"^                               
            "predlist=ref[],\n"^
            "calcstat=ref(UnProc)})))};\n"^
  "val CPN'node_num = ref 0;\n"^
      "val (insertstaterec as ref(CPN'OGState innerrec),wasthere) \n"^
         "= (CPN'RecSearchTree.Insert\n"^
            "(CPN'State'recs, staterec, CPN'OGEncode.State staterec));\n"^
    "in\n"^
    "if wasthere then (case (!insertstaterec) of\n"^
    "CPN'OGState CPN'xx => (case (!(!(#owner CPN'xx))) of CPN'OGnode CPN'xx =>"^
	"CPN'node_num := (#no CPN'xx)| _ => ()) | _ => ())\n"^
    "else let\n"^
      "val nodenum = CPN'OGNodeSel.NewNodeNum();\n"^
      "val _ = CPN'node_num := nodenum;"^
      "val firstnoderef\n"^
         "= ref(CPN'OGnode\n"^
                "{state=insertstaterec,\n"^
                 "no=nodenum,\n"^
                 "succlist=ref [],\n"^
                 "predlist=ref [],\n"^
                 "calcstat=ref UnProc}) in\n"^
      "#owner innerrec:=firstnoderef;\n"^
      "CPN'AvlTree.AvlInsert CPN'OGNodes\n"^
      "(mkst_Node nodenum,firstnoderef)\n"^
      "end;\n"^
      "(wasthere,!CPN'node_num)\n"^
      "end;\n"]
)

end(*local*)

end(*struct*);
