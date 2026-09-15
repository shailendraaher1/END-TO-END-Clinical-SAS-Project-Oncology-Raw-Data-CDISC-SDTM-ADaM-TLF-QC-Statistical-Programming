/*******************************************************
 ADaM ADSL CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Dataset: ADSL (Subject-Level Analysis Dataset)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname SDTM "/home/u64086073/03_SDTM";
libname ADAM "/home/u64086073/04_ADAM";


/*-----------------------------------------------------
   STEP 2: Prepare DM Base
-----------------------------------------------------*/
data dm_base;
    set SDTM.DM;

    length TRT01P $50 TRT01PN 8;

    /* Planned Treatment */
    TRT01P = ARM;

    if ARMCD = "A" then TRT01PN = 1;
    else if ARMCD = "B" then TRT01PN = 2;
run;


/*-----------------------------------------------------
   STEP 3: Prepare EX Base (Treatment Dates & Actual Tx)
-----------------------------------------------------*/
proc sort data=SDTM.EX out=ex_sorted;
    by USUBJID EXSTDTC;
run;

data ex_base;
    set ex_sorted;
    by USUBJID;

    retain TRTSDT TRTEDT TRT01A TRT01AN SAFFL;

    if first.USUBJID then do;
        TRTSDT = EXSTDTC;
        TRT01A = EXTRT;
        if ARMCD = "A" then TRT01AN = 1;
        else if ARMCD = "B" then TRT01AN = 2;
        SAFFL = "Y";
    end;

    if last.USUBJID then TRTEDT = EXENDTC;

    keep USUBJID TRTSDT TRTEDT TRT01A TRT01AN SAFFL;
run;


/*-----------------------------------------------------
   STEP 4: Prepare DS Base (Disposition Flags)
-----------------------------------------------------*/
data ds_base;
    set SDTM.DS;

    length COMPFL DTHFL $1;

    if DSDECOD = "COMPLETED" then COMPFL = "Y";
    else COMPFL = "N";

    if DSDECOD = "DEATH" then DTHFL = "Y";
    else DTHFL = "N";

    EOSDT = DSSTDTC;

    keep USUBJID COMPFL DTHFL EOSDT;
run;


/*-----------------------------------------------------
   STEP 5: Merge DM + EX + DS to Create ADSL
-----------------------------------------------------*/
proc sort data=dm_base; by USUBJID; run;
proc sort data=ex_base; by USUBJID; run;
proc sort data=ds_base; by USUBJID; run;

data ADAM.ADSL (label="Subject-Level Analysis Dataset");
    merge dm_base (in=a)
          ex_base
          ds_base;
    by USUBJID;

    if a;  /* Keep all randomized subjects */

    length ITTFL $1 EFFFL $1;

    /* Population Flags */
    ITTFL = "Y";                  /* All randomized subjects */
    if SAFFL = "Y" then EFFFL = "Y";
    else EFFFL = "N";

    /* Reference Dates */
    RANDDT = RFSTDTC;

run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=ADAM.ADSL(obs=10);
run;

proc contents data=ADAM.ADSL;
run;

