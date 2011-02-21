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
 * Module:       SCC
 *
 * Description:  Strongly Connected Components
 *
 * CPN Tools
 *)

(* The following global reference variable is used only in this file and in
the file SCCAnalyze.sml. It holds information about whethet the SCC graph is 
calculated or not. It is false before the function gen_SCC that generates the
SCC graph has been called, and it is true after.*)

val CPN'IsSCCGen = ref false;

structure SCCBasics :
sig
 type Scc
 val InitScc : Scc

 val CalculateSccGraph : unit -> unit
 val SccGraphCalculated : unit -> bool
 val SccDisplay : unit -> unit

 val NodeToScc : Node -> Scc
 val ArcToScc : Arc -> Scc
 val SccToNodes : Scc -> Node list
 val SccToArcs : Scc -> Arc list 

 val SccSourceNode : Arc -> Scc
 val SccDestNode : Arc -> Scc
 val SccArcs : (Scc * Scc) -> Arc list
 val SccInNodes : Scc -> Scc list (* not very efficient *)
 val SccOutNodes : Scc -> Scc list
 val SccInArcs : Scc -> Arc list (* not very efficient *)
 val SccOutArcs : Scc -> Arc list

 val SccNoOfNodes : unit -> int
 val SccNoOfArcs : unit -> int
 val SccNoOfSecs : unit -> int
 val SccTerminal : Scc -> bool
 val TerminalSccs : unit -> Scc list
 val SccFindTerminals : unit -> unit
 val SccTrivial : Scc -> bool
 val SccInitial : Scc -> bool
 
 val SccNodesInPath : (Scc * Scc) -> Scc list
 val SccArcsInPath : (Scc * Scc) -> Arc list
 val SearchSccs : ((Scc list) * (Scc -> bool) * int * (Scc -> 'a) * '1b * (('a * '1b) -> '1b)) -> '1b

end = struct

type Scc = int;

type CPN'ComponentArc = {CPN'dest: int,
			 CPN'arcs: (CPN'OGarcrec ref) list};

type CPN'ComponentNode = {CPN'SCC: int,
			  CPN'arcs : (CPN'OGarcrec ref) list,
			  CPN'nodes : Node list,
			  CPN'out_arcs : CPN'ComponentArc list};

val CPN'SCC = CPN'AvlTree.AvlNew () : CPN'ComponentNode CPN'AvlTree.avltree;

datatype CPN'status = 
    CPN'not_handled | 
    CPN'stacked of int | 
    CPN'all_done of int;

datatype CPN'stackElm = 
    CPN'no_stack_element | 
    CPN'element of {CPN'node : int,
		    CPN'next : CPN'stackElm ref};

type CPN'LocalArc = {CPN'dest: int,
		     CPN'afield: (CPN'OGarcrec ref * int) list};

type CPN'LocalNode = {CPN'SCC: int,
		      CPN'arcs : (CPN'OGarcrec ref) list,
		      CPN'nodes : Node list,
		      CPN'out_arcs : CPN'LocalArc list};

exception SCC_error;
exception SccGraphNotCalculated;

val InitScc = ~1;
val SccComptime = ref (0:Int32.int);

fun NodeToScc (CPN'n : Node) =
 if (!CPN'IsSCCGen)
     then
	 let
	     val CPN'hit = ref 0 : Node ref;
	     exception found
	 in
	     (CPN'AvlTree.AvlApp
	      (fn {CPN'SCC=CPN'scc_node,CPN'nodes=CPN'nodes,...} =>
	       (mem CPN'nodes CPN'n) andalso
	       (CPN'hit := CPN'scc_node; raise found),CPN'SCC);
	      raise SCC_error)
	     handle found => !CPN'hit
	 end
 else
     raise SccGraphNotCalculated;

fun SccGraphCalculated () = !CPN'IsSCCGen;
    
fun ArcToScc (CPN'a : Arc) = NodeToScc (SourceNode CPN'a);
    
fun SccToNodes (CPN'n : Scc) = 
 if (!CPN'IsSCCGen)
 then
  #CPN'nodes (CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'n))
 else
  raise SccGraphNotCalculated;

fun SccToArcs (CPN'a : Scc) = 
 if (!CPN'IsSCCGen)
 then
     map (fn (ref CPN'arc) => CPN'OGUtils.GetArcNo CPN'arc)
     (#CPN'arcs (CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'a)))
 else
  raise SccGraphNotCalculated;

fun SccArcs (CPN'from : Scc, CPN'to : Scc) =
    if (!CPN'IsSCCGen)
	then
	    let
		val _ = CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'from);
		val _ = CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'to);
		    
		fun CPN'find [] = []
		  | CPN'find ({CPN'dest=CPN'dest, CPN'arcs=CPN'arcs}::CPN'r) =
		    if CPN'dest = CPN'to then CPN'arcs else CPN'find CPN'r
	    in
		map (fn (ref arc) => CPN'OGUtils.GetArcNo arc)
		(CPN'find (#CPN'out_arcs (CPN'AvlTree.AvlLookup 
				      (CPN'SCC,Int.toString CPN'from))))
	    end
    else
	raise SccGraphNotCalculated;

val SccSourceNode = NodeToScc o SourceNode;
val SccDestNode = NodeToScc o DestNode;

fun SccOutArcs (CPN'scc:Scc) =
    if (!CPN'IsSCCGen)
	then
	    remdupl
	    (map (CPN'OGUtils.GetArcNo o !)
	     (flatten (map (#CPN'arcs) 
		       (#CPN'out_arcs (CPN'AvlTree.AvlLookup 
				       (CPN'SCC,Int.toString CPN'scc))))))
    else
	raise SccGraphNotCalculated;

fun SccOutNodes (CPN'scc:Scc) =
 if (!CPN'IsSCCGen)
     then
	 remdupl (map (#CPN'dest) (#CPN'out_arcs (CPN'AvlTree.AvlLookup 
						  (CPN'SCC,Int.toString CPN'scc))))
 else
     raise SccGraphNotCalculated;

val CPN'terminals = ref ([]:Scc list);

fun SccFindTerminals ()
    =  if (!CPN'IsSCCGen)
	   then
	       (CPN'terminals:= [];
		CPN'AvlTree.AvlApp
		(fn {CPN'out_arcs=[],CPN'SCC=CPN'scc, ...} => 
		 CPN'terminals := CPN'scc::(!CPN'terminals)
		  | _ => (),
			CPN'SCC))
       else
	   raise SccGraphNotCalculated;
	       
fun TerminalSccs () = 
    if (!CPN'IsSCCGen)
	then
	    !CPN'terminals
    else
	raise SccGraphNotCalculated;
	
fun SccTerminal (CPN'scc:Scc) =
    if (!CPN'IsSCCGen)
	then
	    case (#CPN'out_arcs (CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'scc)))
	      of [] => true | 
		  _ => false
    else
	raise SccGraphNotCalculated;

fun SccTrivial (CPN'scc:Scc) =
    if (!CPN'IsSCCGen)
	then
	    let
		val scc'comp = CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'scc)
	    in
		case #CPN'nodes scc'comp
		  of [_] => (case #CPN'arcs scc'comp
			       of [] => true
				| _ => false)
		   | _ => false
	    end
    else
	raise SccGraphNotCalculated;
 
fun SccInitial (scc:Scc) =
    if (!CPN'IsSCCGen)
	  then
	      ListUtils.mem (SccToNodes scc) 1
    else
	raise SccGraphNotCalculated;
	  
fun SccNoOfNodes () = 
    if (!CPN'IsSCCGen)
	then
	    CPN'AvlTree.AvlNo CPN'SCC
    else
	raise SccGraphNotCalculated;

fun SccNoOfArcs () = 
    if (!CPN'IsSCCGen)
	then
	    CPN'AvlTree.AvlFold
	    ((fn ({CPN'SCC=CPN'scc_node,...},CPN'result) =>
	      (CPN'result+length(SccOutArcs(CPN'scc_node)))),0,CPN'SCC)
    else
	raise SccGraphNotCalculated;
 
fun SccNoOfSecs () = Int32.toInt(!SccComptime);

fun CalculateSccGraph () =
    let
	val CPN'Starttime = tod();
	val CPN'i = ref 1;
	val CPN'j = ref 0;
	    
	val CPN'LocalCC = ref ([] : (CPN'LocalNode ref) list);
	fun insertCC CPN'elm = CPN'LocalCC := (ref CPN'elm) :: (!CPN'LocalCC);

	fun CPN'renumber () =
	    let
		val CPN'j = ref InitScc;
		val CPN'NewNumbers = CPN'AvlTree.AvlNew () : int CPN'AvlTree.avltree;
		fun CPN'findnumber CPN'no =
		    CPN'AvlTree.AvlLookup (CPN'NewNumbers,CPN'no)
		    handle CPN'AvlTree.ExcAvlLookup => 
			let
			    val CPN'newno = !CPN'j
			in
			    CPN'AvlTree.AvlInsert CPN'NewNumbers (CPN'no,CPN'newno);
			    CPN'dec CPN'j;
			    CPN'newno
			end;
       
		fun CPN'update (ref({CPN'SCC=CPN'SCCnode,CPN'arcs,CPN'nodes,
				 CPN'out_arcs}:CPN'LocalNode)) =
		    let
			val CPN'NewSCC = CPN'findnumber (Int.toString CPN'SCCnode);
			val CPN'key = Int.toString CPN'NewSCC;
			val CPN'newout_arcs =
			    map (fn {CPN'dest:int,CPN'afield} =>
				 {CPN'dest=CPN'findnumber (Int.toString CPN'dest),
				  CPN'arcs=map (fn (CPN'arcr,_) => CPN'arcr) 
				  CPN'afield}) CPN'out_arcs;
		    in
			CPN'AvlTree.AvlInsert CPN'SCC 
			(CPN'key,{CPN'SCC=CPN'NewSCC,CPN'nodes=CPN'nodes,
				  CPN'arcs=CPN'arcs,CPN'out_arcs=CPN'newout_arcs})
		    end;
	    in
		map CPN'update (!CPN'LocalCC)
	    end;

	val CPN'V = CPN'AvlTree.AvlNew () : (CPN'status ref) CPN'AvlTree.avltree;
	fun CPN'SetStatus (CPN'i:int,CPN'stacked CPN'n) =
	    CPN'AvlTree.AvlInsert CPN'V (Int.toString CPN'i,ref(CPN'stacked CPN'n))
	  | CPN'SetStatus (CPN'i,CPN'all_done CPN'n) =
	    (CPN'AvlTree.AvlLookup (CPN'V,Int.toString CPN'i)) := (CPN'all_done CPN'n)
	  | CPN'SetStatus (_,CPN'not_handled) = 
	    raise SCC_error;
	fun CPN'Status (CPN'i:int) =
	    (!(CPN'AvlTree.AvlLookup (CPN'V,Int.toString CPN'i))
	     handle CPN'AvlTree.ExcAvlLookup => CPN'not_handled);

	val CPN'Stack = ref CPN'no_stack_element;
	fun CPN'push CPN'node =
	    let 
		val CPN'tmp = !CPN'Stack 
	    in  
		CPN'Stack:= CPN'element {CPN'node=CPN'node,CPN'next=ref CPN'tmp}
	    end;
	fun CPN'pop () = 
	    case !CPN'Stack
	      of CPN'no_stack_element => raise SCC_error
	       | CPN'element {CPN'node, CPN'next} =>
		     (CPN'Stack := !CPN'next; CPN'node);
	fun CPN'popList CPN'DFI =
	    let
		fun CPN'popLocal CPN'lst =
		    let
			val CPN'tmp = CPN'pop ();
			val CPN'tmpDFI = case CPN'Status CPN'tmp
					   of CPN'stacked CPN'tmpDFI => CPN'tmpDFI
					    | _ => raise SCC_error;
		    in
			CPN'SetStatus (CPN'tmp, CPN'all_done CPN'DFI);
			if CPN'DFI = CPN'tmpDFI
			    then (CPN'tmp::CPN'lst)
			else CPN'popLocal (CPN'tmp::CPN'lst)
		    end;
	    in
		CPN'popLocal [] 
	    end;
    
	val CPN'CrossConn = CPN'AvlTree.AvlNew () : 
	    CPN'LocalArc ref CPN'AvlTree.avltree;
	fun CPN'crossconn (CPN'arc,CPN'SCC:int,CPN'v) =
	    let
		val (CPN'aref as (ref {CPN'afield,...})) =
		    CPN'AvlTree.AvlLookup (CPN'CrossConn, Int.toString CPN'SCC)
	    in
		CPN'aref := {CPN'dest = CPN'SCC, 
			     CPN'afield = (CPN'arc,CPN'v)::CPN'afield}
	    end
	handle CPN'AvlTree.ExcAvlLookup => 
	    CPN'AvlTree.AvlInsert CPN'CrossConn 
	    (Int.toString CPN'SCC, ref {CPN'dest=CPN'SCC, 
				      CPN'afield=[(CPN'arc,CPN'v)]});
        
	fun CPN'getOutArcs () =
	    let
		val CPN'lst = ref [];
		val CPN'toDelete = ref [];
	    in
		CPN'AvlTree.AvlAppKey
		(fn (CPN'key,CPN'aref as (ref {CPN'dest=CPN'SCC, 
					       CPN'afield=CPN'arcs})) =>
		 let
		     fun CPN'sel [] CPN'arcs CPN'rest = (CPN'arcs,CPN'rest)
		       | CPN'sel ((CPN'a,CPN'v)::CPN'arest) CPN'arcs CPN'rest =
			 (case CPN'Status CPN'v
			    of CPN'all_done _ => CPN'sel CPN'arest 
				((CPN'a,CPN'v)::CPN'arcs) CPN'rest
			     | CPN'stacked _ => CPN'sel CPN'arest CPN'arcs 
				   ((CPN'a,CPN'v)::CPN'rest)
			     | CPN'not_handled => raise SCC_error)
		 in
		     case CPN'sel CPN'arcs [] []
		       of ([],_) => ()
			| (CPN'arcs,[]) =>
			      (CPN'toDelete := CPN'key::(!CPN'toDelete);
			       CPN'lst := {CPN'dest=CPN'SCC, 
					   CPN'afield=CPN'arcs}::(!CPN'lst))
			| (CPN'arcs,CPN'rest) =>
			      (CPN'aref := {CPN'dest=CPN'SCC, 
					    CPN'afield= CPN'rest};
			       CPN'lst := {CPN'dest=CPN'SCC, 
					   CPN'afield=CPN'arcs}::(!CPN'lst))
		 end,
	     CPN'CrossConn);
		map (CPN'AvlTree.AvlDelete CPN'CrossConn) (!CPN'toDelete);
		!CPN'lst
	    end;
  
	fun CPN'define_component CPN'DFI CPN'arcs =
	    (insertCC {CPN'SCC = CPN'DFI,
		       CPN'arcs = CPN'arcs,
		       CPN'nodes = CPN'popList CPN'DFI,
		       CPN'out_arcs = CPN'getOutArcs ()};
	     (CPN'all_done CPN'DFI,[]));
	    
	fun CPN'put_intArc CPN'newQ CPN'newintarc ((CPN'DFI,CPN'Q,CPN'intarc,
						    CPN'arclst)::CPN'stack) =
	    ((CPN'DFI,Int.min (CPN'newQ,CPN'Q),CPN'intarc^^CPN'newintarc,
	      CPN'arclst)::CPN'stack)
	  | CPN'put_intArc _ _ [] = raise SCC_error;

	val (CPN'abs_part, CPN'rel_part) = 
	    case (NoOfArcs()) 
	      of CPN'n => 
		  if CPN'n>1000 
		      then 
			  let
			      val CPN'abs_part = Int.min(CPN'n div 10,1000)
			      val CPN'rel_part = 
				  ((real CPN'abs_part)/(real CPN'n))*100.0
			  in
			    (CPN'abs_part,
			     CPN'rel_part)
			  end
		  else (1000, 0.0); 

	val CPN'abs_part_done = ref CPN'abs_part;
	val CPN'rel_part_done = ref 0.0;

	fun CPN'DFSSCC ((CPN'DFI,CPN'Q,CPN'intarc,CPN'arc::CPN'arclst)::CPN'stack) =
	    let
		val CPN'v = DestNode CPN'arc

	    in
		case CPN'Status CPN'v
		  of CPN'all_done CPN'SCC => 
		      (CPN'crossconn (CPN'OGUtils.ArcToArcRef CPN'arc,
				      CPN'SCC, SourceNode CPN'arc);
		       CPN'DFSSCC ((CPN'DFI,CPN'Q,CPN'intarc,
				    CPN'arclst)::CPN'stack))
		   | CPN'stacked newDFI =>
			 CPN'DFSSCC ((CPN'DFI,Int.min(CPN'Q,newDFI),CPN'arc::
				      CPN'intarc,CPN'arclst):: CPN'stack)
		   | CPN'not_handled =>
			 (CPN'dec CPN'j;
			  CPN'inc CPN'i;
			  CPN'push CPN'v;
			  CPN'SetStatus (CPN'v, CPN'stacked (!CPN'i));
       
			  CPN'DFSSCC ((!CPN'i,!CPN'i,[],OutArcs CPN'v)::
				      ((CPN'DFI,CPN'Q,CPN'intarc,CPN'arc::CPN'arclst)::
				       CPN'stack)))
	    end
	  | CPN'DFSSCC ((CPN'DFI,CPN'Q,CPN'intarc,[])::CPN'stack) =
	    if CPN'Q = CPN'DFI
		then (CPN'define_component CPN'DFI 
		      (map CPN'OGUtils.ArcToArcRef CPN'intarc);
		CPN'DFSSCC CPN'stack)
	    else CPN'DFSSCC (CPN'put_intArc CPN'Q CPN'intarc CPN'stack)
	  | CPN'DFSSCC [] = ()
    in
	CPN'AvlTree.AvlReset CPN'SCC;
	CPN'push 1;
	CPN'SetStatus (1, CPN'stacked 1);
	CPN'DFSSCC [(1,1,[],OutArcs 1)]; (* start from initial marking *)
	CPN'renumber ();
	CPN'IsSCCGen := true; (* record that the SCC graph is generated *)
	SccComptime := (tod() - CPN'Starttime);
	()
    end; 

fun SccDisplay () = () 
(*
    let
	val CPN'Displayed_nodes = CPN'AvlTree.AvlNew () : int CPN'AvlTree.avltree;
	fun CPN'SetDisplay (CPN'node:int,CPN'modstruc) =
	    CPN'AvlTree.AvlInsert CPN'Displayed_nodes 
	    (Int.toString CPN'node,CPN'modstruc);
	fun CPN'IsDisplayed (CPN'node:int) =
	    ($(CPN'AvlTree.AvlLookup (CPN'Displayed_nodes,Int.toString CPN'node))
	     handle CPN'AvlTree.ExcAvlLookup => $$);
   
	val CPN'horisontal = 100;
	val CPN'vertical = 55;
	val CPN'page = DSStr_GetCurPage();
   
	fun CPN'SetGraphicAttr CPN'node [] CPN'number = (* terminal *)
	    DSWtAttr_ObjectVisuals{obj= CPN'node,
				   line = 26,
				   thick = if CPN'number = ~1 then 2 else 1,
				   fill = 20,
				   vis = true}
	  | CPN'SetGraphicAttr CPN'node _ CPN'number = (* not terminal *)
	    DSWtAttr_ObjectVisuals{obj= CPN'node,
				   line = 1,
				   thick = if CPN'number = ~1 then 2 else 1,
				   fill = 20,
				   vis = true};
    
	fun CPN'display CPN'node CPN'x CPN'y =
	    case CPN'IsDisplayed CPN'node
	      of $ CPN'modstruc => CPN'modstruc
	       | $$ => 
		     let
			 val CPN'thisnode = DSStr_CreateNode
			     {page=CPN'page,x=CPN'x,y=CPN'y,w=80,h=30,shape=RNDRECT};
			 val {CPN'nodes, CPN'arcs, CPN'out_arcs,...} = 
			     CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'node);
			 val CPN'i = ref ((real(~((length CPN'out_arcs)-1)))/2.0);
		     in
			 CPN'SetGraphicAttr CPN'thisnode CPN'out_arcs CPN'node;

			 DSText_Put{obj=CPN'thisnode,
				    text=((Int.toString CPN'node)^":\013#Nodes: "^
					  (Int.toString (length(SccToNodes CPN'node)))^
					  "\013#Arcs: "^
					  (Int.toString (length(SccToArcs CPN'node))))};
			 CPN'SetDisplay (CPN'node,CPN'thisnode);
       
			 map (fn {CPN'arcs, CPN'dest} => 
			      let 
				  val CPN'modstruc = CPN'display CPN'dest 
				      (CPN'x+(floor((!CPN'i)*(real CPN'horisontal))))
				      (CPN'y+CPN'vertical);
				  val CPN'connid = DSStr_CreateConn
				      {page=CPN'page,
				       node1=CPN'thisnode,
				       node2=CPN'modstruc};
			      in
				  CPN'i := (!CPN'i) + 1.0;
				  DSText_Put{obj=CPN'connid,
					     text=Int.toString
					     (length(SccArcs(CPN'node,CPN'dest)))}
			      end)
			 CPN'out_arcs;
			 CPN'thisnode
		     end
    in
	if (!CPN'IsSCCGen)
	    then
		(CPN'display (~1) 0 0;())
	else
	    raise SccGraphNotCalculated
    end;
*)
   
local
    exception CPN'stopsearch;
    val CPN'found=ref 0
in
    fun SearchSccs(CPN'scclist, CPN'pred, CPN'limit, CPN'eval, CPN'start, CPN'comb) =
	if (!CPN'IsSCCGen)
	    then
		(let
		     val CPN'result=ref CPN'start;
		     fun CPN'searchone (CPN'n:Scc)
			 = if CPN'pred CPN'n
			       then
				   (CPN'result:=CPN'comb(CPN'eval(CPN'n),!CPN'result);
				    CPN'found := !CPN'found + 1;
				    if !CPN'found=CPN'limit
					then raise CPN'stopsearch
				    else ())
			   else ()
		 in
		     CPN'result:=CPN'start;
		     CPN'found:=0;
		     (if CPN'scclist=[0]
			  then CPN'AvlTree.AvlApp(fn {CPN'SCC=CPN'n,...} => 
						  CPN'searchone CPN'n, CPN'SCC)
		      else 
			  (map CPN'searchone CPN'scclist;())) 
			  handle CPN'stopsearch => ();
			      !CPN'result
		 end(*let*))
	else
	    raise SccGraphNotCalculated
end(*local*);

local
 fun CPN'SccToSccRef (CPN'scc:Scc) =
     ref (CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'scc));
 
 val CPN'Noderefs = CPN'AvlTree.AvlNew()    (* temp store to contains paths *)
     :((CPN'ComponentNode ref)*(Scc list)) CPN'AvlTree.avltree;
 
 val CPN'ToProcess = ref([]:Scc list);
 
 fun CPN'ProcessNew CPN'n =
     let
	 val (_,CPN'path) (* the path from CPN'n1 to CPN'n (reversed) *)
	     = CPN'AvlTree.AvlLookup(CPN'Noderefs,Int.toString CPN'n)
     in
	 map (fn CPN'outn
	      => (CPN'AvlTree.AvlLookup(CPN'Noderefs,Int.toString CPN'outn)
               
		  handle CPN'AvlTree.ExcAvlLookup (* store path from n1 to CPN'outn *)
		  => (CPN'AvlTree.AvlInsert CPN'Noderefs
		      (Int.toString CPN'outn,
		       (CPN'SccToSccRef CPN'outn,
			CPN'outn::CPN'path));
                         
		      CPN'ToProcess:=CPN'outn::(!CPN'ToProcess);
                         
		      (CPN'SccToSccRef CPN'outn,
		       [])(*dummy value*));
		      ()))
	 (SccOutNodes CPN'n)
     end;
 
 fun CPN'AreWeDone CPN'nr2
     = let 
	   val (_,CPN'path)
	       = CPN'AvlTree.AvlLookup
	       (CPN'Noderefs,Int.toString (#CPN'SCC(!CPN'nr2)))
               
               handle CPN'AvlTree.ExcAvlLookup 
	       (* nr2 not found so process another round *)
	       => let
		      val CPN'newcand = ListUtils.remdupl(!CPN'ToProcess)
		  in
		      if CPN'newcand=[]
			  then (* no more cands, hence no path *)
			      (CPN'nr2(*dummy value*),[])
		      else (* process the cands, and test whether we are done or not *)
                          (CPN'ToProcess:=[];
			   map CPN'ProcessNew CPN'newcand;
			   (CPN'nr2(*dummy value*),CPN'AreWeDone CPN'nr2))
		  end(*let*)
       in
	   CPN'path
       end(*let*);
in
    fun SccNodesInPath (CPN'n1:Scc,CPN'n2:Scc) = 
	(* implementaion of Dijkstra's shortest path alg *)
	(* with the modification that we stop when n2 is *)
	(* reached *)
	
	(if (!CPN'IsSCCGen)
	     then
		 (CPN'AvlTree.AvlReset CPN'Noderefs;
   
		  CPN'AvlTree.AvlInsert CPN'Noderefs 
		  (* record that there is a path from n1 to n1 ! *)

		  (Int.toString CPN'n1,(CPN'SccToSccRef CPN'n1,[CPN'n1]));
   
		  CPN'ToProcess:=[CPN'n1];
   
		  rev(CPN'AreWeDone(CPN'SccToSccRef CPN'n2)))
	 else
	     raise SccGraphNotCalculated)
end;

fun SccArcsInPath (CPN'n1:Scc, CPN'n2:Scc) =
    let
	fun CPN'arcs (CPN'n1::(CPN'n2::CPN'rest)) =
	    (hd(SccArcs(CPN'n1,CPN'n2)))::(CPN'arcs(CPN'n2::CPN'rest))
	  | CPN'arcs _ = []
    in
	CPN'arcs (SccNodesInPath(CPN'n1,CPN'n2))
    end;
    
fun SccInArcs (CPN'scc:Scc) =
    if (!CPN'IsSCCGen)
	then
	    (let
		 val _ = CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'scc);
		     
		 fun CPN'filter _ [] = []
		   | CPN'filter CPN'f (CPN's::CPN'r) =
		     if CPN'f CPN's 
			 then CPN's::(CPN'filter CPN'f CPN'r)
		     else CPN'filter CPN'f CPN'r;
	     in
		 SearchSccs([0],fn _ => true,0,
			    fn CPN'nscc => (CPN'filter 
					    (fn CPN'x => CPN'scc = NodeToScc(DestNode CPN'x)) 
					    (SccOutArcs CPN'nscc)),
			    [],fn (CPN'a,CPN'b) => CPN'a^^CPN'b)
	     end)
    else
	raise SccGraphNotCalculated;

fun SccInNodes (CPN'scc:Scc) = 
    if (!CPN'IsSCCGen)
	then
	    (let
		 val _ = CPN'AvlTree.AvlLookup (CPN'SCC,Int.toString CPN'scc);

		 fun CPN'filter _ [] = []
		   | CPN'filter CPN'f (CPN's::CPN'r) =
		     if CPN'f CPN's
			 then CPN's::(CPN'filter CPN'f CPN'r)
		     else CPN'filter CPN'f CPN'r;
	     in
		 remdupl (SearchSccs
			  ([0],fn _ => true,0,
			   fn CPN'nscc => map (NodeToScc o SourceNode)
			   (CPN'filter (fn CPN'x => CPN'scc = NodeToScc(DestNode CPN'x)) 
			    (SccOutArcs CPN'nscc)),
			   [],fn (CPN'a,CPN'b) => CPN'a^^CPN'b))
	     end)
    else
	raise SccGraphNotCalculated;

end;

open SCCBasics;

fun PredSccs (CPN'area,CPN'pred,CPN'limit)
   = SearchSccs(CPN'area,CPN'pred,CPN'limit,fn CPN'x => CPN'x,[],op ::);
fun EvalSccs(CPN'area,CPN'eval)
   = SearchSccs(CPN'area,fn _=>true,0,CPN'eval,[],op ::);
fun SearchAllSccs(CPN'pred,CPN'eval,CPN'start,CPN'comb)
   = SearchSccs([0],CPN'pred,0,CPN'eval,CPN'start,CPN'comb);
fun PredAllSccs CPN'pred
   = PredSccs([0],CPN'pred,0);
fun EvalAllSccs CPN'eval
   = EvalSccs([0],CPN'eval);

