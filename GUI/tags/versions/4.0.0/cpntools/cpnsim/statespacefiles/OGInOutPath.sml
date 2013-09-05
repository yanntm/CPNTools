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
 * Module:       OGInOutPath     
 *
 * Description:  Graph functions on the OG
 *
 * CPN Tools
 *)

(* this files defines all the graph functions on the OG *)

fun InArcs (CPN'n:Node):Arc list
   = map (fn ref(CPN'a) => CPN'OGUtils.GetArcNo CPN'a)
      (!(CPN'OGUtils.GetNodePredlist(CPN'OGUtils.NodeToNodeRec CPN'n)));

fun OutArcs (CPN'n:Node):Arc list
   = map (fn ref(CPN'a) => CPN'OGUtils.GetArcNo CPN'a)
      (!(CPN'OGUtils.GetNodeSucclist(CPN'OGUtils.NodeToNodeRec CPN'n)));

fun InNodes (CPN'n:Node):Node list
   = ListUtils.remdupl
      (map (fn ref(CPN'OGarc{src=ref CPN'sn,...}) => CPN'OGUtils.GetNodeNo CPN'sn) 
           (!(CPN'OGUtils.GetNodePredlist(CPN'OGUtils.NodeToNodeRec CPN'n))));

fun OutNodes (CPN'n:Node):Node list
   = ListUtils.remdupl
      (map (fn ref(CPN'OGarc{dest=ref CPN'dn,...}) => CPN'OGUtils.GetNodeNo CPN'dn) 
           (!(CPN'OGUtils.GetNodeSucclist(CPN'OGUtils.NodeToNodeRec CPN'n))));
           
fun SourceNode (CPN'a:Arc):Node
   = CPN'OGUtils.GetNodeNo(!(CPN'OGUtils.GetArcSrc(CPN'OGUtils.ArcToArcRec CPN'a)));

fun DestNode (CPN'a:Arc):Node
   = CPN'OGUtils.GetNodeNo(!(CPN'OGUtils.GetArcDest(CPN'OGUtils.ArcToArcRec CPN'a)));

fun Arcs (CPN'n1:Node,CPN'n2:Node):Arc list
   = ListUtils.mapfilter
      (ref(fn ref(CPN'OGarc{dest=ref CPN'dn,no=CPN'a,...})
             => (CPN'OGUtils.GetNodeNo CPN'dn=CPN'n2,CPN'a)), 
       !(CPN'OGUtils.GetNodeSucclist(CPN'OGUtils.NodeToNodeRec CPN'n1)));

exception NoPathExists;


local
 
 val Noderefs = CPN'AvlTree.AvlNew()    (* temp store to contains paths *)
  :((CPN'OGnoderec ref)*(Node list)) CPN'AvlTree.avltree;
 
 val ToProcess = ref([]:Node list);
 val CPN'path = ref([]: Node list);
 fun ProcessNew CPN'n =
  let
   val (_,CPN'path) (* the path from CPN'n1 to CPN'n (reversed) *)
      = CPN'AvlTree.AvlLookup(Noderefs,mkst_Node CPN'n)
  in
   map (fn CPN'outn
          => (CPN'AvlTree.AvlLookup(Noderefs,mkst_Node CPN'outn)
               
               handle CPN'AvlTree.ExcAvlLookup (* store path from n1 to CPN'outn *)
                     => (
                         CPN'AvlTree.AvlInsert Noderefs
                         (mkst_Node CPN'outn,
                           (CPN'OGUtils.NodeToNodeRef CPN'outn,
                            CPN'outn::CPN'path));
                         
                         ToProcess:=CPN'outn::(!ToProcess);
                         
                         (CPN'OGUtils.NodeToNodeRef CPN'outn,
                          [])(*dummy value*));
              ()
             )
        )
   (OutNodes CPN'n)
  end;
 
 fun AreWeDone CPN'nr2
    = let val (_,CPN'path)
             = CPN'AvlTree.AvlLookup
                (Noderefs,mkst_Node(CPN'OGUtils.GetNodeNo(!CPN'nr2)))
               
               handle CPN'AvlTree.ExcAvlLookup (* nr2 not found so process another round *)
                     => let
                         val newcand = ListUtils.remdupl(!ToProcess)
                        in
                         if newcand=[]
                         then (* no more cands, hence no path *)
                          (CPN'nr2(*dummy value*),[])
                         else (* process the cands, and test whether we are done or not *)
                          (
                           ToProcess:=[];
                           
                           map ProcessNew newcand;
                           
                           (CPN'nr2(*dummy value*),AreWeDone CPN'nr2)
                          )
                        end(*let*)
      in
       CPN'path
      end(*let*);
in
 fun NodesInPath (CPN'n1:Node,CPN'n2:Node) = (* implementaion of Dijkstra's shortest path alg *)
                                      (* with the modification that we stop when n2 is *)
                                      (* reached *)
  (
   CPN'AvlTree.AvlReset Noderefs;
   
   CPN'AvlTree.AvlInsert Noderefs (* record that there is a path from n1 to n1 ! *)
    (mkst_Node CPN'n1,(CPN'OGUtils.NodeToNodeRef CPN'n1,[CPN'n1]));
   
   ToProcess:=[CPN'n1];
   
   CPN'path:=rev(AreWeDone(CPN'OGUtils.NodeToNodeRef CPN'n2));


  if ((!CPN'path)=[])
      then raise NoPathExists
  else
      (!CPN'path))  
end;

fun ArcsInPath (from:Node,to:Node)
   = let
      fun arcs(n1::(n2::rest))
        = (hd(Arcs(n1,n2)))::(arcs(n2::rest))
       | arcs n1 = []
     in arcs(NodesInPath(from,to))
end;
     
fun NoOfNodes() = CPN'AvlTree.AvlNo CPN'OGNodes;

fun NoOfArcs() = CPN'AvlTree.AvlNo CPN'OGArcs;

fun Terminal(CPN'n:Node) = OutArcs CPN'n = [];

