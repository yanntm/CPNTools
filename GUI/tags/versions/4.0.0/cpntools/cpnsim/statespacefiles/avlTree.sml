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
 * Module:	    AVL Tree (AVLT)
 *
 * Description:	    Polymorphic AVL Tree module. Provides storage
 *     		    for efficient lookup of equality types. 
 *
 * CPN Tools
 *)

structure CPN'AvlTree = 
 struct 
  local
   exception avl;
   exception avl_left;
   exception avl_right;
   exception avl_find;
   exception taller;
   exception CPN'shorter;

   datatype balancefactor = LH | EH | RH;
   datatype 'a node = node of {key:string,value:'a, 
                               left:('a node)ref,
                               right:('a node)ref,
                               bf:balancefactor ref}
                         | emptynode;
  in
   abstype 'a avltree = tree of ('a node) ref
   with

   exception ExcAvlInsert;
   exception ExcAvlLookup;
   exception ExcAvlDelete;


   fun AvlNew () = tree(ref emptynode);

   fun AvlIsEmpty (tree(ref emptynode)) = true
     | AvlIsEmpty _ = false;

   fun AvlReset (tree (root)) = root := emptynode;

   fun AvlSet (tree (root1),tree (root2)) = root1 := (!root2);

   local

    fun rotleft (root as ref(node{right=CPN'root_right as 
                                  ref(node{left=CPN'root_right_left,...}),...})) =
     let
      val CPN'temp = (ref emptynode);
     in
      (CPN'temp := !CPN'root_right; 
       CPN'root_right := !CPN'root_right_left;
       CPN'root_right_left := !root; 
       root := !CPN'temp)
     end
      | rotleft _ = ();

    fun rotright (root as ref(node{left=CPN'root_left as 
                                   ref(node{right=CPN'root_left_right,...}),...})) =
     let
      val CPN'temp = (ref emptynode);
     in
      (CPN'temp := !CPN'root_left; 
       CPN'root_left := !CPN'root_left_right;
       CPN'root_left_right := !root; 
       root := !CPN'temp)
     end
      | rotright _ = ();

    fun rightbalance (root as ref(node{bf=root_bf, right=CPN'root_right as
                                       ref(node{bf=CPN'root_right_bf,...}),...})) =
      (case (!CPN'root_right_bf) of
         RH => (root_bf := EH; CPN'root_right_bf := EH; rotleft root; true) |
         EH => (root_bf := RH; CPN'root_right_bf := LH; rotleft root; false) | 
         LH => (case CPN'root_right
                of ref(node{left=ref(node{bf=CPN'root_right_left_bf,...}),...}) =>
                  (case (!CPN'root_right_left_bf) of
                     EH => (root_bf := EH; CPN'root_right_bf := EH) |
                     RH => (root_bf := LH; CPN'root_right_bf := EH) |
                     LH => (root_bf := EH; CPN'root_right_bf := RH);
                  CPN'root_right_left_bf := EH;
                  rotright CPN'root_right;
                  rotleft root;
                  true)
                | _ => raise avl))
      |  rightbalance _ = false;

    fun leftbalance (root as ref(node{bf=root_bf, left=CPN'root_left
                                    as ref(node{bf=CPN'root_left_bf,...}),...})) =
      (case (!CPN'root_left_bf) of
         LH => (root_bf := EH; CPN'root_left_bf := EH; rotright root; true) |
         EH => (root_bf := LH; CPN'root_left_bf := RH; rotright root; false) | 
         RH => (case CPN'root_left
                of ref(node{right=ref(node{bf=CPN'root_left_right_bf,...}),...}) =>
                  (case (!CPN'root_left_right_bf) of
                     EH => (root_bf := EH; CPN'root_left_bf := EH) |
                     RH => (root_bf := EH; CPN'root_left_bf := LH) |
                     LH => (root_bf := RH; CPN'root_left_bf := EH);
                  CPN'root_left_right_bf := EH;
                  rotleft CPN'root_left;
                  rotright root;
                  true)
               | _ => raise avl))
      |  leftbalance _ = false;
   in
    fun AvlInsert (tree(noderef)) (CPN'k,CPN'v) = 
    let 
     fun insert (root as (ref emptynode))
        = (root := node {key=CPN'k, value=CPN'v, right = ref emptynode, 
                            left = ref emptynode, bf = ref EH};
           raise taller)
       | insert (root as (ref (node {key, left, right, bf,...})))
        = if (CPN'k = key) 
            then raise ExcAvlInsert
            else 
              if (CPN'k < key)
                then (insert(left) handle taller =>
                        (case !bf of
                           EH => (bf := LH; raise taller) |
                           LH => (leftbalance root;()) |
                           RH => bf := EH))
                else (insert(right) handle taller =>
                        (case !bf of 
                           EH => (bf := RH; raise taller) |
                           LH => bf := EH |
                           RH => (rightbalance root;()) ));
    in 
     insert noderef handle taller => ()
    end;


(* This functions inserts the element (k,v) into tree if there is no
   element with key "k". If there is such an element (k,w) it is
   exchanged by (k,v).
   If the tree gets taller the function returns true, else false.
 

    fun AvlWriteIn (tree(noderef)) (k,v) = 
    let 
     fun exchange (root as (ref (node{left, right ,bf,...}))) 
        = (root := node {key=k, value=v, right=right, left=left, bf=bf};
           false)
      |  exchange _ = 
            raise CPN'userexcp ("Severe error in internal table")

     fun insert (root as (ref emptynode))
        = (root := node {key=k, value=v, right = ref emptynode, 
                            left = ref emptynode, bf = ref EH};
           raise taller)
       | insert (root as (ref (node {key, left, right, bf,...})))
        = if (k = key) 
            then                 (* we have to exchange *)
              exchange (root)
            else                 (* we have to insert   *)
              if (k < key)
                then (insert(left) handle taller =>
                        (case !bf of
                           EH => (bf := LH; raise taller) |
                           LH => (leftbalance root;true) |
                           RH => (bf := EH;true)))
                else (insert(right) handle taller =>
                        (case !bf of 
                           EH => (bf := RH; raise taller) |
                           LH => (bf := EH;true) |
                           RH => (rightbalance root;true) ));
    in 
     insert noderef handle taller => true
    end; *)

	       fun AvlFold (func,start,tree(noderef)) =
		   let 
		       fun fold (ref emptynode, result)
			   = result 
			 | fold (ref (node {left, right, value,...}),result)
			   = fold(left,func (value, fold(right,result)))
		   in 
		       fold(noderef,start)
		   end;
		   
		   
    fun AvlApp (func,tree(noderef)) =
    let 
     fun app (ref emptynode)
        = () |
      app (ref (node {left, right, value,...}))
        = ((app left); (func value); (app right))
    in 
     app noderef
    end;

    fun AvlAppKey (func,tree(noderef)) =
    let 
     fun app (ref emptynode)
        = () |
      app (ref (node {key, left, right, value,...}))
        = ((app left); (func (key,value)); (app right))
    in 
     app noderef
    end;

    fun AvlLookup (tree(noderef),CPN'k) =
    let 
     fun lookup (ref emptynode)
        = raise ExcAvlLookup
       | lookup (ref (node {key, left, right, value,...}))
        = if (CPN'k = key) 
            then value
            else if (CPN'k < key) then lookup(left) else lookup(right);
    in 
     lookup noderef
    end;

local
fun rightmost (root as (ref (node{left,right as (ref emptynode),...})))
  = let val CPN'tnode = ref (!root)
    in
	(root := !left;
	 (true,CPN'tnode))
    end
  | rightmost (root as (ref (node{right,bf,...})))
    = let val (CPN'short,CPN'tnode) = rightmost right
      in
	  if CPN'short
	  then
    	      case !bf of
		  RH => (bf := EH; (true,CPN'tnode))
		| EH => (bf := LH; (false,CPN'tnode))
		| LH => (leftbalance root,CPN'tnode)
	  else
	      (false,CPN'tnode)
      end
  | rightmost _ = raise avl_right;
    

fun leftmost (root as (ref (node{right,left as (ref emptynode),...})))
   = let val CPN'tnode = ref (!root)
     in
      (root := !right;
       (true,CPN'tnode))
      end
  | leftmost (root as (ref (node{left,bf,...})))
   = let val (CPN'short,CPN'tnode) = leftmost left
     in
      if CPN'short
      then 
       case !bf of
	  LH => (bf := EH; (true,CPN'tnode))
        | EH => (bf := RH; (false,CPN'tnode))
        | RH => (rightbalance root,CPN'tnode)
      else
       (false,CPN'tnode)
     end
  | leftmost _ = raise avl_left;

fun find (root as (ref emptynode)) = raise avl_find
 |  find (root as (ref (node{left as (ref emptynode),right as (ref emptynode),...})))
        = (root := emptynode; raise CPN'shorter)
 | find (root as (ref (node{key=root_key,left=CPN'root_left,right=CPN'root_right,bf=root_bf,...}))) 
       = case !root_bf of
            LH => (case rightmost CPN'root_left of 
                     (CPN'short,(CPN'tnode as (ref (node{key,left,right,bf,...})))) =>
			 (root := !CPN'tnode;
 			  left := !CPN'root_left;
			  right := !CPN'root_right;
   			  if CPN'short
                          then       
                 (bf := EH; raise CPN'shorter)
                else
                 bf := LH)
              | _ => raise avl)
                  
     | RH  => (case leftmost CPN'root_right
               of (CPN'short,(CPN'tnode as (ref (node{key,left,right,bf,...})))) =>
                (root := !CPN'tnode;
                 left := !CPN'root_left;
                 right := !CPN'root_right;
                 if CPN'short
                 then
                  (bf := EH; raise CPN'shorter)
                 else
                  bf := RH)
               | _ => raise avl)
                 
     | EH  => (case leftmost CPN'root_right
               of (CPN'short,(CPN'tnode as (ref (node{key,left,right,bf,...})))) =>
                (root := !CPN'tnode;
                 left := !CPN'root_left;
                 right := !CPN'root_right;
                 if CPN'short
                 then
                  bf := LH
                 else
                  bf := EH)
               | _ => raise avl)
                 
in

    fun AvlDelete (tree(noderef)) CPN'k =
    let 
     fun delete (ref emptynode)
        = raise ExcAvlDelete
       | delete (root as (ref (node {key,left,right,bf,...})))
        = if (CPN'k = key) 
            then (find root)
            else
              if (CPN'k < key)
                then (delete(left) handle CPN'shorter =>
                        (case !bf of
                           EH =>  bf := RH |
                           LH => (bf := EH; raise CPN'shorter) |
                           RH => if rightbalance root
                                 then raise CPN'shorter else () ))
                else (delete(right) handle CPN'shorter =>
                        (case !bf of 
                           EH =>  bf := LH |
                           LH =>  if leftbalance root
                                  then raise CPN'shorter else () |
                           RH => (bf := EH; raise CPN'shorter)));
    in 
     delete noderef handle CPN'shorter => ()
    end

end;

    fun AvlNo tabel
      = let val CPN'no = ref 0
        in
         (AvlApp (fn _ => (CPN'no:= !CPN'no + 1),tabel); (!CPN'no))
        end;

    fun AvlCopy tabel
      = let val CPN'newtab = AvlNew()
        in
         (AvlAppKey(AvlInsert CPN'newtab,tabel); CPN'newtab)
        end;

    fun AvlAdd (tab1,tab2)
      = let val CPN'newtab = AvlCopy tab1
        in
         (AvlAppKey
           (fn elm => AvlInsert CPN'newtab elm handle ExcAvlInsert => (),
           tab2);
          CPN'newtab)
        end;

    fun AvlAnd (tab1,tab2)
      = let val CPN'newtab = AvlNew()
        in
         (AvlAppKey
           (fn (elm as (key,_)) =>
            (AvlLookup (tab2,key); AvlInsert CPN'newtab elm)
              handle ExcAvlLookup => (),
           tab1);
          CPN'newtab)
        end;

    fun AvlSub (tab1,tab2)
      = let val CPN'newtab = AvlNew()
        in
         (AvlAppKey
          (fn elm as (key,_) =>
            (AvlLookup(tab2,key);())
              handle ExcAvlLookup =>
               AvlInsert CPN'newtab elm,
          tab1);
         CPN'newtab)
        end;
   end; 
  end; 
 end; 
end; 

