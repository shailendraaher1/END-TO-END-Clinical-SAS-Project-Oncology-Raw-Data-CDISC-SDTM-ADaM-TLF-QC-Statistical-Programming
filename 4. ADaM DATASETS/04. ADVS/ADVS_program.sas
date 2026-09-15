/**************************************************************************
 Program  : 09_ADVS_FINAL_FIXED.sas
 Study    : ONCO-PEMBRO-500
 Dataset  : ADVS
 Purpose  : FINAL ADVS – ZERO error, ZERO warning (ROOT FIX APPLIED)
**************************************************************************/

options nocenter nodate nonumber;
options notes source stimer;

/*-----------------------------*
 | LIBRARIES
 *-----------------------------*/
libname SDTM "/home/u64086073/03_SDTM";
libname ADAM "/home/u64086073/04_ADAM";

/*-----------------------------*
 | CLEAN OLD WORK
 *-----------------------------*/
proc datasets lib=work nolist;
    delete VS_SQL ADSL_SQL;
quit;

proc datasets lib=adam nolist;
    delete ADVS;
quit;

/*-----------------------------*
 | STEP 1: CREATE VS_SQL (TYPE SAFE)
 *-----------------------------*/
proc sql;
    create table work.VS_SQL as
    select
        STUDYID,
        USUBJID,
        VSTESTCD,
        VSTEST,
        VISIT,

        /* Character representation */
        put(VSORRES, best.) as AVALC length=40,

        /* Numeric value */
        VSORRES as AVAL,

        /* Use date directly (NO substr / strip) */
        VSDTC as ADT format=date9.

    from SDTM.VS
    where VSORRES is not null;
quit;

/*-----------------------------*
 | STEP 2: CREATE ADSL_SQL
 *-----------------------------*/
proc sql;
    create table work.ADSL_SQL as
    select
        STUDYID,
        USUBJID,
        TRTSDT,
        SAFFL
    from ADAM.ADSL
    where SAFFL = "Y";
quit;

/*-----------------------------*
 | STEP 3: FINAL ADVS
 *-----------------------------*/
proc sql;
    create table ADAM.ADVS as
    select
        a.STUDYID,
        a.USUBJID,

        b.VSTESTCD as PARAMCD length=8,
        b.VSTEST   as PARAM   length=40,
        b.VISIT,

        b.AVAL,
        b.AVALC,
        b.ADT,

        case
            when b.ADT >= a.TRTSDT then b.ADT - a.TRTSDT + 1
        end as ADY,

        case
            when b.ADT < a.TRTSDT then b.AVAL
        end as BASE,

        a.SAFFL

    from work.ADSL_SQL as a
    inner join work.VS_SQL as b
        on a.USUBJID = b.USUBJID;
quit;

/*-----------------------------*
 | QC OUTPUT
 *-----------------------------*/

proc print data=ADAM.ADVS(obs=10); run;
proc contents data=ADAM.ADVS; run;