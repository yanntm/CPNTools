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
 * Module:       OGRecSearchTreeFun
 *
 * Description:  Efficient storage for (CPN'OGrec ref) values
 *
 * CPN Tools
 *)

functor CPN'OGRECSTORAGE (CPN'RecSig:sig
                                      type OGrectype;
                                      val IsRecEq:OGrectype*OGrectype->bool;
                                      val NoRec:OGrectype
                                     end) =

 (* generates a structure which provides efficient storage for (CPN'OGrec ref) values;
  * Each node in the search tree keeps a list with elements
  * with the encoding equal to the key of that node.
  * The local function eqfun is used to test for equality, and
  * must be generated anew for each net.
  *
  * The balancing procedure has been taken directly from
  * CPN'AvlTree 
  *)
 
 struct 
  local
   exception avl;
   exception taller;
 
   datatype balancefactor = LH | EH | RH;
   datatype recsnode =
    recsnode of {key:string,
                 value:(CPN'RecSig.OGrectype ref) list, 
                 left:recsnode ref,
                 right:recsnode ref,
                 bf:balancefactor ref}|
    emptyrecsnode           
  in
   abstype recsearchtree = recstree of recsnode ref
   with

   fun New () = recstree(ref emptyrecsnode);

   fun Reset (recstree (root)) = root := emptyrecsnode;


   fun Rehash (recstree (root as(ref(recsnode{key, left, right, bf, value=recreflist}))), CPN'nkey) = 
       root:= recsnode {key=CPN'nkey, value=recreflist, right=right, left=left, bf=bf}
     | Rehash (recstree (ref emptyrecsnode),_) = ();

   local

    fun rotleft (CPN'root as ref(recsnode{right=root_right as 
                                  ref(recsnode{left=root_right_left,...}),...})) =
         let
          val temp = (ref emptyrecsnode);
         in
          (temp := !root_right; 
           root_right := !root_right_left;
           root_right_left := !CPN'root; 
           CPN'root := !temp)
         end
      | rotleft _ = ();

    fun rotright (CPN'root as ref(recsnode{left=root_left as 
                                   ref(recsnode{right=root_left_right,...}),...})) =
         let
          val temp = (ref emptyrecsnode);
         in
          (temp := !root_left; 
           root_left := !root_left_right;
           root_left_right := !CPN'root; 
           CPN'root := !temp)
         end
      | rotright _ = ();

    fun rightbalance (CPN'root as ref(recsnode{bf=root_bf, right=root_right as
                                       ref(recsnode{bf=root_right_bf,...}),...})) =
         (case (!root_right_bf) of
           RH => (root_bf := EH; root_right_bf := EH; rotleft CPN'root; true) |
           EH => (root_bf := RH; root_right_bf := LH; rotleft CPN'root; false) | 
           LH => (case root_right of
                   ref(recsnode{left=ref(recsnode{bf=root_right_left_bf,...}),...}) =>
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

    fun leftbalance (CPN'root as ref(recsnode{bf=root_bf, left=root_left
                                    as ref(recsnode{bf=root_left_bf,...}),...})) =
         (case (!root_left_bf) of
           LH => (root_bf := EH; root_left_bf := EH; rotright CPN'root; true) |
           EH => (root_bf := LH; root_left_bf := RH; rotright CPN'root; false) | 
           RH => (case root_left of
                   ref(recsnode{right=ref(recsnode{bf=root_left_right_bf,...}),...}) =>
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
    
    val refstore = ref (ref CPN'RecSig.NoRec,false);

   in
    fun Insert (recstree(noderef),CPN'rec1,CPN'k) = 
         let
          fun isnotin ([],_) = true
            | isnotin (CPN'x::CPN'xs,CPN'r)
             = if CPN'RecSig.IsRecEq(CPN'r,!CPN'x)
               then (refstore:=(CPN'x,true); false)
               else isnotin(CPN'xs,CPN'r);
 
          fun insert (CPN'root as (ref emptyrecsnode))
             = (CPN'root := recsnode {key=CPN'k, value=[(ref CPN'rec1)], right=ref emptyrecsnode, 
                                  left=ref emptyrecsnode, bf=ref EH};
                refstore:= let val recsnode rootrec = (!CPN'root)
                           in (hd(#value rootrec),false) end;  
                raise taller)
            | insert (CPN'root as(ref(recsnode{key, left, right, bf, value=recreflist})))
             = if (CPN'k = key) 
               then 
                if isnotin(recreflist,CPN'rec1)
                then 
                 (CPN'root := recsnode {key=key, value=(ref CPN'rec1)::recreflist,
                                    right=right, left=left, bf=bf};
                  refstore:= let val recsnode rootrec = (!CPN'root)
                             in (hd(#value rootrec),false) end) 
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


  local
       val refstore = ref (ref CPN'RecSig.NoRec,false);
  in

    fun Member (recstree(noderef),CPN'rec1,CPN'k) = 
         let
          fun isnotin ([],_) = true
            | isnotin (CPN'x::CPN'xs,CPN'r)
             = if CPN'RecSig.IsRecEq(CPN'r,!CPN'x)
               then (refstore:=(CPN'x,true); false)
               else isnotin(CPN'xs,CPN'r);
 
          fun member (CPN'root as (ref emptyrecsnode))
             = (refstore:= (ref CPN'RecSig.NoRec,false))
            | member (CPN'root as(ref(recsnode{key, left, right, bf, value=recreflist})))
             = if (CPN'k = key) 
               then 
                if isnotin(recreflist,CPN'rec1)
                then 
                 (refstore:= (ref CPN'rec1,false))
                 else
                  ()
               else 
                if (CPN'k < key)
                then 
		    member(left)
                else 
		     member(right)
 
         in 
          (member noderef;
           !refstore)
         end(*let*)
   end(*local*);

   fun App (func,recstree(noderef))
      = let 
         fun app (ref emptyrecsnode) = ()
           | app (ref (recsnode {left, right, value,...}))
            = ((app left); (func value); (app right))
        in 
         app noderef
        end(*let*);

  fun No CPN'tabel
      = let
          val CPN'no = ref 0;
          val CPN'll = ref 0
        in
         App (fn CPN'rl => (CPN'no:= (!CPN'no + 1); CPN'll:= !CPN'll+(length CPN'rl)),CPN'tabel);
         (!CPN'no,!CPN'll)
        end(*let*);
  end(*abstype*); 
 end(*local*); 
end(*struct*); 

