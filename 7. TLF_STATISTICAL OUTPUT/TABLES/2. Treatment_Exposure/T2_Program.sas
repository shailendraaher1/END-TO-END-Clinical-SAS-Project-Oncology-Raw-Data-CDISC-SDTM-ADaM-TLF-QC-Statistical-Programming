/*==============================================================*
 | Table 2: Treatment Exposure Summary (ITT Population)
 | Project : Academic / Clinical Research (CRO-style mimic)
 | Dataset : ADAM.ADSL_STD
 *==============================================================*/

options nodate nonumber nocenter;
ods escapechar='^';

libname adam "/home/u64086073/04_ADAM";

/*--------------------------------------------------------------*
 | ITT Population + Exposure Duration
 *--------------------------------------------------------------*/
data exp;
    set adam.adsl_std;
    where ITTFL = 'Y';

    if nmiss(TRTSDT, TRTEDT) = 0 then
        EXPDUR = TRTEDT - TRTSDT + 1;
run;

/*--------------------------------------------------------------*
 | Subject Counts
 *--------------------------------------------------------------*/
proc sql noprint;
    select count(*) into :N_A from exp where ARMCD='A';
    select count(*) into :N_B from exp where ARMCD='B';
    select count(*) into :N_T from exp;
quit;

/*--------------------------------------------------------------*
 | Exposure Summary by Arm
 *--------------------------------------------------------------*/
proc means data=exp noprint;
    class ARMCD;
    var EXPDUR;
    output out=exp_arm
        mean=mean
        std=sd
        median=median
        min=min
        max=max;
run;

/*--------------------------------------------------------------*
 | Overall Exposure Summary
 *--------------------------------------------------------------*/
proc means data=exp noprint;
    var EXPDUR;
    output out=exp_tot
        mean=mean
        std=sd
        median=median
        min=min
        max=max;
run;

/*--------------------------------------------------------------*
 | Store values in macro variables
 *--------------------------------------------------------------*/
data _null_;
    set exp_arm;
    if ARMCD='A' then do;
        call symputx('mean_A', mean);
        call symputx('sd_A', sd);
        call symputx('med_A', median);
        call symputx('min_A', min);
        call symputx('max_A', max);
    end;
    else if ARMCD='B' then do;
        call symputx('mean_B', mean);
        call symputx('sd_B', sd);
        call symputx('med_B', median);
        call symputx('min_B', min);
        call symputx('max_B', max);
    end;
run;

data _null_;
    set exp_tot;
    call symputx('mean_T', mean);
    call symputx('sd_T', sd);
    call symputx('med_T', median);
    call symputx('min_T', min);
    call symputx('max_T', max);
run;

/*--------------------------------------------------------------*
 | Final Table Dataset
 *--------------------------------------------------------------*/
data t2_final;
    length Statistic $40
           ArmA ArmB Total $30;

    Statistic = "Number of Subjects";
    ArmA = "&N_A";
    ArmB = "&N_B";
    Total = "&N_T";
    output;

    Statistic = "Exposure Duration (days)";
    ArmA = "";
    ArmB = "";
    Total = "";
    output;

    Statistic = "  Mean (SD)";
    ArmA = cats(put(&mean_A,6.1)," (",put(&sd_A,6.1),")");
    ArmB = cats(put(&mean_B,6.1)," (",put(&sd_B,6.1),")");
    Total = cats(put(&mean_T,6.1)," (",put(&sd_T,6.1),")");
    output;

    Statistic = "  Median";
    ArmA = put(&med_A,6.1);
    ArmB = put(&med_B,6.1);
    Total = put(&med_T,6.1);
    output;

    Statistic = "  Min, Max";
    ArmA = cats(put(&min_A,6.1),", ",put(&max_A,6.1));
    ArmB = cats(put(&min_B,6.1),", ",put(&max_B,6.1));
    Total = cats(put(&min_T,6.1),", ",put(&max_T,6.1));
    output;
run;

/*--------------------------------------------------------------*
 | RTF OUTPUT
 *--------------------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Tables/Table_2_Treatment_Exposure.rtf"
    style=journal;

title1 "Table 2. Treatment Exposure Summary (ITT Population)";

footnote1
"Exposure duration (days) = Treatment End Date − Treatment Start Date + 1.";
footnote2
"ITT Population: All randomized subjects with ITTFL = 'Y'.";

proc report data=t2_final nowd headline headskip;
    columns Statistic ArmA ArmB Total;

    define Statistic / display "Statistic" style(column)=[cellwidth=40%];
    define ArmA / display "Arm A (N=&N_A)" style(column)=[cellwidth=20%];
    define ArmB / display "Arm B (N=&N_B)" style(column)=[cellwidth=20%];
    define Total / display "Total (N=&N_T)" style(column)=[cellwidth=20%];
run;

ods rtf close;
title;
footnote;
