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
 * Description:  Generation of canonical form
 *
 * Created by:   Lars Michael Kristensen (kris@daimi.au.dk)   
 *
 * Date:         12/07/2000   
 *
*)

(* $Source: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGTimeEquivCanon.sml,v $

$Log: OGTimeEquivCanon.sml,v $
Revision 1.1  2005/01/05 10:47:01  metch
*** empty log message ***

Revision 1.3  2004/12/09 13:51:21  coast
Coast updated to CPN Tools v. 1.2 - fixed EquivCanon error

Revision 1.2  2004/06/23 12:01:40  coast
*** empty log message ***

Revision 1.3  2004/05/10 12:22:08  metch
*** empty log message ***

Revision 1.2  2004/04/19 11:52:04  metch
*** empty log message ***

Revision 1.1.1.1  2004/03/25 15:02:36  metch


Revision 1.1.1.1  2003/02/11 11:34:44  coast
Coast sourcen laegges ind

Revision 1.1  2002/05/04 04:33:57  kris
*** empty log message ***

Revision 1.1.2.6  2000/08/03 12:25:54  kris
Added support for occurrence time equivalence and renamed the canonical functions

Revision 1.1.2.5  2000/08/02 21:37:19  kris
First step towards making canon more efficient by avoiding multiple calculation of occurrence time

Revision 1.1.2.4  2000/07/31 19:32:50  kris
Improved canonical function by not normalising assigned ports

Revision 1.1.2.3  2000/07/29 14:13:11  kris
Fixed a problem when places has different timed colour sets

Revision 1.1.2.2  2000/07/14 13:46:55  kris
Creation time now set to zero

Revision 1.1.2.1  2000/07/13 13:41:28  kris
Initial revision


*)

val rcsid = "$Header: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGTimeEquivCanon.sml,v 1.1 2005/01/05 10:47:01 metch Exp $";

(* --- generation of EquivMark and NodeDescriptor --- *)
structure CPN'TimedEquivGen =
    struct
    local
        open CPN'NetCapture;
        open CPN'CodeGenUtils;


    in
        fun gen_CanonMarkEquiv () =
            (
             code_temp := "CPN'newstaterec \n end);\n";
             map
             (fn {pllist = pllist, pgname = pgname, instlist = instlist,...}
              => CPN'AvlTree.AvlApp
                  (fn {plname="",...} => ()
                    | {plname, plmlno,port,...}
                      => ( map
                               (fn {instno,instmlno}
				   => let
				       val CPN'key = pgname^"'"^plname^instno
				       val CPN'PI  = pgname^"'"^plname^" "^instno
				       val CPN'plikey  =plmlno^" "^instmlno
				       val CPN'IsTimed = CPN'PlaceTable.is_timed plmlno
				   in
				       if port
				       then ()
				       else
					   (code_temp := 
					    (case CPN'IsTimed of
						 true => 
						 "(OESetMark."^CPN'PI^" CPN'newstaterec (subtractfun ("^
						 "OEMark."^CPN'PI^" CPN'staterec)));\n"
					       | false => 
						 "(OESetMark."^CPN'PI^" CPN'newstaterec ("^
						 "OEMark."^CPN'PI^" CPN'staterec));\n")^(!code_temp)
					    )
				   end(*let*))
                               instlist; 
                               ()),
		   pllist))
             (!CPN'NetCapture.Net); 
             code_temp := 
	     "exception timelistexn;"^
             "fun tms_subtracttime t1 min_time t_ms = "^
	     "  map (fn (Time.@(col,t2)) =>   "^ 
	     "    if (IntInf.<(min_time,IntInf.fromInt 0) orelse"^
	     "      IntInf.<(t1,IntInf.fromInt 0))"^
	     "    then raise timelistexn"^
	     "    else Time.@(col, IntInf.max(min_time,IntInf.-(t2,t1))))"^
	     "  t_ms "^
	     "fun CanonMarkEquiv subtimefun timeminfun (CPN'staterec "^ 
	     "as CPN'OGState {owner = owner, creationtime = creationtime,...}) = \n "^
	     "(let \n "^
	     "  val CPN'sub = subtimefun CPN'staterec;\n"^
	     "  val CPN'min = timeminfun CPN'staterec;\n"^
	     "  fun subtractfun CPN'ms = tms_subtracttime CPN'sub CPN'min CPN'ms \n"^
	     "  val CPN'newstaterec = OGCreateEmptyState owner creationtime\n "^
(* 	     "  val CPN'newstaterec = CPN'staterec (\*OGCreateEmptyState owner creationtime (\*(IntInf.fromInt 0)*\) *\)\n "^ *)
	     "in \n"^(!code_temp);

	     (*^
	     (* CT - move everything down by creation time, and make zero the minimal time value *)
	     "val CanonMarkEquivCT = CanonMarkEquiv TimedOE.IntFindCreationTime (fn CPN'x => (IntInf.fromInt 0));\n"^
	     (* OT - move everything down by creation time, and make (ot-ct) the minimal time value *)
	     "val CanonMarkEquivOT = CanonMarkEquiv TimedOE.IntFindCreationTime TimedOE.IntFindTimeDelay;\n"^
	     (* WOT - move everything down by occurrence time, and make zero the minimal time value *)
	     "val CanonMarkEquivWOT = CanonMarkEquiv TimedOE.IntFindOccurrenceTime (fn CPN'x => (IntInf.fromInt 0));\n";*)
             ([!code_temp]))

    end
    end
    
    