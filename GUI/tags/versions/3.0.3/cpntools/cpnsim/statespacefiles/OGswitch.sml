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
 * Module:       Implements the switch to the OG Tool
 *
 * Description:  switch to the OG Tool
 *
 * CPN Tools
 *)


(******* net capture ******)

CPN'NetCapture.exe();
CPN'NetCapture.check_names();         

(*** net dependent 1 ***)

CPN'Env.use_string (CPN'OGIdsGen.gen_TI());   
CPN'Env.use_string (CPN'OGIdsGen.gen_PI());   
CPN'Env.use_string (CPN'OGBTconvGen.gen_binding());
CPN'Env.use_string (CPN'OGBTconvGen.gen_conv());
CPN'Env.use_string (CPN'OGBTconvGen.gen_encode());
CPN'Env.use_string (CPN'OGBTconvGen.gen_st_binding());      
CPN'Env.use_string (CPN'OGBasicRefsGen.gen());     

(*** net independent middle ***)
CPN'debug("[1:7] Building Data Structures...");

structure CPN'RecSearchTree = 
CPN'OGRECSTORAGE (struct
                  type OGrectype=CPN'OGrec
                  val IsRecEq=CPN'OGDataRecIsEq
		  val NoRec=CPN'NoRec
                  end);
                             
structure CPN'BindSearchTree = 
CPN'OGBINDSTORAGE (struct
                   type OGbindtype=CPN'Binding
                   val emptybind=CPN'BTT000000:OGbindtype
                   fun bindeq(CPN'b1,CPN'b2) = CPN'b1=CPN'b2
		   end);
	  
CPN'Env.use_string(CPN'OGGlobTablesGen.gen());   

val ogpath = "/users/mads/cpntoolsML/OGMLFiles/";

use (ogpath^"OGStopLimitCrit.sml");   
use (ogpath^"OGEnabData.sml");
      
(*** net dependent 2 ***)
CPN'debug("[2:7] Defining Basic OG Functions...");
use (ogpath^"OGUtils.sml"); 
if (CPN'Time.name = "unit")
then
    use (ogpath^"OGNodeSel.sml")
else
    use (ogpath^"OGTimeNodeSel.sml");

CPN'Env.use_string(CPN'OGMarkGen.gen());
CPN'Env.use_string(CPN'OGEncodeGen.gen());
CPN'Env.use_string(CPN'OGToSimDataGen.gen());
CPN'Env.use_string(CPN'OGFromSimDataGen.gen());
CPN'Env.use_string(CPN'OGTransferStateGen.gen());
CPN'Env.use_string(CPN'OGCreateStateRec.gen());
CPN'Env.use_string(CPN'OGTransEnabOccGen.gen());

(*** net independent post : the last OG functions ***)
use (ogpath^"OGInOutPath.sml");
CPN'Env.use_string(CPN'OGBindGen.gen_BindStruct());
CPN'Env.use_string(CPN'OGBindGen.gen_ArcToBE());
use (ogpath^"OGBindMap.sml");

(* generate function *)
CPN'Env.use_string(CPN'OGBindGenNew.gen_BEToArc ()); 
CPN'Env.use_string(CPN'OGBindGen.gen_BEToTI());

CPN'debug("[3:7] Defining Print Functions...");
use (ogpath^"OGPrintFuns.sml");

CPN'debug("[4:7] Defining SCC Functions...");
use (ogpath^"SCC.sml"); 

CPN'debug("[5:7] Defining Search Functions...");
use (ogpath^"OGSearchFuns.sml");
use (ogpath^"OGSearchReachable.sml");
use (ogpath^"OGTime.sml");
(*
 * Some support for drawing using CPN Tools should be added, but
 * that seems to be a project quite far into the future.
 *
 * use (ogpath^"OGDrawUtils.sml");
 * use (ogpath^"OGDrawFuns.sml");
 * use (ogpath^"OGDrawSuppl.sml");
 * use (ogpath^"OGSetAttrOptions.sml");
 *)

use (ogpath^"OGGenFilters.sml");
use (ogpath^"OGSetAttrOptions.sml");
CPN'Env.use_string (CPN'OGIdsGen.gen_stTI());   
CPN'Env.use_string (CPN'OGIdsGen.gen_stPI());   
CPN'Env.use_string(CPN'OGMarkGen.gen_st()); 
CPN'Env.use_string(CPN'OGBindGen.gen_st_BE());
use (ogpath^"OGCalcSucc.sml"); 

CPN'debug("[6:7] Defining Query Functions...");
use (ogpath^"OGProps.sml");

CPN'debug("[7:7] Defining Report Functions...");
use (ogpath^"OGNewSaveReport.sml");

CPN'OGNodeSel.NextNodeNum:=0;
OGSimStatetoOG();
