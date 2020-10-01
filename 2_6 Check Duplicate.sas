

PROC FREQ DATA=DEA_4;
TABLES DEA_REG_NUM;
RUN;

PROC SQL;
   CREATE TABLE WORK.DEA_4_DUP1 AS 
   SELECT 
		  T1.RECORD_VINTAGE, 
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
          T1.COUNTY_NAME2, 
          T1.COUNT, 
          T1.DECODE_BA, 
          /* CALCULATION */
            (SUM(T1.COUNT)) AS CALCULATION
      FROM WORK.DEA_4 T1
      GROUP BY 
		      T1.RECORD_VINTAGE, 
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
	          T1.COUNTY_NAME2, 	               
              T1.COUNT,
              T1.DECODE_BA
      ORDER BY 
			   T1.STATE,
			   T1.NAME,
               T1.ADDRESS_1,
               T1.ADDRESS_2,
               T1.CITY,
			   T1.RECORD_VINTAGE, 
			   T1.DEA_REG_NUM,
               T1.EXPIRATION_DATE
;

QUIT;


/*SAME PERSON AT SAME TIMEPEIROD BUT MULTIPLE RECORDS*/
PROC SQL;
   CREATE TABLE WORK.DEA_4_DUP2 AS 
   SELECT 
		  T1.RECORD_VINTAGE, 
		  T1.STATE, 
          T1.NAME, 
/*          T1.ADDRESS_1, */
/*          T1.ADDRESS_2, */
/*          T1.ACTIVITY, */
/*          T1.DRUG_SCHEDULES, */
/*          T1.BUSINESS_ACTIVITY_CODE, */
/*          T1.DEA_REG_NUM, */
/*          T1.PAYMENT_INDICATOR, */
/*          T1.EXPIRATION_DATE, */
/*          T1.ADDITIONAL_COMPANY_INFO, */
/*          T1.CITY, */
/*          T1.ZIP_CODE, */
/*          T1.BUSINES_ACTIVITY_SUB_CODE,*/
/*          T1.COUNTY_NAME2, */
/*          T1.COUNT, */
          T1.DECODE_BA, 
          /* CALCULATION */
            COUNT(T1.COUNT) AS COUNT_Dup
      FROM WORK.DEA_4 T1
      GROUP BY 
		      T1.RECORD_VINTAGE, 
			  T1.STATE, 
	          T1.NAME, 
/*	          T1.ADDRESS_1, */
/*	          T1.ADDRESS_2, */
/*	          T1.ACTIVITY, */
/*	          T1.DRUG_SCHEDULES, */
/*	          T1.BUSINESS_ACTIVITY_CODE, */
/*	          T1.DEA_REG_NUM, */
/*	          T1.PAYMENT_INDICATOR, */
/*	          T1.EXPIRATION_DATE, */
/*	          T1.ADDITIONAL_COMPANY_INFO, */
/*	          T1.CITY, */
/*	          T1.ZIP_CODE, */
/*	          T1.BUSINES_ACTIVITY_SUB_CODE,*/
/*	          T1.COUNTY_NAME2, 	               */
/*              T1.COUNT,*/
              T1.DECODE_BA
      ORDER BY 
			   T1.STATE,
			   T1.NAME,
/*               T1.ADDRESS_1,*/
/*               T1.ADDRESS_2,*/
/*               T1.CITY,*/
			   T1.RECORD_VINTAGE
/*			   T1.DEA_REG_NUM,*/
/*               T1.EXPIRATION_DATE*/
;

QUIT;


PROC FREQ DATA=DEA_4_DUP2;
TABLES COUNT_Dup;
RUN;