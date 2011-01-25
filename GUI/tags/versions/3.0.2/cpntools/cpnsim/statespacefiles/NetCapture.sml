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
 * Module:       Net capture
 *
 * Description:  Captures relevant net structure and instance info
 *               for easy reference while generating OG code.
 *
 * CPN Tools
 *
 *)

structure CPN'NetCapture = 
struct

type TransSeqDescr = string*bool*bool*bool; (* (pgmlno,withcode,istimed,outtimed) *)
val FromTransSeq = CPN'AvlTree.AvlNew():TransSeqDescr CPN'AvlTree.avltree;
					
(* The following types describe the data about the net description
 * used for OG generation *)
type PlDescr = 
     {plname:string,
      plmlno:string,
      port:bool,
      fusgrid:string option} (* if place kind=fusion 
			      * then fusgrid= (SOME id) of fusion group else NOND *)
     
type TrDescr = 
     {trname:string,
      trmlno:string,
      surrports: string list,
      surrpgglobfus:bool}
     
type InstDescr = 
     {instmlno:string,
      instno:string}
     
type PageDescr = 
     {pllist: PlDescr CPN'AvlTree.avltree,
      trlist:TrDescr list,
      instlist:InstDescr list,
      pgname:string,
      pgno:string,
      pgmlno:string}
     
type NetDescr = 
     PageDescr list

val Net = ref ([]:NetDescr)

local
    (* BuildPlaces takes the relevant information for each place
     * on a page from the PlaceTable in the simulator*)
    fun BuildPlaces CPN'x = 
	let
	    val pldescrs = CPN'AvlTree.AvlNew():PlDescr CPN'AvlTree.avltree
	    fun BuildPlaces' nil = ()
	      | BuildPlaces' (CPN'x::CPN'xs) =
		let
		    val {kind,ext={page,name,...},int} = valOf (CPN'PlaceTable.peek CPN'x)
		    val is_port = (case kind of 
				       CPN'PlaceTable.port _ => true
				     | _ => false)
		    val fusion = (case kind of 
				      CPN'PlaceTable.fusion CPN's => (SOME CPN's)
				    | _ => NONE )  
		in
		    if kind = CPN'PlaceTable.group
			then CPN'debug ("Net Capture ignoring fusion group: "^CPN'x)
		    else 
			CPN'AvlTree.AvlInsert pldescrs
			(CPN'x,{plname = name, plmlno = CPN'x, port = is_port, fusgrid = fusion});
			BuildPlaces' CPN'xs
		end
	in
	    (BuildPlaces' CPN'x; pldescrs)
	end

    (* BuildTransitions takes the relevant information for each
     * transition from the TransitionTable in the simulator *)
    fun BuildTransitions nil = nil
      | BuildTransitions (CPN'x::CPN'xs) = 
	case (CPN'TransitionTable.peek CPN'x) of
	    NONE => raise InternalError "BuildTransitions"
	  | SOME (CPN'TransitionTable.substitution {name,page,...}) => 
	    let
		val pagename = (#name (#page (CPN'PageTable.find page)))
		val _ = CPN'debug ("NetCapture ignoring subst. trans: "
				   ^pagename^"'"^name)
	    in
		BuildTransitions CPN'xs
	    end

	  | SOME (CPN'TransitionTable.transition {page,name,input,output,...}) =>
	    (let
		 val tsurrports =
		     let
			 fun get_ports_input nil = nil
			   | get_ports_input ({place,arcs,no_of_tokens}::CPN'xs) =
			     if CPN'PlaceTable.is_kind_port place 
			     then place::get_ports_input CPN'xs
			     else get_ports_input CPN'xs
			 fun get_ports_output nil = nil
			   | get_ports_output ({place,arcs}::CPN'xs) =
			     if CPN'PlaceTable.is_kind_port place 
			     then place::get_ports_output CPN'xs
			     else get_ports_output CPN'xs
		     in
			 (get_ports_input input)^^(get_ports_output output)
		     end
			 
		 val tsurrpgglobfus =
		     let
			 fun getsurr() = 
			     let
				 fun get_inputs nil = nil
				   | get_inputs ({place,arcs,no_of_tokens}::CPN'xs) =
				     place::get_inputs CPN'xs
				 fun get_outputs nil = nil
				   | get_outputs ({place,arcs}::CPN'xs) =
				     place::get_outputs CPN'xs
			     in
				 (get_inputs input)^^(get_outputs output)
			     end
				 
			 fun fusion_exists nil = false
			   | fusion_exists (place_id::ps) =
			     let
				 val {kind,...} = valOf (CPN'PlaceTable.peek place_id)
			     in
				 case kind of CPN'PlaceTable.fusion _ => true   
					    | CPN'PlaceTable.group => true
					    | _ => (fusion_exists ps)
			     end

		     in
			 fusion_exists(getsurr())
		     end
	     in
		 {trname = name,
		  trmlno = CPN'x,
		  surrports = tsurrports,
		  surrpgglobfus = tsurrpgglobfus} 
		 ::BuildTransitions CPN'xs
	     end)

    fun BuildInsts (CPN'id,0) = nil
      | BuildInsts (CPN'id,num_of_insts) =
	{instmlno = CPN'id, instno = Int.toString num_of_insts}::BuildInsts(CPN'id,num_of_insts - 1)
	
	
    (* BuildPages makes a NetDescr from the information in the
     * PageTable in the simulator *)
    fun BuildPages() = 
	let
	    (* Returns the prefix of the string s that consists of
	     * alphanumeric characters, underscores (_) and primes ('). 
	     * Checks that the first char in the string is a letter. *)
	    fun cut_name CPN's =
		let
		    fun check' nil = nil
		      | check' (CPN'x::CPN'xs) =
			(if (Char.isAlphaNum CPN'x) orelse 
			    (CPN'x=(#"_")) orelse 
			    (CPN'x=(#"'"))
			 then CPN'x::check' CPN'xs
			 else nil)
			
		    fun check nil = raise InternalError "Page without a name in Net Capture"
		      | check (CPN'x::CPN'xs) =
			(if (Char.isAlpha CPN'x)
			 then check' (CPN'x::CPN'xs)
			 else raise InternalError "Page name must start with a character in [a-zA-Z]")
		in
		    String.implode(check (String.explode CPN's))
		end

	    fun BuildPages' nil = nil
	      | BuildPages' ((CPN'id,{page = {name,places,transitions,included,prime},
				  decl,super_pages,sub_pages})::CPN'xs) =
		{pllist = BuildPlaces places,
		 trlist = BuildTransitions transitions,
		 instlist = BuildInsts (CPN'id,CPN'InstTable.get_no_of_inst CPN'id),
		 pgname = cut_name name,
		 pgno = "",
		 pgmlno = CPN'id}
		::(BuildPages' CPN'xs)
	in
	    BuildPages' (CPN'PageTable.list())
	end
	    
in

fun capturenet() = Net := BuildPages()

end (* local *)

fun buildTransSeq() =
    let
	val trans_list = CPN'TransitionTable.list()
	fun build (transid,item) =
	    case item of CPN'TransitionTable.substitution _ => ()
		       | CPN'TransitionTable.transition {page,name,...} =>
			 CPN'AvlTree.AvlInsert FromTransSeq
   					       (transid,(page,true,false,true))	                 
    (* withcode = true
     * istimed = false, outtimed = true
     * The time stuff is not used with the new
     * simulator anyway..
     *)
    in
	map build trans_list
    end

fun exe() = 
    (buildTransSeq();
     capturenet())

(* Check uniqueness of names *)

local
    val NodeNames = CPN'AvlTree.AvlNew() : unit CPN'AvlTree.avltree
    val PageNames = CPN'AvlTree.AvlNew() : unit CPN'AvlTree.avltree
in
fun check_names() = 
    (CPN'AvlTree.AvlReset PageNames;
     map
	 (fn {pllist = pltree,trlist = trlist,pgname = pgname,pgno = pgno,...} =>
	     (if pgname=""
	      then (CPN'debug ("Page #"^pgno^" has no name");
		    raise IllegalName ("Page with no name"))
	      else CPN'AvlTree.AvlInsert PageNames (pgname,())
		   handle CPN'AvlTree.ExcAvlInsert => 
			  (CPN'debug ("Non-unique page name: "^pgname);
			   raise IllegalName ("Non-unique page name: "^pgname));
			  
			  CPN'AvlTree.AvlReset NodeNames;
			  CPN'AvlTree.AvlApp
			      (fn {plname = "", ...} => () (* empty name OK *)
				| {plname = plname, ...} =>
				  CPN'AvlTree.AvlInsert NodeNames (plname,())
				  handle CPN'AvlTree.ExcAvlInsert =>
					 (CPN'debug ("Non-unique place name: "^plname^" on page: "^pgname);
					  raise IllegalName ("Non-unique place name: "^plname^" on page: "^pgname)),
					 pltree);
			      
			      CPN'AvlTree.AvlReset NodeNames;
			      map
				  (fn {trname = "", ...} => () (* empty name OK *)
				    | {trname = trname, ...} =>
				      CPN'AvlTree.AvlInsert NodeNames (trname,())
				      handle CPN'AvlTree.ExcAvlInsert =>
					     (CPN'debug ("Non-unique trans name: "^trname^" on page: "^pgname);
					      raise IllegalName ("Non-unique trans name: "^trname^" on page: "^pgname)))
				  trlist)
	     )
	 (!Net))
    
end (* local *)

    
end (* struct *)