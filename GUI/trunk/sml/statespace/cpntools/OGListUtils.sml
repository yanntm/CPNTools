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
 * Module:       Basic list utilities
 *
 * Description:  Design/CPN OG Tool
 *
 * CPN Tools
 *)

(* basic list utilities -- some can be found in Mlib *)

structure CPN'OGListUtils =
struct
 fun mem [] CPN'a = false
   | mem (CPN'x::CPN'xs) CPN'a
    = CPN'a = CPN'x orelse mem CPN'xs CPN'a;

 fun remdupl [] = []
   | remdupl [CPN'x] = [CPN'x]
   | remdupl (CPN'x::CPN'xs)
    = if mem CPN'xs CPN'x
      then remdupl CPN'xs
      else CPN'x::(remdupl CPN'xs);

 fun rm CPN'a [] = []
   | rm CPN'a (CPN'hd::CPN'tl)
    = if CPN'a=CPN'hd
      then CPN'tl
      else CPN'hd::(rm CPN'a CPN'tl);

 fun flatten (CPN'hd::CPN'tl) = CPN'hd^^(flatten CPN'tl)
   | flatten nil = nil;

 fun fmap CPN'fu CPN'l = flatten(map CPN'fu CPN'l);
 
 fun mapfilter (_,nil) = nil
   | mapfilter(CPN'predprocfun,CPN'hd::CPN'tl)
    = let
       val (CPN'pred,CPN'proc) = !CPN'predprocfun CPN'hd
      in
       if CPN'pred
       then CPN'proc::(mapfilter(CPN'predprocfun,CPN'tl))
       else mapfilter(CPN'predprocfun,CPN'tl)
     end(*let*);
     
 fun predlist _ nil = false
   | predlist CPN'predfun (CPN'hd::CPN'tl)
    = if CPN'predfun CPN'hd
      then true
      else predlist CPN'predfun CPN'tl;
      
 fun split (0,CPN'rest,CPN'front) = (CPN'rest, rev CPN'front)
   | split (CPN'n,CPN'hd::CPN'tl,CPN'front)
    = split(CPN'n-1, CPN'tl, CPN'hd::CPN'front);
      
 (*Soren's SCC additions begin*)
 local
  fun merge ([],CPN'ls) = CPN'ls
    | merge (CPN'ls,[]) = CPN'ls
    | merge (CPN'ls1 as ((CPN'node1:int)::rest1),CPN'ls2 as (CPN'node2::rest2)) = 
     if CPN'node1 <= CPN'node2
     then CPN'node1::merge(rest1,CPN'ls2)
     else CPN'node2::merge(CPN'ls1,rest2);
  fun mergepairs ([CPN'ls],_) = [CPN'ls]
    | mergepairs (CPN'lst as (CPN'l1::CPN'l2::CPN'ls),CPN'k) =
     if CPN'k mod 2 = 1
     then CPN'lst
     else mergepairs (merge (CPN'l1,CPN'l2)::CPN'ls, CPN'k div 2)
  fun nextrun (CPN'run,[]) = (rev CPN'run,[])
    | nextrun (CPN'run, CPN'ls as ((CPN'node:int)::CPN'rest)) =
     if CPN'node < hd CPN'run
     then (rev CPN'run, CPN'ls)
     else nextrun (CPN'node::CPN'run, CPN'rest);
  fun samsorting ([], CPN'ls, _) = hd (mergepairs (CPN'ls, 0))
    | samsorting (CPN'node::CPN'rest, CPN'ls, CPN'k) =
     let
      val (CPN'run,CPN'tail) = nextrun ([CPN'node],CPN'rest)
     in
      samsorting (CPN'tail, mergepairs (CPN'run::CPN'ls,CPN'k+1), CPN'k+1)
     end
 in
  fun sort_int_list (CPN'ls:int list) = samsorting (CPN'ls, [], 0)
 end;
 (*Soren's SCC additions end*)

end(*struct*);

open CPN'OGListUtils;















