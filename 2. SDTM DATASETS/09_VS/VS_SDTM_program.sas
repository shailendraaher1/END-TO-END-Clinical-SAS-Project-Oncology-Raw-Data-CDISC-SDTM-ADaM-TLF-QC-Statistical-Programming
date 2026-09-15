/*******************************************************
 SDTM VS CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: VS (Vital Signs)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW VS Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/05_VS_RAW.csv"
    out=raw_vs
    dbms=csv
    replace;
    guessingrows=max;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_vs;
    by STUDYID SITEID SUBJID VSSEQ;
run;


/*-----------------------------------------------------
   STEP 4: Create SDTM VS Base Dataset
-----------------------------------------------------*/
data vs_base;

    set raw_vs;

    length DOMAIN  $2
           USUBJID $50
           VSPOS   $20
           VSMETHOD $20;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "VS";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Date */
    VSDTC = VS_DT;

    /* Position and Method */
    VSPOS    = VS_POS;
    VSMETHOD = VS_METH;

run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM VS Dataset
-----------------------------------------------------*/
data SDTM.VS (label="Vital Signs");
    retain STUDYID DOMAIN USUBJID VSSEQ
           VSTESTCD VSTEST
           VSORRES VSORRESU
           VSSTRESN VSSTRESU
           VSDTC VISIT VISITNUM
           VSPOS VSMETHOD;
    set vs_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=SDTM.VS(obs=10);
run;

proc contents data=SDTM.VS;
run;

