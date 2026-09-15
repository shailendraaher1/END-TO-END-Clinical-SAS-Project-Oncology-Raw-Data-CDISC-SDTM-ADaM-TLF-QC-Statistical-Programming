/*****************************************************************
 Program: Table 4 – Overall Tumor Response Rate (ITT)
 Author : Shailendra Aher
 Input  : ADSL_STD, ADRESP
 Output : Table_4_ORR_Summary.rtf
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

proc sort data=adam.adresp out=adresp_s;
    by usubjid adt;
run;

/*--------------------------------------------------*
 | STEP 2: ITT POPULATION
 *--------------------------------------------------*/
data adsl_itt;
    set adsl_s;
    where ITTFL='Y';
    keep usubjid armcd;
run;

/*--------------------------------------------------*
 | STEP 3: KEEP ONLY RESPONSE RECORDS (BEFORE MERGE)
 *--------------------------------------------------*/
data adresp_resp;
    set adam.adresp;
    where PARAMCD='RESP';
run;

proc sort data=adresp_resp;
    by usubjid adt;
run;

/*--------------------------------------------------*
 | STEP 4: MERGE WITH ITT ADSL
 *--------------------------------------------------*/
data adresp_itt;
    merge adresp_resp (in=a)
          adsl_itt    (in=b);
    by usubjid;
    if a and b;
run;


/*--------------------------------------------------*
 | STEP 4: BEST OVERALL RESPONSE (SUBJECT LEVEL)
 * Priority: CR > PR > SD > PD
 *--------------------------------------------------*/
proc sql;
    create table bor as
    select usubjid,
           armcd,
           min(case 
                 when avalc='CR' then 1
                 when avalc='PR' then 2
                 when avalc='SD' then 3
                 when avalc='PD' then 4
               end) as resp_rank
    from adresp_itt
    group by usubjid, armcd;
quit;

data bor_final;
    set bor;
    length BOR $2;

    if resp_rank=1 then BOR='CR';
    else if resp_rank=2 then BOR='PR';
    else if resp_rank=3 then BOR='SD';
    else if resp_rank=4 then BOR='PD';

    orr_flag = (BOR in ('CR','PR'));
run;

/*--------------------------------------------------*
 | STEP 5: FIXED DENOMINATORS
 *--------------------------------------------------*/
%let N_A = 250;
%let N_B = 250;
%let N_T = 500;

/*--------------------------------------------------*
 | STEP 6: COUNTS BY ARM
 *--------------------------------------------------*/
proc sql;
    create table t4_cnt as
    select armcd,
           sum(orr_flag) as n_orr,
           sum(BOR='CR') as n_cr,
           sum(BOR='PR') as n_pr,
           sum(BOR='SD') as n_sd,
           sum(BOR='PD') as n_pd
    from bor_final
    group by armcd;
quit;

/*--------------------------------------------------*
 | STEP 7: FINAL TABLE
 *--------------------------------------------------*/
data t4_final;
    length Statistic $50 ArmA ArmB Total $30;
    retain A_orr B_orr A_cr B_cr A_pr B_pr A_sd B_sd A_pd B_pd 0;

    set t4_cnt end=last;

    if armcd='A' then do;
        A_orr=n_orr; A_cr=n_cr; A_pr=n_pr; A_sd=n_sd; A_pd=n_pd;
    end;
    if armcd='B' then do;
        B_orr=n_orr; B_cr=n_cr; B_pr=n_pr; B_sd=n_sd; B_pd=n_pd;
    end;

    if last then do;

        Statistic="Subjects with ORR (CR+PR), n (%)";
        ArmA=cats(A_orr," (",put(A_orr/&N_A*100,5.1),")");
        ArmB=cats(B_orr," (",put(B_orr/&N_B*100,5.1),")");
        Total=cats(A_orr+B_orr," (",put((A_orr+B_orr)/&N_T*100,5.1),")");
        output;

        Statistic="Subjects with CR, n (%)";
        ArmA=cats(A_cr," (",put(A_cr/&N_A*100,5.1),")");
        ArmB=cats(B_cr," (",put(B_cr/&N_B*100,5.1),")");
        Total=cats(A_cr+B_cr," (",put((A_cr+B_cr)/&N_T*100,5.1),")");
        output;

        Statistic="Subjects with PR, n (%)";
        ArmA=cats(A_pr," (",put(A_pr/&N_A*100,5.1),")");
        ArmB=cats(B_pr," (",put(B_pr/&N_B*100,5.1),")");
        Total=cats(A_pr+B_pr," (",put((A_pr+B_pr)/&N_T*100,5.1),")");
        output;

        Statistic="Subjects with SD, n (%)";
        ArmA=cats(A_sd," (",put(A_sd/&N_A*100,5.1),")");
        ArmB=cats(B_sd," (",put(B_sd/&N_B*100,5.1),")");
        Total=cats(A_sd+B_sd," (",put((A_sd+B_sd)/&N_T*100,5.1),")");
        output;

        Statistic="Subjects with PD, n (%)";
        ArmA=cats(A_pd," (",put(A_pd/&N_A*100,5.1),")");
        ArmB=cats(B_pd," (",put(B_pd/&N_B*100,5.1),")");
        Total=cats(A_pd+B_pd," (",put((A_pd+B_pd)/&N_T*100,5.1),")");
        output;
    end;
run;

/*--------------------------------------------------*
 | STEP 8: RTF OUTPUT
 *--------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Tables/Table_4_ORR_Summary.rtf"
    style=journal;

title "Table 4. Overall Tumor Response Rate (ITT Population)";

footnote1 "ORR = Complete Response (CR) or Partial Response (PR).";
footnote2 "Best overall response derived per subject.";

proc report data=t4_final nowd headline headskip;
    columns Statistic ArmA ArmB Total;
    define Statistic / display "Statistic";
    define ArmA / display "Arm A (N=&N_A)";
    define ArmB / display "Arm B (N=&N_B)";
    define Total / display "Total (N=&N_T)";
run;

ods rtf close;
title;
footnote;
