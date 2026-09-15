/*******************************************************
          SDTM DM CREATION PROGRAM (FINAL)
          Study: ONCO-PEMBRO-500
          Domain: DM (Demographics)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW DM Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/DM_RAW.csv"
    out=raw_dm
    dbms=csv
    replace;
    guessingrows=500;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_dm; 
    by SITEID SUBJID; 
run;


/*-----------------------------------------------------
   STEP 4: Create Base SDTM Variables 
-----------------------------------------------------*/
data dm_base;
    length DOMAIN $2 USUBJID $50 ARMCD $2 AGEU $5;

    set raw_dm;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "DM";
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* ARMCD Derivation */
    if RAND_ARM = "Arm A" then ARMCD = "A";
    else if RAND_ARM = "Arm B" then ARMCD = "B";

    AGEU = "YEARS";
run;


/*-----------------------------------------------------
   STEP 5: Trial Reference Dates
-----------------------------------------------------*/
data dm_dates;
    set dm_base;

    /* Randomization Date */
    RFSTDTC = RANDDT;
run;


/*-----------------------------------------------------
   STEP 6: Final SDTM DM Dataset
-----------------------------------------------------*/
data SDTM.DM (label="Demographics");
    retain STUDYID DOMAIN USUBJID SITEID SUBJID 
           ARM ARMCD AGE AGEU 
           SEX RACE ETHNIC COUNTRY ECOG PDL1 RFSTDTC;

    set dm_dates;
run;


/*-----------------------------------------------------
   STEP 7: QC Output
-----------------------------------------------------*/
proc print data=SDTM.DM(obs=10); 
run;

proc contents data=SDTM.DM; 
run;
