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


   fun Rehash (recstree (root as(ref(recsnode{key=CPN'key, left=CPN'left, right=CPN'right, bf=CPN'bf, value=recreflist}))), CPN'nkey) = 
       root:= recsnode {key=CPN'nkey, value=recreflist, right=CPN'right, left=CPN'left, bf=CPN'bf}
     | Rehash (recstree (ref emptyrecsnode),_) = ();

   local

    fun rotleft (CPN'root as ref(recsnode{right=CPN'root_right as 
                                  ref(recsnode{left=CPN'root_right_left,...}),...})) =
         let
          val CPN'temp = (ref emptyrecsnode);
         in
          (CPN'temp := !CPN'root_right; 
           CPN'root_right := !CPN'root_right_left;
           CPN'root_right_left := !CPN'root; 
           CPN'root := !CPN'temp)
         end
      | rotleft _ = ();

    fun rotright (CPN'root as ref(recsnode{left=CPN'root_left as 
                                   ref(recsnode{right=CPN'root_left_right,...}),...})) =
         let
          val CPN'temp = (ref emptyrecsnode);
         in
          (CPN'temp := !CPN'root_left; 
           CPN'root_left := !CPN'root_left_right;
           CPN'root_left_right := !CPN'root; 
           CPN'root := !CPN'temp)
         end
      | rotright _ = ();

    fun rightbalance (CPN'root as ref(recsnode{bf=CPN'root_bf, right=CPN'root_right as
                                       ref(recsnode{bf=CPN'root_right_bf,...}),...})) =
         (case (!CPN'root_right_bf) of
           RH => (CPN'root_bf := EH; CPN'root_right_bf := EH; rotleft CPN'root; true) |
           EH => (CPN'root_bf := RH; CPN'root_right_bf := LH; rotleft CPN'root; false) | 
           LH => (case CPN'root_right of
                   ref(recsnode{left=ref(recsnode{bf=CPN'root_right_left_bf,...}),...}) =>
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

    fun leftbalance (CPN'root as ref(recsnode{bf=CPN'root_bf, left=CPN'root_left
                                    as ref(recsnode{bf=CPN'root_left_bf,...}),...})) =
         (case (!CPN'root_left_bf) of
           LH => (CPN'root_bf := EH; CPN'root_left_bf := EH; rotright CPN'root; true) |
           EH => (CPN'root_bf := LH; CPN'root_left_bf := RH; rotright CPN'root; false) | 
           RH => (case CPN'root_left of
                   ref(recsnode{right=ref(recsnode{bf=CPN'root_left_right_bf,...}),...}) =>
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
    
    val CPN'refstore = ref (ref CPN'RecSig.NoRec,false);

   in
    fun Insert (recstree(noderef),CPN'rec1,CPN'k) = 
         let
          fun isnotin ([],_) = true
            | isnotin (CPN'x::CPN'xs,CPN'r)
             = if CPN'RecSig.IsRecEq(CPN'r,!CPN'x)
               then (CPN'refstore:=(CPN'x,true); false)
               else isnotin(CPN'xs,CPN'r);
 
          fun insert (CPN'root as (ref emptyrecsnode))
             = (CPN'root := recsnode {key=CPN'k, value=[(ref CPN'rec1)], right=ref emptyrecsnode, 
                                  left=ref emptyrecsnode, bf=ref EH};
                CPN'refstore:= let val recsnode rootrec = (!CPN'root)
                           in (hd(#value rootrec),false) end;  
                raise taller)
            | insert (CPN'root as(ref(recsnode{key=CPN'key, left=CPN'left, right=CPN'right, bf=CPN'bf, value=recreflist})))
             = if (CPN'k = CPN'key) 
               then 
                if isnotin(recreflist,CPN'rec1)
                then 
                 (CPN'root := recsnode {key=CPN'key, value=(ref CPN'rec1)::recreflist,
                                    right=CPN'right, left=CPN'left, bf=CPN'bf};
                  CPN'refstore:= let val recsnode rootrec = (!CPN'root)
                             in (hd(#value rootrec),false) end) 
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


  local
       val CPN'refstore = ref (ref CPN'RecSig.NoRec,false);
  in

    fun Member (recstree(noderef),CPN'rec1,CPN'k) = 
         let
          fun isnotin ([],_) = true
            | isnotin (CPN'x::CPN'xs,CPN'r)
             = if CPN'RecSig.IsRecEq(CPN'r,!CPN'x)
               then (CPN'refstore:=(CPN'x,true); false)
               else isnotin(CPN'xs,CPN'r);
 
          fun member (CPN'root as (ref emptyrecsnode))
             = (CPN'refstore:= (ref CPN'RecSig.NoRec,false))
            | member (CPN'root as(ref(recsnode{key=CPN'key, left=CPN'left, right=CPN'right, bf=CPN'bf, value=recreflist})))
             = if (CPN'k = CPN'key) 
               then 
                if isnotin(recreflist,CPN'rec1)
                then 
                 (CPN'refstore:= (ref CPN'rec1,false))
                 else
                  ()
               else 
                if (CPN'k < CPN'key)
                then 
		    member(CPN'left)
                else 
		     member(CPN'right)
 
         in 
          (member noderef;
           !CPN'refstore)
         end(*let*)
   end(*local*);

   fun App (func,recstree(noderef))
      = let 
         fun app (ref emptyrecsnode) = ()
           | app (ref (recsnode {left=CPN'left, right=CPN'right, value=CPN'value,...}))
            = ((app CPN'left); (func CPN'value); (app CPN'right))
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

