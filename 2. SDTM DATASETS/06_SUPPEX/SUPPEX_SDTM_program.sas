/*******************************************************
 SDTM SUPPEX CREATION PROGRAM
 Study: ONCO-PEMBRO-500
 Domain: SUPPEX (Supplemental Qualifiers for EX)
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
   STEP 3: Prepare Base SUPPEX Structure
-----------------------------------------------------*/
data supp_ex_base;

    length STUDYID  $20
           RDOMAIN  $2
           USUBJID  $50
           IDVAR    $8
           IDVARVAL $10
           QNAM     $8
           QLABEL   $60
           QVAL     $40
           QORIG    $10
           QTYPE    $1;

    set raw_ex;

    STUDYID  = "ONCO-PEMBRO-500";
    RDOMAIN  = "EX";

    /* Create USUBJID */
    USUBJID = catx("-", STUDYID, SITEID, SUBJID);

    /* Link to EX record */
    IDVAR    = "EXSEQ";
    IDVARVAL = strip(put(EXSEQ, best.));

    QORIG = "CRF";
    QTYPE = "D";
run;


/*-----------------------------------------------------
   STEP 4: Create SUPPEX Records
-----------------------------------------------------*/
data SDTM.SUPPEX (label="Supplemental Qualifiers for EX");
    set supp_ex_base;

    /* Dose Interrupted */
    QNAM   = "EXINT";
    QLABEL = "Dose Interrupted";
    QVAL   = EX_INT;
    output;

    /* Dose Reduced */
    QNAM   = "EXRED";
    QLABEL = "Dose Reduced";
    QVAL   = EX_RED;
    output;

    /* Treatment Discontinued */
    QNAM   = "EXDISC";
    QLABEL = "Treatment Permanently Discontinued";
    QVAL   = EX_DISC;
    output;

    /* Reason for Dose Modification */
    QNAM   = "EXMODR";
    QLABEL = "Reason for Dose Modification";
    QVAL   = EX_MODR;
    output;

    /* Treatment Compliance */
    QNAM   = "EXCOMP";
    QLABEL = "Treatment Compliance";
    QVAL   = EX_COMP;
    output;

    keep STUDYID RDOMAIN USUBJID IDVAR IDVARVAL
         QNAM QLABEL QVAL QORIG QTYPE;
run;


/*-----------------------------------------------------
   STEP 5: QC Output
-----------------------------------------------------*/
proc print data=SDTM.SUPPEX(obs=15);
run;

proc contents data=SDTM.SUPPEX;
run;
