/*=============================================================*
 | L1 – Subject Listing (CRO Style)
 | Population : ITT
 | Source     : ADAM.ADSL_STD
 | Output     : One RTF
 *=============================================================*/

options nodate nonumber nocenter
        nonotes nosource;

ods escapechar='^';

/*-------------------------------------------------------------*
 | Library
 *-------------------------------------------------------------*/
libname adam "/home/u64086073/04_ADAM";

/*-------------------------------------------------------------*
 | Prepare Subject Listing Dataset
 *-------------------------------------------------------------*/
data l1_subject;
    set adam.adsl_std;
    where ittfl = 'Y';

    keep
        studyid
        usubjid
        siteid
        country
        armcd
        arm
        randdt
        age
        sex
        race
        ethnic
        ecog
        height
        weight
        ittfl
        saffl
        efffl
        dthfl
        eosdt;
run;

/*-------------------------------------------------------------*
 | Sort for clean listing
 *-------------------------------------------------------------*/
proc sort data=l1_subject;
    by armcd usubjid;
run;

/*-------------------------------------------------------------*
 | Open RTF
 *-------------------------------------------------------------*/
ods rtf file="/home/u64086073/05_TLF/Listings/L1_Subject_Listing.rtf"
        style=journal;

/*-------------------------------------------------------------*
 | Titles
 *-------------------------------------------------------------*/
title1 "Listing 1. Subject Listing";
title2 "ONCO-PEMBRO-500 | ITT Population";

/*-------------------------------------------------------------*
 | Subject Listing Output
 *-------------------------------------------------------------*/
proc report data=l1_subject nowd headline headskip split='|';
    columns
        studyid usubjid siteid country
        armcd arm randdt
        age sex race ethnic ecog height weight
        ittfl saffl efffl dthfl eosdt;

    define studyid  / "Study ID" width=10;
    define usubjid  / "Subject ID" width=16;
    define siteid   / "Site ID" width=6;
    define country  / "Country" width=8;

    define armcd    / "Arm|Code" width=6;
    define arm      / "Treatment Arm" width=18;
    define randdt   / "Randomization|Date" format=date9. width=10;

    define age      / "Age|(Years)" width=6;
    define sex      / "Sex" width=4;
    define race     / "Race" width=10;
    define ethnic   / "Ethnicity" width=12;
    define ecog     / "ECOG|Score" width=6;
    define height   / "Height|(cm)" width=8;
    define weight   / "Weight|(kg)" width=8;

    define ittfl    / "ITT|Flag" width=5;
    define saffl   / "Safety|Flag" width=6;
    define efffl   / "Efficacy|Flag" width=6;
    define dthfl   / "Death|Flag" width=6;
    define eosdt   / "End of|Study Date" format=date9. width=10;
run;

/*-------------------------------------------------------------*
 | Footnotes
 *-------------------------------------------------------------*/
footnote1 "ITT Population includes all randomized subjects.";
footnote2 "ECOG = Eastern Cooperative Oncology Group performance status.";
footnote3 "Dates are presented in DDMMMYYYY format.";

/*-------------------------------------------------------------*
 | Close RTF
 *-------------------------------------------------------------*/
ods rtf close;

options notes source;
title;
footnote;
