


/*SET UP DATE AND UPDATE VERSION */

%LET DATE=01042021;

%let DEA_VERSION= V1.14;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;