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

    fun rotleft (CPN'root as ref(bindsnode{right=CPN'root_right as 
                                  ref(bindsnode{left=CPN'root_right_left,...}),...})) =
         let
          val CPN'temp = (ref emptybindsnode);
         in
          (CPN'temp := !CPN'root_right; 
           CPN'root_right := !CPN'root_right_left;
           CPN'root_right_left := !CPN'root; 
           CPN'root := !CPN'temp)
         end
      | rotleft _ = ();

    fun rotright (CPN'root as ref(bindsnode{left=CPN'root_left as 
                                   ref(bindsnode{right=CPN'root_left_right,...}),...})) =
         let
          val CPN'temp = (ref emptybindsnode);
         in
          (CPN'temp := !CPN'root_left; 
           CPN'root_left := !CPN'root_left_right;
           CPN'root_left_right := !CPN'root; 
           CPN'root := !CPN'temp)
         end
      | rotright _ = ();

    fun rightbalance (CPN'root as ref(bindsnode{bf=CPN'root_bf, right=CPN'root_right as
                                       ref(bindsnode{bf=CPN'root_right_bf,...}),...})) =
         (case (!CPN'root_right_bf) of
           RH => (CPN'root_bf := EH; CPN'root_right_bf := EH; rotleft CPN'root; true) |
           EH => (CPN'root_bf := RH; CPN'root_right_bf := LH; rotleft CPN'root; false) | 
           LH => (case CPN'root_right of
                   ref(bindsnode{left=ref(bindsnode{bf=CPN'root_right_left_bf,...}),...}) =>
                    (case (!CPN'root_right_left_bf) of
                      EH => (CPN'root_bf := EH; CPN'root_right_bf := EH) |
                      RH => (CPN'root_bf := LH; CPN'root_right_bf := EH) |
                      LH => (CPN'root_bf := EH; CPN'root_right_bf := RH);
                     CPN'root_right_left_bf := EH;
                     rotright CPN'root_right;
                     rotleft CPN'root;
                     true) |
                   _ => raise avl))
      |  rightbalance _ = false;

    fun leftbalance (CPN'root as ref(bindsnode{bf=CPN'root_bf, left=CPN'root_left
                                    as ref(bindsnode{bf=CPN'root_left_bf,...}),...})) =
         (case (!CPN'root_left_bf) of
           LH => (CPN'root_bf := EH; CPN'root_left_bf := EH; rotright CPN'root; true) |
           EH => (CPN'root_bf := LH; CPN'root_left_bf := RH; rotright CPN'root; false) | 
           RH => (case CPN'root_left of
                   ref(bindsnode{right=ref(bindsnode{bf=CPN'root_left_right_bf,...}),...}) =>
                    (case (!CPN'root_left_right_bf) of
                      EH => (CPN'root_bf := EH; CPN'root_left_bf := EH) |
                      RH => (CPN'root_bf := EH; CPN'root_left_bf := LH) |
                      LH => (CPN'root_bf := RH; CPN'root_left_bf := EH);
                     CPN'root_left_right_bf := EH;
                     rotleft CPN'root_left;
                     rotright CPN'root;
                     true) |
                   _ => raise avl))
      |  leftbalance _ = false;
    
    val CPN'refstore = ref(ref(CPN'BindSig.emptybind))

   in
    fun Insert (bindstree(noderef),CPN'rec1,CPN'k) = 
         let
 
          fun isnotin ([],_) = true
            | isnotin (CPN'x::CPN'xs,CPN'r)
             = if CPN'BindSig.bindeq(CPN'r,!CPN'x)
               then (CPN'refstore:=CPN'x; false)
               else isnotin(CPN'xs,CPN'r);
 
          fun insert (CPN'root as (ref emptybindsnode))
             = (CPN'root := bindsnode {key=CPN'k, value=[(ref CPN'rec1)], right=ref emptybindsnode, 
                                  left=ref emptybindsnode, bf=ref EH};
                CPN'refstore:= let val bindsnode rootrec = (!CPN'root)
                           in hd(#value rootrec) end;  
                raise taller)
            | insert (CPN'root as(ref(bindsnode{key=CPN'key, left=CPN'left, right=CPN'right, bf=CPN'bf, value=recreflist})))
             = if (CPN'k = CPN'key) 
               then 
                if isnotin(recreflist,CPN'rec1)
                then 
                 (CPN'root := bindsnode {key=CPN'key, value=(ref CPN'rec1)::recreflist,
                                    right=CPN'right, left=CPN'left, bf=CPN'bf};
                  CPN'refstore:= let val bindsnode rootrec = (!CPN'root)
                             in hd(#value rootrec) end) 
                 else
                  ()
               else 
                if (CPN'k < CPN'key)
                then (insert(CPN'left) handle taller =>
                       (case !CPN'bf of
                         EH => (CPN'bf := LH; raise taller) |
                         LH => (leftbalance CPN'root;()) |
                         RH => CPN'bf := EH))
                else (insert(CPN'right) handle taller =>
                       (case !CPN'bf of 
                         EH => (CPN'bf := RH; raise taller) |
                         LH => CPN'bf := EH |
                         RH => (rightbalance CPN'root;()) ));
 
         in 
          (insert noderef handle taller => ();
           !CPN'refstore)
         end(*let*)
   end(*local*);

   fun App (func,bindstree(noderef))
      = let 
         fun app (ref emptybindsnode) = ()
           | app (ref (bindsnode {left=CPN'left, right=CPN'right, value=CPN'value,...}))
            = ((app CPN'left); (func CPN'value); (app CPN'right))
        in 
         app noderef
        end(*let*);

   fun No CPN'tabel
      = let
          val CPN'no = ref 0;
          val CPN'll = ref 0
        in
         App (fn CPN'bl => (CPN'no:=(!CPN'no+1); CPN'll:= !CPN'll+(length CPN'bl)),CPN'tabel);
         (!CPN'no,!CPN'll)
        end(*let*);
  end(*abstype*); 
 end(*local*); 
end(*struct*); 

