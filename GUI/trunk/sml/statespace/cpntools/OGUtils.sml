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
 * Module:       OGUtils
 *
 * Description:  Utilities for referencing global tables and records
 *
 * CPN Tools
 *)

(* utilities for easy referencing of global tables and fields in records *)

structure CPN'OGUtils =
struct
   
 fun NodeToNodeRef (CPN'n:Node)
    = CPN'AvlTree.AvlLookup (CPN'OGNodes,mkst_Node CPN'n);

 fun NodeToNodeRec (CPN'n:Node) = !(NodeToNodeRef CPN'n);

 fun ArcToArcRef (CPN'a:Arc)
    = CPN'AvlTree.AvlLookup (CPN'OGArcs,mkst_Arc CPN'a);
 
 fun ArcToArcRec (CPN'a:Arc) = !(ArcToArcRef CPN'a);

 fun GetStateRec (CPN'n:Node)
    = let val ref(CPN'OGnode{state=
               ref(CPN'OGState staterec),...})
             = (NodeToNodeRef CPN'n)
      in staterec end;

 fun GetNodeNo (CPN'OGnode CPN'nrec) = #no CPN'nrec;

 fun GetNodeSucclist (CPN'OGnode CPN'nrec) = #succlist CPN'nrec;
 fun GetNodePredlist (CPN'OGnode CPN'nrec) = #predlist CPN'nrec;

 fun GetNodeCalcStat (CPN'OGnode CPN'nrec) = #calcstat CPN'nrec;

 fun GetArcInscr (CPN'OGarc CPN'arec) = #inscr CPN'arec;
 fun GetArcNo (CPN'OGarc CPN'arec) = #no CPN'arec;

 fun GetArcSrc (CPN'OGarc CPN'arec) = #src CPN'arec;
 fun GetArcDest (CPN'OGarc CPN'arec) = #dest CPN'arec;

 fun NodeExists (CPN'n:Node)
    = (CPN'AvlTree.AvlLookup (CPN'OGNodes,mkst_Node CPN'n);true)
      handle ExcAvlLookup => false

 fun ArcExists (CPN'a:Arc)
    = (CPN'AvlTree.AvlLookup (CPN'OGArcs,mkst_Arc CPN'a);true)
      handle ExcAvlLookup => false

end(*struct*);

