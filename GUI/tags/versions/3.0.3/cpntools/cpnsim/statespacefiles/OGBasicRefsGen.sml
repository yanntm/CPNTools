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
 * Module:       OGBasicRefsGen
 *
 * Description:  Basic reference types generator
 *
 * CPN Tools
 *)

(* This structure generates all the basic reference types for the OG       
 * data structure records. Also the function to test equality of two state 
 * records is generated here 
 *)

structure CPN'OGBasicRefsGen =
struct

local
    
open CPN'CodeGenUtils;
  
fun gen_field CPN'first {fieldname=fieldname,colset=colset}
   = code_temp:=(!code_temp)^
                    ((if CPN'first
                      then ""
                      else ",\n")^
                      fieldname^":("^colset^" ms)ref"^
                      (if CPN'CSTable.is_timed colset
                      then ","^fieldname^"t: (CPN'Time.time list)ref"
                      else ""));

fun gen_localrecs (recname,ref fieldlist)
   = (code_temp:=(!code_temp)^("CPN'OGLocal"^recname^" of {");
      if fieldlist<>nil
      then
       (gen_field true (hd fieldlist);
        map (gen_field false) (tl fieldlist))
      else
       [];
      code_temp:=(!code_temp)^"}\n| ")


fun  gen_pageinstrectest(recname,_)
   = code_temp2:=(!code_temp2)^
                     ("| CPN'OGDataRecIsEq(CPN'OGLocal"^recname^" rec1,\n"^
                      "CPN'OGLocal"^recname^" rec2)=rec1=rec2");

in

fun gen() =
 let
  val nonlocalfus= (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields,"pgglobfus");true)
                    handle _ => false

 in

 code_temp:="datatype CPN'OGrec =\n";

 CPN'AvlTree.AvlAppKey(gen_localrecs, CPN'OGIdsGen.DataRecFields);
 
 code_temp:=(!code_temp)^"CPN'OGState of {";

 map
  (fn {pgmlno = pgmlno, instlist = instlist,...}
     =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
         (* check that record is used - otherwise an exception is rasied *)
        map
        (fn {instno=instno,...}
           => code_temp:=(!code_temp)^("pg"^pgmlno^"'"^instno^":CPN'OGrec ref,\n"))
        instlist) handle CPN'AvlTree.ExcAvlLookup => [])
  (!CPN'NetCapture.Net);

 if nonlocalfus
 then
   code_temp:=(!code_temp)^"pgglobfus:CPN'OGrec ref,\n"
 else
  ();
 
 if (CPN'Time.name <> "unit")
 then
   code_temp:=(!code_temp)^"creationtime:CPN'Time.time,\n"
 else
  ();
 
 code_temp:=(!code_temp)^(
                "owner : (CPN'OGnoderec ref)ref}\n| "^
                "CPN'NoRec\n"^
                "and CPN'OGarcrec =\n"^
                "CPN'OGarc of "^
                "{src : CPN'OGnoderec ref,\n"^
                 "dest: CPN'OGnoderec ref,\n"^
                 "no:Arc,\n"^
                 "inscr : (CPN'TransInst * (CPN'Binding ref))}\n"^
                "and CPN'OGnoderec =\n"^
                 "CPN'OGnode of "^
                 "{state:CPN'OGrec ref,\n"^
                  "no:Node,\n"^
                  "succlist:(CPN'OGarcrec ref list) ref,\n"^
                  "predlist:(CPN'OGarcrec ref list) ref,\n"^
                  "calcstat:CalcStat ref};\n");


 code_temp2:= "fun CPN'OGDataRecIsEq(CPN'OGState rec1, CPN'OGState rec2) =\n";
 
 map
  (fn {pgmlno = pgmlno, instlist = instlist,...}
     =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
        (* check that record is used - otherwise an exception is rasied *)
        map
        (fn {instno=instno,...}
           => code_temp2:=(!code_temp2)^
              ("(#pg"^pgmlno^"'"^instno^" rec1)=(#pg"^pgmlno^"'"^instno^" rec2)andalso\n"))
        instlist) handle CPN'AvlTree.ExcAvlLookup => [])
  (!CPN'NetCapture.Net);
 
 code_temp2:=(!code_temp2)^(
                 if nonlocalfus
                 then
                  "(#pgglobfus rec1)=(#pgglobfus rec2)"
                 else
                   "true");

 if (CPN'Time.name <> "unit")
 then
  code_temp2:=(!code_temp2)^"\nandalso(CPN'Time.cmp((#creationtime rec1),(#creationtime rec2)) = EQUAL)"
 else
  ();
 
 CPN'AvlTree.AvlAppKey(gen_pageinstrectest, CPN'OGIdsGen.DataRecFields);

 code_temp2:=(!code_temp2)^";\n";
  
 (!code_temp)::[!code_temp2]
 
end(*let*)

end(*local*)

end(*struct*);


 
