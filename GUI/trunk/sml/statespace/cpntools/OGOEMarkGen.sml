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
 * Module:       OGMarkGen
 *
 * Description:  For generation of the Mark function
 *
 * CPN Tools
 *
 * $Id: OGOEMarkGen.sml,v 1.1 2005/01/05 10:47:00 metch Exp $
 *)

(* structure for generations of the Mark function *)


structure CPN'OGOEMarkGen =
struct

local
    
open CPN'CodeGenUtils
 
fun extractfieldname (#"'"::tl) fieldname
   = fieldname
  | extractfieldname (hd::tl) fieldname
   = extractfieldname tl (fieldname^(Char.toString hd))
  | extractfieldname nil fieldname
   = fieldname

fun  gen_placeinstmark({OGdatarec=OGdatarec, OGdatarecfield=OGdatarecfield,
                        pli=pli,...}:CPN'OGIdsGen.PlaceInstDescr,CPN'csistimed)
   = "{"^OGdatarec^"=ref(CPN'OGLocal"^
     (extractfieldname (explode OGdatarec) "")^
     "{"^OGdatarecfield^"=ref CPN'ms,"^
        (if CPN'csistimed
         then (OGdatarecfield^"t=ref CPN'tl,")
         else "")^"...}),...} "

val firstinst = ref false

in


 fun gen()
   = (code_temp:="structure OEMark = struct\n"^
                 (if (CPN'Time.name <> "unit") then
  	              (* CPN'tmscomb takes a multiset and a time list and combines them *)
                      "fun CPN'tmscomb ([],_) = []\n"^
		      "  | CPN'tmscomb (_,[]) = []\n"^
                      "  | CPN'tmscomb ((CPN'col::CPN'ms),(CPN'ftl::CPN'rtl))\n"^
                      "    = Time.@(CPN'col,CPN'ftl)::(CPN'tmscomb(CPN'ms,CPN'rtl))\n"^
		      (* stripms takes a multiset with a timelist, makes a list 
		       * containing only the time values *)
                      "fun stripms empty=[]\n"^
                      "  | stripms((_,CPN'tl)::ms1)=CPN'tl::(stripms ms1)\n"
                   else "");
                         
       map
         (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
             => CPN'AvlTree.AvlApp
                    (fn {plname="",...} => ()
                      | {plname=plname, plmlno=plmlno,...}
			=> if false (* CPN'PlaceTable.is_kind_fusion plmlno *)
			   then ()
			   else
			       (firstinst:=true;
				map
				    (fn {instno=instno,...}
					=> let
					    val CPN'p=pgname^"'"^plname
					    val CPN'plikey=plmlno^" "^instno
					    val CPN'pliinfo=(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.PlaceInsts,CPN'plikey))
					    val CPN'csistimed= CPN'CSTable.is_timed (#colset CPN'pliinfo)
					in
					    code_temp:= !code_temp^
							(if !firstinst then (firstinst:=false;"\nfun ") else "\n  | ")^
							CPN'p^" ("^instno^" : Inst) (state : CPN'OGrec) =\n"^
							"    let \n      val "^
							"CPN'OGState " ^ (gen_placeinstmark (CPN'pliinfo,CPN'csistimed))^
							" = state\n    in\n"^
							(if CPN'csistimed 
							 then "      CPN'tmscomb(CPN'ms,CPN'tl)"
							 else "      CPN'ms")^
							"\n    end"
					end(*let*))
				    instlist;
				    code_temp:= !code_temp^(if !firstinst then "\nfun " else "\n  | ")^
						pgname^"'"^plname^" _ _ =raise IllegalId\n"
				    )
			       ,
			       pllist))
         (!CPN'NetCapture.Net);       
         
       [!code_temp^"end(*struct*)\n"]);
       
       
  
end(*local*)

end(*struct*)

 
