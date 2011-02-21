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
 * Module:       OGBind
 *
 * Description:  Bind, AI, BI & TRI functions
 *
 * CPN Tools
 *)

(* generates the code for the Bind structure and the ArctoBE, 
 * ArcToTI, BEToTI and st_BE/mkst_BE funs 
 *)

structure CPN'OGBindGen =
struct

local

open CPN'CodeGenUtils;

val FirstConstructor = ref true;

 fun lgen_BindStruct()
    =( code_temp:="structure Bind=struct\n"^
                  "datatype Elem=";
                  
       FirstConstructor:=true;
        
       map
          (fn {trlist = trlist, pgname = pgname, ...}
            => map
                 (fn {trname = "", ...} => ()
                   | {trname = trname, trmlno = trmlno, ...}
                    => if CPN'TransitionTable.is_transition trmlno 
		       then code_temp:= !code_temp^
					(if !FirstConstructor
					 then (FirstConstructor:=false;"")
					 else "|")^
					pgname^"'"^trname^" of (Inst*CPN'BRT"^trmlno^")\n"
		       else ())
                 trlist)
          (!CPN'NetCapture.Net);       
        
       code_temp:= !code_temp^(if !FirstConstructor then "" else "|")^
                   "unnamedBE end;\n");

 
  fun lgen_ArcToBE()
    =( patterncount:=0;
       partfuncount:=0;
       code_temp:="";
       code_storage:= ["fun CPN'ArcToBE0 _ = Bind.unnamedBE;\n"];

       map
          (fn {trlist = trlist, pgname = pgname,...}
            => map
                 (fn {trname = "", ...} => ()
                   | {trname = trname, trmlno = trmlno, ...} => 
		     if CPN'TransitionTable.is_transition trmlno 
		     then
			 let
                             val internalid = "(\""^trmlno^"\",CPN'instno)";
			 in
                             newpattern("CPN'ArcToBE",
					"("^internalid^",ref(CPN'BRTT"^trmlno^" CPN'b))=\n"^
					"Bind."^pgname^"'"^trname^"(CPN'instno,CPN'b)")
			 end(*let*)
		     else ())
                 trlist)
          (!CPN'NetCapture.Net);
          
       if !patterncount>0
       then (* finish the last function in code_temp *)
        (code_storage:= !code_storage^^
                        [!code_temp^
                         "|CPN'ArcToBE"^(Int.toString(!partfuncount+1))^" CPN'x=CPN'ArcToBE"^
                        (Int.toString(!partfuncount))^" CPN'x;\n"];
         code_temp:="")
       else
        ();
        
       code_storage:= !code_storage^^
         ["fun ArcToBE CPN'a=CPN'ArcToBE"^
         (Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^
         "(CPN'OGUtils.GetArcInscr(CPN'OGUtils.ArcToArcRec CPN'a));\n"]);

   fun lgen_BEToTI()
    =( patterncount:=0;
       partfuncount:=0;
       code_temp:="";
       code_storage:= ["fun CPN'BEToTI0 _ = TI.unnamedTI;\n"];

       map
          (fn {trlist = trlist, pgname = pgname,...}
            => map
                 (fn {trname = "", ...} => ()
                   | {trname = trname, trmlno = trmlno, ...}
                    => if CPN'TransitionTable.is_transition trmlno 
		       then
			   newpattern("CPN'BEToTI",
                                      "(Bind."^pgname^"'"^trname^
                                      "(CPN'instno,_))=\n"^
                                      "TI."^pgname^"'"^trname^" CPN'instno")
		       else ()
                       )
                 trlist)
          (!CPN'NetCapture.Net);
                 
       if !patterncount>0
       then (* finish the last function in code_temp *)
        (code_storage:= !code_storage^^
                        [!code_temp^
                         "|CPN'BEToTI"^(Int.toString(!partfuncount+1))^" CPN'x=CPN'BEToTI"^
                        (Int.toString(!partfuncount))^" CPN'x;\n"];
         code_temp:="")
       else
        ();
        
       code_storage:= !code_storage^^
         ["val BEToTI =CPN'BEToTI"^
         (Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^";\n",
         
         "val ArcToTI = BEToTI o ArcToBE;\n"]);
         
       
 fun lgen_st_BE()
    =( patterncount:=0;
       partfuncount:=0;
       code_temp:="";
       code_storage:= ["fun CPN'st_BE0 _ _ = \"*** BE without a name ***\";\n"];

       map
          (fn {trlist = trlist, pgname = pgname,...}
            => map
                 (fn {trname = "", ...} => ()
                   | {trname = trname, trmlno = trmlno, ...}
                     => if CPN'TransitionTable.is_transition trmlno 
			then newpattern_2param("CPN'st_BE",
					       "CPN'mkst (Bind."^pgname^"'"^trname^
					       "(CPN'instno,CPN'b))=\n"^
					       "(if CPN'mkst then "^"\"Bind.\"^"^"(CPN'OGBindGen.skiptransno(\""^pgname^"'"^trname^" \"^(Int.toString CPN'instno)))^\n"^"\"(\"^(Int.toString CPN'instno)^"^"\",\"^(CPN'st_binding'"^(CPN'OGBTconvGen.findmlnoforbinding trmlno)^" CPN'b)^\")\""^
					       "else !OGSet.stringrepberef(!OGSet.stringreptiref(\""^pgname^"\",\""^trname^"\",Int.toString(CPN'instno)),(CPN'st_binding'"^(CPN'OGBTconvGen.findmlnoforbinding trmlno)^
					       " CPN'b)))") 
			else ())
                 trlist)
          (!CPN'NetCapture.Net);
                 
       if !patterncount>0
       then (* finish the last function in code_temp *)
        (code_storage:= !code_storage^^
                        [!code_temp^
                         "|CPN'st_BE"^(Int.toString(!partfuncount+1))^" CPN'm CPN'x=CPN'st_BE"^
                        (Int.toString(!partfuncount))^" CPN'm CPN'x;\n"];
         code_temp:="")
       else
        ();
        
       code_storage:= !code_storage^^
         ["val mkst_BE =CPN'st_BE"^
         (Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^" true;\n",
         "val st_BE =CPN'st_BE"^
         (Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^" false;"]);      
     
in    

fun gen_BindStruct() =
(lgen_BindStruct();
 [!code_temp]);

fun gen_ArcToBE() =
(lgen_ArcToBE();
 !code_storage);

fun gen_BEToTI() =
(lgen_BEToTI();
 !code_storage);
 
fun gen_st_BE() =
(lgen_st_BE();
 !code_storage);
 
local
 fun skiptospace(CPN'l as (#" "::_))=CPN'l
   | skiptospace(CPN'hd::CPN'tl)=skiptospace CPN'tl
in
 fun skiptransno CPN'str = implode(rev(skiptospace(rev(explode CPN'str))))
end(*local*)
 
 
end(*local*)
end(*struct*);
 

