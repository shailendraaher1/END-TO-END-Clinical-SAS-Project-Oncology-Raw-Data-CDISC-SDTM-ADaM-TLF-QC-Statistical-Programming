/****************************************************************************
Program   : QC for Figure 1 – Kaplan–Meier Plot of Overall Survival 
Study     : ONCO-PEMBRO-500
Phase     : Phase III
Population: ITT
Endpoint  : Overall Survival (OS)
Input     : ADAM.ADTTE
Output    : RTF (QC Tables)
Author    : Shailendra Aher
Date      : 09-02-2026
******************************************************************************/

options nodate nonumber orientation=landscape;
ods listing close;

/*---------------------------------------------------------------------------
Output location
---------------------------------------------------------------------------*/
ods rtf file="/home/u64086073/09_VALIDATION/F1_OS_QC_Output.rtf"
    style=journal;

/*---------------------------------------------------------------------------
QC Dataset Creation (Independent Logic)
NOTE: SAFFL variable NOT USED
---------------------------------------------------------------------------*/
data qc_adtte_os;
    set adam.adtte_os;
    where PARAMCD = "OS";
run;

/*---------------------------------------------------------------------------
QC 1: Subject Count by Treatment Arm
---------------------------------------------------------------------------*/
title1 "QC 1: Subject Count by Treatment Arm (OS)";
proc freq data=qc_adtte_os;
    tables ARM / nocum;
run;

/*---------------------------------------------------------------------------
QC 2: Event vs Censor Distribution by Arm
CNSR = 0 → Event (Death)
CNSR = 1 → Censored
---------------------------------------------------------------------------*/
title1 "QC 2: Event vs Censor Status by Treatment Arm";
proc freq data=qc_adtte_os;
    tables ARM*CNSR / norow nocol nopercent;
run;

/*---------------------------------------------------------------------------
QC 3: Time Variable (AVAL) Summary by Arm
---------------------------------------------------------------------------*/
title1 "QC 3: Overall Survival Time (AVAL) Summary by Arm";
proc means data=qc_adtte_os n min median mean max;
    class ARM;
    var AVAL;
run;

/*---------------------------------------------------------------------------
QC 4: Data Integrity Checks
---------------------------------------------------------------------------*/
data qc_logic_check;
    set qc_adtte_os;
    length FLAG $50;

    if AVAL <= 0 then FLAG = "ERROR: AVAL <= 0";
    else if CNSR = 0 and DEATHDT = . then FLAG = "ERROR: Death without date";
    else FLAG = "OK";
run;

title1 "QC 4: Data Integrity Check Flags";
proc freq data=qc_logic_check;
    tables FLAG / missing;
run;

/*---------------------------------------------------------------------------
QC 5: Total Subject Count Check
---------------------------------------------------------------------------*/
title1 "QC 5: Total Subject Count (OS)";
proc sql;
    select count(distinct USUBJID) as TOTAL_SUBJECTS
    from qc_adtte_os;
quit;

/*---------------------------------------------------------------------------
End of QC
---------------------------------------------------------------------------*/
ods rtf close;
ods listing;

/******************************************************************************
QC EXPECTATION SUMMARY:
- Total Subjects = 500
- Arm A = 250, Arm B = 250
- CNSR distribution matches F1 output
- No ERROR flags in integrity checks
******************************************************************************/
