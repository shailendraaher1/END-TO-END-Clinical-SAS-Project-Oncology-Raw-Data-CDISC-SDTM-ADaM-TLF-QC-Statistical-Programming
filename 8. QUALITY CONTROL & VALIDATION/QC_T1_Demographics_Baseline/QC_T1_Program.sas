/*==============================================================*
 | QC Program : QC_T01_Demographic_Baseline
 | Table      : Table 1 – Demographic and Baseline Characteristics
 | Purpose    : Independent QC using separate logic
 | Dataset    : ADAM.ADSL_STD
 | Standard   : CRO-style Validation (Academic Project)
 *==============================================================*/

options nocenter nodate nonumber;
ods listing close;

libname adam "/home/u64086073/04_ADAM";

/*--------------------------------------------------------------*
 | Open QC RTF
 *--------------------------------------------------------------*/
ods rtf file="/home/u64086073/09_VALIDATION/QC_T01_Demographic_Baseline.rtf"
        style=journal;

/*--------------------------------------------------------------*
 | Titles
 *--------------------------------------------------------------*/
title1 "QC Report – Table 1";
title2 "Demographic and Baseline Characteristics";
title3 "ONCO-PEMBRO-500 | ITT Population";

/*--------------------------------------------------------------*
 | ITT Population (QC Dataset)
 *--------------------------------------------------------------*/
data adsl_qc;
    set adam.adsl_std;
    where ittfl = 'Y';
run;

/*--------------------------------------------------------------*
 | QC 1: Denominator Check
 *--------------------------------------------------------------*/
title4 "QC Check 1: Subject Count by Treatment Arm";

proc freq data=adsl_qc;
    tables armcd / missing;
run;

/*--------------------------------------------------------------*
 | QC 2: Sex Distribution
 *--------------------------------------------------------------*/
title4 "QC Check 2: Sex Distribution by Treatment Arm";

proc freq data=adsl_qc;
    tables armcd*sex / missing;
run;

/*--------------------------------------------------------------*
 | QC 3: Age Summary
 *--------------------------------------------------------------*/
title4 "QC Check 3: Age (Years) Summary";

proc means data=adsl_qc n mean std min max maxdec=1;
    class armcd;
    var age;
run;

/*--------------------------------------------------------------*
 | QC 4: Race Distribution
 *--------------------------------------------------------------*/
title4 "QC Check 4: Race Distribution";

proc freq data=adsl_qc;
    tables race*armcd / missing;
run;

/*--------------------------------------------------------------*
 | QC 5: ECOG Distribution
 *--------------------------------------------------------------*/
title4 "QC Check 5: ECOG Score";

proc freq data=adsl_qc;
    tables ecog*armcd / missing;
run;

/*--------------------------------------------------------------*
 | QC 6: Sample Subject-Level Review
 *--------------------------------------------------------------*/
title4 "QC Check 6: Sample Subject Review (First 10 Subjects)";

proc print data=adsl_qc(obs=10);
    var studyid usubjid armcd age sex race ecog height weight ittfl;
run;

/*--------------------------------------------------------------*
 | Close RTF
 *--------------------------------------------------------------*/
ods rtf close;

title;
ods listing;
