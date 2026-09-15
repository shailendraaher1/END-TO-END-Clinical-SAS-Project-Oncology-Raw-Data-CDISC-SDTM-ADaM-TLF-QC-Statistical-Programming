/*=====================================================================*
 | Program Name :Table 7 – Time-to-Event Endpoints from Baseline (Days) 
 | Population   : ITT (N=500)                                           |
 | Analysis     : OS and PFS                                            |
 | Input        : ADaM.ADSL,ADaM.ADTTE  
 | Author       : Shailendra Aher                                       |
 | Date         : 03-FEB-2026                                           |
 |=====================================================================*/

options nodate nonumber nocenter
        nonotes nosource;

/*---------------------------------------------------------------------*
 | Library assignments                                                 |
 *---------------------------------------------------------------------*/
libname adam "/home/u64086073/04_ADAM";

/*---------------------------------------------------------------------*
 | Format definitions                                                  |
 *---------------------------------------------------------------------*/
proc format;
    value $armf
        'A'='Arm A'
        'B'='Arm B'
        'T'='Total';

    value $endpf
        'OS' ='Overall Survival'
        'PFS'='Progression-Free Survival';
run;

/*---------------------------------------------------------------------*
 | Prepare reporting dataset                                           |
 | Source: ADaM.ADSL,ADaM.ADTTE                                            |
 *---------------------------------------------------------------------*/
data work.tte_rep;
    set adam.adtte_all;

    length endpoint $40 trt $10;

    endpoint = put(paramcd, $endpf.);
    trt      = put(armcd, $armf.);
run;

/*---------------------------------------------------------------------*
 | Open RTF output                                                     |
 *---------------------------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Table_07_TTE_Final.rtf"
        style=journal;

/*---------------------------------------------------------------------*
 | Titles                                                              |
 *---------------------------------------------------------------------*/
title1 "Table 7. Time-to-Event Endpoints from Baseline (Days)";
title2 "ONCO-PEMBRO-500 | ITT Population (N=500)";

/*---------------------------------------------------------------------*
 | Table 7 Output                                                      |
 *---------------------------------------------------------------------*/
proc means data=work.tte_rep
           n median min max
           maxdec=1;
    class endpoint trt;
    var aval;
    where trt in ('Arm A','Arm B','Total');
run;

/*---------------------------------------------------------------------*
 | Footnotes                                                           |
 *---------------------------------------------------------------------*/
footnote1 "N represents the number of subjects in the ITT population.";
footnote2 "Time-to-event is calculated from randomization date to the date of event or censoring.";
footnote3 "Overall Survival is defined as time to death from any cause.";
footnote4 "Progression-Free Survival is defined as time to disease progression or death, whichever occurs first.";

/*---------------------------------------------------------------------*
 | Close RTF                                                           |
 *---------------------------------------------------------------------*/
ods rtf close;

/*---------------------------------------------------------------------*
 | Reset options                                                       |
 *---------------------------------------------------------------------*/
options notes source;
title;
footnote;
