/*****************************************************************
 Program: Table 5 – Best Overall Response (ITT)
 Author : Shailendra Aher
 Input  : ADSL_STD, ADRESP
 Output : Table_5_BOR_Summary.rtf
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
    by usubjid;
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
 | STEP 3: MERGE ADSL + ADRESP (RESP ONLY)
 *--------------------------------------------------*/
data adresp_itt;
    merge adresp_s (in=a)
          adsl_itt  (in=b);
    by usubjid;

    if a and b;

    /* Use tumor response records only */
    if PARAMCD='RESP';

    /* If ANL01FL exists, keep only analysis records */
    if missing(ANL01FL) or ANL01FL='Y';
run;

/*--------------------------------------------------*
 | STEP 4: BOR RANKING (CR > PR > SD > PD)
 *--------------------------------------------------*/
data adresp_rank;
    set adresp_itt;

    length bor $2;
    if AVALC='CR' then rank=1;
    else if AVALC='PR' then rank=2;
    else if AVALC='SD' then rank=3;
    else if AVALC='PD' then rank=4;
    else delete;

    bor = AVALC;
run;

/*--------------------------------------------------*
 | STEP 5: SUBJECT LEVEL BOR
 *--------------------------------------------------*/
proc sql;
    create table bor_subj as
    select usubjid,
           armcd,
           min(rank) as best_rank
    from adresp_rank
    group by usubjid, armcd;
quit;

data bor_final;
    set bor_subj;
    length BOR $2;

    if best_rank=1 then BOR='CR';
    else if best_rank=2 then BOR='PR';
    else if best_rank=3 then BOR='SD';
    else if best_rank=4 then BOR='PD';
run;

/*--------------------------------------------------*
 | STEP 6: DENOMINATORS (FIXED – ITT)
 *--------------------------------------------------*/
%let N_A = 250;
%let N_B = 250;
%let N_T = 500;

/*--------------------------------------------------*
 | STEP 7: COUNTS BY ARM AND BOR
 *--------------------------------------------------*/
proc sql;
    create table bor_cnt as
    select armcd,
           BOR,
           count(distinct usubjid) as n
    from bor_final
    group by armcd, BOR;
quit;

/*--------------------------------------------------*
 | STEP 8: FINAL TABLE STRUCTURE
 *--------------------------------------------------*/
data t5_final;
    length Statistic $40 ArmA ArmB Total $30;
    retain CR_A PR_A SD_A PD_A
           CR_B PR_B SD_B PD_B 0;

    set bor_cnt end=last;

    if armcd='A' then do;
        if BOR='CR' then CR_A=n;
        if BOR='PR' then PR_A=n;
        if BOR='SD' then SD_A=n;
        if BOR='PD' then PD_A=n;
    end;

    if armcd='B' then do;
        if BOR='CR' then CR_B=n;
        if BOR='PR' then PR_B=n;
        if BOR='SD' then SD_B=n;
        if BOR='PD' then PD_B=n;
    end;

    if last then do;

        Statistic='Subjects with CR, n (%)';
        ArmA=cats(CR_A,' (',put(CR_A/&N_A*100,5.1),')');
        ArmB=cats(CR_B,' (',put(CR_B/&N_B*100,5.1),')');
        Total=cats(CR_A+CR_B,' (',put((CR_A+CR_B)/&N_T*100,5.1),')');
        output;

        Statistic='Subjects with PR, n (%)';
        ArmA=cats(PR_A,' (',put(PR_A/&N_A*100,5.1),')');
        ArmB=cats(PR_B,' (',put(PR_B/&N_B*100,5.1),')');
        Total=cats(PR_A+PR_B,' (',put((PR_A+PR_B)/&N_T*100,5.1),')');
        output;

        Statistic='Subjects with SD, n (%)';
        ArmA=cats(SD_A,' (',put(SD_A/&N_A*100,5.1),')');
        ArmB=cats(SD_B,' (',put(SD_B/&N_B*100,5.1),')');
        Total=cats(SD_A+SD_B,' (',put((SD_A+SD_B)/&N_T*100,5.1),')');
        output;

        Statistic='Subjects with PD, n (%)';
        ArmA=cats(PD_A,' (',put(PD_A/&N_A*100,5.1),')');
        ArmB=cats(PD_B,' (',put(PD_B/&N_B*100,5.1),')');
        Total=cats(PD_A+PD_B,' (',put((PD_A+PD_B)/&N_T*100,5.1),')');
        output;
    end;
run;

/*--------------------------------------------------*
 | STEP 9: RTF OUTPUT
 *--------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Tables/Table_5_BOR_Summary.rtf"
    style=journal;

title "Table 5. Best Overall Response (ITT Population)";

footnote1 "Best overall response derived per subject using tumor response assessments.";
footnote2 "Response categories ordered as CR > PR > SD > PD.";

proc report data=t5_final nowd headline headskip;
    columns Statistic ArmA ArmB Total;
    define Statistic / display "Statistic";
    define ArmA / display "Arm A (N=&N_A)";
    define ArmB / display "Arm B (N=&N_B)";
    define Total / display "Total (N=&N_T)";
run;

ods rtf close;
title;
footnote;
