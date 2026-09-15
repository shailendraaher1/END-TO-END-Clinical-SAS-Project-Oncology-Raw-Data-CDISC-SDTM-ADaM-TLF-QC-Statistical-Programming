/*******************************************************
 SDTM EX CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: EX (Exposure)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW EX Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/03_EX_RAW.csv"
    out=raw_ex
    dbms=csv
    replace;
    guessingrows=max;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_ex;
    by STUDYID SITEID SUBJID EXSEQ;
run;


/*-----------------------------------------------------
   STEP 4: Create Base SDTM EX Variables
-----------------------------------------------------*/
data ex_base;
    set raw_ex;

    length DOMAIN $2
           USUBJID $50
           EXTRT   $40
           EXDOSU  $10
           EXROUTE $20
           EXFREQ  $10
           EXENRF  $20;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "EX";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Map Treatment */
    EXTRT = EX_TRTP;

    /* Dose Information */
    EXDOSE = EX_DOSE;
    EXDOSU = EX_DOSU;
    EXROUTE = EX_ROUTE;
    EXFREQ  = EX_FREQ;

    /* Exposure Dates */
    EXSTDTC = EX_DT;
    EXENDTC = EX_ENDDT;

    /* Ongoing Treatment Flag */
    if EX_ONGO = "YES" then EXENRF = "ONGOING";
run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM EX Dataset
-----------------------------------------------------*/
data SDTM.EX (label="Exposure");
    retain STUDYID DOMAIN USUBJID EXSEQ
           EXTRT EXDOSE EXDOSU EXROUTE EXFREQ
           EXSTDTC EXENDTC EXENRF;
    set ex_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=SDTM.EX(obs=10);
run;

proc contents data=SDTM.EX;
run;
