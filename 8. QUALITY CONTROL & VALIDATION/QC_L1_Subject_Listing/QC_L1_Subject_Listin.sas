proc sql;
select 
    count(*) as n_obs,
    count(distinct usubjid) as n_subj
from adam.adsl_std
where ittfl='Y';
quit;
proc freq data=adam.adsl_std;
where ittfl='Y';
tables armcd / nocum;
title "QC – Treatment Arm Distribution (L1)";
run;
proc freq data=adam.adsl_std;
tables ittfl saffl efffl dthfl / missing;
title "QC – Subject Flags (L1)";
run;
proc print data=adam.adsl_std(obs=10);
var studyid usubjid armcd age sex race ecog height weight ittfl saffl efffl dthfl eosdt;
title "QC – Sample Subject Check vs L1 Listing";
run;
