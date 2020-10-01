

/*Denominator: The population size estimate for each HCS community will be the mid-year population estimate as of July 1 for the year under surveillance.*/
/*Numerator: The total number of buprenorphine for OUD treatment providers*/
/*	Create numerator:*/
/*1.	Subset the DEA data to capture certain providers within the state. */
/*The Business Activity Code and Sub-codes included:*/
/*1)	Civilian physicians: C1, C4, and CB */
/* OR */
/*2)	civilian nurse practitioners: MF, MH, and MK*/
/*OR*/
/*3)	civilian physician assistants: MG, MI, and ML*/
/*2.	Subset step 1 data to only include valid registration. Use all variables to check duplications and only keep unique records.*/
/*3.	Identify HSC communities using City/Zip code and subset step 2 data to HSC communities.*/
/*4.	Calculate counts of providers with waiver at HSC community level by measurement periods.*/
/*Rate: Number of Providers with DATA 2000 Waiver per 100,000 population.*/


/*************************STEP2. FILTER AND SUBSET***********************************

/*The Business Activity Code and Sub-codes included:*/
/*1)	Civilian physicians: C1, C4, and CB */
/* OR */
/*2)	civilian nurse practitioners: MF, MH, and MK*/
/*OR*/
/*3)	civilian physician assistants: MG, MI, and ML

**************************************************************************************/

PROC SQL;
   CREATE TABLE DEA_1 AS 
   SELECT DISTINCT T1.RECORD_VINTAGE, 
          T1.STATE, 
          T1.NAME, 
          T1.ADDRESS_1, 
          T1.ADDRESS_2, 
          T1.ACTIVITY, 
          T1.DRUG_SCHEDULES, 
          T1.BUSINESS_ACTIVITY_CODE, 
          T1.DEA_REG_NUM, 
          T1.PAYMENT_INDICATOR, 
          T1.EXPIRATION_DATE, 
          T1.ADDITIONAL_COMPANY_INFO, 
          T1.CITY, 
          T1.ZIP_CODE, 
          T1.BUSINES_ACTIVITY_SUB_CODE,
		  T2.COUNTY_NAME2
      FROM WORK.redivis_export AS T1 LEFT JOIN ZIP AS T2 ON 
	  	  T1.ZIP_CODE=T2.ZIP_CODE
      WHERE ( T1.BUSINESS_ACTIVITY_CODE = 'C' AND T1.BUSINES_ACTIVITY_SUB_CODE IN 
           (
           '1',
           '4',
           'B'
           ) ) OR ( T1.BUSINESS_ACTIVITY_CODE = 'M' AND T1.BUSINES_ACTIVITY_SUB_CODE IN 
           (
           'F',
           'G',
           'H',
           'I',
           'K',
           'L'
           ) );
QUIT;

/*FILTER SELECTED COUNTY*/
DATA DEA_2;
	SET DEA_1;
	COUNT=1;
		WHERE COUNTY_NAME2 IN ('Broome',
'Cayuga',
'Chautauqua',
'Columbia',
'Cortland',
'Genesee',
'Greene',
'Lewis',
'Putnam',
'Orange',
'Sullivan',
'Ulster',
'Yates',
'Rochester',
'Buffalo',
'Brookhaven',
'Erie'
'Monroe'
'Suffolk'

);
RUN;

PROC FREQ DATA=DEA_2;
TABLES record_vintage activity;
RUN;

/*************STEP2.1***************************FILTER WRONG EXPIRATION DATE AND ACTIVITY CODE NE A*/


/*UPDATE 4/17/20 BY DAN, NO NEED TO DROP EXPIRATION AND ACTIVE STATUS*/

DATA DEA_3;
	SET DEA_2;

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


/*CHECK*/
DATA DEA_3_CHECK;
SET DEA_2;

/*SUBSTRING YEAR AND MONTH OF RECORD_VINTAGE*/
YEAR_RECORD_VIN=input(substr(VVALUE(record_vintage),1,4),4.);
MONTH_RECORD_VIN=input(SUBSTR(VVALUE(record_vintage),6,2),2.);

/*create date for expiration date*/
EXPIRATION_DATE2=INPUT(PUT(EXPIRATION_DATE,BEST8.),YYMMDD8.);
FORMAT EXPIRATION_DATE2 DATE9.;

IF (YEAR_RECORD_VIN>=YEAR(EXPIRATION_DATE2) AND MONTH_RECORD_VIN>MONTH(EXPIRATION_DATE2));
RUN;

/*16 RECORDS DELETED DUE TO WRONG RECORD VIN AND EXPIRATION DATE*/
/*record_vintage	state	name	address_1	address_2	activity	drug_schedules	business_activity_code	dea_reg_num	payment_indicator	expiration_date*/
/*2019-06	NY	WENZEL, ABBY	200 DUNHAM A		I	22N 33N 4 5	 Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)	MW1673979	P	20190531*/
/*2019-07	NY	ACKERMAN-RAP	ROCKLAND PSY	350 WASHINGT	I	22N 33N 4 5	C	BA7290024	E	20190630*/
/*2019-07	NY	AHMED, MAHMO	HOSPITALIST	33-57 HARRIS	I	22N 33N 4 5	C	BB7610442	P	20190630*/
/*2019-07	NY	DIAZ, MARIA	NEW YORK STA	325 RIVERSID	I	22N 33N 4 5	 Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)	MD1171494	E	20190630*/
/*2019-09	NY	CASS, SHARYN	206 S. ELMWO		I	22N 33N 4 5	 Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)	MB2894839	P	20190831*/
/*2019-09	NY	CHRISTENSEN,	737 MAIN ST		A	22N 33N 4 5	C	FC6050013	P	20190831*/
/*2019-09	NY	CONDOR, ELIS	ROCHESTER ME	490 EAST RID	I	22N 33N 4 5	 Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)	MK4397255	P	20190831*/
/*2019-09	NY	CUZZACREA, A	860 MAIN ROA		I	22N 33N 4 5	 Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)	MC3923439	P	20190831*/
/*2019-10	NY	CHRISTENSEN,	737 MAIN ST		A	22N 33N 4 5	C	FC6050013	P	20190831*/
/*2019-10	NY	GORDON, PAUL	3 COATES DRI	SUITE 8	I	22N 33N 4 5	C	AG9569851	P	20190930*/
/*2019-11	NY	CHRISTENSEN,	737 MAIN ST		A	22N 33N 4 5	C	FC6050013	P	20190831*/
/*2019-11	NY	HARVEY, RAYM	1 FAMILY PRA		I	22N 33N 4 5	C	BH6017431	P	20191031*/
/*2020-02	NY	MILLER, LAUR	601 ELMWOOD		I	22N 33N 4 5	C	FM4295449	P	20200131*/
/*2020-02	NY	MURPHY, CHER	283 W 2ND ST		A	22N 33N 4 5	 Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)	MM2367666	P	20200131*/
/*2020-03	NY	SCHULER, MAR	155 LAWN AVE		I	22N 33N 4 5	 Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)	MS1846293	P	20200229*/
/*2020-03	NY	SENGUPTA, PI	2 HEATHER RI		I	22N 33N 4 5	C	AS3171232	P	20200229*/

