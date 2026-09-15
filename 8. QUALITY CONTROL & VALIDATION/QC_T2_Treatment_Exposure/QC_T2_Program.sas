/*==============================================================*
 | QC Table 2: Treatment Exposure Summary (ITT Population)
 | Independent QC – Light but Strong
 *==============================================================*/

options nodate nonumber nocenter;
ods escapechar='^';

libname adam "/home/u64086073/04_ADAM";

/*--------------------------------------------------------------*
 | QC – ITT Population + Exposure Duration
 *--------------------------------------------------------------*/
data qc_exp;
    set adam.adsl_std;
    where ITTFL = 'Y';

    if not missing(TRTSDT) and not missing(TRTEDT) then
        QC_EXPDUR = TRTEDT - TRTSDT + 1;
run;

/*--------------------------------------------------------------*
 | QC – Subject Counts (PROC SQL)
 *--------------------------------------------------------------*/
proc sql noprint;
    select count(*) into :QC_N_A from qc_exp where ARMCD='A';
    select count(*) into :QC_N_B from qc_exp where ARMCD='B';
    select count(*) into :QC_N_T from qc_exp;
quit;

/*--------------------------------------------------------------*
 | QC – Exposure Summary by Arm (PROC MEANS)
 *--------------------------------------------------------------*/
proc means data=qc_exp noprint;
    class ARMCD;
    var QC_EXPDUR;
    output out=qc_arm
        mean=mean
        std=sd
        median=median
        min=min
        max=max;
run;

/*--------------------------------------------------------------*
 | QC – Overall Exposure Summary
 *--------------------------------------------------------------*/
proc means data=qc_exp noprint;
    var QC_EXPDUR;
    output out=qc_tot
        mean=mean
        std=sd
        median=median
        min=min
        max=max;
run;

/*--------------------------------------------------------------*
 | Store QC values in macro variables
 *--------------------------------------------------------------*/
data _null_;
    set qc_arm;
    if ARMCD='A' then do;
        call symputx('QC_mean_A', mean);
        call symputx('QC_sd_A', sd);
        call symputx('QC_med_A', median);
        call symputx('QC_min_A', min);
        call symputx('QC_max_A', max);
    end;
    else if ARMCD='B' then do;
        call symputx('QC_mean_B', mean);
        call symputx('QC_sd_B', sd);
        call symputx('QC_med_B', median);
        call symputx('QC_min_B', min);
        call symputx('QC_max_B', max);
    end;
run;

data _null_;
    set qc_tot;
    call symputx('QC_mean_T', mean);
    call symputx('QC_sd_T', sd);
    call symputx('QC_med_T', median);
    call symputx('QC_min_T', min);
    call symputx('QC_max_T', max);
run;

/*--------------------------------------------------------------*
 | QC Final Table Dataset
 *--------------------------------------------------------------*/
data qc_t2_final;
    length Statistic $40 ArmA ArmB Total $30;

    Statistic = "Number of Subjects";
    ArmA = "&QC_N_A";
    ArmB = "&QC_N_B";
    Total = "&QC_N_T";
    output;

    Statistic = "Exposure Duration (days)";
    ArmA = ""; ArmB = ""; Total = "";
    output;

    Statistic = "  Mean (SD)";
    ArmA = cats(put(&QC_mean_A,6.1)," (",put(&QC_sd_A,6.1),")");
    ArmB = cats(put(&QC_mean_B,6.1)," (",put(&QC_sd_B,6.1),")");
    Total = cats(put(&QC_mean_T,6.1)," (",put(&QC_sd_T,6.1),")");
    output;

    Statistic = "  Median";
    ArmA = put(&QC_med_A,6.1);
    ArmB = put(&QC_med_B,6.1);
    Total = put(&QC_med_T,6.1);
    output;

    Statistic = "  Min, Max";
    ArmA = cats(put(&QC_min_A,6.1),", ",put(&QC_max_A,6.1));
    ArmB = cats(put(&QC_min_B,6.1),", ",put(&QC_max_B,6.1));
    Total = cats(put(&QC_min_T,6.1),", ",put(&QC_max_T,6.1));
    output;
run;

/*--------------------------------------------------------------*
 | QC RTF OUTPUT
 *--------------------------------------------------------------*/
ods rtf file="/home/u64086073/09_VALIDATION/TLF_QC/QC_Outputs/Tables/QC_Table_2_Treatment_Exposure.rtf"
    style=journal;

title1 "QC Table 2. Treatment Exposure Summary (ITT Population)";
footnote1 "QC exposure duration (days) = Treatment End Date − Treatment Start Date + 1.";
footnote2 "QC performed using independent PROC SQL and PROC MEANS logic.";

proc report data=qc_t2_final nowd headline headskip;
    columns Statistic ArmA ArmB Total;

    define Statistic / display "Statistic";
    define ArmA / display "Arm A (N=&QC_N_A)";
    define ArmB / display "Arm B (N=&QC_N_B)";
    define Total / display "Total (N=&QC_N_T)";
run;

ods rtf close;
title;
footnote;
