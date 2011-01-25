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
 * Module:       OGStopLimitCrit
 *
 * Description:  Storage for stop/limitation criteria
 *
 * CPN Tools
 *)

(* this file contains structures for storing: 
 * 1) the stop criteria and a test function   
 * 2) the limitation criteria                 
 *)


structure CPN'OGStopCrit = struct
val NodeLimit=ref 0;         
val ArcLimit=ref 0;
val CompTimeLimit=ref (0:Int32.int);               
val ProcNodePred = ref (fn(CPN'n:Node)=>false);
local
 val NodeCount=ref 0;
 val ArcCount=ref 0;
 val NextStopTime=ref (0:Int32.int);
 val TotalTime=ref (0:Int32.int);
 val LastTotalCalc=ref (0:Int32.int);
 val StartTime=ref (0:Int32.int);
 exception ProcPredTrue;
 in

 fun InitCounts()
    =let
      val curtod = tod()
     in
      NodeCount:=0;
      ArcCount:=0;
      NextStopTime:=
       (if !CompTimeLimit=0 then valOf(Int32.maxInt) else !CompTimeLimit+curtod);
      LastTotalCalc:=curtod;
      StartTime:=curtod
     end(*let*);

 fun IncrAndTest(CPN'newnodes,CPN'newarcs,CPN'procnl,CPN'curtod)
    =((*update counters*)
      NodeCount:= !NodeCount + CPN'newnodes;
      ArcCount:= !ArcCount + CPN'newarcs;
      
      TotalTime:= !TotalTime + (CPN'curtod - !LastTotalCalc);
      LastTotalCalc:=CPN'curtod;
      
      (*test counters and return result*)
      ((map (fn CPN'n
              => if !ProcNodePred CPN'n then raise ProcPredTrue else ())
           CPN'procnl;
        false)
       handle ProcPredTrue => true) orelse
      ((!NodeLimit<>0)andalso(!NodeLimit<= !NodeCount))orelse
      ((!ArcLimit<>0)andalso(!ArcLimit<= !ArcCount))orelse
      (!NextStopTime<=tod()));
  

 fun StandardReport()
    = let
       val curtod=tod();
       val nodecountstr=Int.toString(!NodeCount)^
                        (if !NodeLimit<>0
                         then "/"^(Int.toString(!NodeLimit))
                         else "");
       val totalnodecountstr=Int.toString(CPN'AvlTree.AvlNo CPN'OGNodes);
       val arccountstr=Int.toString(!ArcCount)^
                        (if !ArcLimit<>0
                         then "/"^(Int.toString(!ArcLimit))
                         else "");
       val totalarccountstr=Int.toString(CPN'AvlTree.AvlNo CPN'OGArcs);
       val thistimestr=Int32.toString(curtod- !StartTime)^
                        (if !CompTimeLimit<>0
                         then "/"^(Int32.toString(!CompTimeLimit))
                          else "");
       val totaltimestr=Int32.toString(!TotalTime) 
      in
       (nodecountstr^"/"^totalnodecountstr,
        arccountstr^"/"^totalarccountstr,
        thistimestr^"/"^totaltimestr)
      end(*let*);

 fun GetTotalTime()
    = Int32.toString(!TotalTime);

 fun GetTotalTimeSecs()
    = !TotalTime;
end;

fun SetParams{NodeLimit=CPN'nl,ArcLimit=CPN'al,
              CompTimeLimit=CPN'ctl,ProcNodePred=CPN'pnp}
   = (NodeLimit:=CPN'nl;
      ArcLimit:=CPN'al;
      CompTimeLimit:=CPN'ctl;
      ProcNodePred:= CPN'pnp);

end(*struct*);

structure CPN'OGBranching = struct
 val TransInstLimit=ref 0;
 val BindingLimit=ref 0;
 val Pred  = ref (fn(CPN'n:Node)=>true);
 fun SetParams{Pred=CPN'pf,TransInstLimit=CPN'til,BindingLimit=CPN'bl}
    = (TransInstLimit:= CPN'til;
       BindingLimit:= CPN'bl;
       Pred:= CPN'pf);

end(*struct*);

structure CPN'OGInspection = struct
 val Freq=ref 0;
 val StandardReport = CPN'OGStopCrit.StandardReport;
    val Action=ref (fn () => ())
 local
  val NextInspectTime=ref (0:Int32.int)
 in
  fun InitCounts()
     = NextInspectTime:=
       (if !Freq=0 then valOf(Int32.maxInt) else (Int32.fromInt(!Freq))+tod());
 
  fun Test CPN'curtod
    = if !NextInspectTime<=CPN'curtod
      then (!Action();
            NextInspectTime:= (Int32.fromInt(!Freq)+CPN'curtod))
      else ()
 end(*local*);
 fun SetParams{Frequency=CPN'fs,Action=CPN'a}
    = (Freq:=CPN'fs; Action:=CPN'a);

end(*struct*);

fun NoOfSecs () = Int32.toInt(CPN'OGStopCrit.GetTotalTimeSecs ());

val EntireGraph = [0];

val NoLimit = 0;

CPN'OGStopCrit.SetParams{
     NodeLimit= 0,
     ArcLimit= 0,
     CompTimeLimit= 300,
     ProcNodePred= fn _ => false};

CPN'OGInspection.SetParams{
     Frequency= 60,
     Action= !CPN'OGInspection.Action};

CPN'OGBranching.SetParams{
     Pred= fn _ => true,
     TransInstLimit= 0,
     BindingLimit= 0};
