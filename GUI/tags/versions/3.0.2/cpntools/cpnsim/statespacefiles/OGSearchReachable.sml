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
 * Module:       OGSearchReachable
 *
 * Description:  Functions for graph traversel
 *
 * CPN Tools
 *)


structure OG'SearchReachable :
sig
 val SearchReachableNodes :
   (Node *            (* Start Node *)
   (Node -> bool) *   (* Node Predicate *)
   int *              (* Number of hits *)
   (Node -> 'a) *     (* Node evaluation function *)
   '1b *               (* Start value *)
   (('a * '1b) -> '1b)  (* Combination function *)
   ) -> '1b            (* Result *)
   
 val SearchReachableArcs :
   (Node *            (* Start Node *)
   (Arc -> bool) *    (* Arc Predicate *)
   int *              (* Number of hits *)
   (Arc -> 'a) *      (* Arc evaluation function *)
   '1b *               (* Start value *)
   (('a * '1b) -> '1b)  (* Combination function *)
   ) -> '1b            (* Result *)
   
 val SearchReachableSccs :
   (Scc *             (* Start Scc *)
   (Scc -> bool) *    (* Scc Predicate *)
   int *              (* Number of hits *)
   (Scc -> 'a) *      (* Scc evaluation function *)
   '1b *               (* Start value *)
   (('a * '1b) -> '1b)  (* Combination function *)
   ) -> '1b            (* Result *)

 val SearchSubgraphSccs :
   ((Node -> bool) *  (* Node Predicate, true indicates that the node should be
                         included in the generation of Scc's *)
   (Arc -> bool) *    (* Arc Predicate, true indicates that the arc should be
                         included in the generation of Scc's *)
   (((Node list) * (Arc list) * (Arc list)) -> bool) * 
                      (* Scc Predicate, which sccs should be included in the search,
                         #1 States in component,
                         #2 Arcs internal in the component,
                         #3 Arcs out of the component *)
   int *              (* Number of hits *)
   (((Node list) * (Arc list) * (Arc list)) -> 'a) *
                      (* Scc evaluation function,
                         #1 States in component,
                         #2 Arcs internal in the component,
                         #3 Arcs out of the component *)
   '1b *               (* Start value *)
   (('a * '1b) -> '1b)  (* Combination function *)
   ) -> '1b            (* Result *)

 val TerminalSubgraphScc : ((Node list) * (Arc list) * (Arc list)) -> bool

 val TrivialSubgraphScc : ((Node list) * (Arc list) * (Arc list)) -> bool

 val SearchSubgraphCycles :
   (Node list *             (* Start Nodes *)
   (Node -> bool) *         (* Node Predicate, true indicates that the node should be
                               included in the cycle search *)
   (Arc -> bool) *          (* Arc Predicate, true indicates that the arc should be
                               included in the cycle search *)
   ((Node list) -> bool) *  (* Cycle Predicate *)
   int *                    (* Limit *)
   ((Node list) -> 'a) *    (* Cycle evaluation function *)
   '1b *                    (* Start value *)
   (('a * '1b) -> '1b)      (* Combination function *)
   ) -> '1b                 (* Result *)

end =
struct
    fun SearchReachableNodes 
	(CPN'startnode,CPN'pred,CPN'limit,CPN'eval,CPN'start,CPN'comb)
	= let
	      val CPN'Done = CPN'AvlTree.AvlNew () : unit CPN'AvlTree.avltree;
	      fun CPN'TestAndSet (CPN'node: Node)
		  = (CPN'AvlTree.AvlInsert CPN'Done (Int.toString CPN'node,());
		     true)
		  handle CPN'AvlTree.ExcAvlInsert => false;
		      
	      exception CPN'stopsearch;
	      val CPN'found=ref 0
	      val CPN'result=ref CPN'start;
	      fun CPN'searchone (CPN'n:Node)
		  = if CPN'pred CPN'n
			then
			    (CPN'result:=CPN'comb(CPN'eval(CPN'n),!CPN'result);
			     CPN'found := !CPN'found + 1;
			     if !CPN'found=CPN'limit
				 then raise CPN'stopsearch
			     else ())
		    else ();
	      fun CPN'searchlist [] = ()
		| CPN'searchlist (CPN'h::CPN't)
		  = (if CPN'TestAndSet CPN'h then CPN'searchone CPN'h else ();
		     CPN'searchlist CPN't;
		     CPN'searchlist (OutNodes CPN'h))
	  in
	      CPN'result:=CPN'start;
	      CPN'found:=0;
      
	      CPN'searchlist [CPN'startnode]
	      handle CPN'stopsearch => ();
      
		  !CPN'result
	  end;
     

    fun SearchReachableArcs
	(CPN'startnode,CPN'pred,CPN'limit,CPN'eval,CPN'start,CPN'comb)
	= let
	      val CPN'Done = CPN'AvlTree.AvlNew () : unit CPN'AvlTree.avltree;
	      fun CPN'TestAndSet (CPN'arc: Arc)
		  = (CPN'AvlTree.AvlInsert CPN'Done (Int.toString CPN'arc,());
		     true)
		  handle CPN'AvlTree.ExcAvlInsert => false;

	      exception CPN'stopsearch;
	      val CPN'found=ref 0
	      val CPN'result=ref CPN'start;
	      fun CPN'searchone (CPN'n:Arc)
		  = if CPN'pred CPN'n
			then
			    (CPN'result:=CPN'comb(CPN'eval(CPN'n),!CPN'result);
			     CPN'found := !CPN'found + 1;
			     if !CPN'found=CPN'limit
				 then raise CPN'stopsearch
			     else ())
		    else ();
	      fun CPN'searchlist [] = ()
		| CPN'searchlist (CPN'h::CPN't)
		  = (if CPN'TestAndSet CPN'h then CPN'searchone CPN'h else ();
		     CPN'searchlist CPN't;
		     CPN'searchlist (OutArcs (DestNode CPN'h)))
	  in
	      CPN'result:=CPN'start;
	      CPN'found:=0;
      
	      CPN'searchlist (OutArcs CPN'startnode)
	      handle CPN'stopsearch => ();
      
		  !CPN'result
	  end;
     

    fun SearchReachableSccs 
	(CPN'startnode,CPN'pred,CPN'limit,CPN'eval,CPN'start,CPN'comb)
	= let
	      val CPN'Done = CPN'AvlTree.AvlNew () : unit CPN'AvlTree.avltree;
	      fun CPN'TestAndSet (CPN'node: Scc)
		  = (CPN'AvlTree.AvlInsert CPN'Done (Int.toString CPN'node,());
		     true)
		  handle CPN'AvlTree.ExcAvlInsert => false;

	      exception CPN'stopsearch;
	      val CPN'found=ref 0
	      val CPN'result=ref CPN'start;
	      fun CPN'searchone (CPN'n:Scc)
		  = if CPN'pred CPN'n
			then
			    (CPN'result:=CPN'comb(CPN'eval(CPN'n),!CPN'result);
			     CPN'found := !CPN'found + 1;
			     if !CPN'found=CPN'limit
				 then raise CPN'stopsearch
			     else ())
		    else ();
	      fun CPN'searchlist [] = ()
		| CPN'searchlist (CPN'h::CPN't)
		  = (if CPN'TestAndSet CPN'h then CPN'searchone CPN'h else ();
		     CPN'searchlist CPN't;
		     CPN'searchlist (SccOutNodes CPN'h))
	  in
	      CPN'result:=CPN'start;
	      CPN'found:=0;
      
	      CPN'searchlist [CPN'startnode] 
	      handle CPN'stopsearch => ();
      
		  !CPN'result
	  end;


    datatype CPN'status
	= CPN'not_handled
      | CPN'stacked of int
      | CPN'all_done of int;

    datatype CPN'stackElm
	= CPN'no_stack_element
      | CPN'element of {CPN'node : int, CPN'next : CPN'stackElm ref};

    fun SearchSubgraphSccs 
	(CPN'nodepred,CPN'arcpred,CPN'sccpred,CPN'limit,CPN'eval,
	 CPN'start,CPN'comb)
	= let
	      val CPN'i = ref 1;
	      exception CPN'SCC_error;
  
	      exception CPN'stopsearch;
	      val CPN'found=ref 0
	      val CPN'result=ref CPN'start;

	      val CPN'V = CPN'AvlTree.AvlNew () : (CPN'status ref) CPN'AvlTree.avltree;
	      fun CPN'SetStatus (CPN'i:int,CPN'stacked CPN'n)
		  = CPN'AvlTree.AvlInsert CPN'V (Int.toString CPN'i,
						 ref(CPN'stacked CPN'n))
		| CPN'SetStatus (CPN'i,CPN'all_done CPN'n)
		  = (CPN'AvlTree.AvlLookup (CPN'V,Int.toString CPN'i))
		  := (CPN'all_done CPN'n)
		| CPN'SetStatus (_,CPN'not_handled)
		  = raise CPN'SCC_error;

	      fun CPN'Status (CPN'i:int)
		  =  (!(CPN'AvlTree.AvlLookup (CPN'V,Int.toString CPN'i))
		      handle CPN'AvlTree.ExcAvlLookup => CPN'not_handled);

	      val CPN'Stack = ref CPN'no_stack_element;

	      fun CPN'push CPN'node
		  = let
			val CPN'tmp = !CPN'Stack
		    in
			CPN'Stack:= CPN'element {CPN'node=CPN'node,
						 CPN'next=ref CPN'tmp}
		    end;

	      fun CPN'pop ()
		  = (case !CPN'Stack
		       of CPN'no_stack_element => raise CPN'SCC_error
			 | CPN'element {CPN'node, CPN'next}
			   => (CPN'Stack := !CPN'next; CPN'node));
      
	      fun CPN'popList CPN'DFI
		  = let
			fun CPN'popLocal CPN'lst
			    = let
				  val CPN'tmp = CPN'pop ();
				  val CPN'tmpDFI = case CPN'Status CPN'tmp
						     of CPN'stacked CPN'tmpDFI
							 => CPN'tmpDFI
						       | _ => raise CPN'SCC_error;
			      in
				  CPN'SetStatus (CPN'tmp, 
						 CPN'all_done CPN'DFI);
				  if CPN'DFI = CPN'tmpDFI
				      then (CPN'tmp::CPN'lst)
				  else CPN'popLocal (CPN'tmp::CPN'lst)
			      end;
		    in
			CPN'popLocal [] 
		    end;
   
	      val CPN'CrossConn = CPN'AvlTree.AvlNew () : Arc CPN'AvlTree.avltree;

	      fun CPN'crossconn CPN'arc
		  = CPN'AvlTree.AvlInsert CPN'CrossConn 
		  (Int.toString CPN'arc,CPN'arc);

	      fun CPN'get_crossconn (CPN'nodelist)
		  = let
			val CPN'lst = ref [];
			val CPN'delete = ref [];
			fun CPN'inlist [] _ = false
			  | CPN'inlist (CPN'h::CPN't) CPN'node
			    = CPN'node = CPN'h orelse 
			    (CPN'inlist CPN't CPN'node)
		    in
			CPN'AvlTree.AvlAppKey
			(fn (CPN'key,CPN'arc) =>
			 if CPN'inlist CPN'nodelist (SourceNode CPN'arc)
			     then
				 (CPN'lst := CPN'arc::(!CPN'lst);
				  CPN'delete := CPN'key::(!CPN'delete))
			 else (), CPN'CrossConn);
			map (CPN'AvlTree.AvlDelete CPN'CrossConn)
			(!CPN'delete);
			!CPN'lst
		    end;

	      fun CPN'DFSSCC CPN'v
		  = (case CPN'Status CPN'v
		       of CPN'all_done CPN'SCC => (CPN'all_done CPN'SCC,[])
			| CPN'stacked CPN'DFI => (CPN'stacked CPN'DFI,[])
			| CPN'not_handled =>
			      let
				  val CPN'DFI = !CPN'i
				  val CPN'Q = ref (!CPN'i)
				  val CPN'internalconns = ref []
			      in
				  CPN'inc CPN'i;
				  CPN'push CPN'v;
				  CPN'SetStatus (CPN'v, CPN'stacked CPN'DFI);
     
				  map (fn (CPN'arc as
					   (ref (CPN'OGarc 
						 {dest = ref (CPN'OGnode 
							      {no = CPN'no,...} ),
						  no=CPN'arcno,...}))) => 
				       (if (CPN'nodepred CPN'no) andalso 
					    (CPN'arcpred CPN'arcno)
					    then
						(case CPN'DFSSCC CPN'no 
						   of (CPN'all_done CPN'SCC,_)
						       => (CPN'crossconn
							   (CPN'OGUtils.GetArcNo (!CPN'arc)))
						     | (CPN'stacked CPN'DFI,
							CPN'intconn) =>
						       (CPN'Q := Int.min (!CPN'Q,CPN'DFI);
							CPN'internalconns := (CPN'arc::CPN'intconn)^^(!CPN'internalconns))
						      | (CPN'not_handled,_) => raise CPN'SCC_error)
					else ()))
				  (case (CPN'OGUtils.NodeToNodeRef CPN'v)
				     of (ref (CPN'OGnode {succlist = ref CPN'lst ,...})) => CPN'lst);

				       if !CPN'Q = CPN'DFI
					   then (let
						     val CPN'nodelist = CPN'popList CPN'DFI:Node list;
						     val CPN'tscc = (CPN'nodelist,
								     map (CPN'OGUtils.GetArcNo o !) (!CPN'internalconns),
								     CPN'get_crossconn CPN'nodelist)
						 in
						     if CPN'sccpred CPN'tscc
							 then
							     (CPN'result :=
							      CPN'comb (CPN'eval CPN'tscc,!CPN'result);
							      CPN'found := !CPN'found + 1)
						     else ()
						 end;
						 if !CPN'found=CPN'limit
						     then raise CPN'stopsearch
						 else ();
						     (CPN'all_done CPN'DFI,[]))
				       else (CPN'stacked(!CPN'Q),!CPN'internalconns)
			      end)
	  in
	      CPN'AvlTree.AvlApp(fn ref(CPN'OGnode{no=CPN'n,...}) =>
				 CPN'DFSSCC CPN'n, CPN'OGNodes)
	      handle CPN'stopsearch => ();
		  !CPN'result
	  end;
 
    fun TerminalSubgraphScc (_,_,[]) = true
      | TerminalSubgraphScc _ = false;
 
    fun TrivialSubgraphScc ([_],[],_) = true
      | TrivialSubgraphScc _ = false;

    fun SearchSubgraphCycles 
	(CPN'startnodes,CPN'nodepred,CPN'arcpred,CPN'cycpred,
	 CPN'limit,CPN'eval,CPN'start,CPN'comb)
	= let
	      val CPN'Done = CPN'AvlTree.AvlNew () : unit CPN'AvlTree.avltree;
	      fun CPN'FirstTime CPN'node
		  = (CPN'AvlTree.AvlInsert CPN'Done (mkst_Node CPN'node,());
		     true)
		  handle CPN'AvlTree.ExcAvlInsert => false;

	      exception CPN'stopsearch;
	      val CPN'found=ref 0
	      val CPN'result=ref CPN'start;

	      fun CPN'filterList _ [] = []
		| CPN'filterList CPN'p (CPN'h::CPN't)
		  = if CPN'p CPN'h
			then
			    CPN'h::(CPN'filterList CPN'p CPN't)
		    else
			CPN'filterList CPN'p CPN't;
           
	      fun CPN'extractcyc CPN'OnStack CPN'startnode
		  = let
			fun CPN'find (CPN'node::CPN'rst) CPN'lst
			    = if CPN'node = CPN'startnode
				  then CPN'lst
			      else CPN'find CPN'rst (CPN'node::CPN'lst)
		    in
			CPN'find CPN'OnStack [CPN'startnode]
		    end;
         
	      fun CPN'searchlist _ [] = ()
		| CPN'searchlist CPN'OnStack (CPN'h::CPN't)
		  = (case (CPN'FirstTime CPN'h, CPN'nodepred CPN'h)
		       of (true,true) =>
			   CPN'searchlist (CPN'h::CPN'OnStack) 
			   (map DestNode (CPN'filterList CPN'arcpred 
					  (OutArcs CPN'h)))
			| (false,true) =>
			      (if (mem CPN'OnStack CPN'h)
				   then
				       let
					   val CPN'cyc = (CPN'extractcyc CPN'OnStack CPN'h) 
				       in
					   if CPN'cycpred CPN'cyc
					       then
						   (CPN'result:=CPN'comb(CPN'eval CPN'cyc,!CPN'result);
						    CPN'found := !CPN'found + 1;
						    if !CPN'found=CPN'limit
							then raise CPN'stopsearch
						    else ())
					   else ()
				       end
			       else
				   ())
			| _ => ();
			      CPN'searchlist CPN'OnStack CPN't);
	  in
	      CPN'result:=CPN'start;
	      CPN'found:=0;
      
	      CPN'searchlist [] CPN'startnodes
	      handle CPN'stopsearch => ();

		  !CPN'result
	  end;
end;

open OG'SearchReachable;


 
