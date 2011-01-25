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
 * Module:       OGBTconvGen
 *
 * Description:  Binding type conversion functions
 *
 * CPN Tools
 *)


(* this structure generates the conversion functions for simulator binding types    
 * to the Binding type in the OG structures and vice versa, one for each transition 
 * Info on use of variables for a transition is retrieved through the glue 
 *)

structure CPN'OGBTconvGen = 
struct

type varlisttype = string list
val varlist = ref([]:varlisttype)
val varlists = CPN'AvlTree.AvlNew() :
	       {mlnos:(string list) ref, vars:varlisttype, BTT_st: string} CPN'AvlTree.avltree
     

local 
    open CPN'CodeGenUtils

    exception mlnofound
    val mymlno = ref ""
    val NoOfVarsToEncode = ref 2;
    val firstBTT = ref true	 
		  
    fun GenBTconv trmlno
      = code_storage:=("fun CPN'BT"^trmlno^"conv(CPN'b:CPN'BT"^trmlno^")"^
		       "=CPN'BTT"^trmlno^" CPN'b;\n")::(!code_storage);
 
    fun st_varlist [] = ""
      | st_varlist (name::CPN'tl) = name^"\n"^(st_varlist CPN'tl)
				    
    fun varlistinsert (CPN'transmlno,CPN'varlist,CPN'BTT_st) =
	let
	    val CPN'key = CPN'transmlno^(st_varlist CPN'varlist)
	in
	    CPN'AvlTree.AvlInsert 
		varlists
		(CPN'key,{mlnos=ref [CPN'transmlno], vars=CPN'varlist, BTT_st=CPN'BTT_st})
		handle CPN'AvlTree.ExcAvlInsert =>
		       let
			   val CPN'mlnosref = #mlnos(CPN'AvlTree.AvlLookup(varlists,CPN'key))
		       in
			   CPN'mlnosref:=CPN'transmlno::(!CPN'mlnosref)
		       end
	end
	    
    local 
	fun buildvarpatterns (name::CPN'tl,intpat,extpat)
	  = buildvarpatterns(CPN'tl, 
                             intpat^name^"= CPN'"^name^(if CPN'tl<>nil then ",\n" else ""),
                             extpat^name^"= CPN'"^name^(if CPN'tl<>nil then ",\n" else ""))
	  | buildvarpatterns (nil,intpat,extpat)=(intpat,extpat) 
    in
    
    fun getvarpatterns() = 
	let 
	    val (intpat,extpat)=buildvarpatterns(!varlist,"{","{")
	in
	    (intpat^"}",extpat^"}")
	end
    end 
    
    local
	fun buildvartype (name::tl,typestr) = 
	    buildvartype(tl,typestr^name^": "^
			    (#cs(CPN'VarTable.find name))^
			    (if tl<>nil then ",\n" else ""))
	  | buildvartype (nil,typestr)=typestr
    in
    
    (* example of typestr {n: Count,r1: Result,r2: Result} *)
    fun getvartype() = buildvartype(!varlist,"{") ^"}" 
	handle Option => raise InternalError "OGBTconvGen - var with no type"
    end 

    fun TakeSomeVars (hdvar::tlvars) count =
	if count>0
	then
	    (if (foldr (fn (CPN'x,CPN'y) => ((hdvar = CPN'x) orelse CPN'y)) false (#msvar(CPN'CSTable.find(#cs(CPN'VarTable.find hdvar)))))
	     then (* hdvar is a msvar *)
		 ("^\" \"^(let val CPN'vv = "^hdvar^" in ")^
		 (CPN'CSTable.get_prime_cs (#cs(CPN'VarTable.find hdvar)))^".mkstr_ms CPN'vv end)\n"
	     else (* hdvar is not a msvar *)      
		 ("^\" \"^(let val CPN'vv = "^hdvar^" in ")^
		 (CPN'CSTable.get_prime_cs (#cs(CPN'VarTable.find hdvar)))^".mkstr CPN'vv end)\n"^
		 (TakeSomeVars tlvars (count-1)))
	else
	    ""
      | TakeSomeVars [] _ = "";


    fun genvarstrings (hdvar::tlvars) = 
	(if (foldr (fn (CPN'x,CPN'y) => ((hdvar = CPN'x) orelse CPN'y)) false (#msvar(CPN'CSTable.find(#cs(CPN'VarTable.find hdvar)))))
	 then
	     ("\""^hdvar^"=\"^("^(CPN'CSTable.get_prime_cs (#cs(CPN'VarTable.find hdvar)))^".mkstr_ms "^hdvar^")"^
	      (if length tlvars>0 then "^\",\"^\n" else ""))
	 else
	     ("\""^hdvar^"=\"^("^(CPN'CSTable.get_prime_cs (#cs(CPN'VarTable.find hdvar)))^".mkstr "^hdvar^")"^
	      (if length tlvars>0 then "^\",\"^\n" else ""))^
	     (genvarstrings tlvars))
      | genvarstrings [] = ""	

    fun create_bindingtype_st trmlno = 
	"{"^(concat(tl(foldr (fn (CPN'v,CPN'sl) => 
				 ","::CPN'v::":"::
				 (#cs (CPN'VarTable.find CPN'v))::CPN'sl) 
			     ["","}"] 
			     (CPN'TransitionTable.get_all_vars trmlno))))
in

fun gen_grbinding () = 
    ((* generate CPN'GroupBinding - one entry for each varlist, 
      * use MLno of head of list 
      * In this data type there is one constructor for each 
      * transition, and the constructor is a function that takes one
      * or more arguments: 1 argument for each binding group for the
      * transition, and 1 argument for each free variable. 
      * Variables bound in code segments are ignored here. *)
	 firstBTT := true;
	 code_temp := "datatype CPN'GroupBinding = \n";
	 CPN'AvlTree.AvlApp
	     (fn {mlnos = ref(CPN'onemlno::_),...} =>
		 code_temp := !code_temp^
			      (if !firstBTT then (firstBTT := false; "") else "|")^
			      "CPN'BTT"^CPN'onemlno^" of CPN'BT"^CPN'onemlno^"\n",
	      varlists);
	     [!code_temp ^ (if !firstBTT then "" else "|")^"CPN'BTT000000;\n"])

fun gen_binding () = 
    (map (fn {trlist = trlist, ...} =>
	     map (fn {trmlno = trmlno, ...} =>
		     (varlist:=[];
		      if CPN'TransitionTable.is_transition trmlno then
			  varlistinsert
			      (trmlno,
			       (CPN'TransitionTable.get_all_vars trmlno),
			       create_bindingtype_st trmlno) else ()))
		 trlist)
	 (!CPN'NetCapture.Net);
	 
	 (* clean up *)
	 varlist := [];
	 
	 (* generate CPN'Binding - one entry for each varlist, 
	  * use MLno of head of list 
	  * In this data type there is one constructor for each 
	  * transition, and the constructor is a function that takes
	  * a record specifying a binding of _all_ of the variables
	  * of the transition *)
	 firstBTT := true;
	 code_temp := "datatype CPN'Binding = \n";
	 CPN'AvlTree.AvlApp
	     (fn {mlnos = ref(CPN'onemlno::_),...} =>
		 code_temp := !code_temp^
			      (if !firstBTT then (firstBTT := false; "") else "|")^
			      "CPN'BRTT"^CPN'onemlno^" of CPN'BRT"^CPN'onemlno^"\n",
	      varlists);
	     [!code_temp^(if !firstBTT then "" else "|")^"CPN'BRTT000000;\n"])

fun gen_conv() =  
    (code_storage:=[];
     code_temp:="";
     
     (* generate a conversion fun for each varlist, use MLno of head of list *)
     CPN'AvlTree.AvlApp
	 (fn {mlnos=ref(CPN'onemlno::_),...}
	     => GenBTconv CPN'onemlno,
	  varlists);
	 
	 (* return resulting code *)   
	 (!code_storage))

fun gen_encode() = 
    ( patterncount:=0;
      partfuncount:=0;
      code_temp:="";
      code_storage:= ["fun CPN'OGEncodeBinds0 _ = raise IllegalId;\n"];
      
      CPN'AvlTree.AvlApp
	  (fn {mlnos=ref(CPN'onemlno::_),vars=vars,BTT_st,...}
              => newpattern("CPN'OGEncodeBinds",
			    "(CPN'BRTT"^CPN'onemlno^" "^BTT_st^")"^
			    " =\""^CPN'onemlno^"\""^(TakeSomeVars vars (!NoOfVarsToEncode))),
           varlists);
	  
	  newpattern("CPN'OGEncodeBinds","CPN'BRTT000000=\"\"\n");
	  
	  if !patterncount>0
	  then 
              (code_storage:= !code_storage^^[!code_temp^
			"|CPN'OGEncodeBinds"^(Int.toString(!partfuncount+1))^" CPN'x=CPN'OGEncodeBinds"^
			(Int.toString(!partfuncount))^" CPN'x;\n"];
	       code_temp:="")
	  else
              ();
              
	      !code_storage^^
			["val CPN'OGEncodeBinds=CPN'OGEncodeBinds"^
			(Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^";\n"]);
    
fun gen_st_binding() = 
    (code_storage := nil;
     CPN'AvlTree.AvlApp
	 (fn {mlnos = ref(CPN'onemlno::_), vars = vars,BTT_st = BTT_st} =>
	     (varlist := vars;
	      let
		  val (_, CPN'extpat) = getvarpatterns()
	      in
		  code_storage :=
		  ("fun CPN'st_binding'"^CPN'onemlno^BTT_st^"=\n"^
                   (if vars=[]
                    then "\"{}\""
                    else "\"{\"^"^(genvarstrings vars)^"^\"}\";\n"))
                  ::(!code_storage)
	      end),
	     varlists);
	 !code_storage);
    
(* below three functions to acces info on var list canonical forms based on mlnos *)        
		       
fun findmlnoforbinding CPN'transmlno
  =(CPN'AvlTree.AvlApp
        (fn {mlnos=ref(mlnoslist as (firstmlno::_)),...}
            => if ListUtils.mem mlnoslist CPN'transmlno
               then (mymlno:=firstmlno; raise mlnofound)
               else (),
         varlists) handle mlnofound => ();
    !mymlno)

end (* local *)

end (* struct *)
