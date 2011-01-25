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
 * Module:       
 *
 * Description:  For generation of OGE<trmlno> and OGO<trmlno>
 *
 * CPN Tools
 *)

(* structure to generate two functions for each transition                          
 *
 *  OGE<trmlno>: calculates whether the transition is enabled in 
 *               the given instance if so the given candidate is recorded 
 *               in CPN'OGEnabData/TimeEnabData with enabled bindings up 
 *               to the user specified limit                 
 *
 *  OGO<trmlno>: executes the transition with the given binding in the 
 *               given instance 
 *                                                                                   
 *  Furthermore two functions are generated:                                          
 *
 *  CPN'OGCalcEnab which calls OGE for all trans instances                           
 *
 *  CPN'OGExecute  which brances on tri and calls the appropriate OGO                
 *)

structure CPN'OGTransEnabOccGen =
struct

local
    
open CPN'CodeGenUtils;

val firsttri = ref true
	       
fun gen_enabfun (trstr,(pgstr,withcode:bool,withtime, _(*outtimed*))) =
    code_storage:=
    ("fun CPN'OGE"^trstr^"(CPN'inst,CPN'cand)=\n"^
     "CPN'OGEnabData.add_cand(CPN'cand,\n"^
     "map CPN'BT"^
     (CPN'OGBTconvGen.findmlnoforbinding trstr)^"conv\n"^
     "(CPN'transition"^(CPN'OGBTconvGen.findmlnoforbinding trstr)^
     ".CPN'bindings(CPN'inst)))\n")::
    (!code_storage)
            
fun gen_occfun (trstr,(pgstr,withcode:bool, withtime,outtimed))
    = code_storage:=
    ("fun CPN'OGO"^trstr^"(CPN'inst,CPN'BTT"^
     (CPN'OGBTconvGen.findmlnoforbinding trstr)^" CPN'b)=\n"^
     "(CPN'transition"^(CPN'OGBTconvGen.findmlnoforbinding trstr)^
     ".CPN'occfun(CPN'inst,CPN'b,false);\n"^
     "CPN'BRTT"^(CPN'OGBTconvGen.findmlnoforbinding trstr)^
     " (!CPN'BR"^(CPN'OGBTconvGen.findmlnoforbinding trstr)^")) \n")::
     (!code_storage)
             

 fun gen_transfun() =
       (code_temp:= "fun CPN'OGCalcEnab()= (CPN'Sim.reset_scheduler();\n";
       firsttri := true;
	
       map 
        (fn {trlist = trlist, pgno = pgno, instlist = instlist,...}
          => map
               (fn {trmlno = trmlno, trname=trname,...}
                  => if CPN'TransitionTable.is_transition trmlno then
			 if
			     let val (_,_,istimed,_) =
                                     CPN'AvlTree.AvlLookup(CPN'NetCapture.FromTransSeq,trmlno)
			     in not istimed end
			 then
			     map
				 (fn {instmlno=instmlno,instno=instno,...}
				     => let
					 val internalid = "(\""^trmlno^"\","^instno^")"
				     in
					 code_temp:= !code_temp^(if !firsttri then (firsttri := false;"") else ";\n")^
                               ("if CPN'Sim.check_enab"^internalid^
                               " then CPN'OGE"^trmlno^"("^instno^","^internalid^
                               ") else ()")
		                     end(*let*))
				 instlist
			 else
			     []
		     else [])
               trlist)
        (!CPN'NetCapture.Net);


	(if (CPN'Time.name <> "unit") then
	     (code_temp := !code_temp^"; \n (if CPN'OGEnabData.get_cands() = [] andalso \
           \ (#1(CPN'Sim.increase_model_time())) then CPN'OGCalcEnab() else ()));\n")
	     
	 else code_temp:= !code_temp^";\n");
	
       code_storage:=(!code_storage)^^[!code_temp];
       
       patterncount:=0;
       partfuncount:=0;
       code_temp:="";
       code_storage:= !code_storage^^["fun CPN'OGExecute0 _ = raise IllegalId;\n"];
                          
       map
        (fn {trlist = trlist, pgno = pgno, instlist = instlist,...}
           => map
               (fn {trmlno = trmlno, ...}
		   => if CPN'TransitionTable.is_transition trmlno then
			  map
			      (fn {instmlno=instmlno,instno=instno,...}
				  => let
				      val internalid = "(\""^trmlno^"\","^instno^")"
				  in
				      newpattern("CPN'OGExecute",
						 "("^internalid^",CPN'b)=CPN'OGO"^trmlno^
						 "("^instno^",CPN'b)")
				  end(*let*))
			      instlist
		      else [()])
               trlist)
        (!CPN'NetCapture.Net);
       
 
       if !patterncount>0
       then (* finish the last function in code_temp *)
        (code_storage:= !code_storage^^
                        [!code_temp^
                         "|CPN'OGExecute"^(Int.toString(!partfuncount+1))^" CPN'x=CPN'OGExecute"^
                        (Int.toString(!partfuncount))^" CPN'x;\n"];
         code_temp:="")
       else
        ();
        
       code_storage:= !code_storage^^
         ["val CPN'OGExecute=CPN'OGExecute"^
         (Int.toString(!partfuncount+(if !patterncount=0 then 0 else 1)))^";\n"]);


in

fun gen () =
(code_storage:=[];
 CPN'AvlTree.AvlAppKey(gen_enabfun,CPN'NetCapture.FromTransSeq);
 CPN'AvlTree.AvlAppKey(gen_occfun,CPN'NetCapture.FromTransSeq);
 gen_transfun();
 (!code_storage))

end(*local*)
 
end(*struct*)
 
