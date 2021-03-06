(************************************************************************)
(* CPN Tools Simulator (Simulator/CPN)                                  *)
(* Copyright 2010-2011 AIS Group, Eindhoven University of Technology    *)
(* All rights reserved.                                                 *)
(*                                                                      *)
(* This file is part of the CPN Tools Simulator (Simulator/CPN).        *)
(*                                                                      *)
(* You can choose among two licenses for this code, either the GNU      *)
(* General Public License version 2 or the below 4-clause BSD License.  *)
(*                                                                      *)
(************************************************************************)
(* GNU General Public License for CPN Tools Simulator (Simulator/CPN)   *)
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
(* 4-clause BSD License for CPN Tools Simulator (Simulator/CPN)         *)
(*                                                                      *)
(* Redistribution and use in source and binary forms, with or without   *)
(* modification, are permitted provided that the following conditions   *)
(* are met:                                                             *)
(*                                                                      *)
(* 1. Redistributions of source code must retain the above copyright    *)
(* notice, this list of conditions and the following disclaimer.        *)
(* 2. Redistributions in binary form must reproduce the above copyright *)
(* notice, this list of conditions and the following disclaimer in the  *)
(* documentation and/or other materials provided with the distribution. *)
(* 3. All advertising materials mentioning features or use of this      *)
(* software must display the following acknowledgement: ???This product   *)
(* includes software developed by the AIS Group, Eindhoven University   *)
(* of Technology and the CPN Group, Aarhus University.???                 *)
(* 4. Neither the name of the AIS Group, Eindhoven University of        *)
(* Technology, the name of Eindhoven University of Technology, nor the  *)
(* names of its contributors may be used to endorse or promote products *)
(* derived from this software without specific prior written permission.*)
(*                                                                      *)
(* THIS SOFTWARE IS PROVIDED BY THE AIS GROUP, EINDHOVEN UNIVERSITY OF  *)
(* TECHNOLOGY AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,   *)
(* BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND    *)
(* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL   *)
(* THE AIS GROUP, EINDHOVEN UNIVERSITY OF TECHNOLOGY BE LIABLE FOR ANY  *)
(* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL   *)
(* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE    *)
(* GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS        *)
(* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER *)
(* IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR      *)
(* OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN  *)
(*IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                         *)
(************************************************************************)
(*
  Module:           Sim Processor

  Description:      Simulator support. Functions which can be called
                    with a stream containing a sim request.
                    The request will be read out of the stream, processed
                    and the result written out to the given stream.

  CPN Tools
*)

import "stream.sig";
import "error.sig";
import "miscUtils.sig";
import "byteArray.sig";
import "majorOpcodes.sig";
import "simProcess.sig";

functor SimProcess (
                structure Extension : EXTENSION
		    structure Err : GRAMERROR
		    structure BAExt : BYTEARRAYEXT
		    structure Opcodes : MAJOROPCODES
                ) : SIMPROCESS = struct

    type ilist = int list
    type blist = bool list
    type slist = string list
    type gluefun = ((blist * ilist * slist) -> (blist * ilist * slist))
	
    exception InternalError of string

    val gluefun: gluefun = fn (blist: blist,ilist: ilist, slist: slist) =>
	(nil: blist, nil: ilist, nil: slist)

    (* Initialization values for callbacks *)
    val NSBootstrap = ref (fn (timetype: string, 
			       starttime: string, 
			       filename: string) => 
			   (nil:blist,nil: ilist ,nil: slist));
    val NSMisc = ref gluefun
    val NSCompileDecl = ref gluefun
    val NSSyntaxCheck = ref gluefun
    val NSSimulate = ref gluefun
    val NSMonitor = ref gluefun
    val NSChart = ref gluefun
    val NSWFA = ref gluefun
    val NSStateSpace = ref gluefun
    val NSExtension = ref gluefun

    val ERRTAG = ~1
    val TERMTAG = 1
    val RESPTAG = 2

    fun add_termtag(blist,ilist,slist) = (blist, TERMTAG::ilist, slist)

        fun process message =
	    (case message of
		 (_,100::_,timetype::starttime::dumpfile::_) => 
		     add_termtag(!NSBootstrap(timetype,starttime,dumpfile))
	       | (blist,200::ilist,slist) => 
		     add_termtag(!NSMisc(blist,ilist,slist))
	       | (blist,300::ilist,slist) => 
		     add_termtag(!NSCompileDecl(blist,ilist,slist))
	       | (blist,400::ilist,slist) => 
		     add_termtag(!NSSyntaxCheck(blist,ilist,slist))
	       | (blist,450::ilist,slist) => 
		     add_termtag(!NSMonitor(blist,ilist,slist))
	       | (blist,500::ilist,slist) => 
		     add_termtag(!NSSimulate(blist,ilist,slist))
	       | (blist,600::ilist,slist) => 
		     add_termtag(!NSChart(blist,ilist,slist))
	       | (blist,700::ilist,slist) => 
		     add_termtag(!NSWFA(blist,ilist,slist))
	       | (blist,800::ilist,slist) => 
		     add_termtag(!NSStateSpace(blist,ilist,slist))
	       | (blist,10000::ilist,slist) => 
		     (!NSExtension(blist,ilist,slist))
	       | (_, opcode::list, _) => 
		     raise InternalError("Unknown Opcode: "^Int.toString(opcode))
	       | _ => raise InternalError("Missing Opcode"))
		 handle (exn as (InternalError str))=>
		     let
			 val err = "InternalError: "^str^"\n"^(String.concat(List.map (fn s => ("\t"^s^"\n"))
                   (SMLofNJ.exnHistory exn)))

		     in
			 (Err.debug err; (nil, [ERRTAG], [err]))
                 end
		      | exn => 
		     let
			 val err = "Uncaught Exception!: "^(exnMessage
                   exn)^"\n"^(String.concat(List.map (fn s => ("\t"^s^"\n"))
                   (SMLofNJ.exnHistory exn)))
		     in
			 (Err.debug err; (nil, [ERRTAG], [err]))
		     end
end; (* functor SimProcess *)
