/*****************************************************************************
Program   : Figure 3 – Bar Chart of Best Overall Response (BOR)
Study     : ONCO-PEMBRO-500
Phase     : Phase III
Population: ITT
Endpoint  : Best Overall Response (BOR)
Input     : ADAM.ADRESP
Author    : Shailendra Aher
Date      : 09-02-2026
*****************************************************************************/

options nodate nonumber nocenter validvarname=upcase;

/*---------------------------------------------------------------------------
 | Libraries
 *---------------------------------------------------------------------------*/
libname adam "/home/u64086073/04_ADAM";

/*---------------------------------------------------------------------------
 | ODS setup
 *---------------------------------------------------------------------------*/
ods listing close;
ods graphics on;

ods rtf file="/home/u64086073/05_TLF/F3_BOR_Table_and_Bar_Chart.rtf"
        style=journal;

/*---------------------------------------------------------------------------
 | STEP 1: Create BOR summary dataset (COUNT + PERCENT)
 *---------------------------------------------------------------------------*/
proc freq data=adam.adresp noprint;
    tables ARM*AVALC / out=bor_freq;
    where ANL01FL="Y";
run;

proc sql;
    create table bor_summary as
    select a.ARM,
           a.AVALC,
           a.COUNT as N,
           round(a.COUNT / b.TOTAL * 100, 0.1) as PERCENT
    from bor_freq as a
    left join
        (select ARM, sum(COUNT) as TOTAL
         from bor_freq
         group by ARM) as b
    on a.ARM=b.ARM;
quit;

/*---------------------------------------------------------------------------
 | TABLE: Best Overall Response
 *---------------------------------------------------------------------------*/
title1 "Table 3. Best Overall Response (BOR)";
title2 "ITT Population";

proc report data=bor_summary nowd headline headskip;
    columns ARM AVALC N PERCENT;

    define ARM     / group "Treatment Arm";
    define AVALC   / group "Response Category";
    define N       / analysis sum "n";
    define PERCENT / analysis mean "%";
run;

/*---------------------------------------------------------------------------
 | FIGURE: Bar Chart of Best Overall Response
 *---------------------------------------------------------------------------*/
title1 "Figure 3. Bar Chart of Best Overall Response (BOR)";
title2 "ITT Population";

proc sgplot data=bor_freq;
    vbar AVALC / response=COUNT
                 group=ARM
                 groupdisplay=cluster
                 stat=sum
                 datalabel;
    xaxis label="Best Overall Response";
    yaxis label="Number of Subjects";
    keylegend / title="Treatment Arm";
run;

/*---------------------------------------------------------------------------
 | Close ODS
 *---------------------------------------------------------------------------*/
ods rtf close;
ods listing;
ods graphics off;
