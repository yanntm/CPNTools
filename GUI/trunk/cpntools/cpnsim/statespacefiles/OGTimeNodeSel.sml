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
 * Module:       OGTimeNodeSel
 *
 * Description:  Mechanisms for selecting the next node - tailored for time
 *
 * CPN Tools
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

    (* time addition, begin *)
    fun CreationTime CPN'n = #creationtime(CPN'OGUtils.GetStateRec CPN'n);
	
    fun CPN'sort_nodes [] = []
      | CPN'sort_nodes (CPN'n::CPN'r)
	= let
	      val CPN'cr_time = CreationTime CPN'n;
	      fun CPN'ins [] = [CPN'n]
		| CPN'ins (CPN'n1::CPN'r1)
		  = if not (CPN'Time.leq((CreationTime CPN'n1),CPN'cr_time))
			then (CPN'n::(CPN'n1::CPN'r1))
		    else (CPN'n1::(CPN'ins CPN'r1))
	  in
	      CPN'ins (CPN'sort_nodes CPN'r)
	  end;
	   
    fun CPN'insert_list [] CPN'lst _ = CPN'lst
      | CPN'insert_list (CPN'n1::CPN'r1) CPN'lst CPN'cr_time
	=  if not (CPN'Time.leq((CreationTime CPN'n1),CPN'cr_time))
	       then CPN'lst^^(CPN'n1::CPN'r1)
	   else (CPN'n1::(CPN'insert_list CPN'r1 CPN'lst CPN'cr_time));
	       
    (* time addition, end *)

 val ToProcess = ref ([]:Node list);

 fun StdSelNextNode():Node
   = if !ToProcess=[] 
      then
         raise NoSelPossible
      else
         let
          val CPN'nexthead::CPN'nexttail = (!ToProcess)
         in
          ToProcess:= CPN'nexttail;
          if !CPN'OGBranching.Pred CPN'nexthead
          then
           CPN'nexthead
          else (CPN'OGUtils.GetNodeCalcStat(CPN'OGUtils.NodeToNodeRec CPN'nexthead):=PartProc;
            StdSelNextNode())
         end(*let*); 
  
 val OnlyThisList=ref false;

in
  val SelectNextNode = StdSelNextNode;
  
  fun AssignList CPN'nl (* assigns list of nodes to be processed - omits illegal nodes *)
     = ToProcess := 
       CPN'sort_nodes
           (ListUtils.mapfilter(
				      ref(fn CPN'n
					     => ((CPN'AvlTree.AvlLookup (CPN'OGNodes,mkst_Node CPN'n);
						  true) handle CPN'AvlTree.ExcAvlLookup => false,
						 CPN'n)),
				      CPN'nl));
  
  fun AppendList [] = () (* appends list to list of nodes to be processed *)
    | AppendList CPN'nl (* appends list to list of nodes to be processed *)
     = if !OnlyThisList
       then ()
       else 
	   ToProcess:= 
		CPN'insert_list (!ToProcess) CPN'nl (CreationTime(hd CPN'nl))
                    
  fun BuildList() (* assigns list of all non-full processed nodes to the list to be processed *)
     = (CPN'AvlTree.AvlApp(
        fn ref(CPN'OGnode{calcstat,no = CPN'no,...})
          => if !calcstat<>FullProc
             then
              if !CPN'OGBranching.Pred CPN'no
              then ToProcess:= (CPN'no)::(!ToProcess)
              else calcstat:= PartProc
             else
              (),
         CPN'OGNodes);
        ToProcess:= CPN'sort_nodes (rev(!ToProcess)))

  fun InitList() = ToProcess:=[]

  fun StartSelOnlyOne() = OnlyThisList:=true;

  fun RestoreStdSel() =  OnlyThisList:=false;

end(*local*)

end(*struct*); 
