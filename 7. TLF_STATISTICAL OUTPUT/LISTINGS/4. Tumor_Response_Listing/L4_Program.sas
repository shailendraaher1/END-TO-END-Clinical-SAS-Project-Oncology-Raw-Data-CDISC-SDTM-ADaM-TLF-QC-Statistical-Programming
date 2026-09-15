/*============================================================*
 | L4 – Tumor Response Assessments Listing (CRO Style)
 | Study      : ONCO-PEMBRO-500
 | Population : ITT Population
 | Input      : ADSL_STD, ADRESP
 | Output     : One RTF Listing
 *============================================================*/

options nodate nonumber nocenter
        mprint nomlogic nosymbolgen
        validvarname=upcase;

libname adam "/home/u64086073/04_ADAM";

/*-------------------------*
 | SORT INPUT DATA
 *-------------------------*/
proc sort data=adam.adsl_std out=adsl_srt;
    by usubjid;
run;

proc sort data=adam.adresp out=adresp_srt;
    by usubjid adt;
run;

/*-------------------------*
 | MERGE DATA
 *-------------------------*/
data l4_resp;
    length treatment $40 assessdtc $12;

    merge adresp_srt(in=a
                     keep=studyid usubjid param avalc adt anl01fl)
          adsl_srt (in=b
                     keep=usubjid siteid country trt01a rand_arm ittfl);

    by usubjid;

    if a and b;
    if ittfl = "Y";

    /* Treatment handling */
    if not missing(trt01a) then treatment = trt01a;
    else treatment = rand_arm;

    /* Assessment Date – no derivation */
    if not missing(adt) then assessdtc = put(adt, date9.);
    else assessdtc = "";

run;



/*-------------------------*
 | FINAL SORT
 *-------------------------*/
proc sort data=l4_resp;
    by studyid usubjid adt param;
run;

/*-------------------------*
 | RTF OUTPUT
 *-------------------------*/
ods rtf file="/home/u64086073/05_TLF/Listings/L4_Tumor_Response_Assessments_Listing.rtf"
        style=journal;

title1 "Listing 4. Tumor Response Assessments Listing";
title2 "ONCO-PEMBRO-500 | ITT Population";

/*-------------------------*
 | REPORT
 *-------------------------*/
proc report data=l4_resp nowd headline headskip split="|";

    columns
        studyid
        usubjid
        siteid
        country
        treatment
        param
        avalc
        assessdtc
        anl01fl;

    define studyid   / "Study ID";
    define usubjid   / "Subject ID";
    define siteid    / "Site ID";
    define country   / "Country";
    define treatment / "Treatment";
    define param     / "Response Parameter";
    define avalc     / "Tumor Response";
    define assessdtc / "Assessment Date";
    define anl01fl   / "Analysis Flag";

run;
