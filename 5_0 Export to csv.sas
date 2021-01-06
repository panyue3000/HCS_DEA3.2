
libname export "C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.2 DEA\HCS deliveries";






/*5 DELIVERY FILES TO HCS DELIVERIES*/

/*DEA32_FINAL_&DATE.*/
/*DEA32_HCS_NYONLY_&DATE.*/
/*DEA32_HCS_NYONLY_nocom_&DATE.*/
/*DEA32_HCS_ALLSTATE_&DATE.*/
/*DEA32_HCS_ALLSTATE_nocom_&DATE.*/

/*filter all records from NY—so will have people outside of HCS communities*/
/*DEA32_ALLCTS_NY_&DATE. */
/*DEA32_ALLCTS_NY_NOCOM_&DATE. */

%macro csv_export (DATA);

proc export data=&DATA. dbms=CSV
outfile= %TSLIT (C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.2 DEA\HCS deliveries\RAW\&DATA..CSV)
replace;
run;

%mend csv_export;

%csv_export(DEA32_FINAL_&DATE.);
%csv_export(DEA32_HCS_NYONLY_&DATE.);
%csv_export(DEA32_HCS_NYONLY_nocom_&DATE.);
%csv_export(DEA32_HCS_ALLSTATE_&DATE.);
%csv_export(DEA32_HCS_ALLSTATE_nocom_&DATE.);
%csv_export(DEA32_ALLCTS_NY_&DATE. );
%csv_export(DEA32_ALLCTS_NY_NOCOM_&DATE. );


/*1 INTERNAL DELIVERY FILE FOR EXCEL */
/*DEA32_FINAL_EXCEL_092720*/

%macro csv_export (DATA);

proc export data=&DATA. dbms=CSV
outfile= %TSLIT (C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.2 DEA\Export\RAW\&DATA..CSV)
replace;
run;

%mend csv_export;

%csv_export(DEA32_FINAL_EXCEL_&DATE.);


/*1 COMPARISON INTERNAL DELIVERY FILE FOR EXCEL  */
/*CREATE THE COLUMN TO COMPARE TWO DELIVERIES AND RANK BY %CHANGE*/
