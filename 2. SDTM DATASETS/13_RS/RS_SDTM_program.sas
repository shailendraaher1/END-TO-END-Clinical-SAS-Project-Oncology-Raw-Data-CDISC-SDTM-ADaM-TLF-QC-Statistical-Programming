/*******************************************************
 SDTM RS CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: RS (Response Status)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW RS Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/08_RS_RAW.csv"
    out=raw_rs
    dbms=csv
    replace;
    guessingrows=max;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_rs;
    by STUDYID SITEID SUBJID VISITNUM;
run;


/*-----------------------------------------------------
   STEP 4: Create SDTM RS Base Dataset
-----------------------------------------------------*/
data rs_base;

    set raw_rs;

    length DOMAIN     $2
           USUBJID    $50
           RSTESTCD   $8
           RSTEST     $40
           RSCAT      $30
           RSORRES    $8
           RSSTRESC   $8;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "RS";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Sequence */
    RSSEQ = _N_;

    /* Test Identification */
    RSTESTCD = RS_TESTCD;
    RSTEST   = RS_TEST;
    RSCAT    = "OVERALL RESPONSE";

    /* Results */
    RSORRES  = RS_RESP;
    RSSTRESC = RS_RESP;

    /* Timing */
    RSDTC = RS_DT;

    /* Status */
    RSSTAT = RS_STAT;

run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM RS Dataset
-----------------------------------------------------*/
data SDTM.RS (label="Response Status");
    retain STUDYID DOMAIN USUBJID RSSEQ
           RSTESTCD RSTEST RSCAT
           RSORRES RSSTRESC
           RSDTC VISIT VISITNUM
           RSSTAT;
    set rs_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=SDTM.RS(obs=10);
run;

proc contents data=SDTM.RS;
run;