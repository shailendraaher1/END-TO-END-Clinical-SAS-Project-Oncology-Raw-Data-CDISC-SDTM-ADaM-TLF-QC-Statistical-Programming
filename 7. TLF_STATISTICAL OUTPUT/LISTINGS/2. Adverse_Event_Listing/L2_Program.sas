*============================================================*
 | L2 – Adverse Events Subject Listing (CRO Style)
 | Study      : ONCO-PEMBRO-500
 | Population : Safety Population
 | Input      : ADSL_STD, ADAE
 | Output     : One RTF Listing
 *============================================================*/

/*-------------------------*
 | OPTIONS
 *-------------------------*/
options nodate nonumber nocenter
        mprint nomlogic nosymbolgen
        validvarname=upcase;

/*-------------------------*
 | LIBRARIES
 *-------------------------*/
libname adam "/home/u64086073/04_ADAM";

/*-------------------------*
 | SORT INPUT DATA
 *-------------------------*/
proc sort data=adam.adsl_std
          out=adsl_srt;
    by usubjid;
run;

proc sort data=adam.adae
          out=adae_srt;
    by usubjid;
run;

/*-------------------------*
 | MERGE ADSL + ADAE
 | (Subject-level + AE-level)
 *-------------------------*/
data l2_ae;
    merge adae_srt(in=a)
          adsl_srt(in=b
              keep=usubjid studyid siteid country arm trt01a saffl);
    by usubjid;

    if a and b;
    if saffl = "Y";

    length treatment $40;
    treatment = trt01a;

    format ae_start ae_end date9.;
run;

/*-------------------------*
 | FINAL SORT FOR REPORT
 *-------------------------*/
proc sort data=l2_ae;
    by studyid usubjid ae_start ae_end;
run;

/*-------------------------*
 | RTF OUTPUT
 *-------------------------*/
ods rtf file="/home/u64086073/05_TLF/Listings/L2_AE_Subject_Listing.rtf"
        style=journal;

/*-------------------------*
 | TITLE
 *-------------------------*/
title1 "Listing 2. Adverse Events Subject Listing";
title2 "ONCO-PEMBRO-500 | Safety Population";

/*-------------------------*
 | PROC REPORT
 *-------------------------*/
proc report data=l2_ae nowd headline headskip split="|";

    columns
        studyid
        usubjid
        siteid
        country
        arm
        treatment
        aeterm
        ae_pt
        aesoc
        aesev
        ae_grade
        aeser
        ae_start
        ae_end
        aeout
        ae_action
        sae_dth
        sae_life
        sae_hosp;

    define studyid   / "Study ID" width=14;
    define usubjid   / "Subject ID" width=20;
    define siteid    / "Site ID" width=6;
    define country   / "Country" width=8;
    define arm       / "Arm" width=4;
    define treatment / "Treatment" width=18;

    define aeterm    / "AE Term" width=20;
    define ae_pt     / "Preferred Term" width=20;
    define aesoc     / "SOC" width=28;

    define aesev     / "Severity" width=8;
    define ae_grade  / "CTCAE|Grade" width=6;
    define aeser     / "Serious|AE" width=6;

    define ae_start  / "AE Start|Date" width=10 format=date9.;
    define ae_end    / "AE End|Date" width=10 format=date9.;

    define aeout     / "Outcome" width=14;
    define ae_action / "Action|Taken" width=14;

    define sae_dth   / "Death" width=6;
    define sae_life  / "Life|Threatening" width=6;
    define sae_hosp  / "Hospitalization" width=6;

run;

/*-------------------------*
 | CLOSE ODS
 *-------------------------*/
ods rtf close;

title;
