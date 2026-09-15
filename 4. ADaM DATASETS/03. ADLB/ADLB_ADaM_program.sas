/*****************************************************************************************
Program   : 08_ADLB_program.sas
Study     : ONCO-PEMBRO-500
Dataset   : ADLB (Laboratory Analysis Dataset)
Purpose   : Create CRO-ready ADLB with ZERO errors & ZERO warnings
Author    : Final Stable Version
*****************************************************************************************/

/*------------------------------------------------------------
 STEP 0 : OPTIONS (Notes ON – Do NOT hide)
------------------------------------------------------------*/
options nocenter nodate nonumber;
options notes source stimer;

/*------------------------------------------------------------
 STEP 1 : Assign Libraries
------------------------------------------------------------*/
libname SDTM "/home/u64086073/03_SDTM";
libname ADAM "/home/u64086073/04_ADAM";

/*------------------------------------------------------------
 STEP 2 : Clean start – delete old ADLB if exists
------------------------------------------------------------*/
proc datasets lib=ADAM nolist;
    delete ADLB;
quit;

/*------------------------------------------------------------
 STEP 3 : Prepare SDTM.LB (NO length redefinition)
------------------------------------------------------------*/
proc sort data=SDTM.LB
          out=WORK.LB_BASE;
    by STUDYID USUBJID LBDTC LBTESTCD;
run;

/*------------------------------------------------------------
 STEP 4 : Merge ADSL with LB
 (ADSL is subject-level master – DO NOT redefine lengths)
------------------------------------------------------------*/
proc sort data=ADAM.ADSL
          out=WORK.ADSL_BASE;
    by STUDYID USUBJID;
run;

data WORK.ADLB_BASE;
    merge WORK.ADSL_BASE (in=a)
          WORK.LB_BASE   (in=b);
    by STUDYID USUBJID;
    if a and b;
run;

/*------------------------------------------------------------
 STEP 5 : Derivations (Clean & Standard)
------------------------------------------------------------*/
data ADAM.ADLB;
    set WORK.ADLB_BASE;

    /* Analysis Value */
    if not missing(LBSTRESN) then AVAL = LBSTRESN;

    /* Analysis Visit */
    AVISIT  = VISIT;
    AVISITN = VISITNUM;

    /* Baseline Flag */
    if LBSTRESN ne . and LBDTC <= RFSTDTC then ABLFL = "Y";
    else ABLFL = " ";

    /* Change from Baseline */
    retain BASE;
    if ABLFL = "Y" then BASE = AVAL;
    if BASE ne . and AVAL ne . then CHG = AVAL - BASE;

    /* Parameter */
    PARAM   = catx(" ", LBTEST, LBSTRESU);
    PARAMCD = LBTESTCD;

    label
        AVAL    = "Analysis Value"
        BASE    = "Baseline Value"
        CHG     = "Change from Baseline"
        ABLFL   = "Baseline Flag"
        PARAM   = "Parameter"
        PARAMCD = "Parameter Code";
run;

/*------------------------------------------------------------
 STEP 6 : PROC PRINT (Results tab – sample check)
------------------------------------------------------------*/

proc print data=ADAM.ADLB (obs=20);
run;
/*------------------------------------------------------------
 STEP 7 : PROC CONTENTS (Results tab)
------------------------------------------------------------*/
proc contents data=ADAM.ADLB;
run;



/*****************************************************************************************
 END OF PROGRAM
*****************************************************************************************/
