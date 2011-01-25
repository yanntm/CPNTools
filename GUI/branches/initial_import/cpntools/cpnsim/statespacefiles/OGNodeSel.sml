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
 * Module:       OGNodeSel
 *
 * Description:  Mechanisms for selecting the next node
 *
 * CPN Tools
 *)

(* this structure hold the mechanims for selecting the next node 
 * for processing in the OG generation                           
 *)

structure CPN'OGNodeSel =
struct

exception StopCritSatisfied;
exception NoSelPossible;

val NextNodeNum = ref 0;
fun NewNodeNum () = (NextNodeNum:=(!NextNodeNum + 1);!NextNodeNum);

val NextArcNum = ref 0;
fun NewArcNum () = (NextArcNum:=(!NextArcNum + 1);!NextArcNum);


local
 
 val ToProcess = ref ([]:Node list);

 fun StdSelNextNode():Node
   = if !ToProcess=[] 
      then
         raise NoSelPossible
      else
         let
          val nexthead::nexttail = (!ToProcess)
         in
          ToProcess:= nexttail;
          if !CPN'OGBranching.Pred nexthead
          then
           nexthead
          else (CPN'OGUtils.GetNodeCalcStat(CPN'OGUtils.NodeToNodeRec nexthead):=PartProc;
            StdSelNextNode())
         end(*let*); 
  
 val OnlyThisList=ref false;

in
  val SelectNextNode = StdSelNextNode;
  
  fun AssignList CPN'nl (* assigns list of nodes to be processed - omits illegal nodes *)
     = ToProcess:= ListUtils.mapfilter(
                    ref(fn CPN'n
                          => ((CPN'AvlTree.AvlLookup (CPN'OGNodes,mkst_Node CPN'n);
                               true) handle CPN'AvlTree.ExcAvlLookup => false,
                              CPN'n)),
                    CPN'nl);
  
  fun AppendList CPN'nl (* appends list to list of nodes to be processed *)
     = if !OnlyThisList
       then ()
       else ToProcess:= (!ToProcess)^^(CPN'nl);
                    
  fun BuildList() (* assigns list of all non-full processed nodes to the list to be processed *)
     = (CPN'AvlTree.AvlApp(
        fn ref(CPN'OGnode{calcstat,no,...})
          => if !calcstat<>FullProc
             then
              if !CPN'OGBranching.Pred no
              then ToProcess:= no::(!ToProcess)
              else calcstat:= PartProc
             else
              (),
         CPN'OGNodes);
        ToProcess:= rev (!ToProcess))

  fun InitList() = ToProcess:=[]

  fun StartSelOnlyOne() = OnlyThisList:=true;

  fun RestoreStdSel() =  OnlyThisList:=false;

end(*local*)

end(*struct*); 
