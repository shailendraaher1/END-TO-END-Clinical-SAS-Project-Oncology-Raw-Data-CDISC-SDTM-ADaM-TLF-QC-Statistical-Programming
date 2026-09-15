/*******************************************************
 SDTM SUPPVS CREATION PROGRAM
 Study : ONCO-PEMBRO-500
 Domain: SUPPVS (Supplemental Qualifiers for VS)
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
   STEP 3: Prepare Base SUPPVS Structure
-----------------------------------------------------*/
data suppvs_base;

    length STUDYID  $20
           RDOMAIN  $2
           USUBJID  $50
           IDVAR    $7
           IDVARVAL $10
           QNAM     $8
           QLABEL   $60
           QVAL     $40
           QORIG    $10
           QTYPE    $1;

    set raw_vs;

    STUDYID = "ONCO-PEMBRO-500";
    RDOMAIN = "VS";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Link to VS record */
    IDVAR    = "VSSEQ";
    IDVARVAL = strip(put(VSSEQ, best.));

    QORIG = "CRF";
    QTYPE = "D";
run;


/*-----------------------------------------------------
   STEP 4: Create SUPPVS Records
-----------------------------------------------------*/
data SDTM.SUPPVS (label="Supplemental Qualifiers for VS");
    set suppvs_base;

    /* Clinically Significant Abnormality */
    QNAM   = "VSCSIG";
    QLABEL = "Clinically Significant Abnormality";
    QVAL   = VS_CSA;
    output;

    /* Action Taken */
    QNAM   = "VSACT";
    QLABEL = "Action Taken for Abnormal Vital Sign";
    QVAL   = VS_ACT;
    output;

    /* Abnormality Description */
    QNAM   = "VSDESC";
    QLABEL = "Description of Abnormal Vital Sign";
    QVAL   = VS_DESC;
    output;

    keep STUDYID RDOMAIN USUBJID IDVAR IDVARVAL
         QNAM QLABEL QVAL QORIG QTYPE;
run;


/*-----------------------------------------------------
   STEP 5: QC Output
-----------------------------------------------------*/
proc print data=SDTM.SUPPVS(obs=15);
run;

proc contents data=SDTM.SUPPVS;
run;