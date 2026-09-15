/*====================================================================*
 Program  : 09_ADTTE_FINAL_THESIS.sas
 Study    : ONCO-PEMBRO-500
 Dataset  : ADTTE
 Purpose  : Create CRO / Thesis ready ADTTE dataset
 Author   : Shailendra Aher
 Status   : FINAL – ZERO ERRORS / ZERO WARNINGS
*--------------------------------------------------------------------*
 Description:
 - Time-to-Event dataset for Overall Survival (OS)
 - Uses standardized ADSL_STD and ADAE_STD
 - Includes PROC CONTENTS and PROC PRINT for documentation
*====================================================================*/

/*----------------------------*
 | STEP 0 : OPTIONS
 *----------------------------*/
options nocenter nodate nonumber;
options notes source stimer;

/*----------------------------*
 | STEP 1 : LIBRARIES
 *----------------------------*/
libname ADAM "/home/u64086073/04_ADAM";

/*----------------------------*
 | STEP 2 : DELETE OLD ADTTE
 *----------------------------*/
proc datasets lib=adam nolist;
    delete adtte;
quit;

/*----------------------------*
 | STEP 3 : CREATE ADTTE
 *----------------------------*/
data ADAM.ADTTE;
    length
        STUDYID   $20
        USUBJID   $40
        TRT01P    $20
        TRT01A    $20
        PARAMCD   $8
        PARAM     $40
        AVAL       8
        CNSR       8
        STARTDT    8
        ADT        8
        AENDT      8
        ADY        8
    ;

    format STARTDT ADT AENDT date9.;

    /* Merge subject level + event level */
    set ADAM.ADSL_STD
        ADAM.ADVS;

    /* Parameter definition */
    PARAMCD = "OS";
    PARAM   = "Overall Survival";

    /* Start date = Treatment start date */
    STARTDT = TRTSDT;

    /* Event logic */
    if not missing(AESTDT) then do;
        ADT  = AESTDT;   /* Event date */
        CNSR = 0;        /* Event occurred */
    end;
    else do;
        ADT  = RFENDT;   /* Censor date */
        CNSR = 1;        /* Censored */
    end;

    AENDT = ADT;

    /* Analysis value (time in days) */
    if n(STARTDT, ADT) = 2 then
        AVAL = ADT - STARTDT + 1;

    /* Analysis day */
    if n(ADT, TRTSDT) = 2 then
        ADY = ADT - TRTSDT + 1;

run;

/*----------------------------*
 | STEP 5 : PROC PRINT (Sample)
 *----------------------------*/
title "PROC PRINT – ADTTE (First 20 Subjects)";
proc print data=ADAM.ADTTE(obs=20) label;
    var STUDYID USUBJID TRT01P PARAMCD PARAM
        STARTDT ADT AENDT AVAL CNSR ADY;
run;
title;

/*----------------------------*
 | STEP 4 : PROC CONTENTS
 *----------------------------*/
title "PROC CONTENTS – ADTTE Dataset";
proc contents data=ADAM.ADTTE varnum;
run;
title;



/*----------------------------*
 | END OF PROGRAM
 *----------------------------*/
