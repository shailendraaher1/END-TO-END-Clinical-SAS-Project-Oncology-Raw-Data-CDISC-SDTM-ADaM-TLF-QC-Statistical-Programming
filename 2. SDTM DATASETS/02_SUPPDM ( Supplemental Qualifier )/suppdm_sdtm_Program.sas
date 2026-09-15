/*******************************************************
        SDTM SUPPDM CREATION PROGRAM (FINAL)
        Study : ONCO-PEMBRO-500
        Domain: SUPPDM
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
   STEP 3: Prepare Base Variables (WARNING-FREE)
-----------------------------------------------------*/
data suppdm_base;

    /* Declare LENGTH FIRST */
    length STUDYID  $20
           RDOMAIN  $2
           USUBJID  $50
           IDVAR    $7
           IDVARVAL $10
           QNAM     $8
           QLABEL   $50
           QVAL     $20
           QORIG    $10
           QTYPE    $1;

    set raw_dm;

    STUDYID  = "ONCO-PEMBRO-500";
    RDOMAIN  = "DM";
    USUBJID  = catx("-", STUDYID, SITEID, SUBJID);
    IDVAR    = "SUBJID";
    IDVARVAL = SUBJID;
    QORIG    = "CRF";
    QTYPE    = "D";
run;


/*-----------------------------------------------------
   STEP 4: Create SUPPDM Records
-----------------------------------------------------*/
data SDTM.SUPPDM (label="Supplemental Qualifiers for DM");
    set suppdm_base;

    /* Smoking Status */
    QNAM   = "SMOKER";
    QLABEL = "Smoking Status at Baseline";
    QVAL   = SMK;
    output;

    /* Height */
    QNAM   = "HEIGHT";
    QLABEL = "Height in centimeters";
    QVAL   = strip(put(HEIGHT, 8.1));
    output;

    /* Weight */
    QNAM   = "WEIGHT";
    QLABEL = "Weight in kilograms";
    QVAL   = strip(put(WEIGHT, 8.1));
    output;

    keep STUDYID RDOMAIN USUBJID IDVAR IDVARVAL
         QNAM QLABEL QVAL QORIG QTYPE;
run;


/*-----------------------------------------------------
   STEP 5: QC Output
-----------------------------------------------------*/
proc print data=SDTM.SUPPDM(obs=15);
run;

proc contents data=SDTM.SUPPDM;
run;
