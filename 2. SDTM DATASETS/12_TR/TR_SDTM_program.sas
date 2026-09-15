/*******************************************************
 SDTM TR CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: TR (Tumor Results)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW TR Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/07_TR_RAW.csv"
    out=raw_tr
    dbms=csv
    replace;
    guessingrows=max;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_tr;
    by STUDYID SITEID SUBJID LESION_ID VISITNUM;
run;


/*-----------------------------------------------------
   STEP 4: Create SDTM TR Base Dataset
-----------------------------------------------------*/
data tr_base;

    set raw_tr;

    length DOMAIN    $2
           USUBJID   $50
           TRTESTCD  $8
           TRTEST    $40
           TRCAT     $20
           TRORRES   $20;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "TR";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Sequence */
    TRSEQ = _N_;

    /* Link to TU */
    TULNKID = LESION_ID;

    /* Test Identification */
    TRTESTCD = TR_TESTCD;
    TRTEST   = TR_TEST;
    TRCAT    = "TARGET LESION";

    /* Results */
    TRORRES  = strip(put(TR_VAL, best.));
    TRORRESU = TR_UNIT;

    TRSTRESN = TR_VAL;
    TRSTRESU = TR_UNIT;

    /* Timing */
    TRDTC = TR_DT;

    /* Baseline Flag */
    if BASE_FL = "Y" then TRBASFL = "Y";
    else TRBASFL = "";

    /* Measurable Flag */
    if MEAS_FL = "Y" then TRMEASFL = "Y";
    else TRMEASFL = "";

    /* Status */
    TRSTAT = TR_STAT;

run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM TR Dataset
-----------------------------------------------------*/
data SDTM.TR (label="Tumor Results");
    retain STUDYID DOMAIN USUBJID TRSEQ
           TULNKID TRTESTCD TRTEST TRCAT
           TRORRES TRORRESU
           TRSTRESN TRSTRESU
           TRDTC VISIT VISITNUM
           TRBASFL TRMEASFL TRSTAT;
    set tr_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=SDTM.TR(obs=10);
run;

proc contents data=SDTM.TR;
run;
