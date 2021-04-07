


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=040621;

%let DEA_VERSION= V1.18;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;