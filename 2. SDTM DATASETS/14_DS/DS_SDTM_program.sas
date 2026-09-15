/*******************************************************
 SDTM DS CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: DS (Disposition)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW DS Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/09_DS_RAW.csv"
    out=raw_ds
    dbms=csv
    replace;
    guessingrows=max;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_ds;
    by STUDYID SITEID SUBJID;
run;


/*-----------------------------------------------------
   STEP 4: Create SDTM DS Base Dataset
-----------------------------------------------------*/
data ds_base;

    set raw_ds;

    length DOMAIN   $2
           USUBJID  $50
           DSTERM   $40
           DSCAT    $30
           DSDECOD  $40;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "DS";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Sequence */
    DSSEQ = _N_;

    /* Disposition Terms */
    DSTERM  = DS_TERM;
    DSCAT   = DS_CAT;
    DSDECOD = DS_DECOD;

    /* Disposition Date */
    DSSTDTC = DS_DT;

    /* Reason for Disposition (if applicable) */
    DSREASND = DS_REASON;

run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM DS Dataset
-----------------------------------------------------*/
data SDTM.DS (label="Disposition");
    retain STUDYID DOMAIN USUBJID DSSEQ
           DSTERM DSCAT DSDECOD DSREASND
           DSSTDTC VISIT VISITNUM;
    set ds_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=SDTM.DS(obs=10);
run;

proc contents data=SDTM.DS;
run;
