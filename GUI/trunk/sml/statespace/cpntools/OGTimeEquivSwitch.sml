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
 * Description:  Load equivalence library on timed state spaces
 *
 * Created by:   Lars Michael Kristensen (kris@daimi.au.dk)   
 *
 * Date:         12/07/2000   
 *
*)

(* $Source: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGTimeEquivSwitch.sml,v $

$Log: OGTimeEquivSwitch.sml,v $
Revision 1.1  2005/01/05 10:47:01  metch
*** empty log message ***

Revision 1.1.1.1  2004/06/23 07:52:30  coast


Revision 1.1.1.1  2004/03/25 15:02:36  metch


Revision 1.1.1.1  2003/02/11 11:34:44  coast
Coast sourcen laegges ind

Revision 1.2  2002/05/06 04:57:10  kris
*** empty log message ***

Revision 1.1  2002/05/04 04:33:57  kris
*** empty log message ***

Revision 1.1.2.3  2000/08/06 15:10:09  kris
Resolved conflicts

Revision 1.1.2.2  2000/08/03 18:14:53  kris
renamed canonical functions

Revision 1.1.2.1  2000/07/13 13:41:27  kris
Initial revision


*)

val rcsid = "$Header: /users/cpntools/repository/cpn2000/sml/statespace/cpntools/OGTimeEquivSwitch.sml,v 1.1 2005/01/05 10:47:01 metch Exp $";

(* --- load the utility functions --- *)
DSUI_SetStatusBarMessage ("Loading Timed Equivalence Library ...");
use (projectpath^"equiv/OGTimeEquivUtils.sml");

(* --- load functions for generating an empty state --- *)
DSUI_SetStatusBarMessage ("Generating Basic Functions ...");
use (ogpath^"OGCreateEmptyState.sml");
usestring [(CPN'OGCreateEmptyState.gen ())];

(* --- load functions for generating canonilisation functions --- *)
DSUI_SetStatusBarMessage ("Installing Equivalence Functions ...");
use (projectpath^"equiv/OGTimeEquivCanon.sml");
usestring (CPN'TimedEquivGen.gen_CanonMarkEquiv ());

(* --- disable/enabled equivalence on the timed state space --- *);
fun TimeDisableEquivalence () = OGSetCanonical.DisableCanonFun ();
fun TimeEnableEquivalenceCT () = OGSetCanonical.EnableCanonFun (CanonMarkEquivCT);
fun TimeEnableEquivalenceOT () = OGSetCanonical.EnableCanonFun (CanonMarkEquivOT);
fun TimeEnableEquivalenceWOT () = OGSetCanonical.EnableCanonFun (CanonMarkEquivWOT);

use (projectpath^"equiv/equiv.sml");

DSUI_SetStatusBarMessage ("Timed Equivalence Library Loaded ...")

