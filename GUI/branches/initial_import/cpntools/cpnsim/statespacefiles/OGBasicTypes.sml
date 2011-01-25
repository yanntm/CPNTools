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
 * Module:       OGBasicTypes
 *
 * Description:  Basic net independent types & functions
 *
 * CPN Tools
 *)

(* this file contains all the basic net independent types+funs used for OG 
 * See the OG Analyzer Manual *)

type Node = int;

type Arc = int;

val InitNode = 1:Node;

val OGrapgh = [0];

datatype CalcStat = FullProc | PartProc | UnProc;

exception IllegalId;

type Inst = int;

type CPN'TransInst= string(*MLno*)*Inst;

fun mkst_Node (CPN'n:Node) = Int.toString CPN'n;

fun mkst_Arc (CPN'a:Arc) = Int.toString CPN'a;
