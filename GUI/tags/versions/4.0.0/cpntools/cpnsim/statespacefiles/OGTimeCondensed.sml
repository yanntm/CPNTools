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

structure CPN'OGReductionOptions = struct
    val CreationTime = ref false
    val TerminationTime = ref false

    fun SetParams { CreationTime = CPN'creationtime,
                    TerminationTime = CPN'terminationtime } =
        (CreationTime := CPN'creationtime;
         TerminationTime := CPN'terminationtime)
end;

structure CPN'OGTimeCondensed = struct
    fun gen_one (name, ref elements) =
    let
        fun gen_header ([], lst) = lst
           | gen_header ({colset, fieldname}::rest, lst) =
           let
               val times = 
                   if CPN'CSTable.is_timed colset
                   then String.concat [", ", fieldname, "t"]
                   else ""
           in
               gen_header (rest, ", "::fieldname::times::lst)
           end
        fun gen_body ([], lst) = lst
           | gen_body ({colset, fieldname}::rest, lst) =
           let
               val times = 
                   if CPN'CSTable.is_timed colset
                   then String.concat [", ", fieldname, "t = CPN'subtract creationtime ", fieldname, "t"]
                   else ""
           in
               gen_body (rest, ", "::fieldname::" = "::fieldname::times::lst)
           end
    in
        List.concat [["fun compressST", name, " creationtime {"], List.tl (gen_header
        (elements, [""])), ["} = { "],
        List.tl (gen_body (elements, [""])), ["}\n"]]
    end
    fun gen_starttime_ones () =
    let
        val code = ref [[""]]
        fun fuck_avl elms = (code := (gen_one elms)::(!code))
        val _ = CPN'AvlTree.AvlAppKey (fuck_avl, CPN'OGIdsGen.DataRecFields)
    in
        List.concat (!code)
    end
    fun gen_starttime () =
    let
        val code1 = ref [" }) = if creationtime = CPN'Time.null then CPN'state else { "]
        val code2 = ref [" }"]
        fun fuck_avl (name, _) = (code1 := (", "::name::(!code1));
            code2 := (", "::name::" = compressST"::name::" creationtime "::name::(!code2)))
        val _ = CPN'AvlTree.AvlAppKey (fuck_avl, CPN'OGIdsGen.DataRecFields)
    in
        List.concat [["fun compressST (CPN'state as { creationtime, owner"], !code1,
        ["creationtime = CPN'Time.null, owner = owner"], !code2]
    end

    fun gen() = ["structure CPN'TimeEquivalence = struct\n",
        "fun CPN'clamp creationtime [] = []\n",
          "| CPN'clamp creationtime (CPN'h::CPN't) =",
          " if (CPN'Time.lt (CPN'h, creationtime)) ",
          "then creationtime::(CPN'clamp creationtime CPN't) ",
          "else CPN'h::(CPN'clamp creationtime CPN't)\n",
        "fun CPN'subtract creationtime [] = []\n",
          "| CPN'subtract creationtime (CPN'h::CPN't) =",
          " if (CPN'Time.lt (CPN'h, creationtime)) ",
          "then CPN'Time.null::(CPN'subtract creationtime CPN't) ",
          "else (CPN'Time.sub (CPN'h, creationtime))::(CPN'subtract creationtime CPN't)\n",
        String.concat (gen_starttime_ones ()),
        String.concat (gen_starttime ()),
        "fun compress CPN'state = ",
        "if (!CPN'OGReductionOptions.CreationTime) ",
        "then compressST CPN'state else CPN'state\n", 
        "fun compressTime creationtime CPN'time = ",
        "if (!CPN'OGReductionOptions.CreationTime) ",
        "then CPN'clamp creationtime CPN'time else CPN'time\n",
        "fun compressTimestamp creationtime = ",
        "if (!CPN'OGReductionOptions.CreationTime) ",
        "then CPN'Time.null else creationtime\n",
        "end"]
end;
