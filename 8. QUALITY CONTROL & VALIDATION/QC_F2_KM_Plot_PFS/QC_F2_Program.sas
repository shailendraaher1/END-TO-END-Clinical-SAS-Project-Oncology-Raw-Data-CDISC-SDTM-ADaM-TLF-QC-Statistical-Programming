/****************************************************************************
Program   : QC for Figure 2 – Kaplan–Meier Plot of Progression-Free Survival
Study     : ONCO-PEMBRO-500
Phase     : Phase III
Population: ITT
Input     : ADAM.ADTTE (adtte.sas7bdat)
Output    : RTF (QC Tables) WITH FIGURE
Author    : Shailendra Aher
Date      : 09-02-2026
****************************************************************************/

options nodate nonumber nocenter;

/*--------------------------------------------------------------------------*
 | RTF Output
 *--------------------------------------------------------------------------*/
ods listing close;
ods rtf file="/home/u64086073/09_VALIDATION/QC_F2_PFS_ADTTE.rtf"
        style=journal;

/*--------------------------------------------------------------------------*
 | QC 1: Total Subject Count (Independent)
 *--------------------------------------------------------------------------*/
title "QC 1: Total Subjects (ADTTE – PFS)";
proc sql;
    select count(distinct USUBJID) as TOTAL_SUBJECTS
    from adam.adtte
    where ITTFL = "Y" and PARAMCD = "PFS";
quit;

/*--------------------------------------------------------------------------*
 | QC 2: Subject Count by Treatment Arm
 *--------------------------------------------------------------------------*/
title "QC 2: Subjects by Treatment Arm";
proc freq data=adam.adtte;
    where ITTFL = "Y" and PARAMCD = "PFS";
    tables ARM / nocum;
run;

/*--------------------------------------------------------------------------*
 | QC 3: Event vs Censor Status
 *--------------------------------------------------------------------------*/
title "QC 3: Event vs Censor (CNSR)";
proc freq data=adam.adtte;
    where ITTFL = "Y" and PARAMCD = "PFS";
    tables CNSR / nocum;
run;

/*--------------------------------------------------------------------------*
 | QC 4: PFS Time Range Check
 *--------------------------------------------------------------------------*/
title "QC 4: PFS Time Range (AVAL)";
proc sql;
    select min(AVAL) as MIN_PFS,
           max(AVAL) as MAX_PFS
    from adam.adtte
    where ITTFL = "Y" and PARAMCD = "PFS";
quit;

/*--------------------------------------------------------------------------*
 | QC 5: Median PFS by Arm (Independent Logic)
 *--------------------------------------------------------------------------*/
title "QC 5: Median PFS by Treatment Arm";
proc means data=adam.adtte median;
    where ITTFL = "Y" and PARAMCD = "PFS";
    class ARM;
    var AVAL;
run;

/*--------------------------------------------------------------------------*
 | QC 6: Mandatory Variable Presence Check
 *--------------------------------------------------------------------------*/
title "QC 6: Mandatory ADTTE Variables Present";
proc contents data=adam.adtte out=qc_vars(keep=name) noprint; run;

proc sql;
    select name as Variable_Name
    from qc_vars
    where upcase(name) in
    ("STUDYID","USUBJID","ARM","PARAM","PARAMCD",
     "AVAL","ADT","CNSR","ITTFL");
quit;

ods rtf close;
ods listing;
