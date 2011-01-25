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
 * Module:       OGTimeListTreeFun.sml
 *
 * Description:  Time list storage functor
 *
 * CPN Tools
 *)

functor CPN'OGTLSTORAGE (CPN'tlSig:sig
                             type TimeType
                             val timelisteq: (TimeType list)*(TimeType list)->bool
                         end) =

(* generates a structure which provides efficient storage for time list values;
 * Each node in the search tree keeps a list with elements
 * with the enocoding equal to the key of that node.
 *
 * The balancing procedure has been taken directly from
 * CPN'AvlTree 
 *)
 
 struct 
  local
   exception avl;
   exception taller;
 
   datatype balancefactor = LH | EH | RH;
   datatype tlnode =
    tlnode of {key:string,
                 value:((CPN'tlSig.TimeType list) ref) list, 
                 left:tlnode ref,
                 right:tlnode ref,
                 bf:balancefactor ref}|
    emptytlnode           
  in
   abstype tlsearchtree = tltree of tlnode ref
   with

   fun New () = tltree(ref emptytlnode);

   fun Reset (tltree (root)) = root := emptytlnode;

   local

    fun rotleft (CPN'root as ref(tlnode{right=root_right as 
                                  ref(tlnode{left=root_right_left,...}),...})) =
         let
          val temp = (ref emptytlnode);
         in
          (temp := !root_right; 
           root_right := !root_right_left;
           root_right_left := !CPN'root; 
           CPN'root := !temp)
         end
      | rotleft _ = ();

    fun rotright (CPN'root as ref(tlnode{left=root_left as 
                                   ref(tlnode{right=root_left_right,...}),...})) =
         let
          val temp = (ref emptytlnode);
         in
          (temp := !root_left; 
           root_left := !root_left_right;
           root_left_right := !CPN'root; 
           CPN'root := !temp)
         end
      | rotright _ = ();

    fun rightbalance (CPN'root as ref(tlnode{bf=root_bf, right=root_right as
                                       ref(tlnode{bf=root_right_bf,...}),...})) =
         (case (!root_right_bf) of
           RH => (root_bf := EH; root_right_bf := EH; rotleft CPN'root; true) |
           EH => (root_bf := RH; root_right_bf := LH; rotleft CPN'root; false) | 
           LH => (case root_right of
                   ref(tlnode{left=ref(tlnode{bf=root_right_left_bf,...}),...}) =>
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

    fun leftbalance (CPN'root as ref(tlnode{bf=root_bf, left=root_left
                                    as ref(tlnode{bf=root_left_bf,...}),...})) =
         (case (!root_left_bf) of
           LH => (root_bf := EH; root_left_bf := EH; rotright CPN'root; true) |
           EH => (root_bf := LH; root_left_bf := RH; rotright CPN'root; false) | 
           RH => (case root_left of
                   ref(tlnode{right=ref(tlnode{bf=root_left_right_bf,...}),...}) =>
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
    
    val refstore = ref(ref([]))

   in
    fun Insert (tltree(noderef),CPN'rec1,CPN'k) = 
         let
 
          fun isnotin ([],_) = true
            | isnotin (CPN'x::CPN'xs,CPN'r)
             = if CPN'tlSig.timelisteq(CPN'r,!CPN'x)
               then (refstore:=CPN'x; false)
               else isnotin(CPN'xs,CPN'r);
 
          fun insert (CPN'root as (ref emptytlnode))
             = (CPN'root := tlnode {key=CPN'k, value=[(ref CPN'rec1)], right=ref emptytlnode, 
                                  left=ref emptytlnode, bf=ref EH};
                refstore:= let val tlnode rootrec = (!CPN'root)
                           in hd(#value rootrec) end;  
                raise taller)
            | insert (CPN'root as(ref(tlnode{key, left, right, bf, value=recreflist})))
             = if (CPN'k = key) 
               then 
                if isnotin(recreflist,CPN'rec1)
                then 
                 (CPN'root := tlnode {key=key, value=(ref CPN'rec1)::recreflist,
                                    right=right, left=left, bf=bf};
                  refstore:= let val tlnode rootrec = (!CPN'root)
                             in hd(#value rootrec) end) 
                 else
                  ()
               else 
                if (CPN'k < key)
                then (insert(left) handle taller =>
                       (case !bf of
                         EH => (bf := LH; raise taller) |
                         LH => (leftbalance CPN'root;()) |
                         RH => bf := EH))
                else (insert(right) handle taller =>
                       (case !bf of 
                         EH => (bf := RH; raise taller) |
                         LH => bf := EH |
                         RH => (rightbalance CPN'root;()) ));
 
         in 
          (insert noderef handle taller => ();
           !refstore)
         end(*let*)
   end(*local*);

   fun App (func,tltree(noderef))
      = let 
         fun app (ref emptytlnode) = ()
           | app (ref (tlnode {left, right, value,...}))
            = ((app left); (func value); (app right))
        in 
         app noderef
        end(*let*);

   fun No CPN'tabel
      = let
          val no = ref 0;
          val ll = ref 0
        in
         App (fn CPN'bl => (no := (!no + 1); ll:= !ll+(length CPN'bl)),CPN'tabel);
         (!no,!ll)
        end(*let*);

  end(*abstype*); 
 end(*local*); 
end(*struct*); 

