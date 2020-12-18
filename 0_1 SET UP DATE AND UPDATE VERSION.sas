


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=121820;

%let DEA_VERSION= V1.13;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;