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
 * Module:       OGMSSearchTreeFun
 *
 * Description:  Efficient storage for ColName multi-set values
 *
 * CPN Tools
 *)

functor CPN'OGMSST (CPN'ColSig:sig eqtype ColName end) =

(* Generates structures, which provides efficient storage
 * for ColName multi-set values;
 * Each node in the search tree keeps a list with elements
 * with the encooding equal to the key of that node.
 *
 * The balancing procedure has been taken directly from CPN'AvlTree 
 *)

struct 
  local
   exception avl;
   exception taller;
 
   datatype balancefactor = LH | EH | RH;
   datatype mssnode = mssnode of {key:string,
                                 value:(((CPN'ColSig.ColName) ms) ref) list, 
                                 left:mssnode ref,
                                 right:mssnode ref,
                                 bf:balancefactor ref}|
                      emptymssnode;

   val thistree = ref (emptymssnode);

  in

   fun Reset () = thistree := emptymssnode;

   local

    fun rotleft (CPN'root as ref(mssnode{right=root_right as 
                                  ref(mssnode{left=root_right_left,...}),...})) =
         let
          val temp = (ref emptymssnode);
         in
          (temp := !root_right; 
           root_right := !root_right_left;
           root_right_left := !CPN'root; 
           CPN'root := !temp)
         end
      | rotleft _ = ();

    fun rotright (CPN'root as ref(mssnode{left=root_left as 
                                   ref(mssnode{right=root_left_right,...}),...})) =
         let
          val temp = (ref emptymssnode);
         in
          (temp := !root_left; 
           root_left := !root_left_right;
           root_left_right := !CPN'root; 
           CPN'root := !temp)
         end
      | rotright _ = ();

    fun rightbalance (CPN'root as ref(mssnode{bf=root_bf, right=root_right as
                                       ref(mssnode{bf=root_right_bf,...}),...})) =
         (case (!root_right_bf) of
           RH => (root_bf := EH; root_right_bf := EH; rotleft CPN'root; true) |
           EH => (root_bf := RH; root_right_bf := LH; rotleft CPN'root; false) | 
           LH => (case root_right of
                   ref(mssnode{left=ref(mssnode{bf=root_right_left_bf,...}),...}) =>
                    (case (!root_right_left_bf) of
                      EH => (root_bf := EH; root_right_bf := EH) |
                      RH => (root_bf := LH; root_right_bf := EH) |
                      LH => (root_bf := EH; root_right_bf := RH);
                     root_right_left_bf := EH;
                     rotright root_right;
                     rotleft CPN'root;
                     true) |
                   _ => raise avl))
      |  rightbalance _ = false;

    fun leftbalance (CPN'root as ref(mssnode{bf=root_bf, left=root_left
                                    as ref(mssnode{bf=root_left_bf,...}),...})) =
         (case (!root_left_bf) of
           LH => (root_bf := EH; root_left_bf := EH; rotright CPN'root; true) |
           EH => (root_bf := LH; root_left_bf := RH; rotright CPN'root; false) | 
           RH => (case root_left of
                   ref(mssnode{right=ref(mssnode{bf=root_left_right_bf,...}),...}) =>
                    (case (!root_left_right_bf) of
                      EH => (root_bf := EH; root_left_bf := EH) |
                      RH => (root_bf := EH; root_left_bf := LH) |
                      LH => (root_bf := RH; root_left_bf := EH);
                     root_left_right_bf := EH;
                     rotleft root_left;
                     rotright CPN'root;
                     true) |
                   _ => raise avl))
      |  leftbalance _ = false;
    
    val refstore = ref (ref (empty : CPN'ColSig.ColName ms)); (* Bind with type CPN'ColSig.ColName 
                                                                           when using .74 NJSML or later *)

    fun isnotin ([],_) = true
      | isnotin ((CPN'x:CPN'ColSig.ColName ms ref) ::CPN'xs,CPN'r)
	= if (CPN'r)=(!CPN'x) 
         then (refstore:=CPN'x;false)
         else isnotin(CPN'xs,CPN'r);

    local
     fun lsort  (CPN'x::CPN'xs) (CPN'y::CPN'ys) =
	 if CPN'x<CPN'y then lsort CPN'xs (CPN'x::(CPN'y::CPN'ys))
	 else lsort CPN'xs (CPN'y::(lsort [CPN'x] CPN'ys))
       | lsort (CPN'x::CPN'xs) nil = 
	 lsort CPN'xs [CPN'x]
       | lsort nil CPN'xs = CPN'xs
			
     fun coefms CPN'c (CPN'x::(CPN'y::CPN'ys)) CPN'acc =
	 if (CPN'x=CPN'y)
	 then coefms (CPN'c+1) (CPN'y::CPN'ys) CPN'acc
	 else coefms 1 (CPN'y::CPN'ys) (CPN'c::CPN'acc)
       | coefms CPN'c (CPN'x::nil) CPN'acc = CPN'c::CPN'acc
       | coefms CPN'c nil CPN'acc = CPN'acc

     fun compactmkst CPN'ms1 = mkstr_ms (Int.toString,Int.<) CPN'ms1
    in
      (* Get string representation for the coeficient multiset of CPN'ms1.
       * This is used as the key in the search tree.
       *)
      fun encoding CPN'ms1 = compactmkst(lsort (coefms 1 CPN'ms1 []) [])
    end(*local*)

   in
    fun Insert CPN'ms1 = 
         let 
          fun insert (CPN'root as (ref emptymssnode),CPN'k)
             = (CPN'root := mssnode {key=CPN'k, value=[ref CPN'ms1], right = ref emptymssnode, 
                                 left = ref emptymssnode, bf = ref EH};
                refstore:= let val mssnode rootrec = (!CPN'root)
                           in hd(#value rootrec) end;  
                raise taller)
            | insert (CPN'root as (ref (mssnode {key=CPN'key, left=CPN'left, right=CPN'right, bf=CPN'bf, value=msreflist})),CPN'k)
             = if (CPN'k = CPN'key) 
               then
                if isnotin(msreflist,CPN'ms1)
                then 
                 (CPN'root := mssnode {key=CPN'key, value=(ref CPN'ms1)::msreflist,
                                   right=CPN'right, left=CPN'left, bf=CPN'bf};
                  refstore:= let val mssnode rootrec = (!CPN'root)
                             in hd(#value rootrec) end) 
                else
                 ()
               else 
                if (CPN'k < CPN'key)
                then (insert(CPN'left,CPN'k) handle taller =>
                       (case !CPN'bf of
                         EH => (CPN'bf := LH; raise taller) |
                         LH => (leftbalance CPN'root;()) |
                         RH => CPN'bf := EH))
                else (insert(CPN'right,CPN'k) handle taller =>
                       (case !CPN'bf of 
                         EH => (CPN'bf := RH; raise taller) |
                         LH => CPN'bf := EH |
                         RH => (rightbalance CPN'root;()) ));
         in 
         (insert(thistree, encoding CPN'ms1) handle taller => ();
          !refstore)
         end(*let*)
   end(*local*);

   fun App func =
    let 
     fun app (ref emptymssnode)= ()
       | app (ref (mssnode {left=CPN'left, right=CPN'right, value=CPN'value,...}))
        = ((app CPN'left); (func CPN'value); (app CPN'right))
    in 
     app thistree
    end(*let*);


  fun No ()
      = let
          val CPN'no = ref 0;
          val CPN'll = ref 0
        in
         App (fn CPN'msl => (CPN'no := (!CPN'no + 1); CPN'll:= !CPN'll+(length CPN'msl)));
         (!CPN'no,!CPN'll)
        end(*let*);
  end(*local*) 
end(*struct*);
