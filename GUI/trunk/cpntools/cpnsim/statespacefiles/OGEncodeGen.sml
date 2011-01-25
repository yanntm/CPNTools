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
 * Module:      OGEncodeGen
 *
 * Description: structure for generation of the encoding 
 * functions for records in the global tables. If simulating 
 * with time the creationtime fun is also made here.
 *
 * In CPN Tools we are always simulating with time, so the
 * creationtime fun is generated.
 *
 * CPN Tools
 *)

structure CPN'OGEncodeGen =
struct

local
    
open CPN'CodeGenUtils;

val first = ref false;

(*SC*)
val count = ref 6;
(*SC*)

fun gen_field {fieldname=fieldname, colset=_}
   = if List.nth(explode(fieldname),1)= (#"P")
     then (*ignore the portplace entries*)
      ()
     else
      code_temp:=(!code_temp)^
                    ((if !first
                      then (first:=false;"")
                      else "+\n")^
                      (*SC*)
                      (count:=(!count + 1); Int.toString (!count))^"*"^
                      (*SC, additional brackets in next line! *)
                      "(size(!(#"^fieldname^" instrec)))");

fun gen_localencode (recname,ref fieldlist)
   = (code_temp:=(!code_temp)^
         ("fun Local"^recname^" (CPN'OGLocal"^recname^" instrec)\n"^
          "=Int.toString(\n");
          
      first:=true;
      
      if fieldlist<>nil
      then
        map gen_field fieldlist
      else
       (code_temp:=(!code_temp)^"0";
        []);
        
      if !first
      then (*no fields used*)
        code_temp:=(!code_temp)^"0"
      else
       ();
        
      code_temp:=(!code_temp)^(")^\" \";\n"))


in

fun gen() =

( 
  
 code_temp:= 
  "structure CPN'OGEncode =\n"^
  "struct\n";
  
 CPN'AvlTree.AvlAppKey(gen_localencode, CPN'OGIdsGen.DataRecFields);

 code_temp:=(!code_temp)^(
            "fun State (CPN'OGState staterec)\n"^
            "=");

 first:=true;

 map (* over all page instances *)
  (fn {pgmlno = pgmlno, instlist = instlist,...}
     =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
          (* check that record is used - otherwise an exception is rasied *)
        map
         (fn {instno=instno,...}
            => code_temp:=(!code_temp)^(
                  (if !first then (first:=false;"") else "^")^
                  ("\nLocalpg"^pgmlno^"(!(#pg"^pgmlno^"'"^instno^" staterec)) ")))
        instlist) handle CPN'AvlTree.ExcAvlLookup => [])
  (!CPN'NetCapture.Net);

 if (!first)
 then
	 code_temp:=(!code_temp)^"\"\";"
 else  
   ();

  [!code_temp^
   (if (CPN'Time.name <> "unit")  
    then "local fun encodeone _ nil = \"\"\n"^
                 "| encodeone 0 _ = \"\"\n"^
                 "| encodeone CPN'n (CPN'hd::CPN'tl)\n"^
                  "=\" \"^(CPN'Time.mkstr CPN'hd)^(encodeone (CPN'n-1) CPN'tl)\n"^
         "in\n"^
          "fun TimeList(CPN'tl:CPN'Time.time list)\n"^
             "=(Int.toString(length CPN'tl))^(encodeone 3 CPN'tl)end;\n"
    else "")^
  "end;\n",
   if (CPN'Time.name <> "unit") 
   then
    ("fun CreationTime CPN'n= #creationtime(CPN'OGUtils.GetStateRec CPN'n);\n"^
     "exception StateCreationTimeExn; \n fun StateCreationTime (CPN'OGState {creationtime = CPN'ct,...}) = CPN'ct \n | StateCreationTime _ = raise StateCreationTimeExn;")

   else
    ""])
  
end(*local*)

end(*struct*);


