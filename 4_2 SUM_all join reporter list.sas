/*ORDER BY STATE, COUNTY, YEAR, MONTH*/
PROC SQL;
   CREATE TABLE DEA_5_ORDER AS 
   SELECT DISTINCT 
			T1.*
			FROM DEA_5 t1
      ORDER BY T1.STATE,
			   t1.reporterid,
			   T1.NAME,
			   T1.DW,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN


;
QUIT;



/**************************************YEAR**********************************/
PROC SQL;
   CREATE TABLE DEA_Y AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
/*		  MONTH_RECORD_VIN,*/
		  . AS MONTH,
          /* SUM_of_COUNT */
/*            (SUM(t1.COUNT)) FORMAT=BEST32. AS SUM_CT,*/
			count (distinct name) as sum_ct
/*			count (distinct address_1) as count_address_1,*/
/*			count (distinct dea_reg_num) as count_dea_reg_num*/
      FROM DEA_5 t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN
/*			   T1.MONTH_RECORD_VIN*/
;
QUIT;

/***********************************************QUARTER*******************************************/
PROC SQL;
   CREATE TABLE DEA_QTR AS 
   SELECT DISTINCT 
   		  T1.STATE,
	      t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
		  INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
/* 		  MONTH_RECORD_VIN AS MONTH,*/
          /* SUM_of_COUNT */
            (SUM(t1.COUNT)) FORMAT=BEST32. AS SUM_CT1,
			count (distinct name) as sum_ct
     FROM DEA_5 t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   calculated quarter
;
QUIT;

/**********************************************MONTH***********************************************/
PROC SQL;
   CREATE TABLE DEA_MONTH AS 
   SELECT DISTINCT 
		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
		  MONTH_RECORD_VIN AS MONTH,
          /* SUM_of_COUNT */
            (SUM(t1.COUNT)) FORMAT=BEST32. AS SUM_CT,
			count (distinct name) as sum_ct1
      FROM DEA_5 t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   MONTH_RECORD_VIN
;
QUIT;


DATA DEA_ALL_0(drop=sum_ct1);
SET DEA_Y DEA_QTR DEA_MONTH;
RUN;


/*JOIN REPORTER ID*/
PROC SQL;
   CREATE TABLE DEA_ALL_1 AS 
   SELECT DISTINCT 
		  t1.*, 
		  T2.POP
      FROM DEA_ALL_0 t1
           LEFT JOIN POPEST T2 ON t1.ReporterId=T2.ReporterId AND 
								  T1.YEAR=T2.YEAR
      ORDER BY T1.STATE,
			   t1.ReporterId,
			   T1.YEAR,
			   T1.QUARTER,
			   T1.MONTH
;
QUIT;


/*FORMAT ACCORDING TO THE HCS REQUIREMENT*/
PROC SQL;
   CREATE TABLE DEA_ALL_2 AS 
   SELECT DISTINCT 
   	      STATE,
		  ReporterId,
		  '3.2' AS MEASUREID,
		  SUM_CT AS NUMERATOR,
		  POP AS DENOMINATOR,
		  MONTH,
		  QUARTER,
		  YEAR,
		  CASE WHEN SUM_CT EQ . THEN 1
		       ELSE 0 END AS IsSuppressed,
		  "This data is from DEA &DEA_VERSION." AS NOTES,
		  '' AS STRATIFICATION
      FROM DEA_ALL_1
      ORDER BY REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;


/*DELETE PARTIAL COUNTY WITHOUT A REPORT ID*/
DATA DEA_ALL;
SET DEA_ALL_2;
WHERE REPORTERID NE '';
RUN;

