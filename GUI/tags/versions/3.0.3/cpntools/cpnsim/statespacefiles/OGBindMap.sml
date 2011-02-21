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
 * Module:       OGBindMap
 *
 * Description:  Functions for mapping between internal 
 * and external representation of binding elements
 *
 * CPN Tools
 *)

fun CPN'IntBEToExtBE ((CPN't,CPN'instno),CPN'b) = 
    let
	val CPN'bref = ref CPN'b
    in
	 CPN'ArcToBE1 ((CPN't,CPN'instno),CPN'bref)
    end;

(* Mapping from external representation of internal representation *)
(* extracted from ImageFiles/OGBind.sml *)

structure CPN'OGBindGenNew =
struct

local

open CPN'CodeGenUtils;

val FirstConstructor = ref true;

  fun lgen_BEToArc()
    =( patterncount:=0;
       partfuncount:=0;
       code_temp:="";
       code_storage:= ["exception BEToArcExn; \n fun CPN'BEToArc0 _ = raise BEToArcExn;\n"];

       map
          (fn {trlist = trlist, pgname = pgname,...}
            => map
                 (fn {trname = "", ...} => ()
                   | {trname = trname, trmlno = trmlno, ...}
                    => if CPN'TransitionTable.is_transition trmlno 
		       then 
			   let
                               val internalid = "(\""^trmlno^"\",CPN'instno)";
                           in
                               newpattern("CPN'BEToArc",
					  "(Bind."^pgname^"'"^trname^"(CPN'instno,CPN'b)) = "^
					  "("^internalid^",CPN'BRTT"^trmlno^" CPN'b)\n"
					  
					  )
                           end(*let*)
		       else ())
                 trlist)
          (!CPN'NetCapture.Net);
                 
       if !patterncount>0
       then (* finish the last function in code_temp *)
        (code_storage:= !code_storage^^
                        [!code_temp^
                         "| CPN'BEToArc"^(Int.toString(!partfuncount+1))^" CPN'x=CPN'BEToArc"^
                        (Int.toString(!partfuncount))^" CPN'x;\n"];
         code_temp:="")
       else
        ();
	
	code_storage:= !code_storage^^
         ["fun BEToArc CPN'be=CPN'BEToArc"^
         (Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^
         " CPN'be;\n"]);
     
in    

fun gen_BEToArc() =
(lgen_BEToArc();
 !code_storage);

end(*local*)
end(*struct*);

