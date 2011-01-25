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
 * Module:       Timed Equivalence
 *
 * Description:  Utility functions to implement equivalence on timed state spaces
 *
 * Created by:   Lars Michael Kristensen (kris@daimi.au.dk)   
 *
 * Date:         12/07/2000   
 *
*)

(* $Source: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGTimeEquivUtils.sml,v $

$Log: OGTimeEquivUtils.sml,v $
Revision 1.1  2005/01/05 10:47:01  metch
*** empty log message ***

Revision 1.1.1.1  2004/06/23 07:52:30  coast


Revision 1.2  2004/05/10 12:22:08  metch
*** empty log message ***

Revision 1.1.1.1  2004/03/25 15:02:36  metch


Revision 1.1.1.1  2003/02/11 11:34:44  coast
Coast sourcen laegges ind

Revision 1.1  2002/05/04 04:33:58  kris
*** empty log message ***

Revision 1.1.2.3  2000/08/03 12:26:50  kris
Fixed a bug in FindOccurrenTime so that it now correctly restores the simulator state

Revision 1.1.2.2  2000/08/02 21:36:08  kris
Fixed a problem in FindOccurrence time restoring the originial simulator state

Revision 1.1.2.1  2000/07/13 13:41:26  kris
Initial revision


*)

val rcsid = "$Header: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGTimeEquivUtils.sml,v 1.1 2005/01/05 10:47:01 metch Exp $";

(* --- structure implementing the utility functions --- *)
structure TimedOE = 
    struct

	(* ---------------------------------------------------- *)
	(* --- general utility function on timed multi sets --- *)
	(* ---------------------------------------------------- *)

	fun localtms_rev tempty CPN'tms = CPN'tms 
	  | localtms_rev (CPN't!!!CPN'tms) CPN'tms2 = 
	    localtms_rev CPN'tms (CPN't!!!CPN'tms2);

	(* --- map function on timed multi-sets --- *)
	fun localtms_map _ tempty CPN'tms = localtms_rev CPN'tms tempty
	  | localtms_map CPN'f (CPN't!!!CPN'tms1) CPN'tms2 =
	    localtms_map CPN'f CPN'tms1 ((CPN'f CPN't)!!!CPN'tms2);
 
	fun tms_map CPN'f CPN'tms = localtms_map CPN'f CPN'tms tempty;


	(* ---------------------------------------------------- *)
	(* --- functions for setting time stamps to zero    --- *)
	(* ---------------------------------------------------- *)

	(* --- set time stamps less then CPN't in CPN'tl to zero --- *)
	fun timelist_setzero CPN't CPN'tl = 
	    (map 
	     (fn CPN'ts => if (IntInf.<(CPN'ts,CPN't)) 
			       then (IntInf.fromInt 0)
			   else CPN'ts)
	     CPN'tl)

	fun col_setzero CPN't (CPN'coef,CPN'col,CPN'tl) = 
	    (CPN'coef,CPN'col,(timelist_setzero CPN't CPN'tl))

	(* --- set time stampt in CPN'tms less than CPN't to zero --- *)
	fun tms_setzero CPN't CPN'tms = 
	    tms_map (col_setzero CPN't) CPN'tms; 


	(* ---------------------------------------------------- *)
	(* --- functions for subtraction of time stamps     --- *)
	(* ---------------------------------------------------- *)

	(* --- subtract CPN'n from all timestamps in CPN'tms --- *)
	exception timelistexn;
        fun timelist_subtracttime CPN't CPN'mintime CPN'tl = 
	    if (IntInf.<(CPN'mintime,IntInf.fromInt 0) orelse
		IntInf.<(CPN't,IntInf.fromInt 0))
		then raise timelistexn
	    else
		(map 
		 (fn CPN'ts => (IntInf.max(CPN'mintime,IntInf.-(CPN'ts,CPN't))))
		 CPN'tl);

        fun col_subtracttime CPN't CPN'mintime (CPN'coef,CPN'col,CPN'tl) = 
            (CPN'coef,CPN'col,(timelist_subtracttime CPN't CPN'mintime CPN'tl));

        fun tms_subtracttime CPN't CPN'mintime CPN'tms = 
            tms_map (col_subtracttime CPN't CPN'mintime) CPN'tms;

	(* ---------------------------------------------------- *)
	(* --- functions for removing negative time stamps  --- *)
	(* ---------------------------------------------------- *)

	fun tms_removeneg CPN'tms = 
	    tms_setzero (IntInf.fromInt 0) CPN'tms;
	    
	    
	(* --- normalisation of multi-sets --- *)
	fun tms_normalise CPN't CPN'tms = 
	    tms_subtracttime CPN't (IntInf.fromInt 0) (tms_setzero CPN't CPN'tms);

	fun ms_normalise _ CPN'ms =  CPN'ms;

	(* --- equivalence on timed multi-sets --- *)
	fun tms_equal (CPN'tms1,CPN'tms2) = 
	    ((CPN'timeop.tms'sub (CPN'tms1,CPN'tms2)) = tempty 
	    handle _ => false);

	fun tms_equiv ((CPN'occ1,CPN'tms1),(CPN'occ2,CPN'tms2)) =
	    tms_equal (tms_normalise CPN'occ1 CPN'tms1,
		       tms_normalise CPN'occ2 CPN'tms2);

	fun ms_equiv ((_,CPN'ms1),(_,CPN'ms2)) = (CPN'ms1 == CPN'ms2);

	(* --- calculate enabled binding elements and enabling time --- *)
	fun IntCalculateTimeEnabled CPN'sr = 
	    let
		val CPN'cursimstaterec =  (CPN'simstore_state 
		    (ref (CPN'OGnode {state = ref CPN'sr,
				     no = 0,
				     succlist = ref [],
				     predlist = ref [],
				     calcstat = ref UnProc})));

		val curr_min = !CPN'OGTimeEnabData.curr_min
	    in 

		(CPN'OGEnabData.init();  
		 CPN'OGTimeEnabData.init();
(* 		 CPN'OGToSimData.copy CPN'n; *)
 		 CPN'OGToSimData.copyStateRec 
		 (CPN'OGnode {state = ref CPN'sr,
			      no = 0,
			      predlist = ref [],
			      succlist = ref [],
			      calcstat = ref UnProc});

		 CPN'ValuePrint:=false; 		 
		 CPN'OGCalcEnab();

		 if ((!CPN'env.Timedef)<>CPN'env.timenotdef) andalso
		     (with_time()) andalso
		     (CPN'OGEnabData.get_cands()<>[]) andalso
		     (case (!CPN'OGTimeEnabData.curr_min) of
			  SOME t => IntInf.>(t,(time()))
			| NONE => true)
		     then 
			 CPN'OGTimeEnabData.init()
		 else
		     CPN'OGCalcEnabTimeBinds();
		     
		 CPN'ValuePrint:=true;
                     
		 (let
		      val CPN'enabled = 
			  ((map CPN'IntBEToExtBE (CPN'OGEnabData.get_cands ())),
			   (map CPN'IntBEToExtBE (CPN'OGTimeEnabData.get_cands())),
			   time())
		  in
		      (* --- restore the original state -- *)
		       CPN'OGToSimData.copyStateRec 
		       (CPN'OGnode {state = (ref CPN'cursimstaterec),
				    no = 0,
				    succlist = ref [],
				    predlist = ref [],
				    calcstat = ref UnProc});
		       CPN'OGTimeEnabData.curr_min := curr_min;
		       CPN'enabled
		  end))
	    end;

	fun ExtCalculateTimeEnabled CPN'n =
	    IntCalculateTimeEnabled (CPN'OGState (CPN'OGUtils.GetStateRec CPN'n));	    

	(* --- find the next model time at which something is enabled in CPN'n --- *)
	fun IntFindOccurrenceTime CPN'n = 
	    (let
		 val (_,_,occtime) = IntCalculateTimeEnabled CPN'n
	     in
		 occtime
	     end);

	fun ExtFindOccurrenceTime CPN'n = 
	    IntFindOccurrenceTime (CPN'OGState (CPN'OGUtils.GetStateRec CPN'n));	    

	fun IntFindCreationTime CPN'staterec = 
	    let
		val CPN'OGState {owner = owner,
				 creationtime = creationtime,...} = CPN'staterec
	    in
		creationtime
	    end;

        (* --- find the delay in a state --- *)
        (* --- could be made more effiecient by passing occurrence time *)
        fun IntFindTimeDelay CPN'n =
            let val CPN'ct = IntFindCreationTime CPN'n
                val CPN'ot = IntFindOccurrenceTime CPN'n
             in IntInf.- (CPN'ot, CPN'ct)
            end handle _ => (DSUI_UserAckMessage("IntFindTimeDelay");IntInf.fromInt 0)
	  
    end;

