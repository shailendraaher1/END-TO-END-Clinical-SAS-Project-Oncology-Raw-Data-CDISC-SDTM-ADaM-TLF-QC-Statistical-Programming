/**************************************************************************
Program   : F1 – Kaplan–Meier Plot of Overall Survival
Study     : ONCO-PEMBRO-500
Population: ITT
Input     : ADAM.ADTTE
Output    : RTF
Author    : Shailendra Aher
Date      : 09-02-2026
**************************************************************************/

options nodate nonumber orientation=landscape;
ods listing close;

/*------------------------------------------------------------*
 | Output location
 *------------------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Figures/F1_KM_Overall_Survival.rtf"
    style=journal;

/*------------------------------------------------------------*
 | Title & Footnote
 *------------------------------------------------------------*/
title1 bold "Figure 1. Kaplan–Meier Plot of Overall Survival";
title2 "ITT Population";

footnote1 j=l "Study: ONCO-PEMBRO-500 | Phase III";
footnote2 j=l "Censoring indicated by tick marks";

/*------------------------------------------------------------*
 | KM Analysis – Overall Survival
 *------------------------------------------------------------*/
proc lifetest data=adam.adtte
              plots=survival(atrisk cl)
              method=km
              notable;
   where PARAMCD = "OS";
   time AVAL*CNSR(1);
   strata ARM / test=logrank;
run;

/*------------------------------------------------------------*
 | Close ODS
 *------------------------------------------------------------*/
ods rtf close;
ods listing;
