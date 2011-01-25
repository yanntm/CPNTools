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
 * Module:       OGEnabData
 *
 * Description:  Structure for recording the enabling data
 *
 * CPN Tools
 *)


(* this structure records the enabling data (for immediate trans) like in SAC *)

structure CPN'OGEnabData = struct
val cands = ref ([]:((CPN'TransInst*CPN'GroupBinding) list));
val count = ref 0;
val bindlimit_reached = ref false;
val next_time = ref (!CPN'Time.model_time);
exception TransInstLimitReached;

fun init() = (cands:=[]; count:=0; bindlimit_reached:=false);

local
 val no_bindings = ref 0;
 exception BindStop
in
fun add_cand (_,[]) = ()
  | add_cand (CPN'cand,CPN'bl)
   = (if (!CPN'OGBranching.TransInstLimit<>0)andalso
         (!count = (!CPN'OGBranching.TransInstLimit))
      then raise TransInstLimitReached
      else (no_bindings:= (if !CPN'OGBranching.BindingLimit=0
                          then ~1
                          else !CPN'OGBranching.BindingLimit);
            map (fn CPN'b
                   => if !no_bindings=0
                      then (bindlimit_reached:=true;
                            raise BindStop)
                      else
                       (cands:=(CPN'cand,CPN'b)::(!cands);
                        no_bindings:=(!no_bindings-1))) CPN'bl
             handle BindStop => [];
            count:=(!count+1);
	    next_time := (!CPN'Time.model_time)))
end(*local*);


fun get_cands() = (!cands)

end(*struct*);
