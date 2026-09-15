/*============================================================*
* Table 6 – Laboratory Parameters: Baseline & Change (ITT)
* Input  : ADSL_STD, ADLB
* Output : One RTF, One CRO-like Table
*============================================================*/

options nodate nonumber nocenter;
ods escapechar='^';

/*---------------------------------------------------------------*
 | Step 1: Keep ITT Population only
 *---------------------------------------------------------------*/
data lab_itt;
    set work.adlb_final;
    where ITTFL = 'Y';
run;

/*---------------------------------------------------------------*
 | Step 2: Create analysis rows (Baseline / Change)
 *---------------------------------------------------------------*/
data lab_long;
    set lab_itt;

    length STAT $30 VALUE 8;

    STAT = "Baseline Mean (SD)";
    VALUE = BASE_M;
    output;

    STAT = "Change from Baseline Mean (SD)";
    VALUE = CHG_M;
    output;

    keep USUBJID PARAM PARAMCD TRT01A STAT VALUE;
run;

/*---------------------------------------------------------------*
 | Step 3: Summary statistics
 *---------------------------------------------------------------*/
proc means data=lab_long noprint;
    class PARAM STAT TRT01A;
    var VALUE;
    output out=lab_stats
        mean=MEAN
        std=SD;
run;

/*---------------------------------------------------------------*
 | Step 4: Create display value
 *---------------------------------------------------------------*/
data lab_disp;
    set lab_stats;
    where _TYPE_ > 0;

    length DISP $40;
    DISP = catx(' ', put(MEAN,8.2), '(' || put(SD,8.2) || ')');

    keep PARAM STAT TRT01A DISP;
run;

/*---------------------------------------------------------------*
 | Step 5: Transpose to CRO-like structure
 *---------------------------------------------------------------*/
proc sort data=lab_disp;
    by PARAM STAT;
run;

proc transpose data=lab_disp out=lab_final(drop=_NAME_);
    by PARAM STAT;
    id TRT01A;
    var DISP;
run;

/*---------------------------------------------------------------*
 | Step 6: Generate RTF Table
 *---------------------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Tables/Table_6_Laboratory_Summary.rtf"
    style=journal;

title "Table 6. Laboratory Parameters – Baseline and Change from Baseline (ITT Population)";

proc report data=lab_final nowd headline headskip split='|';
    columns PARAM STAT Pembrolizumab Placebo;

    define PARAM / group "Parameter" width=25;
    define STAT  / group "Statistic" width=30;
    define Pembrolizumab / display "Arm A (Pembrolizumab)" width=22;
    define Placebo       / display "Arm B (Placebo)" width=22;
run;

footnote1 "Baseline defined as last non-missing value prior to first dose.";
footnote2 "Change from baseline = post-baseline value minus baseline.";
footnote3 "Dummy data used for academic demonstration of ADaM to TLF flow.";

ods rtf close;
