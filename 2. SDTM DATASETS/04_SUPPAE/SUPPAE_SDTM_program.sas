/*******************************************************
        SDTM SUPPAE CREATION PROGRAM (FINAL)
        Study : ONCO-PEMBRO-500
        Domain: SUPPAE
*******************************************************/

/*-----------------------------------------------------
   STEP 1: Assign Libraries
-----------------------------------------------------*/
libname RAW  "/home/u64086073/01_RAW_DATA";
libname SDTM "/home/u64086073/03_SDTM";


/*-----------------------------------------------------
   STEP 2: Import RAW AE Dataset
-----------------------------------------------------*/
proc import datafile="/home/u64086073/01_RAW_DATA/02_AE_RAW.csv"
    out=raw_ae
    dbms=csv
    replace;
    guessingrows=500;
run;


/*-----------------------------------------------------
   STEP 3: Prepare SUPPAE Base (WARNING-FREE)
-----------------------------------------------------*/
data suppae_base;

    length STUDYID  $20
           RDOMAIN  $2
           USUBJID  $50
           IDVAR    $5
           IDVARVAL $10
           QNAM     $8
           QLABEL   $60
           QVAL     $20
           QORIG    $10
           QTYPE    $1;

    set raw_ae;

    STUDYID  = "ONCO-PEMBRO-500";
    RDOMAIN  = "AE";
    USUBJID  = catx("-", STUDYID, SITEID, SUBJID);

    IDVAR    = "AESEQ";
    IDVARVAL = strip(put(AESEQ, best.));

    QORIG = "CRF";
    QTYPE = "D";
run;


/*-----------------------------------------------------
   STEP 4: Create SUPPAE Records
-----------------------------------------------------*/
data SDTM.SUPPAE (label="Supplemental Qualifiers for AE");
    set suppae_base;

    /* Results in Death */
    QNAM   = "AESDTH";
    QLABEL = "Results in Death";
    QVAL   = SAE_DTH;
    output;

    /* Life-Threatening */
    QNAM   = "AESLIFE";
    QLABEL = "Life Threatening Event";
    QVAL   = SAE_LIFE;
    output;

    /* Hospitalization */
    QNAM   = "AESHOSP";
    QLABEL = "Requires Hospitalization";
    QVAL   = SAE_HOSP;
    output;

    /* Disability */
    QNAM   = "AESDISAB";
    QLABEL = "Results in Disability";
    QVAL   = SAE_DIS;
    output;

    /* Other Medically Important Event */
    QNAM   = "AESMIE";
    QLABEL = "Other Medically Important Event";
    QVAL   = SAE_OTH;
    output;

    keep STUDYID RDOMAIN USUBJID IDVAR IDVARVAL
         QNAM QLABEL QVAL QORIG QTYPE;
run;


/*-----------------------------------------------------
   STEP 5: QC Outputs
-----------------------------------------------------*/
proc print data=SDTM.SUPPAE(obs=15);
run;


proc contents data=SDTM.SUPPAE;
run;
