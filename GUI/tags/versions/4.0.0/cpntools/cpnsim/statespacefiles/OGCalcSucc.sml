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
 * Module:       OGCalcSucc.sml
 *
 * Description:  OG generation function calcSucc
 *
 * CPN Tools
 *)

(* this is the main OG generation function GenOG *)

local 

 val newnodelist = ref([]:Node list); (* temp store for numbers for new nodes *)
  
 val newarccount = ref 0;			 (* temp counter for new arcs *)
 
 val AlreadyProcesed = CPN'AvlTree.AvlNew(): unit CPN'AvlTree.avltree;
 val CPN'curtod = ref (0: Int32.int);

 (* exception used to catch exception raised during generation *)
 exception CPN'OGExcDuringGen of string ;

 fun CalcSucc' (CPN'n:Node)
     = let
         val _ = CPN'Time.model_time := (CPN'TimeEquivalence.compressTimestamp
         (CreationTime CPN'n))
       val NewCalcStat=ref FullProc; (* temp store for the future cal status of CPN'n *)
       
       fun createnewarc(srcnoderef,destnoderef,(CPN'tri,CPN'b))
          = let
             val newarcnum = CPN'OGNodeSel.NewArcNum();
		              
             val newarc
                = ref (CPN'OGarc {src=srcnoderef,
                                  dest=destnoderef,
                                  no=newarcnum,
                                  inscr=(CPN'tri,CPN'BindSearchTree.Insert
                                         (CPN'Binds,CPN'b,CPN'OGEncodeBinds CPN'b))})
            in
             CPN'AvlTree.AvlInsert CPN'OGArcs(mkst_Arc newarcnum,newarc);
              
             newarccount := !newarccount + 1;
                           
             CPN'OGUtils.GetNodePredlist(!destnoderef):=
                                   newarc::(!(CPN'OGUtils.GetNodePredlist(!destnoderef)));
                           
             CPN'OGUtils.GetNodeSucclist(!srcnoderef):=
                                   newarc::(!(CPN'OGUtils.GetNodeSucclist(!srcnoderef)))                            
                          
            end(*let*);

       fun processBindElem CPN'time (CPN'tri,CPN'b) (* execute CPN'tri with CPN'b and store *)
          = (                              (* the result in the OG structures *)
             CPN'OGToSimData.copy CPN'n; (* prepare the simulator data records *)
             CPN'Time.model_time := (!CPN'OGEnabData.next_time);

             let
		 (* execute CPN'ttri with CPN'b, and record the new binding - this is to handle output form codeseg in the right way.... *)
		 
  	      val CPN'b = (CPN'OGExecute(CPN'tri,CPN'b) 
			   handle CPN'e => 
			       (let
				    val errstr = "Exception "^exnName(CPN'e)^" raised while executing "^CPN'TransitionTable.get_name(#1 CPN'tri)^" ("^(#1 CPN'tri)^") in some binding in Node #"^Int.toString(CPN'n)^"."
				    val _ = CPN'debug (errstr)
				in
				    raise CPN'OGExcDuringGen errstr
				end))
		  
	      val srcnoderef = CPN'OGUtils.NodeToNodeRef CPN'n; 
              
              val staterec = CPN'OGstore_state(srcnoderef,CPN'tri); (* store the state *)
                                                                    (* and return res. *)
                                                                    (* staterec *)
              
              val (insertstaterec as
                   ref(CPN'OGState(innerrec as {owner=ref(noderef),...})),wasthere)
                 = CPN'RecSearchTree.Insert
                    (CPN'State'recs, staterec, CPN'OGEncode.State staterec);
             in

              if not wasthere (* we have a new state and hence we create new node *)
             then
		  let
                val newnodenum = CPN'OGNodeSel.NewNodeNum();
                
                val destnoderef (* the bare record for the new node *)
                   = ref( CPN'OGnode {state=insertstaterec,
                                      no=newnodenum,
                                      succlist=ref [],
                                      predlist=ref [], (* will be assigned below *)
                                      calcstat=ref UnProc})
                
               in
                #owner innerrec:=destnoderef;
            
                createnewarc(srcnoderef,destnoderef,(CPN'tri,CPN'b));
                  
                CPN'AvlTree.AvlInsert CPN'OGNodes(mkst_Node newnodenum,destnoderef);
           
                newnodelist:= newnodenum::(!newnodelist)
                         
               end(*let*)
        
              else (* we have reached an existing state and *)
                   (* hence we may only have to create an arc -- if it does not exist *)
         
               let 
                val destnoderef=noderef
               in
                if ListUtils.predlist (
                    fn ref(CPN'OGarc{dest=CPN'dnr,inscr=(CPN'tri2,ref CPN'b2),...})
                      => (CPN'dnr=destnoderef)andalso
                         (CPN'tri2=CPN'tri)andalso(CPN'b2=CPN'b))
                    (!(CPN'OGUtils.GetNodeSucclist(!srcnoderef)))
                then (* the arc was already there -- only when dev. prev. lim nodes *)
                  ()
                else (* create a new arc *)
                  createnewarc(srcnoderef,destnoderef,(CPN'tri,CPN'b))
                
               end(*let*)
             
             end (*let*));
             
          fun local_st_TI(CPN'trmlno,CPN'instno)
             = CPN'trmlno^","^(Int.toString CPN'instno);

      in
       
         if (!(CPN'OGUtils.GetNodeCalcStat(CPN'OGUtils.NodeToNodeRec CPN'n))<>FullProc)
             andalso
             ((!CPN'OGBranching.TransInstLimit=0)orelse
             (let
                val transinsts = CPN'AvlTree.AvlNew(): unit CPN'AvlTree.avltree
              in
               map (fn ref(CPN'OGarc{inscr=(CPN'tri,_),...})
                      => CPN'AvlTree.AvlInsert transinsts (local_st_TI CPN'tri,())
                          handle CPN'AvlTree.ExcAvlInsert => ())
                   (!(CPN'OGUtils.GetNodeSucclist(CPN'OGUtils.NodeToNodeRec CPN'n)));
               (CPN'AvlTree.AvlNo transinsts)<(!CPN'OGBranching.TransInstLimit)
              end(*let*)))
         then (* let us calculate the successors for this non-fullproc node CPN'n, 
                 which does not fulfill the transition instance branching criteria *)
          (newnodelist:=[]; newarccount:=0; (* initialization *)
           
	   CPN'OGEnabData.init();  (* initialization for immediate trans*)
	   
           CPN'OGToSimData.copy CPN'n;  (* prepare the simulator data records *)

           NewCalcStat:=FullProc; (* new calc status for CPN'n -- may be set to PartProc below *)
           
           ((CPN'OGCalcEnab() (* calculate the enabled binding elements in CPN'n *)
	     handle CPN'OGEnabData.TransInstLimitReached
	     => NewCalcStat:=PartProc)
	    handle CPN'e => (let
				 val errstr = "ML exception "^exnName(CPN'e)^" raised during calculation of enabling in node: "^(Int.toString CPN'n)
				 val _ = CPN'debug (errstr)
			     in
				 raise CPN'OGExcDuringGen errstr
			     end));
		
           if (!CPN'OGEnabData.bindlimit_reached)
           then NewCalcStat:=PartProc
           else ();
           
	   (* generate succesors for arcs stored as timed and untimed enabled binding elements *)
	   map (processBindElem (!CPN'Time.model_time)) (CPN'OGEnabData.get_cands());
	   
           CPN'OGUtils.GetNodeCalcStat(CPN'OGUtils.NodeToNodeRec CPN'n):= !NewCalcStat;
           
           CPN'AvlTree.AvlInsert AlreadyProcesed (mkst_Node CPN'n,())
             handle CPN'AvlTree.ExcAvlInsert => ();
             
           CPN'OGNodeSel.AppendList(ListUtils.mapfilter( (*add the new nodes to the selection list*)
                    ref(fn CPN'outn
                          => (((CPN'AvlTree.AvlLookup(AlreadyProcesed,mkst_Node CPN'outn);
                               false) handle CPN'AvlTree.ExcAvlLookup => true)andalso
                               (!(CPN'OGUtils.GetNodeCalcStat(CPN'OGUtils.NodeToNodeRec CPN'outn))<>FullProc),
                              CPN'outn)),
                    rev (OutNodes CPN'n)));

           (* Freeze time *)
	   CPN'curtod := tod();
             
           (if CPN'OGStopCrit.IncrAndTest(length(!newnodelist),!newarccount,[CPN'n],!CPN'curtod)
           then (* a stop criteria has been satisfied *)
            raise CPN'OGNodeSel.StopCritSatisfied
           else (* continue *)
            ());

           CPN'OGInspection.Test (!CPN'curtod)
          )
         else
          (); 

         CalcSucc'(CPN'OGNodeSel.SelectNextNode()) (* select and treat next node *)
       
      end
in
 
 fun GenOG(CPN'nl:Node list)
    = (
       CPN'OGStopCrit.InitCounts();
       CPN'OGInspection.InitCounts();
       
       if CPN'nl=[]
       then 
        CPN'OGNodeSel.BuildList()
       else
        CPN'OGNodeSel.AssignList CPN'nl;
       
       CPN'AvlTree.AvlReset AlreadyProcesed;
       let
          val CPN'CurState = !(CPN'OGCreateStateRec())
       in 
          (((CalcSucc'(CPN'OGNodeSel.SelectNextNode());
              CPN'OGToSimData.copyStateRec CPN'CurState;
	      CPN'Sim.reset_scheduler())
            handle CPN'OGNodeSel.NoSelPossible (* we are done *)
                   => (CPN'OGToSimData.copyStateRec CPN'CurState;
		       CPN'Sim.reset_scheduler();
                        (!CPN'OGInspection.Action()))
		 | CPN'OGNodeSel.StopCritSatisfied
                   => (CPN'OGToSimData.copyStateRec CPN'CurState;
		       CPN'Sim.reset_scheduler();
                        !CPN'OGInspection.Action();
                        raise CPN'OGNodeSel.StopCritSatisfied)))
	  handle CPN'OGExcDuringGen errstr
	  => (CPN'OGToSimData.copyStateRec CPN'CurState;
	      CPN'Sim.reset_scheduler();
	      (* FIXME: CPN'Error is raised so that an error message
	       * can be returned to the user. This is only necessary
	       * as long as state space functions are called via ML
	       * evaluate rather than via message passing such as what
	       * is found in simglue.sml
	       *)
	      raise CPN'Error errstr)

         end)
                 
fun CalculateOccGraph () = GenOG [];

end (*local*);
