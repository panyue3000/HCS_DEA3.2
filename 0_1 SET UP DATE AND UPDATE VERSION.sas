


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=0921;

%let DEA_VERSION= V1.23;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;