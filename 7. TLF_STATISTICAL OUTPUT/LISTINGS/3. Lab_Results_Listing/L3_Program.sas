/*============================================================*
 | L3 – Laboratory Results Listing (CRO Style)
 | Study      : ONCO-PEMBRO-500
 | Population : Safety Population
 | Input      : ADLB
 | Output     : One RTF Listing
 | Notes      : Direct ADLB use, no re-derivation
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
 | PREP LAB DATA (FIXED)
 *-------------------------*/
proc sort data=adam.adlb out=adlb_srt;
    by usubjid;
run;

proc sort data=adam.adsl_std out=adsl_srt;
    by usubjid;
run;

data l3_lab;
    length usubjid $50
           studyid $20
           siteid  $3
           country $5
           arm     $8
           trt01a  $40
           param   $200
           paramcd $5
           visit   $8
           lbstresu $6;

    merge adlb_srt(in=a)
          adsl_srt(in=b
              keep=usubjid studyid siteid country arm trt01a saffl);
    by usubjid;

    if a and b;
    if saffl = "Y";

    if paramcd in ("ALT","AST","CREAT","HGB","PLAT","WBC");

    lab_value = aval;
    lab_unit  = lbstresu;
    lab_date  = lbdt;

    format lab_date date9.;

run;

/*-------------------------*
 | SORT FOR REPORT
 *-------------------------*/
proc sort data=l3_lab;
    by studyid usubjid paramcd visitnum lab_date;
run;

/*-------------------------*
 | RTF OUTPUT
 *-------------------------*/
ods rtf file="/home/u64086073/05_TLF/Listings/L3_Laboratory_Results_Listing.rtf"
        style=journal;

/*-------------------------*
 | TITLES
 *-------------------------*/
title1 "Listing 3. Laboratory Results Listing";
title2 "ONCO-PEMBRO-500 | Safety Population";

/*-------------------------*
 | PROC REPORT
 *-------------------------*/
proc report data=l3_lab nowd headline headskip split="|";

    columns
        studyid
        usubjid
        siteid
        country
        arm
        trt01a
        param
        paramcd
        visit
        lab_date
        lab_value
        lab_unit
        base
        chg
        ablfl;

    define studyid  / "Study ID" width=14;
    define usubjid  / "Subject ID" width=20;
    define siteid   / "Site ID" width=6;
    define country  / "Country" width=8;
    define arm      / "Arm" width=6;
    define trt01a   / "Treatment" width=18;

    define param    / "Laboratory Test" width=24;
    define paramcd  / "Test|Code" width=6;

    define visit    / "Visit" width=10;
    define lab_date / "Assessment|Date" width=11 format=date9.;

    define lab_value / "Result" width=10;
    define lab_unit  / "Unit" width=6;

    define base     / "Baseline" width=10;
    define chg      / "Change|from Baseline" width=12;
    define ablfl    / "Baseline|Flag" width=6;

run;

/*-------------------------*
 | CLOSE ODS
 *-------------------------*/
ods rtf close;
title;
