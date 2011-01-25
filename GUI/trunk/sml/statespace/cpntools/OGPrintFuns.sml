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
 * Module:       OGPrintFuns
 *
 * Description:  Defines user accessible print functions
 *
 * CPN Tools
 *)


(* this file defines user accessible print functions *)


val st_NodeDescrRef = ref (fn (CPN'n:Node)=>"");

fun NodeDescriptor (CPN'n:Node) = (!st_NodeDescrRef) CPN'n

val st_ArcDescrRef = ref (fn (CPN'a:Arc)=>"");

fun ArcDescriptor (CPN'a:Arc) = (!st_ArcDescrRef) CPN'a

fun FullyProcessed CPN'n
   = !(CPN'OGUtils.GetNodeCalcStat
	(CPN'OGUtils.NodeToNodeRec CPN'n)) = FullProc;

fun Processed CPN'n
   = not (!(CPN'OGUtils.GetNodeCalcStat
	(CPN'OGUtils.NodeToNodeRec CPN'n)) = UnProc);
