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
 * Module:       CodeGenUtils
 *
 * Description:  Code generation utilities
 *
 * CPN Tools
 *
 *)

structure CPN'CodeGenUtils =
struct

val maxfunpatterns = ref 40 (* a constant >0, which tells approx. how many
			     * pattern matches to include in a generated function
			     * - in this context e.g. the functions 
			     * PLid,PLIid,TRid,TRIid *)

val patterncount = ref 0
val partfuncount = ref 0    (* to count function postfixes *)

val code_storage = ref ([]:string list)
(* an extra one used in certain other modules *) 
val code_storage2 = ref ([]:string list)
		    
		    
val code_temp = ref ""
(* an extra one used in certain other modules *)
val code_temp2 = ref ""

fun newpattern (funname,patternetc) = 
    let
	val CPN'res = (if !patterncount=0 then "fun " else "|")^
                  funname^(Int.toString(!partfuncount+1))^" "^patternetc^"\n"
    in
	if !patterncount>= !maxfunpatterns
	then (* generate underscore pattern to call prev. fun + empty code_temp *)
            (* and add contents to code_storage *)
	    (patterncount:=0;
             code_storage:= 
	     !code_storage^^
			  [!code_temp^CPN'res^
			   "|"^funname^(Int.toString(!partfuncount+1))^" CPN'x="^
			   funname^(Int.toString(!partfuncount))^" CPN'x;\n"];
			  CPN'inc partfuncount;
			  code_temp:="")
	else
	    (CPN'inc patterncount;
             code_temp:= !code_temp^CPN'res)
    end(*let*)

fun newpattern_2param (funname,patternetc) = 
    let
	val CPN'res = (if !patterncount=0 then "fun " else "|")^
                  funname^(Int.toString(!partfuncount+1))^" "^patternetc^"\n"
    in
	if !patterncount>= !maxfunpatterns
	then (* generate underscore pattern to call prev. fun + empty code_temp *)
            (* and add contents to code_storage *)
	    (patterncount:=0;
             code_storage:= 
	     !code_storage^^[!code_temp^CPN'res^
		"|"^funname^(Int.toString(!partfuncount+1))^" CPN'x1 CPN'x2="^
		funname^(Int.toString(!partfuncount))^" CPN'x1 CPN'x2;\n"];
	     partfuncount := !partfuncount + 1;
	     code_temp:="")
	else
	    (patterncount := !patterncount + 1;
             code_temp:= !code_temp^CPN'res)
    end(*let*);
    

end(*struct*);
