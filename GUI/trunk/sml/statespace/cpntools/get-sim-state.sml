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
 * Module:	    GetSimState
 *
 * Description:	    Generates a function that can retrieve the state of the simulator.
 *
 * CPN Tools
 *)
local
    
    open CPN'CodeGenUtils

    (* ---------------------------------------------------- *)
    val first = ref false
		
    fun mk_placeGetter placeMLno instNo = "CPN'place"^placeMLno^".get "^instNo

    fun mk_placeRecordField fieldName colset =
	let
	    val [placeMLno,instNo] = String.tokens (fn CPN'x => CPN'x = (#"P") orelse
								CPN'x = (#"F") orelse 
								CPN'x = (#"'")) fieldName
	    val komma = if (!first) = true
			then (first := false; "")
			else ",\n" 
	in
	    komma ^ fieldName^"  = ref (CPN'MS.sort_ms "^
	    (CPN'CSTable.get_prime_cs colset)^".lt ("^ mk_placeGetter placeMLno instNo ^ "))"
	end			  


    fun mk_timedPlaceRecordField fieldName colset =
	let
	    val [placeMLno,instNo] = String.tokens (fn CPN'x => CPN'x = (#"P") orelse
								CPN'x = (#"F") orelse 
								CPN'x = (#"'")) fieldName
	    val komma = if (!first) = true
			then (first := false; "")
			else ",\n" 
	in
	    komma ^ fieldName^"  = ref (CPN'MS.sort_ms " ^
	    (CPN'CSTable.get_prime_cs colset)^".lt ("^"map Time.col "^
	    "("^ mk_placeGetter placeMLno instNo ^ ")))" ^ ",\n" ^
	    
	    fieldName^"t = ref (CPN'extract_time(Misc.sort (TMS.tlt "^
	    (CPN'CSTable.get_prime_cs colset)^".lt) ("^ mk_placeGetter placeMLno instNo ^ ")))"
	end			  
	    
    fun mk_placeRecord fieldList =
	(first := true; (String.concat (map (fn {fieldname = fieldName, colset} =>
						if CPN'CSTable.is_timed colset 
						then mk_timedPlaceRecordField fieldName colset 
						else mk_placeRecordField      fieldName colset)
					    fieldList))) 
	
	

    fun mk_pageRecord pageName =
	let
	    val ref fieldList = CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, pageName)
	in
	    "ref (CPN'OGLocal"^pageName^"{" ^(mk_placeRecord fieldList) ^ "}),\n"
	end

in

(* ---------------------------------------------------- *)
fun gen_GetSimState () =
    (code_temp:= "fun CPN'GetSimState() = \n" ^ "CPN'OGState{\n";
     map
	 (fn {instlist = instlist,pgmlno = pgmlno,...}
	     =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
		(* check that record is used - otherwise an exception is rasied *)
		map
		    (fn {instno=instno,instmlno=instmlno,...}
			=> code_temp:=(!code_temp)^("pg"^pgmlno^"'"^instno^" = " ^
						    (mk_pageRecord ("pg"^pgmlno))))
		    instlist) handle CPN'AvlTree.ExcAvlLookup => [])
	 (!CPN'NetCapture.Net);

	 (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields,"pgglobfus");
	  code_temp:=(!code_temp)^"pgglobfus=CPN'OGstore_pgglobfus(),\n")
	 handle CPN'AvlTree.ExcAvlLookup =>();
	 
         
	 
	 (*CPN'AvlTree.AvlAppKey(mk_pageRecord, CPN'OGIdsGen.DataRecFields);*)
	 
	 if (CPN'Time.name <> "unit")
	 then
	     code_temp:=(!code_temp)^"creationtime=(!Time.model_time),\n"
	 else (); 
	 [(!code_temp)^
	  "owner=ref(ref(CPN'OGnode("^
	  "{no=0,\n"^
	  "state=ref(CPN'NoRec),\n"^
	  "succlist=ref[],\n"^                               
	  "predlist=ref[],\n"^
	  "calcstat=ref(UnProc)})))}\n"])
    