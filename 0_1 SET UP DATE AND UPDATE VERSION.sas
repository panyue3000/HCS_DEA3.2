


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=092720;

%let DEA_VERSION= V1.12;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;