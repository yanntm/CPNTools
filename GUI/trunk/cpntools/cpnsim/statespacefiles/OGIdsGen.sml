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
 * Module:        OGIdsGen.sml
 *
 * Description:   CPN Tools OG Tool
 * 
 * CPN Tools
 *
 *)

structure CPN'OGIdsGen = 
struct

datatype plidescr = assignedport | unassignedport | nonport
						    
type PlaceInstDescr =
     {simplace: string, siminst: string, OGdatarec: string, OGdatarecfield:string,
      pli:string, plitype:plidescr, colset:string}
(* e.g."(#P3 CPN'PS147)" "pg22'7" "#P3" "[3,7,14]"  "false" "Slaves" *)

(* search tree to keep detailed place instance data for the code generation 
 * key in the search tree is mlid-of-place + instnum in string form *) 
val PlaceInsts = CPN'AvlTree.AvlNew():PlaceInstDescr CPN'AvlTree.avltree;

(* search tree to keep all record field entries for datarecs 
 * key in the search tree is data record name e.g."pgglobfus" or "pg22" 
 * for one entry the tree holds fieldname and color set *)
val DataRecFields = CPN'AvlTree.AvlNew():
                     (({fieldname:string,colset:string} list) ref) CPN'AvlTree.avltree; 

val FirstItem = ref true
		    
local
    
    open CPN'CodeGenUtils

    (* (plmlno, port, fusgrid, pgno, pgmlno, instno, instmlno, fullid, colset) *)
    type plinstdescr = string*bool*string option*string*string*string*string*string*string;

    val portinstances = ref ([]:plinstdescr list) (* temp list for post processing *)

    fun store_datarecfield(recname,fieldname,colset) =
	CPN'AvlTree.AvlInsert DataRecFields (recname, ref [{fieldname=fieldname, colset=colset}])
	handle CPN'AvlTree.ExcAvlInsert => (* recname was there => add fieldname to the list *)
	       let
		   val fieldsref = (CPN'AvlTree.AvlLookup(DataRecFields,recname))
               in
		   if ListUtils.mem (!fieldsref) {fieldname=fieldname,colset=colset}
		   then (* was already in list *)
                       ()
		   else
                       fieldsref:={fieldname=fieldname,colset=colset}::(!fieldsref)
               end(*let*)


    (* record the port place instance in PlaceInst *) 
    fun store_portinst (plmlno,_,_,pgno,pgmlno,instno,instmlno,fullid,colset) =	
	CPN'AvlTree.AvlInsert PlaceInsts
			      ((plmlno^" "^instno),
			      let
				  val inst_conns = CPN'InstTable.get_inst_cons((plmlno,valOf (Int.fromString instno)),nil)
				  val (assigned,socketid,socketinst) = 
				      let 
					  fun walk nil = (false,"","")
					    | walk ((socketid,i2)::CPN'xs) = 
					      if (socketid <> plmlno) orelse (i2 <> valOf (Int.fromString instno))
					      then 
						   (if CPN'PlaceTable.is_kind_port socketid then walk CPN'xs else (true,socketid,(Int.toString i2)))  
					      else walk CPN'xs
				      in
					  walk inst_conns
				      end handle Option => raise InternalError "Instno not an integer in OGIdsGen - store_portinst"
			      in
				  if assigned 
				  then  (* assigned port place *)
				      let
					  val {OGdatarec=topOGdatarec, OGdatarecfield=topOGdatarecfield, ...}
					      = CPN'AvlTree.AvlLookup
						    (PlaceInsts,(socketid^" "^socketinst))
				      in
					  {simplace="CPN'place"^plmlno,
					   siminst=instno,
					   OGdatarec=topOGdatarec,
					   OGdatarecfield=topOGdatarecfield,
					   pli=fullid,
					   plitype=assignedport,
					   colset=colset}
					  
				      end(*let*)
				  else (*unassigned port place => record field is needed for pg *)
				      (store_datarecfield("pg"^pgmlno,"PP"^plmlno^"'"^instno,colset);
				       
				       {simplace="CPN'place"^plmlno,
					siminst=instno,
					OGdatarec="pg"^pgmlno^"'"^instno,
					OGdatarecfield="PP"^plmlno^"'"^instno,
					pli=fullid,
					plitype=unassignedport,
					colset=colset})
			      end(*let*) handle Option => raise InternalError "Instno not an integer in OGIdsGen - store_portinst"
				  )
    
    (* record the place instance in PlaceInst or if port save it for later processing *)           
    fun store_pli (plidescr as (plmlno,port,fusgrid,pgno,pgmlno,instno,instmlno,fullid,colset)) =
	if port
	then (* save it instead for later processing, when all other pli has been processed *) 
	    portinstances:= plidescr::(!portinstances)
	else
	    CPN'AvlTree.AvlInsert PlaceInsts
				  ((plmlno^" "^instno),
				   if (CPN'PlaceTable.is_kind_place plmlno)
				   then (*non-fused, non-port place*)
				       (store_datarecfield("pg"^pgmlno,"P"^plmlno,colset);
					
					{simplace="CPN'place"^plmlno,
					 siminst=instno,
					 OGdatarec="pg"^pgmlno^"'"^instno,
					 OGdatarecfield="P"^plmlno,
					 pli=fullid,
					 plitype=nonport,
					 colset=colset})
				       
				   else (*page or global fus*)
				       (store_datarecfield("pgglobfus","F"^valOf(fusgrid),colset);
					
					{simplace="CPN'place"^(valOf fusgrid),
					 siminst=instno,
					 OGdatarec="pgglobfus",
					 OGdatarecfield="F"^(valOf fusgrid),
					 pli=fullid,
					 plitype=nonport,
					 colset=colset}
					)
				       )
				  
		
    fun lgen_TI() =
	
	(code_temp := "\nstructure TI = struct\n"^
		      "datatype TransInst = \n";
	 FirstItem:=true;
	 map (fn {trlist = trlist, pgname = pgname, ...} => 
		 map (fn {trname = "", ...} => ()
		       | {trname = trname, ...} =>
			 code_temp:= !code_temp^
				     (if !FirstItem
				      then (FirstItem:=false;"")
				      else "|")^pgname^"'"^trname^" of Inst\n")
		     trlist)
	     (!CPN'NetCapture.Net);

	 code_temp:= !code_temp^(if !FirstItem then "" else "|")^
                     "unnamedTI;\n"^
                     "val All:(TransInst list)= [\n";

	 FirstItem:=true;

	 map
          (fn {trlist = trlist, pgname = pgname, instlist = instlist,...} => 
	      map (fn {trname = "", ...} => []
                    | {trname = trname, ...} => 
		      map (fn {instno=instno,...} => 
			      let
                                  val CPN'ti=pgname^"'"^trname^" "^instno
                              in
                                  code_temp:= !code_temp^
					      (if !FirstItem
					       then (FirstItem:=false; "")
					       else ",")^
					      CPN'ti^"\n"
                              end(*let*))
                          instlist)
                  trlist)
          (!CPN'NetCapture.Net);            
          
	  code_temp:= !code_temp^"]"^
                      "end(*struct*);\n"
    )
	
    fun lgen_stTI() = 
	(patterncount:=0;
	 partfuncount:=0;
	 code_temp:="";
	 code_storage:=["fun st_TI0 _ = raise IllegalId; \n"];
	 
	 map
	     (fn {trlist = trlist, pgname = pgname, instlist = instlist,...}
		 => map
			(fn {trname = "", ...} => []
			  | {trname = trname, ...}
			    => map
				   (fn {instno=instno,...} (* pattern match on specific instno *)
				       => let               (* in order to detect illegal ids   *)
					   val CPN'ti=pgname^"'"^trname^" "^instno
				       in
					   newpattern("st_TI","(TI."^ CPN'ti^")= (!OGSet.stringreptiref)(\""^pgname^"\",\""^trname^"\",\""^instno^"\")")
				       end(*let*))
				   instlist)
			trlist)
             (!CPN'NetCapture.Net);
             
	     newpattern("st_TI","(TI.unnamedTI)=\"*** TI without a name ***\"");
	     
	     if !patterncount>0
	     then (* finish the last function in code_temp *)
		 (code_storage:= 
		  !code_storage^^[!code_temp^
				  "|st_TI"^(Int.toString(!partfuncount+1))^" CPN'x=st_TI"^
				  (Int.toString(!partfuncount))^" CPN'x;\n"];
		  code_temp:="")
	     else
		 ();
		 code_storage:= 
		 !code_storage^^["val st_TI=st_TI"^
				 (Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^";\n",
				 "fun mkst_TI CPN'ti=\"TI.\"^(st_TI CPN'ti);\n"]
		 )
	
    fun lgen_PI() = 
	(CPN'AvlTree.AvlReset PlaceInsts;
	 CPN'AvlTree.AvlReset DataRecFields;
	 portinstances:=[];
	 
	 code_temp:="structure PI=struct\n"^
                    "datatype PlaceInst=\n";
                    
	 FirstItem:=true;
	 
	 map (fn {pllist = pllist, pgname = pgname, pgno = pgno, instlist = instlist,
		  pgmlno = pgmlno,...} =>
		 CPN'AvlTree.AvlAppKey
		     (fn (plmlnostr,{plname=plname, plmlno=plmlno, port=port, fusgrid = fusgrid}) =>
			 (*if CPN'PlaceTable.is_kind_group plmlno then () else *)
			 (let
			      fun StripWhiteSpace CPN'st =
				  let
				      fun strip (#" "::CPN'r) = strip CPN'r(* space *)
					| strip (#"\009"::CPN'r) = strip CPN'r (* tab *)
					| strip (#"\013"::CPN'r) = strip CPN'r (* cr *)
					| strip (#"\010"::CPN'r) = strip CPN'r (* nl *)
					| strip stlst = stlst
				  in
				      implode (rev (strip (rev (strip (explode CPN'st)))))
				  end
			      val colset = StripWhiteSpace (#cs(CPN'PlaceTable.get_ext plmlnostr))
			  in
			      map 
				  (fn {instmlno=instmlno,instno=instno} => 
				      store_pli(plmlno,port,fusgrid,pgno,pgmlno,
						instno,instmlno,
						pgname^"'"^plname^" "^instno,
						colset))
				  instlist
			  end(*let*);
			  
			  
			  if plname=""
			  then ()	
			  else code_temp:= !code_temp^
					   (if !FirstItem
					    then (FirstItem:=false;"")
					    else "|")^
					   pgname^"'"^plname^" of Inst\n"
			       ),
			 pllist))
             (!CPN'NetCapture.Net);       
             
	     code_temp:= !code_temp^(if !FirstItem then "" else "|")^
			 "unnamedPI;\n"^
			 "val All:(PlaceInst list)= [\n";
			 
			 FirstItem:=true;
			 
			 map
			     (fn {pllist = pllist, pgname = pgname, instlist = instlist,...} =>
				 CPN'AvlTree.AvlApp
				     (fn {plname="",...} => []
				       | {plname=plname, plmlno=plmlno,...} =>
					 if CPN'PlaceTable.is_kind_group plmlno then [] else
					 map
					     (fn {instno=instno,...} =>
						 let
						     val CPN'pi=pgname^"'"^plname^" "^instno
						 in
						     code_temp:= !code_temp^
								 (if !FirstItem
								  then (FirstItem:=false; "")
								  else ",")^
								 CPN'pi^"\n"
						 end(*let*))
					     instlist,
					     pllist))
			     (!CPN'NetCapture.Net);
			     
			     code_temp:= !code_temp^"]"^
					 "end(*struct*);\n";
					     
					 map store_portinst (!portinstances);
					 portinstances:=[])
	
    fun lgen_stPI() = 
	(patterncount:=0;
	 partfuncount:= 0;
	 code_temp:="";
	 code_storage:= ["fun st_PI0 _ = raise IllegalId;\n"];
	 
	 map
             (fn {pllist = pllist, pgname = pgname, instlist = instlist,...} =>
		 CPN'AvlTree.AvlApp
		     (fn {plname="",...} => []
		       | {plname=plname, plmlno=plmlno,...} =>
			 map
			     (fn {instno=instno,...} => (* pattern match on specific instno in
							 * order to detect illegal ids *)
				 let  
				     
				     val CPN'pi=pgname^"'"^plname^" "^instno
				 in
				     newpattern("st_PI","(PI."^ CPN'pi^")= (!OGSet.stringreppiref)(\""^pgname^"\",\""^plname^"\",\""^instno^"\")")
				 end(*let*))
			     instlist,
			     pllist))
             (!CPN'NetCapture.Net);
	  
	     newpattern("st_PI","(PI.unnamedPI)=\"*** PI without a name ***\"");
	     
	     if !patterncount>0
	     then (* finish the last function in code_temp *)
		 (code_storage:= !code_storage 
				     ^^ [!code_temp^
					 "|st_PI"^(Int.toString(!partfuncount+1))^" CPN'x=st_PI"^
					 (Int.toString(!partfuncount))^" CPN'x;\n"];
		  code_temp:="")
	     else
		 ();
		 
		 code_storage:= !code_storage
				    ^^ ["val st_PI =st_PI"^
					(Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^";\n",
					"fun mkst_PI CPN'pi=\"PI.\"^(st_PI CPN'pi);\n"])
	
in

fun gen_TI() =
    (lgen_TI();
     [!code_temp])
    
fun gen_stTI () =
    (lgen_stTI();
     !code_storage)
    
fun gen_PI () =
    (lgen_PI();
     [!code_temp])
    
fun gen_stPI () =
    (lgen_stPI();
     !code_storage)
    
end (* local *)
end (* struct *)
