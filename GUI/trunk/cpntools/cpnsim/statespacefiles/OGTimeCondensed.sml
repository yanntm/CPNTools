(************************************************************************)
(* CPN Tools                                                            *)
(* Copyright 2013 AIS Group, Eindhoven University of Technology         *)
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
 * Module:       OGTimeCondensed
 *
 * Description:  Time condensed state spaces
 *
 * CPN Tools
 *)

structure CPN'OGStopCrit = struct
    val CreationTime = ref false
    val TerminationTime = ref false

    fun SetParams { CreationTime = CPN'creationtime,
                    TerminationTime = CPN'terminationtime } =
        (CreationTime := CPN'creationtime;
         TerminationTime := CPN'terminationtime)
end;

structure CPN'OGTimeCondensed = struct
    fun gen() = [""]
end;
