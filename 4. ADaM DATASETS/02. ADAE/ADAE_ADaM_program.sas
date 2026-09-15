/************************************************************
 Program   : 07_ADAE_program.sas
 Study     : ONCO-PEMBRO-500
 Dataset   : ADAE
 Purpose   : Final CRO-ready ADAE (LOG ENABLED)
************************************************************/

options notes source stimer nocenter nodate nonumber;

/*----------------------------------------------------------
 STEP 1: Assign Libraries
----------------------------------------------------------*/
libname SDTM "/home/u64086073/03_SDTM";
libname ADAM "/home/u64086073/04_ADAM";

/*----------------------------------------------------------
 STEP 2: Clean Start
----------------------------------------------------------*/
proc datasets lib=adam nolist;
    delete adae;
quit;

/*----------------------------------------------------------
 STEP 3: Prepare AE (NO conflicts)
----------------------------------------------------------*/
data ae_clean;
    set SDTM.AE;

    length AESTDTC_C AEENDTC_C $20;

    AESTDTC_C = AESTDTC;
    AEENDTC_C = AEENDTC;

    AESTDT = input(AESTDTC_C, yymmdd10.);
    AEENDT = input(AEENDTC_C, yymmdd10.);

    format AESTDT AEENDT date9.;
run;

/*----------------------------------------------------------
 STEP 4: Merge with ADSL
----------------------------------------------------------*/
proc sort data=ae_clean; by USUBJID; run;
proc sort data=ADAM.ADSL; by USUBJID; run;

data ADAM.ADAE (label="Adverse Events Analysis Dataset");
    merge ae_clean(in=a) ADAM.ADSL(in=b);
    by USUBJID;

    if a and b;

    /* Treatment Emergent Flag */
    if not missing(AESTDT) and AESTDT >= TRTSDT then TRTEMFL = "Y";
    else TRTEMFL = "N";

    /* Analysis Study Day */
    if not missing(AESTDT) and not missing(TRTSDT) then
        ASTDY = AESTDT - TRTSDT + 1;

    retain
        STUDYID USUBJID
        TRT01A TRT01AN
        SAFFL
        AETERM AEDECOD AESOC
        AESEV AESER AEOUT
        AESTDT AEENDT ASTDY
        TRTEMFL;
run;

/*----------------------------------------------------------
 STEP 5: QC Outputs
----------------------------------------------------------*/
proc print data=ADAM.ADAE(obs=20);
    title "ADAE – First 20 Records";
run;


proc contents data=ADAM.ADAE varnum;
    title "ADAE – Variable Metadata";
run;


