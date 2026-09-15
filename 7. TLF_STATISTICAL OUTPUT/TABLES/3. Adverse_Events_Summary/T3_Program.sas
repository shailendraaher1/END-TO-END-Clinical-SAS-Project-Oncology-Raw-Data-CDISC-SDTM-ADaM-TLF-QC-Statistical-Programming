/*****************************************************************
 Program: Table 3 – TEAE Summary (ITT)
 Author : Shailendra Aher
 Input  : ADSL_STD, ADAE
 Output : Table_3_TEAE_Summary.rtf
*****************************************************************/

options nodate nonumber nocenter;
ods escapechar='^';

libname adam "/home/u64086073/04_ADAM";

/*--------------------------------------------------*
 | STEP 1: SORT
 *--------------------------------------------------*/
proc sort data=adam.adsl_std out=adsl_s;
    by usubjid;
run;

proc sort data=adam.adae out=adae_s;
    by usubjid;
run;

/*--------------------------------------------------*
 | STEP 2: ITT POPULATION (DENOMINATOR FIX)
 *--------------------------------------------------*/
data adsl_itt;
    set adsl_s;
    where ITTFL='Y';
run;

/*--------------------------------------------------*
 | STEP 3: MERGE ADAE WITH ITT ADSL
 *--------------------------------------------------*/
data adae_t3;
    merge adae_s (in=a)
          adsl_itt (in=b keep=usubjid armcd);
    by usubjid;

    if a and b;

    /* TEAE FLAGS */
    any_teae = 1;
    ser_teae = (AESER='Y');
    gr3_teae = (AE_GRADE >= 3);
run;

/*--------------------------------------------------*
 | STEP 4: SUBJECT LEVEL COLLAPSE
 *--------------------------------------------------*/
proc sql;
    create table t3_subj as
    select armcd,
           usubjid,
           max(any_teae) as any_teae,
           max(ser_teae) as ser_teae,
           max(gr3_teae) as gr3_teae
    from adae_t3
    group by armcd, usubjid;
quit;

/*--------------------------------------------------*
 | STEP 5: FIXED DENOMINATORS (250/250/500)
 *--------------------------------------------------*/
%let N_A = 250;
%let N_B = 250;
%let N_T = 500;

/*--------------------------------------------------*
 | STEP 6: COUNTS
 *--------------------------------------------------*/
proc sql;
    create table t3_cnt as
    select armcd,
           sum(any_teae) as n_any,
           sum(ser_teae) as n_ser,
           sum(gr3_teae) as n_gr3
    from t3_subj
    group by armcd;
quit;

/*--------------------------------------------------*
 | STEP 7: FINAL TABLE STRUCTURE
 *--------------------------------------------------*/
data t3_final;
    length Statistic $50 ArmA ArmB Total $30;
    retain A_any B_any A_ser B_ser A_gr3 B_gr3 0;

    set t3_cnt end=last;

    if armcd='A' then do;
        A_any=n_any; A_ser=n_ser; A_gr3=n_gr3;
    end;
    if armcd='B' then do;
        B_any=n_any; B_ser=n_ser; B_gr3=n_gr3;
    end;

    if last then do;

        /* Any TEAE */
        Statistic="Subjects with ≥1 TEAE, n (%)";
        ArmA=cats(A_any," (",put(A_any/&N_A*100,5.1),")");
        ArmB=cats(B_any," (",put(B_any/&N_B*100,5.1),")");
        Total=cats(A_any+B_any," (",put((A_any+B_any)/&N_T*100,5.1),")");
        output;

        /* Serious TEAE */
        Statistic="Subjects with ≥1 Serious TEAE, n (%)";
        ArmA=cats(A_ser," (",put(A_ser/&N_A*100,5.1),")");
        ArmB=cats(B_ser," (",put(B_ser/&N_B*100,5.1),")");
        Total=cats(A_ser+B_ser," (",put((A_ser+B_ser)/&N_T*100,5.1),")");
        output;

        /* Grade ≥3 TEAE */
        Statistic="Subjects with ≥1 Grade ≥3 TEAE, n (%)";
        ArmA=cats(A_gr3," (",put(A_gr3/&N_A*100,5.1),")");
        ArmB=cats(B_gr3," (",put(B_gr3/&N_B*100,5.1),")");
        Total=cats(A_gr3+B_gr3," (",put((A_gr3+B_gr3)/&N_T*100,5.1),")");
        output;
    end;
run;

/*--------------------------------------------------*
 | STEP 8: RTF OUTPUT
 *--------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Tables/Table_3_TEAE_Summary.rtf"
    style=journal;

title "Table 3. Summary of Treatment-Emergent Adverse Events (ITT Population)";

footnote1 "TEAE: Treatment-emergent adverse event occurring on or after first dose.";
footnote2 "Serious TEAE defined as AESER='Y'. Grade ≥3 defined as AE_GRADE ≥3.";

proc report data=t3_final nowd headline headskip;
    columns Statistic ArmA ArmB Total;
    define Statistic / display "Statistic";
    define ArmA / display "Arm A (N=&N_A)";
    define ArmB / display "Arm B (N=&N_B)";
    define Total / display "Total (N=&N_T)";
run;

ods rtf close;
title;
footnote;
