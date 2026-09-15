/*******************************************************
 SDTM TU CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: TU (Tumor Identification)
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW TU Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/06_TU_RAW.csv"
    out=raw_tu
    dbms=csv
    replace;
    guessingrows=max;
run;


/*-----------------------------------------------------
   STEP 3: Sort RAW Data
-----------------------------------------------------*/
proc sort data=raw_tu;
    by STUDYID SITEID SUBJID LESION_ID VISITNUM;
run;


/*-----------------------------------------------------
   STEP 4: Create SDTM TU Base Dataset
-----------------------------------------------------*/
data tu_base;

    set raw_tu (rename=(TUSITE=RAW_TUSITE));

    length DOMAIN   $2
           USUBJID  $50
           TULNKID  $10
           TUCAT    $20
           TUSITE   $20
           TULOC    $40
           TULAT    $12
           TUMETHOD $12;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "TU";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Lesion Link ID */
    TULNKID = LESION_ID;

    /* Tumor Identification Date */
    TUDTC = TU_DT;

    /* Category */
    TUCAT = LESION_CAT;

    /* Baseline Flag */
    if BASE_FL = "Y" then TUBASFL = "Y";
    else TUBASFL = "";

    /* Measurable Flag */
    if MEAS_FL = "Y" then TUMEASFL = "Y";
    else TUMEASFL = "";

    /* Tumor Site */
    TUSITE = RAW_TUSITE;

    /* Tumor Location and Laterality */
    TULOC = TU_LOC;
    TULAT = LATERAL;

    /* Imaging Method */
    TUMETHOD = IMGMOD;

    /* Tumor Presence */
    if TU_PRES = "Y" then TUPRES = "Y";
    else TUPRES = "";

    /* New Lesion Flag */
    if NEW_LESION = "Y" then TUNEWFL = "Y";
    else TUNEWFL = "";

run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM TU Dataset
-----------------------------------------------------*/
data SDTM.TU (label="Tumor Identification");
    retain STUDYID DOMAIN USUBJID
           TULNKID TUCAT TUBASFL TUMEASFL
           TUSITE TULOC TULAT TUMETHOD
           TUPRES TUNEWFL
           TUDTC VISIT VISITNUM;
    set tu_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Output
-----------------------------------------------------*/
proc print data=SDTM.TU(obs=10);
run;

proc contents data=SDTM.TU;
run;
