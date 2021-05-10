


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=051021;

%let DEA_VERSION= V1.19;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;