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
 * COPYRIGHT (C) 2006 by the CPN group, University of Aarhus, Denmark.
 * 
 * Module: State space glue
 *
 * Description: Functions used to communicate with the GUI
 *
 * CPN Tools
 *)

structure CPN'StateSpaceGlue = 
struct
local
    
    fun flatten (CPN'bislists) = 
	foldr (fn ((CPN'bl,CPN'il,CPN'sl),(CPN'x,CPN'y,CPN'z)) =>
		  (CPN'bl^^CPN'x,CPN'il^^CPN'y,CPN'sl^^CPN'z)) 
	      (nil,nil,nil) CPN'bislists

    fun nodeInfo (CPN'ssid:CPN'Id.id) (CPN'n:int) = 
	let
	    (*
	     * Node number 
	     * State space ID (so that different state spaces can be drawn), dummy now
	     * Number of predecessors 
	     * Number of successors 
	     * Node descriptor 
	     * Status (processed, fully processed) 
	     * x,y coordinates 
	     *)
	    val innodes = InNodes(CPN'n)
	    val outnodes = OutNodes(CPN'n)
	in
	    (* true indicates success in retrieving info *)
	    ([true,Processed CPN'n, FullyProcessed CPN'n],
	     (* 0,0 are dummy x and y coordinates *)
	     [CPN'n,0,0,length(innodes),length(outnodes)],
	     [NodeDescriptor(CPN'n)])
	end
	    handle ExcAvlLookup => 
		   (* false indicates that node CPN'n was not found *)
		   ([false],[CPN'n],nil)
	
    fun arcInfo (CPN'ssid:CPN'Id.id) (CPN'arc:int) = 
	let
	    (* ID 
	     * Arc number 
	     * State space ID (so that different state spaces could be drawn) 
	     * Source and destination nodes 
	     * Arc descriptor 
	     * Bend points 
	     *)
	    val srcnode = SourceNode (CPN'arc)
	    val dstnode = DestNode (CPN'arc)
	in
	    (* true indicates success retrieving arc info *)
	    (([true],
	      (* 0 is number of dummy bend points  *)
	      [CPN'arc,0,srcnode,dstnode],
	      [ArcDescriptor(CPN'arc)]))
	end
	    handle ExcAvlLookup =>
		   (* false indicates that arc CPN'arc was not found *)
		   ([false],[CPN'arc],nil)
	
    fun arcAndEndpointsInfo (CPN'ssid:CPN'Id.id) (CPN'arc:int) = 
	let
	    val arcinfo = arcInfo CPN'ssid CPN'arc
	    val srcinfo = nodeInfo CPN'ssid (SourceNode (CPN'arc))
	    val dstinfo = nodeInfo CPN'ssid (DestNode (CPN'arc))
	in
	    (* true indicates success retrieving arc info *)
	    (((#1 arcinfo)^^(#1 srcinfo)^^(#1 dstinfo),
	      (* 0 is number of dummy bend points  *)
	      (#2 arcinfo)^^(#2 srcinfo)^^(#2 dstinfo),
	      (#3 arcinfo)^^(#3 srcinfo)^^(#3 dstinfo)))
	end
	    handle ExcAvlLookup =>
		   (* false indicates that arc CPN'arc was not found *)
		   ([false],[CPN'arc],nil)

in

    val CPN'arclist = ref ([]: Arc list)
    val CPN'nodelist = ref ([]: Node list)

    (* Note that the call for entering the state space
     * tool is in the misc function in simglue.sml *)

    fun statespace (nil,[1],[CPN'nodesstop,CPN'arcsstop,CPN'secsstop,
			     CPN'predstop,
			     CPN'TIbranch,CPN'Bbranch,CPN'predbranch]) = 
	(* set options for generating state space *)

	let
	    val CPN'stopfunerr = CPN'Env.is_decl ("val _ =\n"^CPN'predstop)
	    val (CPN'stoperr,CPN'stoperrmsg) = 
		case CPN'stopfunerr of
		    NONE => (false, "")
		  | SOME CPN'msg => 
		    (true,"Error in predicate stop function:\n"^CPN'msg)

	    val CPN'branchfunerr = CPN'Env.is_decl ("val _ =\n"^CPN'predbranch)
	    val (CPN'brancherr,CPN'brancherrmsg) = 
		case CPN'branchfunerr of
		    NONE => (false, "")
		  | SOME CPN'msg => 
		    (true,"Error in predicate branching function:\n"^CPN'msg)
	in
	    case (CPN'stopfunerr,CPN'branchfunerr) of 
		(NONE,NONE) => 	
		(CPN'Env.use_string["OGSet.StopOptions {Nodes = ", 
				    CPN'nodesstop,
				    ", Arcs = ",CPN'arcsstop,
				    ", Secs = ",CPN'secsstop,
				    ", Predicate = ",CPN'predstop," };"];
		 CPN'Env.use_string["OGSet.BranchingOptions {TransInsts = ",
				    CPN'TIbranch,
				    ", Bindings = ",CPN'Bbranch,
				    ", Predicate = ",CPN'predbranch," };"];
		 (* true indicates success *)
		 ([true],nil,nil))
	      | _ => 
		(* false indicates error *)
		([false,CPN'stoperr,CPN'brancherr],
		 [],
		 [CPN'stoperrmsg,CPN'brancherrmsg])
	end

      | statespace (nil,[2],[CPN'ssid]) = 
	(* Calculate state space *)
	(let
	     val stopcritsatisfied = 
		 (CalculateOccGraph();
		  false)
		 handle StopCritSatisfied => true
	     val (CPN'nodestr,CPN'arcstr,CPN'timestr) =  
		 CPN'OGInspection.StandardReport()
	 in
	     (* true indicates success *)
	     ([true,stopcritsatisfied,EntireGraphCalculated()],
	      [],
	      [CPN'ssid,CPN'nodestr,CPN'arcstr,CPN'timestr])
	 end
	     handle exn =>
		    let
			val errmsg = 
			    exnName(exn)^
			    " exception when calculating state space"^ 
			    (case exn of 
				 CPN'Error CPN's => ": "^CPN's
			       | InternalError CPN's => ": "^CPN's
			       | _ => ".")
		    in
			([false],[],[CPN'ssid,errmsg])
		    end)
	    
      | statespace (nil,[3],[CPN'ssid]) = 
	(* Calculate scc graph *)
	((CalculateSccGraph();
	  ([true],[],[CPN'ssid]))
	 handle exn =>
		let
		    val errmsg = 
			exnName(exn)^
			" exception when calculating Scc graph"^ 
			(case exn of 
			     CPN'Error CPN's => ": "^CPN's
			   | InternalError CPN's => ": "^CPN's
			   | _ => ".")
		in
		    ([false],[],[CPN'ssid,errmsg])
		end)
	
      | statespace (nil,[4,CPN'node],[CPN'ssid]) = 
	(* Copy state corresponding to node CPN'node to simulator *)
	((CPN'OGToSimData.copy CPN'node;
	  ([true],nil,[CPN'ssid]))
	 handle exn =>
		let
		    val errmsg = 
			case exn of 
			    CPN'AvlTree.ExcAvlLookup => 
			    "Node "^Int.toString(CPN'node)^
			    " does not exist in the state space."
			  | _ => 
			    exnName(exn)^
			    " exception when transferring state space node "^
			    Int.toString(CPN'node)^" to simulator"^
			    (case exn of 
				 CPN'Error CPN's => ": "^CPN's
			       | InternalError CPN's => ": "^CPN's
			       | _ => ".")
		in
		    ([false],[],[CPN'ssid,errmsg])
		end)
	
      | statespace (nil,[5],[CPN'ssid]) = 
	(* Transfer simulator state to state space *)
	(let
	     val (CPN'wasthere,CPN'node) = OGSimStatetoOG()
	 in
	     ([true,CPN'wasthere],[CPN'node],[CPN'ssid])
	 end
	 handle exn =>
		let
		    val errmsg = 
			exnName(exn)^
			" exception when transferring simulator state to state space"^
			(case exn of 
			     CPN'Error CPN's => ": "^CPN's
			   | InternalError CPN's => ": "^CPN's
			   | _ => ".")
		in
		    ([false],[],[CPN'ssid,errmsg])
		end)
	
      | statespace ([CPN'stats, CPN'intbounds,CPN'multbounds,CPN'homemark,
		     CPN'deadmark,CPN'deadTI,CPN'liveTI,CPN'fairness],
		    [6],[CPN'ssid,CPN'filename]) = 
	(* Save state space report *)
	((OGSaveReport.SaveReport(CPN'stats, CPN'intbounds,CPN'multbounds,
				  CPN'homemark,CPN'deadmark,CPN'deadTI,
				  CPN'liveTI,CPN'fairness,CPN'filename);
	  ([true],[],[CPN'ssid]))
	 handle exn =>
		let
		    (* FIXME: handle SccGraphNotCalculated (and IO?) explicitly *)
		    val errmsg = 
			exnName(exn)^
			" exception when saving state space report"^
			(case exn of 
			     CPN'Error CPN's => ": "^CPN's
			   | InternalError CPN's => ": "^CPN's
			   | _ => ".")
		in
		    ([false],[],[CPN'ssid,errmsg])
		end)
	
      | statespace (nil,[7],[CPN'ssid]) = 
	(* is entire state space with id CPN'ssid calculated?  *)
	([EntireGraphCalculated()],nil,[CPN'ssid])

      | statespace (nil,10::CPN'ilist,[CPN'ssid]) = 
	(* get information for the nodes with the numbers in CPN'ilist
	 * from the state space with id CPN'ssid *)
	let
	    val nodeinfos = map (nodeInfo CPN'ssid) CPN'ilist
	    val (CPN'bres,CPN'ires,CPN'sres) = flatten nodeinfos
	in
	    (CPN'bres,length(nodeinfos)::CPN'ires,CPN'ssid::CPN'sres)
	end
				     
      | statespace (nil,11::CPN'ilist,[CPN'ssid]) = 
	(* get information for the arcs with the numbers in CPN'ilist
	 * from the state space with id CPN'ssid  *)
	let
	    val arcinfos = map (arcAndEndpointsInfo CPN'ssid) CPN'ilist
	    val (CPN'bres,CPN'ires,CPN'sres) = flatten arcinfos
	in
	    (CPN'bres,length(arcinfos)::CPN'ires,CPN'ssid::CPN'sres)
	end

      | statespace (nil,[12,CPN'n],[CPN'ssid]) = 
	(* get information regrading successors and corresponding arcs
	 * for node CPN'n in state space with id CPN'ssid*)
	(let
	     val targetinfo = nodeInfo CPN'ssid CPN'n
	     val outarcs = OutArcs(CPN'n)
	     val arcinfos = map (fn CPN'a => arcInfo CPN'ssid CPN'a) outarcs
	     val arcsflat = flatten arcinfos
	     val outnodes = OutNodes(CPN'n)
	     val nodeinfos = map (fn CPN'n => nodeInfo CPN'ssid CPN'n) outnodes
	     val nodesflat = flatten nodeinfos
	 in
	     ((#1 targetinfo)^^(#1 arcsflat)^^(#1 nodesflat),
	      ((#2 targetinfo)^^((length outarcs)::(length outnodes)::
				 (#2 arcsflat))^^(#2 nodesflat)),
              CPN'ssid::((#3 targetinfo)^^(#3 arcsflat)^^(#3 nodesflat)))
	 end
	     handle ExcAvlLookup => 
		    (* false indicates that node CPN'n was not found *)
		    ([false],[CPN'n],[CPN'ssid]))

      | statespace (nil,[13,CPN'n],[CPN'ssid]) = 
	(* get information regrading predecessors and corresponding arcs
	 * for node CPN'n in state space with id CPN'ssid*)
	(let
	     val targetinfo = nodeInfo CPN'ssid CPN'n
	     val inarcs = InArcs(CPN'n)
	     val arcinfos = map (fn CPN'a => arcInfo CPN'ssid CPN'a) inarcs
	     val arcsflat = flatten arcinfos
	     val innodes = InNodes(CPN'n)
	     val nodeinfos = map (fn CPN'n => nodeInfo CPN'ssid CPN'n) innodes
	     val nodesflat = flatten nodeinfos
	 in
	     ((#1 targetinfo)^^(#1 arcsflat)^^(#1 nodesflat),
	      ((#2 targetinfo)^^((length inarcs)::(length innodes)::
				 (#2 arcsflat))^^(#2 nodesflat)),
	      CPN'ssid::((#3 targetinfo)^^(#3 arcsflat)^^(#3 nodesflat)))
	 end
	     handle ExcAvlLookup => 
		    (* false indicates that node CPN'n was not found *)
		    ([false],[CPN'n],[CPN'ssid]))

      | statespace (nil,[14],[CPN'ssid,CPN'mlexpr]) = 
	(* evaluate ml expression CPN'mlexpr which should return a 
	 * list of Nodes, and return the information for the nodes *)
	let
	    val declerr = CPN'Env.is_decl("val _ =\n"^CPN'mlexpr)
	    val typeerr = CPN'Env.is_decl("val _ =\n"^CPN'mlexpr^" : Node list")	in
	    case (declerr,typeerr) of 
		(NONE,NONE) => 
		let
		    val _ = CPN'Env.use_string ["CPN'StateSpaceGlue.CPN'nodelist := ",
						CPN'mlexpr]
		    val nodeinfos = map (nodeInfo CPN'ssid) 
					(!CPN'nodelist)
		    val _ = CPN'nodelist := []
		    val (CPN'bres,CPN'ires,CPN'sres) = flatten nodeinfos
		in
		    (true::CPN'bres, (* true indicates success *)
		     length(nodeinfos)::CPN'ires,
		     CPN'ssid::CPN'sres)
		end
		    
	      | (SOME CPN'err, _) => ([false],[],[CPN'ssid,CPN'err])
	      | (_, SOME CPN'err) => ([false],[],[CPN'ssid,CPN'err])
	end

      | statespace (nil,[15],[CPN'ssid,CPN'mlexpr]) = 
	(* evaluate ml expression CPN'mlexpr which should return a 
	 * list of Arcs, and return the information for the arcs *)
	let
	    val declerr = CPN'Env.is_decl("val _ =\n"^CPN'mlexpr)
	    val typeerr = CPN'Env.is_decl("val _ =\n"^CPN'mlexpr^" : Arc list")	in
	    case (declerr,typeerr) of 
		(NONE,NONE) => 
		let
		    val _ = CPN'Env.use_string ["CPN'StateSpaceGlue.CPN'arclist := ",
						CPN'mlexpr]
		    val arcinfos = map (arcAndEndpointsInfo CPN'ssid) 
				       (!CPN'arclist)
		    val _ = CPN'arclist := []
		    val (CPN'bres,CPN'ires,CPN'sres) = flatten arcinfos
		in
		    (true::CPN'bres, (* true indicates success *)
		     length(arcinfos)::CPN'ires,
		     CPN'ssid::CPN'sres)
	    	end
		    
	      | (SOME CPN'err, _) => ([false],[],[CPN'ssid,CPN'err])
	      | (_, SOME CPN'err) => ([false],[],[CPN'ssid,CPN'err])
	end
				     
      | statespace _ = 
	(CPN'debug "Match error in CPN'StateSpaceGlue.statespace"; raise Match)


end (* local *)
end (* structure *)

val _ = CpnMLSys.SimProcess.NSStateSpace:= CPN'StateSpaceGlue.statespace;
