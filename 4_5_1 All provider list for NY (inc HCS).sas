



/*FILTER NY*/

/*CHECK STATE*/

PROC FREQ DATA=DEA_1;
TABLES STATE;
RUN;

DATA DEA_1_NY_0;
	SET DEA_1;
	COUNT=1;
		WHERE STATE IN ('NY');
RUN;

/*CREATE DISTINCT COUNTY NAME AND ZIPCODE FOR REST COUNTY NAME*/

PROC SQL;
   CREATE TABLE DEA_1_NY_1 AS 
   SELECT DISTINCT 
          t1.zip_code, 
          t1.COUNTY_NAME2, 
          t2.County_Name
      FROM WORK.DEA_1_NY_0 (WHERE=(COUNTY_NAME2 = '')) t1
           LEFT JOIN ZIP.NEW_YORK_STATE_ZIP t2 ON (t1.zip_code = t2.ZIP_Code)
	  ORDER BY 
	  	  ZIP_CODE
;
QUIT;

/*649 ZIPCODE&COUNTY TO 563 ZIPCODE-COUNTY, SELECT FIRST MATCH*/
DATA DEA_1_NY_2;
SET DEA_1_NY_1;
BY zip_code;
IF FIRST.ZIP_CODE;
RUN;

PROC SQL;
   CREATE TABLE DEA_1_NY_3 AS 
   SELECT t1.record_vintage, 
          t1.state, 
          t1.name, 
          t1.address_1, 
          t1.address_2, 
          t1.activity, 
          t1.drug_schedules, 
          t1.business_activity_code, 
          t1.dea_reg_num, 
          t1.payment_indicator, 
          t1.expiration_date, 
          t1.additional_company_info, 
          t1.city, 
          t1.zip_code, 
          t1.busines_activity_sub_code, 
          t1.COUNTY_NAME2, 
          t1.COUNT, 
          t2.County_Name
      FROM WORK.DEA_1_NY_0 t1
           LEFT JOIN DEA_1_NY_2 t2 ON (t1.zip_code = t2.ZIP_Code);
QUIT;

PROC FREQ DATA=DEA_1_NY_3;
TABLES County_Name COUNTY_NAME2;
RUN;

DATA DEA_2_NY;
SET DEA_1_NY_3;
IF COUNTY_NAME2 NE '' THEN COUNTY=COUNTY_NAME2;
ELSE IF COUNTY_NAME2 = ''  THEN COUNTY=County_Name;
DROP COUNTY_NAME2 COUNTY_NAME;
RUN;
PROC FREQ DATA=DEA_2_NY;
TABLES COUNTY;
RUN;



PROC FREQ DATA=DEA_2_NY;
TABLES record_vintage activity;
RUN;



/*UPDATE 4/17/20 BY DAN, NO NEED TO DROP EXPIRATION AND ACTIVE STATUS*/
DATA DEA_3_NY;
	SET DEA_2_NY;

/***********************************************SUBSTRING YEAR AND MONTH OF RECORD_VINTAGE*/
YEAR_RECORD_VIN=input(substr(VVALUE(record_vintage),1,4),4.);
MONTH_RECORD_VIN=input(SUBSTR(VVALUE(record_vintage),6,2),2.);

/*****************************************create date for expiration date*/
/*EXPIRATION_DATE2=INPUT(PUT(EXPIRATION_DATE,BEST8.),YYMMDD8.);*/
/*FORMAT EXPIRATION_DATE2 DATE9.;*/
/**/
/*IF YEAR_RECORD_VIN>=YEAR(EXPIRATION_DATE2) AND MONTH_RECORD_VIN>MONTH(EXPIRATION_DATE2) THEN DELETE;*/
/**/
/*WHERE activity = 'A';*/

RUN;


/*RECODE ACTIVITY CODE*/


DATA DEA_4_NY;
	SET DEA_3_NY;
	LENGTH DECODE_BA $100.;
	LENGTH DW $10.;

	 IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='1' THEN Decode_BA='1.Practitioner DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='4' THEN Decode_BA='2.Practitioner DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='B' THEN Decode_BA='3.Practitioner DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='F' THEN Decode_BA='4.MLP-Nurse Practitioner DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='G' THEN Decode_BA='7.MLP-Physician Assistant DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='H' THEN Decode_BA='5.MLP-Nurse Practitioner DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='I' THEN Decode_BA='8.MLP-Physician Assistant DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='K' THEN Decode_BA='6.MLP-Nurse Practitioner DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='L' THEN Decode_BA='9.MLP-Physician Assistant DW275';

	 IF Decode_BA ne '' and BUSINES_ACTIVITY_SUB_CODE IN ('1','F','G') THEN DW='DW-30';
ELSE IF Decode_BA ne '' and BUSINES_ACTIVITY_SUB_CODE IN ('4','H','I') THEN DW='DW-100';
ELSE IF Decode_BA ne '' and BUSINES_ACTIVITY_SUB_CODE IN ('B','K','L') THEN DW='DW-275';


RUN;

proc freq data=dea_4_NY;
tables decode_ba record_vintage COUNTY zip_code county*zip_code;
run;

proc freq data=dea_4_NY;
tables decode_ba BUSINESS_ACTIVITY_CODE BUSINES_ACTIVITY_SUB_CODE dw;
run;

proc freq data=dea_4_NY;
tables dw*record_vintage;
run;



/*ADD QUARTER*/

DATA DEA_4_0_NY;
SET DEA_4_NY;

     IF MONTH_RECORD_VIN IN (1,2,3) THEN QUARTER_RECORD_VIN='Q1';
ELSE IF MONTH_RECORD_VIN IN (4,5,6) THEN QUARTER_RECORD_VIN='Q2';
ELSE IF MONTH_RECORD_VIN IN (7,8,9) THEN QUARTER_RECORD_VIN='Q3';
ELSE IF MONTH_RECORD_VIN IN (10,11,12) THEN QUARTER_RECORD_VIN='Q4';

QUARTER_RECORD_VIN1=catx('-', YEAR_RECORD_VIN, QUARTER_RECORD_VIN);

RUN;

proc freq data=dea_4_0_NY;
tables record_vintage;
run;



/*scenario 1 with zip code and county FOR ALL COUNTIES IN NY*/

PROC SQL;
   CREATE TABLE DEA32_ALLCTS_NY_&DATE. AS 
   SELECT DISTINCT 
			T1.STATE,
	        T1.COUNTY,
/*			t1.reporterid,*/
            t1.YEAR_RECORD_VIN AS YEAR,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
			T1.MONTH_RECORD_VIN AS MONTH,
			T1.NAME,
			t1.dea_reg_num,
			T1.DW
			FROM dea_4_0_NY t1
      ORDER BY T1.STATE,
			   t1.COUNTY,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.DW
;
QUIT;

/*scenario 2 without zip code and county FOR ny*/

PROC SQL;
   CREATE TABLE DEA32_ALLCTS_NY_NOCOM_&DATE. AS 
   SELECT DISTINCT 
			T1.STATE,
            t1.YEAR_RECORD_VIN AS YEAR,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
			T1.MONTH_RECORD_VIN AS MONTH,
			T1.NAME,
			t1.dea_reg_num,
			T1.DW
			FROM dea_4_0_NY t1 
      ORDER BY T1.STATE,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.DW
;
QUIT;