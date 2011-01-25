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
 * Module:       For generation of the OESetMark function
 *
 * Description:  Design/CPN OG Tool
 *
 * Created by:   Lars Kristensen (kris@daimi.aau.dk)   
 *
 * Date:         12/07/2000   
 *
 * Design/CPN (tm)  Copyright (c) University of Aarhus, Denmark 1998
 *)

(* $Source: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGSetMarkGen.sml,v $

$Log: OGSetMarkGen.sml,v $
Revision 1.1  2005/01/05 10:47:00  metch
*** empty log message ***

Revision 1.1.1.1  2004/06/23 07:52:30  coast


Revision 1.1  2004/05/10 12:23:12  metch
*** empty log message ***

Revision 1.1.2.1  2000/07/13 13:41:24  kris
Initial revision


*)

val rcsid = "$Header: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGSetMarkGen.sml,v 1.1 2005/01/05 10:47:00 metch Exp $";

(* structure for generations of the OESetMark function *)


structure CPN'OGSetMarkGen =
struct

local
    
open CPN'CodeGenUtils;
 
fun extractfieldname (#"'"::tl) fieldname
   = fieldname
  | extractfieldname (hd::tl) fieldname
   = extractfieldname tl (fieldname^(Char.toString hd))
  | extractfieldname nil fieldname
   = fieldname;


fun  gen_placeinstmark({OGdatarec=OGdatarec, OGdatarecfield=OGdatarecfield,
                        pli=pli,...}:CPN'OGIdsGen.PlaceInstDescr,CPN'csistimed)
   = 
    "{"^OGdatarec^"=ref(CPN'OGLocal"^
     (extractfieldname (explode OGdatarec) "")^
     "{"^OGdatarecfield^"= CPN'oldms,"^
        (if CPN'csistimed
         then (OGdatarecfield^"t = CPN'tl,")
         else "")^"...}),...}\n";

(* "(#"^OGdatarecfield^" (#"^OGdatarec^" CPN'n)) := CPN'ms"*)

val firstinst = ref false;

in


 fun gen()
    = (code_temp:="structure OESetMark=struct\n"^
                  (if (CPN'Time.name <> "unit") 
		   then "fun striptl [] = empty\n"^
			"| striptl (Time.@(CPN'col,CPN'ftl)::tms1)="^
			"CPN'col::(striptl tms1);\n"^
			
			"fun stripms [] = []\n"^
			"  | stripms(Time.@(_,CPN'tl)::ms1)=CPN'tl::(stripms ms1)\n"
(*
			"fun stripms tempty=[]\n"^
			"|stripms((_,_,CPN'tl)!!!ms1)=CPN'tl^^(stripms ms1);\n"
	*)		
                   else "");
                         
       map
         (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
            => CPN'AvlTree.AvlApp
                 (fn {plname="",...} => ()
                   | {plname=plname, plmlno,...}
		            => (firstinst:=true;
		                map
		                (fn {instno=instno,instmlno}
		                   => let
		                       val CPN'p=pgname^"'"^plname
		                       val CPN'plikey=plmlno^" "^instno
		                       val CPN'pliinfo=(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.PlaceInsts,CPN'plikey))
				       val CPN'csistimed= CPN'CSTable.is_timed (#colset CPN'pliinfo)
		                   in
		                         code_temp:= !code_temp^
		                          (if !firstinst then (firstinst:=false;"fun ") else "\n | ")^
		                          CPN'p^"("^instno^":Inst) (CPN'n:CPN'OGrec) CPN'newms =\n"^"let val "^
		                          "CPN'OGState "^(gen_placeinstmark (CPN'pliinfo,CPN'csistimed))^
		                          "= CPN'n in \n "^
		                            (if CPN'csistimed 
		                             then "(CPN'oldms := striptl CPN'newms;\n"^ 
						  " CPN'tl := stripms CPN'newms;\n"
		                             else "(CPN'oldms := CPN'newms;\n ")
		                            ^"()) \n end"
		                       end(*let*))
		                   instlist;
		                   code_temp:= !code_temp^(if !firstinst then "fun " else "\n | ")^
		                                pgname^"'"^plname^" _ _ _ =raise IllegalId;\n\n"
		                  ),
		                 pllist))
          (!CPN'NetCapture.Net);       
        
       [!code_temp^"end(*struct*);\n"]);
       
end(*local*)

end(*struct*);

 