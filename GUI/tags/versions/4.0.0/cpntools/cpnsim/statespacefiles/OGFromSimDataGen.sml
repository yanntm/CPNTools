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
 * Module:       OGFromSimDataGen
 *
 * Description:  structure for generation of the functions for copying the contents of 
 *               the regular CPN simulator structures into the OG structures          
 *
 * CPN Tools
 *)


structure CPN'OGFromSimDataGen =
struct

local
    
open CPN'CodeGenUtils

val first = ref false

fun gen_field {fieldname=fieldname, colset=colset} =
    code_temp := (!code_temp)^
		 let
		     val [plmlno] = String.tokens (fn CPN'x => CPN'x = (#"P") orelse CPN'x = (#"F")) fieldname
		 in
		     ((if !first
		       then (first := false; "")
		       else ",\n")^
		      fieldname^"=CPN'"^colset^"'mss.Insert(CPN'MS.sort_ms "^(CPN'CSTable.get_prime_cs colset)^".lt ("^
		      (if CPN'CSTable.is_timed colset then "map CPN'Time.col " else "")^
		      "(CPN'place"^plmlno^".get CPN'pginst)))"^
		      (if CPN'CSTable.is_timed colset
		       then ",\n"^fieldname^"t="^
			    "let fun CPN'extract_time ((CPN'Time.@(_,CPN't))::CPN'xs) = CPN't::CPN'extract_time CPN'xs \n \
		            \      | CPN'extract_time nil = nil \n \
			    \    val CPN'tl=CPN'extract_time(Misc.sort (TMS.tlt "^(CPN'CSTable.get_prime_cs colset)^".lt) "^		  
                      "((CPN'place"^plmlno^".get CPN'pginst))) \n" ^
                      "val CPN'tl = CPN'TimeEquivalence.compressTime creationtime CPN'tl\n"^
                      "in \n"^
			    "CPN'TimeListsTree.Insert(CPN'TimeListTree,CPN'tl,CPN'OGEncode.TimeList (CPN'tl)) end"
		       else ""))
		 end

fun gen_localstore ("pgglobfus",ref fieldlist)
   = (code_temp:=("fun CPN'OGstore_pgglobfus(creationtime)\n"^
          "= let\n"^
	     "val CPN'pginst = 1 (* Is CPN'pginst always 1 for global fusion set? *)\n"^ (* Does this always work? *)
              "val pgglobfusrec\n"^
                 "=CPN'OGLocalpgglobfus\n{");
          
      first:=true;
      
      map gen_field fieldlist;  
      code_temp:=(!code_temp)^("};\n"^
       "val (newref,_)\n"^
          "= CPN'RecSearchTree.Insert\n"^
             "(CPN'pgglobfus'recs,\n"^
               "pgglobfusrec,\n"^
              "CPN'OGEncode.Localpgglobfus pgglobfusrec)\n"^
       "in newref end;\n");
       
       code_storage:=(!code_temp)::(!code_storage))

  | gen_localstore (recname,ref fieldlist)
  = (code_temp:=("fun CPN'OGstore_"^recname^"(creationtime, CPN'pginst:Inst)\n"^
          "= let\n"^
              "val "^recname^"rec\n"^
                 "=CPN'OGLocal"^recname^"\n{");
          
      first:=true;
      
      map gen_field fieldlist;
        
      code_temp:=(!code_temp)^("};\n"^
       "val (newref,_)\n"^
          "= CPN'RecSearchTree.Insert\n"^
             "(CPN'"^recname^"'recs,\n"^
               recname^"rec,\n"^
              "CPN'OGEncode.Local"^recname^" "^recname^"rec)\n"^
       "in newref end;\n");
       
       code_storage:=(!code_temp)::(!code_storage))

in

fun gen () =

let
 val allOGrecs=CPN'AvlTree.AvlNew(): unit CPN'AvlTree.avltree;
 val _ = map
           (fn {instlist = instlist,pgmlno = pgmlno,...}
              =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
                   (* check that record is used - otherwise an exception is rasied *)
                 map
                  (fn {instno=instno,...}
                     => CPN'AvlTree.AvlInsert allOGrecs("pg"^pgmlno^"'"^instno,()))                       
                  instlist) handle CPN'AvlTree.ExcAvlLookup => [])
           (!CPN'NetCapture.Net);
in
 
 code_storage:=[];
 code_storage2:=[];
  
 CPN'AvlTree.AvlAppKey(gen_localstore, CPN'OGIdsGen.DataRecFields);

 code_temp:="";
 first:=true; 
 
 map
  (fn {trlist = trlist, pgname = pgname, pgno = pgno, instlist = instlist,
       pgmlno = pgmlno,...}
     => map
          (fn {surrports=surrports, surrpgglobfus=surrpgglobfus, trmlno=trmlno, ...}
             => map
                 (fn {instmlno=instmlno,instno=instno}
                    => let
                        val internalid = "(\""^trmlno^"\","^instno^")";
                        val funpostfix = trmlno^"'"^instno;
                        val pgglobfuschng = ref surrpgglobfus;
                        val unchngrecs = CPN'AvlTree.AvlCopy allOGrecs;
                        fun reg_chng "pgglobfus"
                           = pgglobfuschng:=true
                          | reg_chng recname
                           = 
			   CPN'AvlTree.AvlDelete unchngrecs recname
                              handle CPN'AvlTree.ExcAvlDelete =>() (*already removed*)
		    in
                        (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
                          (* check that record is used - otherwise an exception is rasied *)
                         reg_chng("pg"^pgmlno^"'"^instno))
                         handle CPN'AvlTree.ExcAvlLookup => ();
                           
			map
                         (fn portmlid
                             => reg_chng(
                                #OGdatarec
                                 (CPN'AvlTree.AvlLookup
                                  (CPN'OGIdsGen.PlaceInsts,
                                   portmlid^" "^instno))))
                         surrports;

                        code_temp2:=
                         "fun CPN'OGstore_state"^funpostfix^
                          "(srcnoderef as ref(CPN'OGnode{state=ref(CPN'OGState srcrec),...}))\n"^
                          "=let val creationtime = time() in CPN'OGState\n{"; 
                         
                        
                        map
                         (fn {instlist = instlist,pgmlno = pgmlno,...}
                            =>(CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields, "pg"^pgmlno);
                                (* check that record is used - otherwise an exception is rasied *)
                               map
                               (fn {instno=instno,instmlno=instmlno,...}
                                  => code_temp2:=(!code_temp2)^"pg"^pgmlno^"'"^instno^"= "^
                                      ((CPN'AvlTree.AvlLookup(unchngrecs,"pg"^pgmlno^"'"^instno);
                                        "#"^"pg"^pgmlno^"'"^instno^" srcrec,\n")
                                        handle CPN'AvlTree.ExcAvlLookup
                                          =>"CPN'OGstore_pg"^pgmlno^"(creationtime, "^instno^"),\n"))
                               instlist) handle CPN'AvlTree.ExcAvlLookup => [])
                         (!CPN'NetCapture.Net);
                          
                                               
                        (CPN'AvlTree.AvlLookup(CPN'OGIdsGen.DataRecFields,"pgglobfus");
                         if !pgglobfuschng
                         then code_temp2:=(!code_temp2)^
                              "pgglobfus= CPN'OGstore_pgglobfus(creationtime),\n"
                         else code_temp2:=(!code_temp2)^"pgglobfus= #pgglobfus srcrec,\n")
                        handle CPN'AvlTree.ExcAvlLookup =>();
                        
                        if (CPN'Time.name <> "unit")
                        then
                         code_temp2:=(!code_temp2)^"creationtime = creationtime,\n"
                        else
                         ();
             
                        code_temp2:=(!code_temp2)^"owner = ref srcnoderef} end;\n";

                        code_storage2:=(!code_temp2)::(!code_storage2);
                        
                        code_temp:=(!code_temp)^(
                         (if !first then (first:=false;"fun ") else "|")^
                         "CPN'OGstore_state(srcnoderef,"^internalid^")="^
                         "CPN'OGstore_state"^funpostfix^" srcnoderef\n")
                                            
			           end(*let*))
                 instlist)
          trlist)
 (!CPN'NetCapture.Net);
 
 
 code_temp:= (!code_temp)^";\n";
  
 !code_storage^^(!code_storage2)^^[!code_temp]
 
end (*let*)
  
end(*local*)

end(*struct*);

