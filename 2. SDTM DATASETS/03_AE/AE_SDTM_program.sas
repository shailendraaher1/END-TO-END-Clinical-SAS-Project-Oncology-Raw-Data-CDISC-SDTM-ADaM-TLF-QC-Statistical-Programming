/*******************************************************
        SDTM AE CREATION PROGRAM (FINAL)
        Study : ONCO-PEMBRO-500
        Domain: AE (Adverse Events)
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
   STEP 3: Sort RAW AE Data
-----------------------------------------------------*/
proc sort data=raw_ae;
    by SITEID SUBJID AESEQ;
run;


/*-----------------------------------------------------
   STEP 4: Create Base SDTM AE Variables
-----------------------------------------------------*/
data ae_base;

    length STUDYID  $20
           DOMAIN   $2
           USUBJID  $50
           AETERM   $200
           AEDECOD  $200
           AESOC    $200
           AESEV    $20
           AEREL    $20
           AESER    $1
           AEACN    $40
           AEOUT    $40
           AEENRF   $20;

    set raw_ae;

    STUDYID = "ONCO-PEMBRO-500";
    DOMAIN  = "AE";

    /* Unique Subject Identifier */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Core AE Mappings */
    AETERM  = AE_TERM;
    AEDECOD = AE_PT;
    AESOC   = AE_SOC;

    /* Dates */
    AESTDTC = AE_START;
    AEENDTC = AE_END;

    if AE_ONGO = "YES" then AEENRF = "ONGOING";

    /* Severity, Relationship, Seriousness */
    AESEV = cats("Grade ", AE_GRADE);
    AEREL = AE_REL;
    AESER = SAE_FLAG;

    /* Action & Outcome */
    AEACN = AE_ACTION;
    AEOUT = AE_OUT;

run;


/*-----------------------------------------------------
   STEP 5: Create Final SDTM AE Dataset
-----------------------------------------------------*/
data SDTM.AE (label="Adverse Events");
    retain STUDYID DOMAIN USUBJID AESEQ
           AETERM AEDECOD AESOC
           AESTDTC AEENDTC AEENRF
           AESEV AEREL AESER
           AEACN AEOUT;
    set ae_base;
run;


/*-----------------------------------------------------
   STEP 6: QC Outputs
-----------------------------------------------------*/
proc contents data=SDTM.AE;
run;

proc print data=SDTM.AE(obs=15);
run;
