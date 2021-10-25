

/*start from 2.FILTER HCS COMMUNITY*/
/**/
/*DEA_1*/



/*scenario 1 with zip code and county FOR ny*/

PROC SQL;
   CREATE TABLE DEA32_HCS_NYONLY_&DATE. AS 
   SELECT DISTINCT 
			T1.STATE,
	        T2.COMMUNITY AS COUNTY,
			t1.reporterid,
            t1.YEAR_RECORD_VIN AS YEAR,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
			T1.MONTH_RECORD_VIN AS MONTH,
			T1.NAME,
			t1.dea_reg_num,
			T1.DW
			FROM DEA_4_1 t1 LEFT JOIN MAP.REPORTER_LIST T2 ON t1.REPORTERID=T2.REPORTERID
      ORDER BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.DW
;
QUIT;

/*scenario 2 without zip code and county FOR ny*/

PROC SQL;
   CREATE TABLE DEA32_HCS_NYONLY_nocom_&DATE. AS 
   SELECT DISTINCT 
			T1.STATE,
/*	        T2.COMMUNITY AS COUNTY,*/
/*			t1.reporterid,*/
            t1.YEAR_RECORD_VIN AS YEAR,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
			T1.MONTH_RECORD_VIN AS MONTH,
			T1.NAME,
			t1.dea_reg_num,
			T1.DW
			FROM DEA_4_1 t1 
      ORDER BY T1.STATE,
/*			   t1.reporterid,*/
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.DW
;
QUIT;





libname zipcode "C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.2 DEA\Import\HCS ZIPCODE";


DATA DEA_3_all;
	SET DEA_1;

/***********************************************SUBSTRING YEAR AND MONTH OF RECORD_VINTAGE*/
YEAR_RECORD_VIN=input(substr(VVALUE(record_vintage),1,4),4.);
MONTH_RECORD_VIN=input(SUBSTR(VVALUE(record_vintage),6,2),2.);
RUN;


DATA DEA_4_all;
	SET DEA_3_all;
	LENGTH DECODE_BA $100.;
	LENGTH DW $10.;

	 IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='1' THEN Decode_BA='1.Practitioner DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='4' THEN Decode_BA='2.Practitioner DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='B' THEN Decode_BA='3.Practitioner DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='K' THEN Decode_BA='1.1 Practitioner DW30/SW';

	 IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='F' THEN Decode_BA='4.MLP-Nurse Practitioner DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='G' THEN Decode_BA='7.MLP-Physician Assistant DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='H' THEN Decode_BA='5.MLP-Nurse Practitioner DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='I' THEN Decode_BA='8.MLP-Physician Assistant DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='K' THEN Decode_BA='6.MLP-Nurse Practitioner DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='L' THEN Decode_BA='9.MLP-Physician Assistant DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='Q' THEN Decode_BA='4.1 MLP-Nurse Practitioner DW30/SW';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='R' THEN Decode_BA='7.1 MLP-Physician Assistant DW30/SW';

	 IF Decode_BA ne '' and BUSINES_ACTIVITY_SUB_CODE IN ('1','F','G','K','Q','R') THEN DW='DW-30';
ELSE IF Decode_BA ne '' and BUSINES_ACTIVITY_SUB_CODE IN ('4','H','I') THEN DW='DW-100';
ELSE IF Decode_BA ne '' and BUSINES_ACTIVITY_SUB_CODE IN ('B','K','L') THEN DW='DW-275';


RUN;

proc freq data=dea_4_all;
tables decode_ba record_vintage county_name2 zip_code county_name2*zip_code;
run;



/*ADD QUARTER*/

DATA DEA_4_0_all;
SET DEA_4_all;

     IF MONTH_RECORD_VIN IN (1,2,3) THEN QUARTER_RECORD_VIN='Q1';
ELSE IF MONTH_RECORD_VIN IN (4,5,6) THEN QUARTER_RECORD_VIN='Q2';
ELSE IF MONTH_RECORD_VIN IN (7,8,9) THEN QUARTER_RECORD_VIN='Q3';
ELSE IF MONTH_RECORD_VIN IN (10,11,12) THEN QUARTER_RECORD_VIN='Q4';

QUARTER_RECORD_VIN1=catx('-', YEAR_RECORD_VIN, QUARTER_RECORD_VIN);

RUN;



/*scenario 1 with zip code and county*/

PROC SQL;
   CREATE TABLE DEA32_HCS_ALLSTATE_&DATE. AS 
   SELECT DISTINCT 
			T1.STATE,
	        T2.COMMUNITY AS COUNTY,
            t1.YEAR_RECORD_VIN AS YEAR,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
			T1.MONTH_RECORD_VIN AS MONTH,
			T1.NAME,
			t1.dea_reg_num,
			T1.DW
			FROM DEA_4_0_all t1 LEFT JOIN zipcode.hcs_zipcode T2 ON 
			   t1.zip_code=t2.column1
ORDER BY       T1.STATE,
			   county,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.DW
;
QUIT;

/*scenario 2 without zip code and county*/
PROC SQL;
   CREATE TABLE DEA32_HCS_ALLSTATE_nocom_&DATE. AS 
   SELECT DISTINCT 
			T1.STATE,
/*	        T2.COMMUNITY AS COUNTY,*/
            t1.YEAR_RECORD_VIN AS YEAR,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
			T1.MONTH_RECORD_VIN AS MONTH,
			T1.NAME,
			t1.dea_reg_num,
			T1.DW
			FROM DEA_4_0_all t1
ORDER BY       T1.STATE,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.DW
;
QUIT;

/*proc freq data=dea.DEA32_FORHCS_ALLSTATE_&DATE.;*/
/*tables state*county;*/
/*run;*/