/*============================================================*
 | Program Name : L5_Time_to_Event_Endpoints_Listing.sas
 | Study        : ONCO-PEMBRO-500
 | Input Data   : ADTTE, ADSL_STD
 | Output File  : L5_Time_to_Event_Endpoints_Listing.rtf
 | Author       : Aher Shailendra
 | Date         : 07/02/2026
 *============================================================*/

/*-------------------------*
 | OPTIONS
 *-------------------------*/
options nodate nonumber nocenter validvarname=upcase;

/*-------------------------*
 | LIBRARY
 *-------------------------*/
libname adam "/home/u64086073/04_ADAM";

/*-------------------------*
 | SORT INPUT DATA
 *-------------------------*/
proc sort data=adam.adtte out=adtte_srt;
    by usubjid;
run;

proc sort data=adam.adsl_std out=adsl_srt;
    by usubjid;
run;

/*-------------------------*
 | MERGE ADTTE + ADSL
 *-------------------------*/
data l5_final;
    merge adtte_srt(in=a
                    keep=studyid usubjid param aval cnsr adt)
          adsl_srt (in=b
                    keep=usubjid siteid country trt01a ittfl);

    by usubjid;

    if a and b;
    if ittfl = "Y";

    length
        endpoint  $40
        treatment $40
        censfl    $1;

    endpoint  = param;
    treatment = trt01a;

    /* Censor Flag (Display Friendly) */
    if cnsr = 1 then censfl = "Y";
    else if cnsr = 0 then censfl = "N";

    format adt date9.;
run;

/*-------------------------*
 | RTF OUTPUT
 *-------------------------*/
ods rtf file="/home/u64086073/05_TLF/Listings/L5_Time_to_Event_Endpoints_Listing.rtf"
    style=journal;

/*-------------------------*
 | TITLES
 *-------------------------*/
title1 "Listing 5. Time-to-Event Endpoints Listing";
title2 "ONCO-PEMBRO-500 | ITT Population";

/*-------------------------*
 | PROC REPORT
 *-------------------------*/
proc report data=l5_final nowd headline headskip split="|";

    columns
        studyid
        usubjid
        siteid
        country
        treatment
        endpoint
        adt
        aval
        censfl;

    define studyid   / "Study ID" width=14;
    define usubjid   / "Subject ID" width=22;
    define siteid    / "Site ID" width=6;
    define country   / "Country" width=8;
    define treatment / "Treatment" width=18;

    define endpoint  / "Endpoint" width=28;
    define adt       / "Event /|Censor Date" format=date9. width=12;
    define aval      / "Time to Event|(Days)" width=12;
    define censfl    / "Censored" width=6;

run;

/*-------------------------*
 | CLOSE ODS
 *-------------------------*/
ods rtf close;
title;
