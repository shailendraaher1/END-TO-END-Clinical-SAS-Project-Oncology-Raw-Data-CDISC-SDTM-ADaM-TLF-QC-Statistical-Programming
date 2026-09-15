/*******************************************************
 SDTM LB CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: LB (Laboratory Test Results)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW LB Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/04_LB_RAW.csv"
    out=raw_lb
    dbms=csv
    replace;
    guessingrows=max;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_lb;
    by STUDYID SITEID SUBJID LBSEQ;
run;


/*-----------------------------------------------------
   STEP 4: Create SDTM LB Base (FINAL FIX)
-----------------------------------------------------*/
data lb_base;

    /* Rename RAW numeric LBORRES to avoid conflict */
    set raw_lb (rename=(LBORRES=LBORRES_N));

    length DOMAIN  $2
           USUBJID $50
           LBSPEC  $20
           LBORRES $20;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "LB";

    /* USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Specimen */
    LBSPEC = LB_SAMP;

    /* Create SDTM character result */
    LBORRES = strip(put(LBSTRESN, best.));

    /* Date */
    LBDTC = LB_DT;
run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM LB Dataset
-----------------------------------------------------*/
data SDTM.LB (label="Laboratory Test Results");
    retain STUDYID DOMAIN USUBJID LBSEQ
           LBTESTCD LBTEST LBSPEC
           LBORRES LBORRESU
           LBSTRESN LBSTRESU
           LBNRLO LBNRHI LBNRIND
           LBDTC VISIT VISITNUM LBFAST;
    set lb_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=SDTM.LB(obs=10);
run;

proc contents data=SDTM.LB;
run;