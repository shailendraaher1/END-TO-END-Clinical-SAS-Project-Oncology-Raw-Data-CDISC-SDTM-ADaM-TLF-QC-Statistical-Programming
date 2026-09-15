/*******************************************************
 SDTM SUPPLB CREATION PROGRAM
 Study : ONCO-PEMBRO-500
 Domain: SUPPLB (Supplemental Qualifiers for LB)
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
   STEP 3: Prepare Base SUPPLB Structure
-----------------------------------------------------*/
data supplb_base;

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

    set raw_lb;

    STUDYID = "ONCO-PEMBRO-500";
    RDOMAIN = "LB";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Link to LB record */
    IDVAR    = "LBSEQ";
    IDVARVAL = strip(put(LBSEQ, best.));

    QORIG = "CRF";
    QTYPE = "D";
run;


/*-----------------------------------------------------
   STEP 4: Create SUPPLB Records
-----------------------------------------------------*/
data SDTM.SUPPLB (label="Supplemental Qualifiers for LB");
    set supplb_base;

    /* Clinically Significant Abnormality */
    QNAM   = "LBCSIG";
    QLABEL = "Clinically Significant Abnormality";
    QVAL   = LB_CSA;
    output;

    /* Action Taken */
    QNAM   = "LBACT";
    QLABEL = "Action Taken for Abnormal Lab Result";
    QVAL   = LB_ACT;
    output;

    /* Abnormality Description */
    QNAM   = "LBDESC";
    QLABEL = "Description of Abnormal Lab Result";
    QVAL   = LB_DESC;
    output;

    keep STUDYID RDOMAIN USUBJID IDVAR IDVARVAL
         QNAM QLABEL QVAL QORIG QTYPE;
run;


/*-----------------------------------------------------
   STEP 5: QC Output
-----------------------------------------------------*/
proc print data=SDTM.SUPPLB(obs=15);
run;

proc contents data=SDTM.SUPPLB;
run;
