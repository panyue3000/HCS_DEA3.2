
data redivis_export;
/*
	SPECIFY THE PATH TO YOUR DOWNLOADED CSV BELOW:
*/
infile 'C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.2 DEA\HCS deliveries\RAW\DEA32_FINAL_comb_fiscal_0123.csv'

delimiter = ',' MISSOVER DSD firstobs=2;


	informat REPORTERID $50. ;
	informat MEASUREID $50. ;
	informat NUMERATOR 32. ;
	informat DENOMINATOR 32. ;
	informat MONTH 32. ;
	informat QUARTER 32. ;
	informat YEAR 32. ;
	informat IsSuppressed 32. ;
	informat NOTES $50. ;
	informat STRATIFICATION $50. ;
	

input
	REPORTERID $
	MEASUREID
	NUMERATOR
	DENOMINATOR
	MONTH 
	QUARTER 
	YEAR
	IsSuppressed
	NOTES $
	STRATIFICATION $
;



run;



data DEA;
	retain REPORTERID MEASUREID month quarter NUMERATOR DENOMINATOR  YEAR IsSuppressed NOTES STRATIFICATION;
set redivis_export;

	format MONTH BEST32. ;
	format QUARTER BEST32. ;
	format NUMERATOR BEST32. ;
	format DENOMINATOR BEST32. ;
	format YEAR BEST32. ;
	format IsSuppressed BEST32. ;


RUN;

/*  Following was to check that FY data was what I thought it was
Data StudyYr;
set DEAFY;
if year=2022;
run;
proc sort data=studyYr;
by reporterid;
run;
*/

proc sort data=DEA;
by reporterid year month quarter;
run;

data m32;
set DEA;
if measureid eq '3.2';
rename
numerator=N32;
drop issuppressed denominator;
run;

data m3230;
set DEA;
if measureid eq '3.2.30';
rename
numerator=N3230;
drop issuppressed denominator;
run;

data m32100;
set DEA;
if measureid eq '3.2.100';
rename
numerator=N32100;
drop issuppressed denominator;
run;

data m32275;
set DEA;
if measureid eq '3.2.275';
rename
numerator=N32275;
drop issuppressed denominator;
run;

Data m32wide;
merge m32 m3230 m32100 m32275;
by reporterid year month quarter;
Calcsum=n3230+n32100+n32275;
If calcsum=n32 then comparison='equal';
If calcsum>n32 then comparison='GT';
if calcsum<n32 then comparison='LT';
difference=calcsum-n32;
if reporterid in ('0368','0369','0370') then delete;
run;
Title 'Look at Sum of submeasures of 3.2 and compare to 3.2';
proc freq data=m32wide;
table comparison difference;
run;
/*
proc freq data=m32wide;
table reporterid;
run;
*/
proc freq data=m32wide;
where month eq . and quarter=.;
table Year*difference;
run;
