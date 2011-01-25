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
 * Module:       Design/CPN OG Tool
 *
 * Description:  Generation of for an empty state record
 *
 * Created by:   Lars Michael Kristensen (kris@daimi.au.dk)   
 *
 * Date:         12/07/2000   
 *
*)

(* $Source: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGCreateEmptyState.sml,v $

$Log: OGCreateEmptyState.sml,v $
Revision 1.1  2005/01/05 10:46:59  metch
*** empty log message ***

Revision 1.1.1.1  2004/06/23 07:52:30  coast


Revision 1.1  2004/05/10 12:23:12  metch
*** empty log message ***

Revision 1.1.2.2  2000/07/20 21:34:56  kris
Added support for gloabal fusions

Revision 1.1.2.1  2000/07/13 13:41:29  kris
Initial revision


*)

val rcsid = "$Header: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGCreateEmptyState.sml,v 1.1 2005/01/05 10:46:59 metch Exp $";

(* This structure generates all the basic reference types for the OG       *)
(* data structure records. Also the function to test equality of two state *)
(* records is generated here *)

structure CPN'OGCreateEmptyState =
struct

local
    
open CPN'CodeGenUtils

  
fun gen_field CPN'first {fieldname=fieldname,colset=colset}
   = code_temp:=(!code_temp)^
                    ((if CPN'first
                      then ""
                      else ",\n")^
                      fieldname^" = ref empty"^
                      (if CPN'CSTable.is_timed colset
                      then ","^fieldname^"t = ref []"
                      else ""))

fun gen_localrecs (recname,ref fieldlist)
   = (code_temp:=(!code_temp)^("fun CPN'OGCreateEmptyLocal"^recname^" () = \n CPN'OGLocal"^recname^" \n {");
      if fieldlist<>nil
      then
       (gen_field true (hd fieldlist);
        map (gen_field false) (tl fieldlist))
      else
       [];
      code_temp:=(!code_temp)^"}\n")


(*
fun  gen_pageinstrectest(recname,_)
   = code_temp2:=(!code_temp2)^
                     ("| CPN'OGDataRecIsEq(CPN'OGLocal"^recname^" rec1,\n"^
                      "CPN'OGLocal"^recname^" rec2)=rec1=rec2");
*)

in

fun gen() =
 let
  val nonlocalfus= (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields,"pgglobfus");true)

                    handle ? => false

 in

 code_temp:="";

 CPN'AvlTree.AvlAppKey(gen_localrecs, CPN'OGIdsGen.DataRecFields);

 

 
 code_temp:=(!code_temp)^"fun OGCreateEmptyState owner creationtime = \n CPN'OGState  {";

 map
  (fn {pgmlno = pgmlno, instlist = instlist,...}
     =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
         (* check that record is used - otherwise an exception is rasied *)
        map
        (fn {instno=instno,...}
           => code_temp:=(!code_temp)^("pg"^pgmlno^"'"^instno^" = ref (CPN'OGCreateEmptyLocalpg"^pgmlno^" ()),\n"))
        instlist) handle CPN'AvlTree.ExcAvlLookup => [])
  (!CPN'NetCapture.Net);
  
 if nonlocalfus
 then
   code_temp:=(!code_temp)^"pgglobfus = ref (CPN'OGCreateEmptyLocalpgglobfus ()),\n"
 else
  ();
 
  if (CPN'Time.name <> "unit") then
      
      code_temp:=(!code_temp)^"creationtime = creationtime,\n"
  else
      ();
 
 code_temp:=(!code_temp)^(
                "owner = owner};\n");


 
 (* CPN'AvlTree.AvlAppKey(gen_pageinstrectest, CPN'OGIdsGen.DataRecFields);

 code_temp2:=(!code_temp2)^";\n";*)
  
 (!code_temp)(*::[!code_temp2]*)
 
end(*let*)

end(*local*)

end(*struct*)


