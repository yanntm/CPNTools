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
 * Module:       OGBindSearchTreeFun
 *
 * Description:  Binding storage functor
 *
 * CPN Tools
 *)

functor CPN'OGBINDSTORAGE (CPN'BindSig:sig
                                      type OGbindtype;
                                      val emptybind:OGbindtype;
                                      val bindeq: OGbindtype*OGbindtype->bool
                                     end) =

 (* generates a structure which provides efficient storage for Binding values;
    Each node in the search tree keeps a list with elements
    with the enocoding equal to the key of that node.

    The balancing procedure has been taken directly from
    CPN'AvlTree 
  *)
 
 struct 
  local
   exception avl;
   exception taller;
 
   datatype balancefactor = LH | EH | RH;
   datatype bindsnode =
    bindsnode of {key:string,
                 value:(CPN'BindSig.OGbindtype ref) list, 
                 left:bindsnode ref,
                 right:bindsnode ref,
                 bf:balancefactor ref}|
    emptybindsnode           
  in
   abstype bindsearchtree = bindstree of bindsnode ref
   with

   fun New () = bindstree(ref emptybindsnode);

   fun Reset (bindstree (root)) = root := emptybindsnode;

   local

    fun rotleft (CPN'root as ref(bindsnode{right=root_right as 
                                  ref(bindsnode{left=root_right_left,...}),...})) =
         let
          val temp = (ref emptybindsnode);
         in
          (temp := !root_right; 
           root_right := !root_right_left;
           root_right_left := !CPN'root; 
           CPN'root := !temp)
         end
      | rotleft _ = ();

    fun rotright (CPN'root as ref(bindsnode{left=root_left as 
                                   ref(bindsnode{right=root_left_right,...}),...})) =
         let
          val temp = (ref emptybindsnode);
         in
          (temp := !root_left; 
           root_left := !root_left_right;
           root_left_right := !CPN'root; 
           CPN'root := !temp)
         end
      | rotright _ = ();

    fun rightbalance (CPN'root as ref(bindsnode{bf=root_bf, right=root_right as
                                       ref(bindsnode{bf=root_right_bf,...}),...})) =
         (case (!root_right_bf) of
           RH => (root_bf := EH; root_right_bf := EH; rotleft CPN'root; true) |
           EH => (root_bf := RH; root_right_bf := LH; rotleft CPN'root; false) | 
           LH => (case root_right of
                   ref(bindsnode{left=ref(bindsnode{bf=root_right_left_bf,...}),...}) =>
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

    fun leftbalance (CPN'root as ref(bindsnode{bf=root_bf, left=root_left
                                    as ref(bindsnode{bf=root_left_bf,...}),...})) =
         (case (!root_left_bf) of
           LH => (root_bf := EH; root_left_bf := EH; rotright CPN'root; true) |
           EH => (root_bf := LH; root_left_bf := RH; rotright CPN'root; false) | 
           RH => (case root_left of
                   ref(bindsnode{right=ref(bindsnode{bf=root_left_right_bf,...}),...}) =>
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
    
    val refstore = ref(ref(CPN'BindSig.emptybind))

   in
    fun Insert (bindstree(noderef),CPN'rec1,CPN'k) = 
         let
 
          fun isnotin ([],_) = true
            | isnotin (CPN'x::CPN'xs,CPN'r)
             = if CPN'BindSig.bindeq(CPN'r,!CPN'x)
               then (refstore:=CPN'x; false)
               else isnotin(CPN'xs,CPN'r);
 
          fun insert (CPN'root as (ref emptybindsnode))
             = (CPN'root := bindsnode {key=CPN'k, value=[(ref CPN'rec1)], right=ref emptybindsnode, 
                                  left=ref emptybindsnode, bf=ref EH};
                refstore:= let val bindsnode rootrec = (!CPN'root)
                           in hd(#value rootrec) end;  
                raise taller)
            | insert (CPN'root as(ref(bindsnode{key, left, right, bf, value=recreflist})))
             = if (CPN'k = key) 
               then 
                if isnotin(recreflist,CPN'rec1)
                then 
                 (CPN'root := bindsnode {key=key, value=(ref CPN'rec1)::recreflist,
                                    right=right, left=left, bf=bf};
                  refstore:= let val bindsnode rootrec = (!CPN'root)
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

   fun App (func,bindstree(noderef))
      = let 
         fun app (ref emptybindsnode) = ()
           | app (ref (bindsnode {left, right, value,...}))
            = ((app left); (func value); (app right))
        in 
         app noderef
        end(*let*);

   fun No CPN'tabel
      = let
          val no = ref 0;
          val ll = ref 0
        in
         App (fn CPN'bl => (no:=(!no+1); ll:= !ll+(length CPN'bl)),CPN'tabel);
         (!no,!ll)
        end(*let*);
  end(*abstype*); 
 end(*local*); 
end(*struct*); 

