/*==============================================================*
 | Table 1: Demographic and Baseline Characteristics (ITT)
 | Project : Academic / Clinical Research
 | Dataset : ADAM.ADSL_STD
 | Output  : CRO-style Indented RTF Table
 *==============================================================*/

options nodate nonumber nocenter;
ods escapechar='^';

libname adam "/home/u64086073/04_ADAM";

/*--------------------------------------------------------------*
 | ITT Population
 *--------------------------------------------------------------*/
data adsl;
    set adam.adsl_std;
    where ITTFL = 'Y';
run;

/*--------------------------------------------------------------*
 | Denominators
 *--------------------------------------------------------------*/
proc sql noprint;
    select count(*) into :N_A from adsl where ARMCD='A';
    select count(*) into :N_B from adsl where ARMCD='B';
    select count(*) into :N_T from adsl;
quit;

/*--------------------------------------------------------------*
 | Age Summary
 *--------------------------------------------------------------*/
proc means data=adsl noprint;
    class ARMCD;
    var AGE;
    output out=age_arm mean=mean std=std;
run;

proc means data=adsl noprint;
    var AGE;
    output out=age_tot mean=mean std=std;
run;

data age_row;
    length characteristic $50 ArmA ArmB Total $30;
    characteristic = 'Age (years), Mean (SD)';

    do until (last);
        set age_arm end=last;
        if ARMCD='A' then ArmA = cats(put(mean,5.1),' (',put(std,5.1),')');
        if ARMCD='B' then ArmB = cats(put(mean,5.1),' (',put(std,5.1),')');
    end;

    set age_tot;
    Total = cats(put(mean,5.1),' (',put(std,5.1),')');

    output;
run;

/*--------------------------------------------------------------*
 | Macro for Indented Categorical Variables
 *--------------------------------------------------------------*/
%macro cat(var=, label=);

proc freq data=adsl noprint;
    tables ARMCD*&var / out=freq_&var;
run;

/* Header row */
data head_&var;
    length characteristic $50 ArmA ArmB Total $30;
    characteristic="&label, n (%)";
    ArmA=''; ArmB=''; Total='';
run;

/* Category rows */
proc sql;
    create table body_&var as
    select 
        cats('  ', &var) as characteristic length=50,
        sum(case when ARMCD='A' then count end) as nA,
        sum(case when ARMCD='B' then count end) as nB,
        sum(count) as nT
    from freq_&var
    group by &var;
quit;

data body_&var;
    set body_&var;
    length ArmA ArmB Total $30;
    ArmA = cats(nA,' (',put(100*nA/&N_A,5.1),'%)');
    ArmB = cats(nB,' (',put(100*nB/&N_B,5.1),'%)');
    Total= cats(nT,' (',put(100*nT/&N_T,5.1),'%)');
    keep characteristic ArmA ArmB Total;
run;

data cat_&var;
    set head_&var body_&var;
run;

%mend;

/*--------------------------------------------------------------*
 | Apply Macro
 *--------------------------------------------------------------*/
%cat(var=SEX,        label=Sex);
%cat(var=RACE,       label=Race);
%cat(var=ECOG,       label=ECOG Performance Status);
%cat(var=PDL1_STATUS,label=PD-L1 Status);

/*--------------------------------------------------------------*
 | Final Table Assembly
 *--------------------------------------------------------------*/
data table1;
    length characteristic $50 ArmA ArmB Total $30;
    characteristic='Number of Subjects, n';
    ArmA="&N_A";
    ArmB="&N_B";
    Total="&N_T";
run;

data table1;
    set table1
        age_row
        cat_SEX
        cat_RACE
        cat_ECOG
        cat_PDL1_STATUS;
run;

/*--------------------------------------------------------------*
 | RTF Output
 *--------------------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Tables/Table_1_Demographics.rtf"
        style=journal;

title "Table 1. Demographic and Baseline Characteristics (ITT Population)";

footnote1 "Percentages are based on the number of subjects in each treatment arm.";
footnote2 "ITT Population: All randomized subjects with ITTFL = 'Y'.";

proc report data=table1 nowd;
    columns characteristic ArmA ArmB Total;
    define characteristic / display "Characteristic" style(column)=[cellwidth=45%];
    define ArmA / display "Arm A (N=&N_A)" style(column)=[cellwidth=18%];
    define ArmB / display "Arm B (N=&N_B)" style(column)=[cellwidth=18%];
    define Total/ display "Total (N=&N_T)" style(column)=[cellwidth=19%];
run;

ods rtf close;
title;
footnote;
