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
 * Module:       OGProps.sml
 *
 * Description:  Basic Query functions cf. Jensen[2]
 *
 * CPN Tools
 *)

(* This file contains functions to analyze O-graphs and their corresponding 
 * SCC-graphs. The functions correspond to results in Kurt Jensens book on
 * Coloured Petri Nets, Volume 2: Analysis Methods ([Jensen]). Each analysis 
 * function is preceded with a comment stating which result in [Jensen] it 
 * corresponds to 
 *)

(* Basic List Operation *)
fun CPN'overlap [] _ = false
  | CPN'overlap _ [] = false
  | CPN'overlap (CPN'h::CPN't) CPN'l2 = (mem CPN'l2 CPN'h) orelse (CPN'overlap CPN't CPN'l2);

(* Special-purpose auxiliary functions *)
fun CPN'memBE [] CPN'x = false
  | CPN'memBE CPN'l CPN'x 
   = let
      val CPN'tmp = mkst_BE CPN'x;
      fun CPN'LocMem [] = false
        | CPN'LocMem (CPN'h::CPN't)
	  = CPN'tmp = (mkst_BE CPN'h) orelse (CPN'LocMem CPN't)
     in
      CPN'LocMem CPN'l
     end;
fun CPN'overlapBE [] _ = false
  | CPN'overlapBE (CPN'h::CPN't) CPN'x
    = (CPN'memBE CPN'x CPN'h) orelse (CPN'overlapBE CPN't CPN'x);

(* General-purpose auxiliary functions *)
fun CPN'rmem CPN'x CPN'l = mem CPN'l CPN'x;

fun CPN'int_list_to_string CPN'l =
   let
       fun CPN'lts [] = ""
        |  CPN'lts [(CPN'x:int)] = Int.toString CPN'x
        |  CPN'lts ((CPN'x:int)::(CPN'y:int)::CPN'l) = 
                (Int.toString CPN'x)^", "^(CPN'lts (CPN'y::CPN'l));
   in
       "["^CPN'lts CPN'l^"]"
   end;
  
(**** Prop 1.12: ****)
(*ii*)
fun Reachable (CPN'm1,CPN'm2) = ((NodesInPath(CPN'm1,CPN'm2);
				 true)
				 handle NoPathExists => (false))
    
fun Reachable' (CPN'm1,CPN'm2) = 
let 
   val CPN'p = (NodesInPath (CPN'm1,CPN'm2)
		handle NoPathExists => []);
   val CPN'res = CPN'p<>[]  
in
   if CPN'res then 
     print("A path from node "^Int.toString CPN'm1^" to node "^Int.toString CPN'm2^
           " is: "^CPN'int_list_to_string CPN'p^"\n")
   else
     print("There is no path from "^Int.toString CPN'm1^" to "^Int.toString CPN'm2^"\n");
   CPN'res
end;       

(*iii*)
fun SccReachable (CPN'm1,CPN'm2) = 
let 
   val CPN'p = SccNodesInPath (NodeToScc CPN'm1,NodeToScc CPN'm2);
in
   CPN'p<>[] 
end;       

fun SccReachable' (CPN'm1,CPN'm2) = 
let 
   val CPN'p = SccNodesInPath (NodeToScc CPN'm1,NodeToScc CPN'm2);
   val CPN'res = CPN'p<>[] 
in
   if CPN'res then 
     print("A path from the SCC of node "^
            Int.toString CPN'm1^" to the SCC of node "^
            Int.toString CPN'm2^" is: "^CPN'int_list_to_string CPN'p^"\n")
   else
     print("There is no path from node "^Int.toString CPN'm1^" to node "^
            Int.toString CPN'm2^"\n");
   CPN'res
end;       

(*iv*)
fun AllReachable () = SccNoOfNodes () = 1;

(**** Prop 1.13 ****)
(*i*)

(* FIXME: Calculations of multisetbounds is not correct!!!  *)

fun CPN'UpperMultiSet (CPN'pimf) = 
    let
	fun CPN'ub (CPN'ms1,nil) = CPN'ms1
          | CPN'ub (CPN'ms1,CPN'ms2)
            = let
		fun CPN'skip (nil,CPN'col) = nil
		  | CPN'skip ((CPN'c::CPN'ms),CPN'col) = 
		    if CPN'c = CPN'col 
		    then CPN'skip (CPN'ms,CPN'col)
		    else CPN'c::(CPN'skip (CPN'ms,CPN'col))
		fun CPN'LocUb nil = CPN'ms2
		  | CPN'LocUb (CPN'col::CPN'ms1) =
		    (case (Int.max((CPN'MS.cf(CPN'col,CPN'ms1)+1)-CPN'MS.cf(CPN'col,CPN'ms2),0))
		      of 0 => CPN'LocUb CPN'ms1
		       | CPN'coef  => CPN'MS.++(CPN'coef`CPN'col,
						(CPN'LocUb (CPN'skip(CPN'ms1,CPN'col)))))
            in
		CPN'LocUb CPN'ms1
            end
    in
	SearchAllNodes(fn _=>true, CPN'pimf, empty, CPN'ub) 
    end;
    
fun CPN'UpperIntegerTimedMultiSet (CPN'pimf)
(*   = CPN'UpperMultiSet (CPN'IntegerTime.striptime o CPN'pimf);*)
    = CPN'UpperMultiSet ((fn CPN'x => map CPN'Time.col CPN'x) o CPN'pimf);

val UpperMultiSet = CPN'UpperMultiSet;
val UpperTimedMultiSet = CPN'UpperIntegerTimedMultiSet;

fun CPN'LowerMultiSet (CPN'pimf)
   = let
      fun CPN'lb (_,nil) = nil
        | CPN'lb (CPN'ms1,CPN'ms2)
         = let
	     fun CPN'skip (nil,CPN'col) = nil
	       | CPN'skip ((CPN'c::CPN'ms),CPN'col) = 
		 if CPN'c = CPN'col 
		 then CPN'skip (CPN'ms,CPN'col)
		 else CPN'c::(CPN'skip (CPN'ms,CPN'col))
             fun CPN'LocLb nil = nil
               | CPN'LocLb (CPN'col::CPN'ms1)
		 = (case Int.min((CPN'MS.cf(CPN'col,CPN'ms1)+1),CPN'MS.cf(CPN'col,CPN'ms2))
                     of 0 => CPN'LocLb CPN'ms1
                      | CPN'coef => CPN'MS.++(CPN'coef`CPN'col,(CPN'LocLb (CPN'skip(CPN'ms1,CPN'col)))))
         in
             CPN'LocLb CPN'ms1
         end
     in
      SearchAllNodes(fn _=>true, CPN'pimf, (CPN'pimf InitNode) , CPN'lb)
     end;

fun CPN'LowerIntegerTimedMultiSet (CPN'pimf)
   = CPN'LowerMultiSet((fn CPN'x => map CPN'Time.col CPN'x) o CPN'pimf);


val LowerMultiSet = CPN'LowerMultiSet;
val LowerTimedMultiSet = CPN'LowerIntegerTimedMultiSet;



(* ii (small modification)*)
fun UpperInteger (CPN'pimf)
   = SearchAllNodes
      (fn _=> true,
       CPN'MS.size o CPN'pimf,

       0,Int.max);

(* ii - version "lower" (small modification)*)
fun LowerInteger (CPN'pimf)
   = SearchAllNodes
      (fn _=> true,
       CPN'MS.size o CPN'pimf,
       (CPN'MS.size o CPN'pimf) InitNode,

       Int.min);

(**** Prop 1.14: ****)
(*i*)
fun HomeSpace CPN'NodeList
  = let
      val CPN'NodeListExp = (if CPN'Time.name <> "unit"
			     then 
				 flatten (map EqualsUntimed CPN'NodeList)
			     else CPN'NodeList)
    in
      SearchSccs ([0],
                fn CPN'scc =>(SccTerminal CPN'scc) andalso
		              (not(CPN'rmem CPN'scc 
				   (remdupl (map NodeToScc CPN'NodeListExp)))),
			      1, fn _ => (), true, fn _=> false)
    end

fun HomeSpace' CPN'NodeList
  = SearchSccs ([0],
                fn CPN'scc => if (SccTerminal CPN'scc) andalso
                             (not(CPN'rmem CPN'scc (remdupl (map NodeToScc CPN'NodeList))))
                          then 
                             (print("No given node can be found in the terminal SCC: "^Int.toString(CPN'scc)^"\n"); 
                              true)
                          else 
                              false,
                1, fn _ => (), true, fn _=> false);

fun HomePredicate CPN'Predicate
 =
let
   fun CPN'ContainsNoSatisfying CPN'scc = List.null (PredNodes(SccToNodes CPN'scc, CPN'Predicate, 1))
in
   List.null (PredSccs (PredAllSccs SccTerminal, CPN'ContainsNoSatisfying, 1))
end


(*ii*)
fun MinimalHomeSpace () = 
    let 
	val CPN'TermSccs = PredAllSccs SccTerminal
    in
	length CPN'TermSccs
    end

(*iii*)
fun HomeMarking CPN'Node
  = (if CPN'Time.name <> "unit"
	 then
	     HomeSpace (EqualsUntimed CPN'Node)
     else
	 SearchSccs ([0],
		     fn CPN'scc =>(SccTerminal CPN'scc) andalso 
		     ((NodeToScc CPN'Node) <> CPN'scc),
		     1, fn _ => (), true, fn _=> false));
		 
fun HomeMarking' CPN'Node
  = SearchSccs ([0],
                fn CPN'scc => if (SccTerminal CPN'scc) andalso 
                             ((NodeToScc CPN'Node) <> CPN'scc)
                          then 
                             (print("The given node is not contained in the terminal SCC: "^Int.toString(CPN'scc)^"\n"); 
                              true)
                          else 
                              false,
                1, fn _ => (), true, fn _=> false);

fun ListHomeMarkings () =
    let
	val CPN'TermSccs = PredAllSccs SccTerminal
    in
	if length CPN'TermSccs = 1
	    then SccToNodes(hd(CPN'TermSccs))
	else
	    []
    end

fun ListHomeScc () =		
    let 
	val CPN'TermSccs = PredAllSccs SccTerminal
    in
	if length CPN'TermSccs = 1
	    then (hd(CPN'TermSccs))
	else
	    0
    end

(*iv*)
fun HomeMarkingExists ()
 = SearchSccs ([0], SccTerminal, 2, fn _ => 1, 0, op +) = 1;

(*v*)
fun InitialHomeMarking () = 
    (if CPN'Time.name <> "unit"
	 then
	     HomeSpace (EqualsUntimed InitNode)
     else
	 SccNoOfNodes () = 1);
	 
(**** Prop 1.15: ****)
(*i*)
fun DeadMarking CPN'Node = OutArcs CPN'Node = [];

fun ListDeadMarkings () = PredAllNodes Terminal;

fun SccListDeadMarkings () = 
    let 
	fun CPN'TermAndTriv CPN'n = SccTerminal CPN'n andalso SccTrivial CPN'n
    in
	flatten (map SccToNodes (PredAllSccs CPN'TermAndTriv))
    end;

(*iii*)
fun BEsDead (CPN'BindingElementList,CPN'Node)
   = SearchReachableSccs
      (NodeToScc CPN'Node,
       fn CPN'scc => (CPN'overlapBE (map ArcToBE ((SccToArcs CPN'scc)^^
                    (SccOutArcs CPN'scc))) CPN'BindingElementList),
       1, fn _ => (),true, fn _ => false);

fun BEsDead' (CPN'BindingElementList,CPN'Node)
   = SearchReachableSccs
      (NodeToScc CPN'Node,
       fn CPN'scc => if (CPN'overlapBE (map ArcToBE ((SccToArcs CPN'scc)^^
                    (SccOutArcs CPN'scc))) CPN'BindingElementList)
                 then
                    (print("A binding element from the given list is contained in the SCC: "^Int.toString(CPN'scc)^" (which is reachable from the SCC of the given node)\n"); 
                    true)
                 else
                    false,
       1, fn _ => (),true, fn _ => false);

fun ListDeadTIs () = 
    let 
	fun CPN'delete (_,[]) = []
	  | CPN'delete (CPN'x,CPN'y::CPN'ys) = if (CPN'x = CPN'y)
				      then CPN'ys
				  else
				      CPN'y::CPN'delete(CPN'x,CPN'ys)

	fun CPN'subtract (CPN'xs,[]) = CPN'xs
	  | CPN'subtract (CPN'xs,CPN'y::CPN'ys) = CPN'subtract(CPN'delete(CPN'y,CPN'xs),CPN'ys)
 
    in
	CPN'subtract (TI.All,remdupl(EvalAllArcs(fn CPN'a => ArcToTI(CPN'a))))
    end


fun TIsDead (CPN'TransInstList,CPN'Node)
   = SearchReachableSccs
      (NodeToScc CPN'Node,
       fn CPN'scc => (CPN'overlap (map ArcToTI ((SccToArcs CPN'scc)^^(SccOutArcs CPN'scc))) CPN'TransInstList),
       1, fn _ => (),true, fn _ => false);

fun TIsDead' (CPN'TransInstList,CPN'Node)
   = SearchReachableSccs
      (NodeToScc CPN'Node,
       fn CPN'scc => if (CPN'overlap (map ArcToTI ((SccToArcs CPN'scc)^^(SccOutArcs CPN'scc)))
                     CPN'TransInstList)
                 then
                    (print("A transition instance from the given list is contained in the SCC: "^Int.toString(CPN'scc)^" (which is reachable from the SCC of the given node)\n");
                    true)
                 else
                    false,
       1, fn _ => (),true, fn _ => false);

(*iv*)
fun BEsLive CPN'BindingElementList
  = SearchSccs ([0],
                fn CPN'scc => (SccTerminal CPN'scc) andalso
                             (not (CPN'overlapBE (map ArcToBE (SccToArcs CPN'scc))
                              CPN'BindingElementList)),
                1, fn _ => (), true, fn _=> false);

fun BEsLive' CPN'BindingElementList
  = SearchSccs ([0],
                fn CPN'scc => if (SccTerminal CPN'scc) andalso
                             (not (CPN'overlapBE (map ArcToBE (SccToArcs CPN'scc))
                              CPN'BindingElementList))
                          then
                              (print("No binding element from the given list is contained in the terminal SCC: "^Int.toString(CPN'scc)^"\n" );
                              true)
                          else
                              false,
                1, fn _ => (), true, fn _=> false);

fun TIsLive CPN'TransInstList
  = SearchSccs ([0],
                fn CPN'scc =>(SccTerminal CPN'scc) andalso
                             (not (CPN'overlap (map ArcToTI (SccToArcs CPN'scc))
                              CPN'TransInstList)),
                1, fn _ => (), true, fn _=> false);

fun TIsLive' CPN'TransInstList
  = SearchSccs ([0],
                fn CPN'scc => if (SccTerminal CPN'scc) andalso
                             (not (CPN'overlap (map ArcToTI (SccToArcs CPN'scc))
                              CPN'TransInstList))
                          then
                             (print("No transition instance from the given list is contained in the terminal SCC: "^Int.toString(CPN'scc)^"\n" );
                              true)
                          else
                              false,
                1, fn _ => (), true, fn _=> false);

fun ListLiveTIs () = 
    let
	fun CPN'member (CPN'x,[]) = false
	  | CPN'member (CPN'x,CPN'y::CPN'ys)
	    = ((CPN'x = CPN'y) orelse (CPN'member (CPN'x,CPN'ys)))

	fun CPN'intersect ([],CPN'ys) = []
	  | CPN'intersect (CPN'x::CPN'xs,CPN'ys)
	    = if (CPN'member (CPN'x,CPN'ys))
		  then
		      CPN'x::(CPN'intersect(CPN'xs,CPN'ys))
	      else
		  CPN'intersect(CPN'xs,CPN'ys)
    in
	SearchAllSccs(SccTerminal,
		      fn CPN'n => remdupl(EvalArcs
					  (SccToArcs(CPN'n),
					   fn CPN'a => ArcToTI(CPN'a))),
		      TI.All,
		      CPN'intersect)
    end

fun BEsStrictlyLive CPN'BindingElementList =
    let
	fun CPN'BELive CPN'BindingElement = BEsLive [CPN'BindingElement]

	fun CPN'alllive ([]) = true
	  | CPN'alllive (CPN'x::CPN'xs) = CPN'x andalso (CPN'alllive CPN'xs)
    in
	CPN'alllive (map CPN'BELive CPN'BindingElementList)
    end

(**** Prop 1.16: ****)
(*iv*)

datatype FairnessProperty = Impartial | Fair | Just | No_Fairness

fun CPN'BEsImpartial CPN'BindingElementList
   = SearchSubgraphSccs
      (fn _ => true,
       fn CPN'arc => not (CPN'memBE CPN'BindingElementList (ArcToBE CPN'arc)),
       not o TrivialSubgraphScc,
       1, fn _ => (), true, fn _ => false);

fun CPN'TIsImpartial CPN'TransInstList
   = SearchSubgraphSccs
      (fn _ => true,
       fn CPN'arc => not (mem CPN'TransInstList (ArcToTI CPN'arc)),
       not o TrivialSubgraphScc,
       1, fn _ => (), true, fn _ => false);

fun CPN'BEsFair CPN'BindingElementList
   = SearchSubgraphSccs
      (fn _ => true,
       fn CPN'arc => not (CPN'memBE (CPN'BindingElementList) (ArcToBE CPN'arc)),
       fn (CPN'scc as (CPN'nodes,_,_)) =>
           not ((TrivialSubgraphScc CPN'scc) orelse
                (not (CPN'overlapBE 
		      (map ArcToBE (flatten (map OutArcs CPN'nodes)))
		      CPN'BindingElementList))),
       1, fn _ => (), true, fn _ => false);

fun CPN'TIsFair CPN'TransInstList
   = SearchSubgraphSccs
      (fn _ => true,
       fn CPN'arc => not (mem CPN'TransInstList (ArcToTI CPN'arc)),
       fn (CPN'scc as (CPN'nodes,_,_)) =>
           not ((TrivialSubgraphScc CPN'scc) orelse
                (not (CPN'overlap (map ArcToTI (flatten (map OutArcs CPN'nodes)))
                              CPN'TransInstList))),
       1, fn _ => (), true, fn _ => false);

fun CPN'BEsJust CPN'BindingElementList
   = SearchSubgraphSccs
      (fn _ => true,
       fn CPN'arc => not (CPN'memBE CPN'BindingElementList (ArcToBE CPN'arc)),
       fn (CPN'scc as (CPN'nodes,CPN'arcs,CPN'outarcs)) =>
           (not (TrivialSubgraphScc CPN'scc) andalso
                (SearchSubgraphCycles 
                  (CPN'nodes,
                   fn CPN'node =>
                    (mem CPN'nodes CPN'node) andalso
                    (CPN'overlapBE CPN'BindingElementList 
		     (map ArcToBE (OutArcs CPN'node))),
                   fn CPN'arc => not (CPN'memBE 
				      CPN'BindingElementList(ArcToBE CPN'arc)),
                   fn _ => true,
                   1, fn _ => (), false, fn _ => true))
                ),
       1, fn _ => (), true, fn _ => false);

fun CPN'TIsJust CPN'TransInstList
   = SearchSubgraphSccs
      (fn _ => true,
       fn CPN'arc => not (mem CPN'TransInstList (ArcToTI CPN'arc)),
       fn (CPN'scc as (CPN'nodes,CPN'arcs,CPN'outarcs)) =>
           (not (TrivialSubgraphScc CPN'scc) andalso
                (SearchSubgraphCycles 
                  (CPN'nodes,
                   fn CPN'node =>
                    (mem CPN'nodes CPN'node) andalso
                    (CPN'overlap CPN'TransInstList (map ArcToTI 
						(OutArcs CPN'node))),
                   fn CPN'arc => not (mem CPN'TransInstList (ArcToTI CPN'arc)),
                   fn _ => true,
                   1, fn _ => (), false, fn _ => true))
                ),
       1, fn _ => (), true, fn _ => false);

fun TIsFairness CPN'TIsl =
    (if (CPN'TIsImpartial CPN'TIsl)
	 then Impartial
     else
	 (if (CPN'TIsFair CPN'TIsl)
	      then Fair
	  else
	      (if (CPN'TIsJust CPN'TIsl)
		   then Just
	       else
		   No_Fairness)))

fun BEsFairness CPN'BEsl =
    (if (CPN'BEsImpartial CPN'BEsl)
	 then Impartial
     else
	 (if (CPN'BEsFair CPN'BEsl)
	      then Fair
	  else
	      (if (CPN'BEsJust CPN'BEsl)
		   then Just
	       else
		   No_Fairness)))
		  
fun CPN'predlist CPN'f [] = []
  | CPN'predlist CPN'f (CPN'x::CPN'xs)
    = (if CPN'f CPN'x
	   then 
	       (CPN'x::(CPN'predlist CPN'f CPN'xs))
       else
	   CPN'predlist CPN'f CPN'xs);

(* The first three functions is used in 'Save Report' *)

fun ListImpartialTIs ()
    = CPN'predlist (fn CPN'TI => (TIsFairness [CPN'TI]) = Impartial) TI.All;

fun ListFairTIs ()
    = CPN'predlist (fn CPN'TI =>
		    (let 
			 val CPN'fairness = TIsFairness [CPN'TI]
		     in
			 (CPN'fairness = Fair) orelse
			 (CPN'fairness = Impartial)
		     end)) TI.All;

fun ListJustTIs ()
    = CPN'predlist (fn CPN'TI => 
		    (let 
			 val CPN'fairness = TIsFairness [CPN'TI]
		     in
			 (CPN'fairness = Just) orelse
			 (CPN'fairness = Fair) orelse
			 (CPN'fairness = Impartial)
		     end)) TI.All;


(** Now come functions that do not have a corresponding proposition
in [Jensen]. Originally (i.e., before 18/8/94), they were in the file 
OGSearchFuns.c, but they seem more appropriate here. **)

fun EntireGraphCalculated ()
   = PredNodes([0],fn CPN'n => not (FullyProcessed CPN'n),1) = [];

fun ListDeadlocks()
   = PredAllNodes Terminal;

fun ListProcDeadlocks()
    = PredAllNodes (fn CPN'n
		    => Terminal CPN'n
                        andalso (FullyProcessed CPN'n));

fun ColorSearch(CPN'col: ''a,CPN'pimf: Node -> ''a ms)
   = PredAllNodes
   (fn CPN'n=>CPN'MS.cf(CPN'col, CPN'pimf CPN'n)>0);

fun MaxEnab()
    = SearchAllNodes(fn _ => true,
		     fn CPN'n => length(ListUtils.remdupl
					(map ArcToTI(OutArcs CPN'n))),
		     0,

		     Int.max);

