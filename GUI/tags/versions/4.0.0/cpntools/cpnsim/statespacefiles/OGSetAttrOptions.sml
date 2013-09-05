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
 * Module:       OGSetAttrOptions
 *
 * Description:  Functions for settings attributes and options
 *
 * CPN Tools
 *)

structure OGSet = struct

    val StandardInspectionReport = ref CPN'OGInspection.StandardReport

(*    fun NodeAttributes {Size = nodesize,
			Graphics = graphics,
			Text = textattr}
	= (CPN'OGDrawUtils.nodesizeref := nodesize;
	   CPN'OGDrawUtils.nodeattrref := graphics;
	   CPN'OGDrawUtils.nodetextref := textattr);


    fun NodeDescriptorAttributes {Size = nodedescrsize,
				  Graphics = graphics,
				  Text = textattr }
	= (CPN'OGDrawUtils.nodedescrsizeref := nodedescrsize;
	   CPN'OGDrawUtils.nodedescrattrref := graphics;
	   CPN'OGDrawUtils.nodedescrtextref := textattr);
	
    fun ArcDescriptorAttributes {Size = arcdescrsize,
				 Graphics = graphics,
				 Text = textattr }
	= (CPN'OGDrawUtils.arcdescrsizeref := arcdescrsize;
	   CPN'OGDrawUtils.arcdescrattrref := graphics;
	   CPN'OGDrawUtils.arcdescrtextref := textattr);
 *)
   
    fun NodeDescriptorOptions (userNodeFilter) =
	st_NodeDescrRef := userNodeFilter
	
    fun ArcDescriptorOptions (userArcFilter) = 
	st_ArcDescrRef := userArcFilter
	
(*    fun SuccPredOptions{FirstSucc = firstsucc,
			NextSucc = nextsucc,
			MaxSucc = maxsucc,
			FirstPred = firstpred,
			NextPred = nextpred,
			MaxPred = maxpred}
	= (CPN'OGDrawUtils.nodesuccoffsetref := firstsucc;
	   CPN'OGDrawUtils.succsuccoffsetref := nextsucc;
	   CPN'OGDrawUtils.max_fanoutref := maxsucc;
	   CPN'OGDrawUtils.nodepredoffsetref := firstpred;
	   CPN'OGDrawUtils.predpredoffsetref := nextpred;
	   CPN'OGDrawUtils.max_faninref := maxpred);
*)

    fun ReductionOptions { CreationTime = creationtime,
                           TerminationTime = terminationtime }
       = CPN'OGReductionOptions.SetParams { CreationTime = creationtime,
                                            TerminationTime = terminationtime }

    fun StopOptions {Nodes = nodes,
		     Arcs = arcs,
		     Secs = secs,
		     Predicate = userpredfun }
	= CPN'OGStopCrit.SetParams {NodeLimit = nodes,
				    ArcLimit = arcs,
				    CompTimeLimit = secs,
				    ProcNodePred = userpredfun}
	
    fun BranchingOptions {TransInsts = transinsts,
			  Bindings = bindings,
			  Predicate = userpredicate }
	= CPN'OGBranching.SetParams {Pred = userpredicate,
				   TransInstLimit = transinsts,
				   BindingLimit = bindings}
	
    fun InspectionOptions {Frequency = freq,
			   Action = useractionfun}
	= CPN'OGInspection.SetParams {Frequency = freq,
				      Action = useractionfun}
	

    val stringrepnoderef = ref (fn (CPN'n:string) => CPN'n);

    val stringreparcref = ref (fn (CPN'a, CPN's, CPN'd) => 
			       (CPN'a)^":"^(CPN's)^"->"^(CPN'd))

    val stringreppiref = ref (fn (CPN'pa,CPN'pl,CPN'in) =>
			      (CPN'pa)^"'"^(CPN'pl)^" "^(CPN'in))

    val stringreptiref = ref (fn (CPN'pa, CPN'tr, CPN'in) =>
			      (CPN'pa)^"'"^(CPN'tr)^" "^(CPN'in))

    val stringrepberef = ref (fn (CPN'tr, CPN'be) =>
			      CPN'tr^": "^CPN'be)

    val stringrepmarkref = ref (fn (CPN'pl, CPN'ma) =>
				CPN'pl^": "^CPN'ma)
	
    fun StringRepOptions'Node (userfilterfun) = stringrepnoderef := userfilterfun;
	
    fun StringRepOptions'Arc (userfilterfun) = stringreparcref := userfilterfun;
	
    fun StringRepOptions'PI (userfilterfun) = stringreppiref := userfilterfun;
	
    fun StringRepOptions'TI (userfilterfun) = stringreptiref := userfilterfun;
	
    fun StringRepOptions'BE (userfilterfun) = stringrepberef := userfilterfun;
	
    fun StringRepOptions'Mark (userfilterfun) = stringrepmarkref := userfilterfun;


end (* struct *)

fun st_Node (CPN'n:Node) = (!OGSet.stringrepnoderef)(Int.toString(CPN'n))
			   
fun st_Arc (CPN'a:Arc) =
    let
	val CPN'ar = CPN'OGUtils.ArcToArcRec CPN'a
    in
	(!OGSet.stringreparcref)((Int.toString(CPN'a)),
				 (st_Node (CPN'OGUtils.GetNodeNo(!(CPN'OGUtils.GetArcSrc CPN'ar)))),
				 (st_Node (CPN'OGUtils.GetNodeNo(!(CPN'OGUtils.GetArcDest CPN'ar)))))
    end
    
