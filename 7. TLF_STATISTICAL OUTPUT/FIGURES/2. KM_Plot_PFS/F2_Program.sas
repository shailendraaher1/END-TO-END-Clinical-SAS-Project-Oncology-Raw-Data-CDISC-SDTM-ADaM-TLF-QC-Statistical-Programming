/****************************************************************************************
 Program   : Figure 2 - Kaplan–Meier Plot of Progression-Free Survival (PFS)
 Study     : ONCO-PEMBRO-500
 Phase     : Phase III, Randomized, Double-Blind
 Input     : ADaM ADTTE.sas7bdat
 Output    : F2_KM_PFS.rtf
 Author    : Shailendra Aher
 Date      : 09-02-2026
****************************************************************************************/

/*------------------------------------------------*
 | SAS Options
 *------------------------------------------------*/
options nodate nonumber nocenter;

/*------------------------------------------------*
 | Library
 *------------------------------------------------*/
libname adam "/home/u64086073/04_ADAM";

/*------------------------------------------------*
 | Output
 *------------------------------------------------*/
ods listing close;
ods rtf file="/home/u64086073/05_TLF/F2_KM_PFS.rtf"
        style=journal;

/*------------------------------------------------*
 | Titles
 *------------------------------------------------*/
title1 "Figure 2. Kaplan–Meier Plot of Progression-Free Survival (PFS)";
title2 "ITT Population";

/*------------------------------------------------*
 | Kaplan–Meier Analysis
 | NOTE:
 | - Generic ADTTE used
 | - PFS selected using PARAMCD
 | - SAME variables as earlier
 *------------------------------------------------*/
proc lifetest data=adam.adtte
              plots=survival(atrisk=0 to 600 by 120);
    where ITTFL = "Y"
          and PARAMCD = "PFS";

    time AVAL * CNSR(1);
    strata ARM;
run;

/*------------------------------------------------*
 | Close Output
 *------------------------------------------------*/
ods rtf close;
ods listing;
