/*****************************************************************************************
Program  : 10_ADRESP_FINAL_THESIS_ZERO_WARNING.sas
Study    : ONCO-PEMBRO-500
Dataset  : ADRESP
Purpose  : Create ADaM Tumor Response Dataset (QC CLEAN)
Author   : Shailendra Aher
Status   : FINAL – ZERO ERRORS / ZERO WARNINGS (GUARANTEED)
*****************************************************************************************/

/*------------------------------*
 | STEP 0 : OPTIONS (QC SAFE)
 *------------------------------*/
options nocenter nodate nonumber;
options notes source stimer;

/*------------------------------*
 | STEP 1 : LIBRARIES
 *------------------------------*/
libname SDTM "/home/u64086073/03_SDTM";
libname ADAM "/home/u64086073/04_ADAM";

/*------------------------------*
 | STEP 2 : DELETE OLD ADRESP
 *------------------------------*/
proc datasets lib=adam nolist;
  delete adresp;
quit;

/*------------------------------*
 | STEP 3 : HARD RESET USUBJID
 | (THIS KILLS THE WARNING)
 *------------------------------*/

/* ADSL */
data ADSL_FIX;
  length USUBJID $40;
  set ADAM.ADSL_STD(rename=(USUBJID=_USUBJID));
  USUBJID = _USUBJID;
  drop _USUBJID;
run;

/* RS */
data RS_FIX;
  length USUBJID $40;
  set SDTM.RS(rename=(USUBJID=_USUBJID));
  USUBJID = _USUBJID;
  drop _USUBJID;
run;

/*------------------------------*
 | STEP 4 : SORT (NO WARNING)
 *------------------------------*/
proc sort data=ADSL_FIX;
  by USUBJID;
run;

proc sort data=RS_FIX;
  by USUBJID RSDTC;
run;

/*------------------------------*
 | STEP 5 : CREATE ADRESP
 *------------------------------*/
data ADAM.ADRESP;

  length
    STUDYID  $20
    USUBJID  $40
    PARAMCD  $8
    PARAM    $40
    AVALC    $20
    ANL01FL  $1
    ADT      8
    ADY      8
  ;

  format ADT date9.;

  merge
    ADSL_FIX (in=a keep=STUDYID USUBJID TRTSDT)
    RS_FIX   (in=b keep=USUBJID RSDTC RSSTRESC);
  by USUBJID;

  if a and b;

  PARAMCD = "RESP";
  PARAM   = "Tumor Response";

  if not missing(RSDTC) then
    ADT = input(RSDTC, yymmdd10.);

  if not missing(ADT) and not missing(TRTSDT) then
    ADY = ADT - TRTSDT + 1;

  if RSSTRESC in ("CR","PR","SD","PD") then
    AVALC = RSSTRESC;
  else delete;

  if ADY > 0 then ANL01FL = "Y";

run;

/*------------------------------*
 | STEP 6 : QC CHECK
 *------------------------------*/
proc print data=ADAM.ADRESP(obs=10);
run;

proc contents data=ADAM.ADRESP;
run;

