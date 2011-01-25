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
 * Module:       OGSearchFuns
 *
 * Description:  User accesible node and arc search functions
 *
 * CPN Tools
 *)

(* this file defines the user accesible node and arc search functions and 
 * their derivates plus one of the standard query functions               
 *)

local
 exception stopsearch;
 val CPN'found=ref 0
in
 fun SearchNodes(CPN'nodelist:Node list, CPN'pred, CPN'limit, CPN'eval, CPN'start, CPN'comb)
    = let
       val CPN'result=ref CPN'start;
       fun searchone (CPN'n:Node)
          = if CPN'pred CPN'n
            then
             (CPN'result:=CPN'comb(CPN'eval(CPN'n),!CPN'result);
              CPN'found := !CPN'found + 1;
              if !CPN'found=CPN'limit
              then raise stopsearch
              else ())
            else ()
      in
       CPN'result:=CPN'start;
       CPN'found:=0;
       (if CPN'nodelist=[0]
        then CPN'AvlTree.AvlApp(fn ref(CPN'OGnode{no=CPN'n,...})
                                  => searchone CPN'n, CPN'OGNodes)
        else (map searchone CPN'nodelist;())) handle stopsearch => ();
        !CPN'result
      end(*let*)
end(*local*);

fun PredNodes (CPN'area,CPN'pred,CPN'limit)
   = SearchNodes(CPN'area,CPN'pred,CPN'limit,fn CPN'x => CPN'x,[],op ::);
fun EvalNodes(CPN'area,CPN'eval)
   = SearchNodes(CPN'area,fn _=>true,0,CPN'eval,[],op ::);
fun SearchAllNodes(CPN'pred,CPN'eval,CPN'start,CPN'comb)
   = SearchNodes([0],CPN'pred,0,CPN'eval,CPN'start,CPN'comb);
fun PredAllNodes CPN'pred
   = PredNodes([0],CPN'pred,0);
fun EvalAllNodes CPN'eval
   = EvalNodes([0],CPN'eval);
 
local
 exception stopsearch;
 val CPN'found=ref 0
in
 fun SearchArcs (CPN'arclist: Arc list,CPN'pred,CPN'limit,CPN'eval,CPN'start,CPN'comb)
    = let
       val CPN'result=ref CPN'start;
       fun processarc (CPN'a:Arc)
          = if CPN'pred CPN'a
            then
             (CPN'result:=CPN'comb(CPN'eval CPN'a,!CPN'result);
              CPN'found := !CPN'found + 1;
              if !CPN'found=CPN'limit
              then raise stopsearch
              else ())
            else ()
      in
       CPN'result:=CPN'start;
       CPN'found:=0;
       (if CPN'arclist=[0]
        then CPN'AvlTree.AvlApp(
              fn ref(CPN'OGarc
                     {no = CPN'a,...})
               => processarc CPN'a,
               CPN'OGArcs)
         else (map processarc CPN'arclist;())) handle stopsearch => ();
       !CPN'result
      end
end;


fun PredArcs (CPN'area,CPN'pred,CPN'limit) = SearchArcs(CPN'area,CPN'pred,CPN'limit,fn CPN'x => CPN'x,[],op ::);

fun EvalArcs(CPN'area,CPN'eval) = SearchArcs(CPN'area,fn _=>true,0,CPN'eval,[],op ::);

fun SearchAllArcs(CPN'pred,CPN'eval,CPN'start,CPN'comb)
   = SearchArcs([0],CPN'pred,0,CPN'eval,CPN'start,CPN'comb);

fun PredAllArcs CPN'pred
   = PredArcs ([0],CPN'pred,0);

fun EvalAllArcs CPN'eval
   = EvalArcs([0],CPN'eval);
