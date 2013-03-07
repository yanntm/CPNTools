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
 * Module:       OGCreateStateRec
 *
 * Description:  Create first node
 *
 * CPN Tools
 *)

(* structure for generation of the function for creating 
 * the very first node by copying the contents of the regular 
 * CPN simulator data into the global OG tables 
 *) 

structure CPN'OGCreateStateRec =
struct

local
    
open CPN'CodeGenUtils;

in

fun gen () =

(
 code_temp:="fun CPN'OGCreateStateRec()\n"^
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
      "val (insertstaterec as ref(CPN'OGState innerrec),_) \n"^
         "= CPN'RecSearchTree.Insert\n"^
            "(CPN'State'recs, staterec, CPN'OGEncode.State staterec);\n"^
      "val firstnoderef\n"^
         "= ref(CPN'OGnode\n"^
                "{state=insertstaterec,\n"^
                 "no=1 ,\n"^
                 "succlist=ref [],\n"^
                 "predlist=ref [],\n"^
                 "calcstat=ref UnProc})\n"^
    "in\n"^
      "firstnoderef\nend;\n"
     ]
)

end(*local*)

end(*struct*);
 
 
