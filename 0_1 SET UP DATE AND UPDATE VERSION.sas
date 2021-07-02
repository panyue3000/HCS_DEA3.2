


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=0621;

%let DEA_VERSION= V1.20;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;