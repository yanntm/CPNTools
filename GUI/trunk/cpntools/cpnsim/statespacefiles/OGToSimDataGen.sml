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
 * Module:       OGToSimDataGen
 *
 * Description: structure for generation of the function for copying a 
 *              node's state into the regular CPN simulator structures
 *
 * CPN Tools
 *)

structure CPN'OGToSimDataGen =
struct

local
    
open CPN'CodeGenUtils;
 
val copy_code_list = ref ([]:string list);
val init_code_list = ref ([]:string list);

fun  gen_placeinstcopy({OGdatarec=OGdatarec, OGdatarecfield=OGdatarecfield,
                        simplace=simplace, siminst=siminst, plitype=plitype,colset=colset,...}
                        :CPN'OGIdsGen.PlaceInstDescr)  =    
   let     
       val cur_elem = if (CPN'Time.name <> "unit") andalso (CPN'CSTable.is_timed colset)
		      then (simplace^".set "^siminst^" (untimedToTimed((!(#"^OGdatarecfield^" og"^OGdatarec^")),\n\
		           \  CPN'TimeEquivalence.CPN'subtract creationtime (!(#"^OGdatarecfield^"t og"^OGdatarec^"))));\n"^
			   simplace^".init "^siminst^";\n") 
		      else (simplace^".set "^siminst^" (!(#"^OGdatarecfield^" og"^OGdatarec^"));\n") 
   in
     if plitype<>CPN'OGIdsGen.assignedport
     then
       if ListUtils.mem (!copy_code_list) cur_elem then ()
       else copy_code_list := !(copy_code_list)^^[cur_elem]
     else
      ()
   end;

in

fun gen () =

let
 val nonlocalfus= (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields,"pgglobfus");true)
                  handle _ => false

in
 
 
 code_temp:= 
  "structure CPN'OGToSimData =\n"^
  "struct\n"^
  "fun copyStateRec (CPN'sr) =\n"^
  "let\n"^
  (if (CPN'Time.name <> "unit") then
  "fun untimedToTimed (_,[]) = []\n\
   \  | untimedToTimed ([],_) = []\n\
   \  | untimedToTimed ((fms::rms),(ftl::rtl)) = \n\
   \              CPN'Time.@(fms,ftl)::untimedToTimed(rms,rtl)\n"
  else "")^
  "val CPN'OGnode{state=ref(CPN'OGState{\n";

 map (* over all page instances *)
  (fn {pgmlno = pgmlno, instlist = instlist,...}
     =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
         (* check that record is used - otherwise an exception is raised *)
        map
        (fn {instno=instno,...}
           => code_temp:=(!code_temp)^
                ("pg"^pgmlno^"'"^instno^
                 "=ref(CPN'OGLocalpg"^pgmlno^" ogpg"^pgmlno^"'"^instno^"),\n"))
        instlist) handle CPN'AvlTree.ExcAvlLookup => [])
  (!CPN'NetCapture.Net);
  
 if nonlocalfus
 then
   code_temp:=(!code_temp)^"pgglobfus=ref(CPN'OGLocalpgglobfus ogpgglobfus),\n"
 else
  ();
 
 if (CPN'Time.name <> "unit")
 then
  code_temp:=(!code_temp)^"creationtime=creationtime,"
 else
  ();
   
 code_temp:= (!code_temp)^(
  "...}),...}=CPN'sr\n"^
  "in\n");
    
 CPN'AvlTree.AvlApp(gen_placeinstcopy, CPN'OGIdsGen.PlaceInsts);

 code_temp:= (!code_temp)^(String.concat (!copy_code_list));

 if (CPN'Time.name <> "unit")
 then
     code_temp:=(!code_temp)^"CPN'Time.model_time:=(CPN'TimeEquivalence.compressTimestamp (creationtime));\n"
 else
     ();

  code_temp:=(!code_temp)^
  ("()\n"^
  "end\n"^
    "fun copy (CPN'n : Node) ="^
   "copyStateRec (CPN'OGUtils.NodeToNodeRec CPN'n)"^
 "end;\n");
  
  copy_code_list := ([]:string list);

 [!code_temp]

end(*let*)
  
end(*local*)

end(*struct*);
