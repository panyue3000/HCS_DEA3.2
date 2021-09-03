


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=0821;

%let DEA_VERSION= V1.22;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;