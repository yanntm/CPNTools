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
 * Module:       OGNewSaveReport.sml
 *
 * Description:  Main structure for generating a Report on the CP-net
 *
 * CPN Tools
 *)

structure OGSaveReport =
struct
    val GenerateHeaderF = ref
    (fn name =>
         "\n\n " ^ name ^ "\n------------------------------------------------------------------------\n"
    )

    fun GenerateHeader name = (!GenerateHeaderF) name

    val GenerateHeadingF = ref
    (fn name =>
         "\n  " ^ name ^ "\n"
    )

    fun GenerateHeading name = (!GenerateHeadingF) name

    val GenerateEntryF = ref
    (fn text =>
         "     " ^ text ^ "\n"
    )

    fun GenerateEntry text = (!GenerateEntryF) text
    
    (* Net name *)
    fun GetNetName() = 
	"CPN Tools state space report for:\n"^
	(OS.Path.concat(Output.getModelDir(),
		       Output.getModelName())
	 handle exn => "<unsaved net>")^
	"\nReport generated: "^
        (Date.toString(Date.fromTimeLocal(Time.now())))^"\n"


    (* Statistics *)
    val Statistics = ref (fn () => "");
    val StatisticsGen = ref false;

    fun GetStatistics CPN'b =
      (GenerateHeader "Statistics") ^
      (if CPN'b 
	     then
		 ((!StatisticsGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 1:8");
			   use (ogpath^"ReportFiles/OGStats.sml");
			   CPN'debug("Processing Statistics..."); true);
		 (!Statistics)())
	 else
	     "")

    (* Boundedness Properties *)
    val IntegerBounds = ref (fn () => "");
    val IntegerBoundsGen = ref false;


    fun GetIntegerBounds CPN'b =
      (GenerateHeader "Boundedness Properties") ^
	(if CPN'b 
	     then
		 ((!IntegerBoundsGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 2:8");
			   use (ogpath^"ReportFiles/OGIntegerBoundsGen.sml");
			   use (ogpath^"ReportFiles/OGIntegerBounds.sml");
			   CPN'debug("Processing Integer Bounds..."); true);
                     (!IntegerBounds()))
	 else
	     "")

    val MultiSetBounds = ref (fn () => "")
    val MultiSetBoundsGen = ref false
			    
    fun GetMultiSetBounds (CPN'b, CPN'bi) = 
	(if CPN'b 
	 then
		 ((!MultiSetBoundsGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 3:8");
		         use (ogpath^"ReportFiles/OGMultiSetBoundsGen.sml");
                     use (ogpath^"ReportFiles/OGMultiSetBounds.sml");
			   CPN'debug("Processing Multi-set Bounds..."); true);
                     (!MultiSetBounds()))
	 else
	     "")

    (* Home Properties *)
    val HomeMarkings = ref (fn () => "")
    val HomeMarkingsGen = ref false

    fun GetHomeMarkings CPN'b = 
      (GenerateHeader "Home Properties") ^
	(if CPN'b 
	     then
		 ((!HomeMarkingsGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 4:8");
			   use (ogpath^"ReportFiles/OGHome.sml");
			   CPN'debug("Processing Home Properties..."); true);
		 (!HomeMarkings()))
	 else
	     "")

    (* Liveness Properties *)
    val DeadMarkings = ref (fn () => "")
    val DeadMarkingsGen = ref false

    fun GetDeadMarkings CPN'b =
      (GenerateHeader "Liveness Properties") ^
	(if CPN'b 
	     then
		 ((!DeadMarkingsGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 5:8");
			   use (ogpath^"ReportFiles/OGDead.sml");
			   CPN'debug("Processing Liveness Properties..."); true);
		 (!DeadMarkings()))
	 else
	     "")


    val DeadTIs = ref (fn () => "")
    val DeadTIsGen = ref false

    fun GetDeadTIs (CPN'b,CPN'pre) = 
	(if CPN'b 
	 then
		 ((!DeadTIsGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 6:8");
			   use (ogpath^"ReportFiles/OGDeadTIs.sml");
			   CPN'debug("Processing Liveness Properties..."); true);
		 (!DeadTIs()))
	 else
	     "")
	
    val LiveTIs = ref (fn () => "")
    val LiveTIsGen = ref false

    fun GetLiveTIs (CPN'b,CPN'pre) = 
	(if CPN'b 
	 then
		 ((!LiveTIsGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 7:8");
			   use (ogpath^"ReportFiles/OGLiveTIs.sml");
			   CPN'debug("Processing Liveness Properties..."); true);
		 (!LiveTIs()))
	 else
	     "")

    (* Fairness Properties *)	
    val FairnessGen = ref false
    val FairnessProperties = ref (fn () => "")
			     
    fun GetFairnessProperties CPN'b = 
      (GenerateHeader "Fairness Properties") ^
	(if CPN'b 
	 then
		 ((!FairnessGen)
		     orelse
			  (CPN'debug("Defining Report Functions - 7:8");
		         use (ogpath^"ReportFiles/OGFairness.sml");
			   CPN'debug("Processing Fairness Properties..."); true);
		 (!FairnessProperties()))
	 else
	     "")

    (* Functions which generates report according to the checked boxes *)
    (* in the Save Report dialog *)

    fun Report (CPN'b1,CPN'b2,CPN'b3,CPN'b4,CPN'b5,CPN'b6,CPN'b7,CPN'b8) = 
	(GetNetName()^(GetStatistics(CPN'b1))^(GetIntegerBounds(CPN'b2))^
	 (GetMultiSetBounds(CPN'b3,CPN'b2))^(GetHomeMarkings(CPN'b4))^
	 (GetDeadMarkings(CPN'b5))^(GetDeadTIs(CPN'b6,CPN'b5))^
	 (GetLiveTIs(CPN'b7,(CPN'b5 orelse CPN'b6)))^
	 (GetFairnessProperties(CPN'b8)))
	     
    (* Function to dump a string on a file *)
    fun DumpReport (CPN'path,CPN'report) =
        let val OUT = TextIO.openOut(CPN'path)
        in
            (TextIO.output(OUT,CPN'report);
             TextIO.closeOut(OUT))
        end

    fun FullOGAndScc () = if ((EntireGraphCalculated ()) andalso (SccGraphCalculated ())) then "1" else "0"

    fun FullOG () = if (EntireGraphCalculated ()) then "1" else "0"

    fun TimedOG () = if CPN'Time.name <> "unit"  then "1" else "0"
    fun SccGen () = if SccGraphCalculated () then "1" else "0"

    (* Main function invoked from the Menu module *)
    fun SaveReport (CPN'b1,CPN'b2,CPN'b3,CPN'b4,CPN'b5,CPN'b6,CPN'b7,CPN'b8,CPN'path) = 
	(CPN'debug ("Dumping report on file: "^CPN'path);
	 DumpReport(CPN'path,Report(CPN'b1,CPN'b2,CPN'b3,CPN'b4,CPN'b5,CPN'b6,CPN'b7,CPN'b8)))




end (* struct CPN'OGReportGen *);

