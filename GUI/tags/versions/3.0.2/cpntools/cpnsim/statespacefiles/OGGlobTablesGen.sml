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
 * Module:       OGGlobTablesGen
 *
 * Description:  For generation of tables to hold OG records
 *
 * CPN Tools
 *)

(* This structure generates all the tables to hold OG records: 
* one for each color set to hold multi sets
* one for each page to hold state record 
* one for the pg/glob fus records (if any) 
* one for state records 
* one for arc records 
* one for node records 
* one for bindings 
* one for the gid -> node ref relationship 
*)


structure CPN'OGGlobTablesGen =
struct
    
local

open CPN'CodeGenUtils;
  
 fun gen_recsearchtree(recname,_)
    = code_storage:= ("val CPN'"^recname^"'recs = CPN'RecSearchTree.New():\n"^   
                         "CPN'RecSearchTree.recsearchtree;\n")
                     ::(!code_storage)

 fun gen_mss ((name,_)::CPN'xs) =
     (code_storage:= (("structure CPN'"^name^"'mss\n"^
		       "=CPN'OGMSST(struct type ColName="^name^" end);\n")
		      ::(!code_storage));
      gen_mss CPN'xs)
   | gen_mss  nil = ()
     
in

fun gen () =
  
 (
 code_storage:=[];
  
 gen_mss (CPN'CSTable.listItemsi());
 
 CPN'AvlTree.AvlAppKey(gen_recsearchtree, CPN'OGIdsGen.DataRecFields);

 (!code_storage)^^[
      if (CPN'Time.name <> "unit")
      then ("structure CPN'TimeListsTree = CPN'OGTLSTORAGE(struct\n"^
                                  "type TimeType=CPN'Time.time;\n"^
                                  "fun timelisteq ([], []) = true | timelisteq (CPN'hd1::CPN'tl1,CPN'hd2::CPN'tl2) = (CPN'Time.cmp(CPN'hd1, CPN'hd2) = EQUAL) andalso (timelisteq (CPN'tl1, CPN'tl2)) | timelisteq _ = false\n"^
                                  "end);\n"^
            "val CPN'TimeListTree = CPN'TimeListsTree.New():\n"^
              "CPN'TimeListsTree.tlsearchtree;")
	   
      else ";",
 
	 "val CPN'State'recs = CPN'RecSearchTree.New():\n"^
	   "CPN'RecSearchTree.recsearchtree;",
	
	 "val CPN'OGArcs = CPN'AvlTree.AvlNew():\n"^
	   "(CPN'OGarcrec ref) CPN'AvlTree.avltree;",
	
	 "val CPN'OGNodes = CPN'AvlTree.AvlNew():\n"^
	   "(CPN'OGnoderec ref) CPN'AvlTree.avltree;",
	
	 "val CPN'Binds = CPN'BindSearchTree.New():\n"^
	   "CPN'BindSearchTree.bindsearchtree;"]
  )

end(*local*)

end(*struct*);
 
