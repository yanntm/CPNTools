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
 * Module:      OGtoFSMView
 * 
 * Description:  Export graph structure of state spaces and 
 *               SCC graphs to FSMView
 *
 * FSMView must be downloaded and installed from
 *     http://www.win.tue.nl/~fvham/fsm/
 *
 *)


structure OGtoFSMView = struct

(* Given a node from either a state space or a SCC graph, 
 * generate a node id for FSMView
 *)
fun nodeToNodeID (CPN'node : Node) = 
    if CPN'node > 0 
    then mkst_Node(CPN'node)(* a state space node *)
    else mkst_Node(abs CPN'node) (* a scc node *)


(* Given a node from either a state space or a SCC graph, 
 * generate a node statement for FSMView
 *)
fun genNodeStmt CPN'node = 
    nodeToNodeID(CPN'node)^"\n" 


fun arcToEdgeLabel (CPN'arc: Arc) =
    mkst_Arc(CPN'arc)^":"^st_BE(ArcToBE(CPN'arc))

(* Given a (sourceNode,arc,destNode) tuple from the state space, 
 * generate an edge statement for FSMView
 * for the arc from the sourceNode to the destNode
 *)
fun genEdgeStmt (CPN'sourceNode,CPN'arc,CPN'destNode) = 
    nodeToNodeID(CPN'sourceNode)^" "^
    nodeToNodeID(CPN'destNode)^" "^ 
    "\""^arcToEdgeLabel(CPN'arc)^"\"\n"


(* Check that all specified nodes exist in state space *)
fun checkNodes (CPN'nodes : Node list) = 
    if CPN'nodes = EntireGraph
    then ()
    else case List.find (not o CPN'OGUtils.NodeExists) CPN'nodes of
	     NONE => ()
	   | SOME CPN'node => 
	     raise CPN'Error ("Node "^mkst_Node(CPN'node)^
			      " does not exist in the state space")
		   
(* Check that all specified arcs exist in state space *)
fun checkArcs (CPN'arcs : Arc list) = 
    if CPN'arcs = EntireGraph
    then ()
    else case List.find (not o CPN'OGUtils.ArcExists) CPN'arcs of
	     NONE => ()
	   | SOME CPN'arc => 
	     raise CPN'Error ("Arc "^mkst_Arc(CPN'arc)^
			      " does not exist in the state space")
(* 
 * function createFSMViewFile
 *
 * Exports the state space graph structure of the nodes determined
 * by stateSpaceArea to the file filename *)
fun createFSMViewFile (CPN'filename: string, 
			CPN'nodes: Node list,
			CPN'edges: (Node * Arc * Node) list) = 
    let
	val fid = TextIO.openOut CPN'filename
	
	(* The beginning of the FSMView file *)
	val _ = TextIO.output(fid, "node_nr(0)\n---\n")

	fun outputStmt stmt = TextIO.output(fid,stmt)

	(* Quick and dirty dump of all nodes 
	 * Does not work if there are unconnected nodes *)
	val allNodes = Misc.sort Int.< (EvalAllNodes (fn CPN'i => CPN'i))

	val _ =  EvalNodes (allNodes, outputStmt o genNodeStmt)

	val _ =  TextIO.output(fid, "---\n")

	val edgeStmts = map genEdgeStmt CPN'edges
	val _ = map outputStmt edgeStmts
    in
	TextIO.closeOut(fid)
    end

fun CPN'nodePathToEdges [] = [] (* should not happen *)
  | CPN'nodePathToEdges [CPN'node] = []
  | CPN'nodePathToEdges (CPN'node1::(CPN'node2::CPN'nodes)) = 
    case Arcs(CPN'node1,CPN'node2) of 
	[] => raise CPN'Error ("No arc between nodes "^
			      mkst_Node(CPN'node1)^" and "^
			      mkst_Node(CPN'node2)^" in CPN'nodesToEdge")
      | CPN'arcs => (map (fn CPN'arc => (CPN'node1,CPN'arc,CPN'node2)) CPN'arcs)^^(CPN'nodePathToEdges(CPN'node2::CPN'nodes))
	    
fun CPN'arcToEdge CPN'arc = 
    (SourceNode(CPN'arc),CPN'arc,DestNode(CPN'arc))

fun CPN'arcPathToEdges [] = [] (* should not happen *)
  | CPN'arcPathToEdges [CPN'arc] = [CPN'arcToEdge CPN'arc]
  | CPN'arcPathToEdges (CPN'arc1::(CPN'arc2::CPN'rest)) = 
    if DestNode(CPN'arc1)=SourceNode(CPN'arc2)
	then (CPN'arcToEdge CPN'arc1)::(CPN'arcPathToEdges (CPN'arc2::CPN'rest))
    else raise CPN'Error ("No node between arcs "^
			  mkst_Node(CPN'arc1)^" and "^
			  mkst_Node(CPN'arc2)^" in CPN'arcPathToEdges")
	
(* Duplicates not removed *)
fun ExportNodes (CPN'filename: string, []) = 
    raise CPN'Error "No nodes to export in ExportNodes" 
  | ExportNodes (CPN'filename: string, CPN'nodes: Node list) =
	(checkNodes(CPN'nodes);
	 createFSMViewFile (CPN'filename, CPN'nodes, []));

	    
fun ExportNodePath(CPN'filename: string, []) = 
    raise CPN'Error "No path to export in ExportNodePath" 
  | ExportNodePath(CPN'filename: string, CPN'nodes: Node list) = 
    	(checkNodes(CPN'nodes);
	 createFSMViewFile (CPN'filename, 
			     case CPN'nodes of
				 [CPN'node] => [CPN'node]
			       | _ => [], 
			     CPN'nodePathToEdges CPN'nodes))

(* Duplicates not removed *)
fun ExportArcs (CPN'filename: string, []) = 
    raise CPN'Error "No arcs to export in ExportArcs" 
  | ExportArcs(CPN'filename: string, CPN'arcs: Arc list) = 
	(checkArcs(CPN'arcs);
	 createFSMViewFile(CPN'filename, [],
			    rev(EvalArcs(CPN'arcs,CPN'arcToEdge))))

fun ExportArcPath(CPN'filename: string, []) = 
    raise CPN'Error "No path to export in ExportArcPath" 
  | ExportArcPath(CPN'filename: string, CPN'arcs: Arc list) = 
	(checkArcs(CPN'arcs);
	createFSMViewFile(CPN'filename, [],
			   CPN'arcPathToEdges CPN'arcs))
		    

(* Duplicates not removed *)
fun ExportSuccessors (CPN'filename: string, []) = 
    raise CPN'Error "No nodes in ExportSuccessors"
  | ExportSuccessors (CPN'filename: string, CPN'nodes: Node list) = 
	let
	    val _ = checkNodes CPN'nodes
	    fun nodeToSuccessorEdges CPN'node = 
		map (fn arc => (CPN'node,arc,DestNode(arc))) 
		(OutArcs(CPN'node))
	    val nodesWithoutSuccessors = 
		rev(PredNodes (CPN'nodes, (fn CPN'node => OutArcs(CPN'node)=[]),NoLimit))
	    val allSuccessorEdges = 
		flatten (rev(EvalNodes(CPN'nodes, nodeToSuccessorEdges)))
	in
	    createFSMViewFile(CPN'filename, nodesWithoutSuccessors, allSuccessorEdges)
	end	


(* Duplicates not removed *)
fun ExportPredecessors (CPN'filename: string, []) = 
    raise CPN'Error "No nodes in ExportPredecessors"
  | ExportPredecessors (CPN'filename: string, CPN'nodes: Node list) = 
	let
	    val _ = checkNodes CPN'nodes
	    fun nodeToPredecessorEdges CPN'node = 
		map (fn arc => (SourceNode(arc),arc,CPN'node)) 
		(InArcs(CPN'node))
	    val nodesWithoutPredecessors = 
		rev(PredNodes(CPN'nodes,(fn CPN'node => InArcs(CPN'node)=[]), NoLimit))
	    val allPredecessorEdges = 
		flatten(rev(EvalNodes (CPN'nodes, nodeToPredecessorEdges)))
	in
	    createFSMViewFile(CPN'filename, nodesWithoutPredecessors,allPredecessorEdges)
	end	


fun ExportStateSpace (CPN'filename: string) = 
    ExportSuccessors(CPN'filename, EntireGraph);

fun ExportSccGraph (CPN'filename: string) = 
    let
	fun sccToSuccessorEdges (CPN'scc: Scc) = 
	    map (fn CPN'arc => (CPN'scc,CPN'arc,SccDestNode(CPN'arc))) 
		(SccOutArcs(CPN'scc))
	val sccsWithoutSuccessors = 
	    rev(PredAllSccs (fn CPN'scc => SccOutArcs(CPN'scc)=[]))
	val allSuccessorEdges = 
	    flatten (rev(EvalAllSccs(sccToSuccessorEdges)))
    in
	createFSMViewFile(CPN'filename, sccsWithoutSuccessors, allSuccessorEdges)
    end	
	
end;
