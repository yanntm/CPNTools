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

fun gen_st_OEMark()
  = let
      val CPN'store = ref [] : string list ref;
	  fun CPN'app CPN'st = CPN'store := CPN'st:: (!CPN'store);
  in (CPN'app ("structure st_OEMark=struct\n"^
               "val format=ref(fn(\"\",\"\")=>\"\");\n");
      map
	  (fn {pllist, pgname, instlist = CPN'hdinst::_,...}
	      => CPN'AvlTree.AvlApp
		     (fn {plname="",...} => ()
		       | {plname, plmlno,...}
			 => 
			 let
			     val CPN'p=pgname^"'"^plname
			     val CPN'plikey=plmlno^" "^(#instno CPN'hdinst)
			     val CPN'pliinfo=(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.PlaceInsts,CPN'plikey))
			     val CPN'colset= (#colset CPN'pliinfo)
			     val CPN'csistimed= CPN'CSTable.is_timed CPN'colset 
			     val CPN'primecol= CPN'CSTable.get_prime_cs CPN'colset
			 in
			     CPN'app 
				 ("fun "^CPN'p
				  ^"(CPN'i:Inst) CPN'n=\n"^"!OGSet.stringrepmarkref(!OGSet.stringreppiref(\""
				  ^pgname^"\",\""^plname^"\",Int.toString(CPN'i)),"
				  ^CPN'primecol^".mkstr_"
				  ^"ms "
				  ^(if CPN'csistimed 
				    then "(CPN'TMS.ms(OEMark."^CPN'p^" CPN'i CPN'n)))"
				    else "(OEMark."^CPN'p^" CPN'i CPN'n))"))
			 end,
			 pllist))
	  (!CPN'NetCapture.Net);       
	  CPN'app ("end(*struct*);\n");
	  (rev (!CPN'store)))
  end
      
      