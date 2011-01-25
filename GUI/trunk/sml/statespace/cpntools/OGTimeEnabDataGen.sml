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
 * Module:       OGTimeEnabDataGen
 *
 * Description:  Structure for recording the enabling data for timed transitions
 *
 * CPN Tools
 *)


CPN'Env.use_string
["structure CPN'OGTimeEnabData=struct\n"^
"val mylasttime="^
   (if ((CPN'Time.name)<>"unit") then "(!CPN'Time.model_time)" else "(():CPN'Time.time)")^";\n"^
"datatype limitmemory=CPN'not_reached|CPN'reached_at of CPN'Time.time;\n"^
"val timecands = ref ([]:(CPN'TransInst list));\n"^
"val bindcands = ref ([]:((CPN'TransInst*CPN'Binding) list));\n"^
"val count = ref 0;\n"^
"val curr_min = ref mylasttime;\n"^
"val trans_inst_limit_occ_at = ref CPN'not_reached;\n"^
"val bind_limit_occ=ref false;\n"^

"fun any_limit()=((!trans_inst_limit_occ_at<>CPN'not_reached)andalso\n"^
                      "(let val CPN'reached_at CPN'limittime= !trans_inst_limit_occ_at\n"^
                       "in CPN'limittime=(!curr_min) end))\n"^
                  "orelse(!bind_limit_occ);\n"^

"fun init() = (timecands:=[];bindcands:=[];count:=0;bind_limit_occ:=false;\n"^
              "curr_min:=mylasttime;trans_inst_limit_occ_at:=CPN'not_reached);\n"^

"fun add_timecand(CPN'cand,CPN't)\n"^
  "= (if not (CPN'Time.leq(CPN't,(!curr_min)))\n"^  (* not leq(a,b) => a>b *)
    "then\n"^ (*ignore this candidate with high enab time *)
      "()\n"^
    "else\n"^
       "if CPN'Time.lt(CPN't,(!curr_min))\n"^
       "then (*new candidate with strictly lower time enabling *)\n"^
         "(timecands:=[CPN'cand]; count:=1; curr_min:=CPN't; trans_inst_limit_occ_at:=CPN'not_reached)\n"^
       "else\n"^(*one more with same enabling time - check if max is reached *)
          "if (!CPN'OGBranching.TransInstLimit<>0)andalso\n"^
             "(!count = (!CPN'OGBranching.TransInstLimit))\n"^
          "then trans_inst_limit_occ_at:=CPN'reached_at CPN't\n"^
          "else (timecands:=CPN'cand::(!timecands);count:=(!count+1)));\n"^

"local\n"^
 "val no_bindings = ref 0;\n"^
 "exception BindStop\n"^
"in\n"^
 "fun add_BE(_,[])=()\n"^
 "|add_BE(CPN'cand,CPN'bl)\n"^
  "=(no_bindings:=(if !CPN'OGBranching.BindingLimit=0\n"^
                 "then ~1\n"^
                 "else !CPN'OGBranching.BindingLimit);\n"^
    "map(fn CPN'b\n"^
         "=> if !no_bindings=0\n"^
            "then (bind_limit_occ:=true;raise BindStop)\n"^
            "else\n"^
                 "(bindcands:=(CPN'cand,CPN'b)::(!bindcands);\n"^
                  "no_bindings:=(!no_bindings+1)))\n"^
           "CPN'bl\n"^
       "handle BindStop=>[];())\n"^       
"end(*local*);\n"^

"fun get_cands() = (!bindcands)\n"^

"end(*struct*);\n",
if  ((CPN'Time.name)<>"unit") then "" else "fun time()=0;"];

