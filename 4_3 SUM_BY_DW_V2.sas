/**************************************YEAR**********************************/
PROC SQL;
   CREATE TABLE DEA_DW_Y AS 
   SELECT DISTINCT 
   		  T1.DW,
   		  T1.STATE,
		  t1.ReporterId,
		  YEAR_RECORD_VIN AS YEAR,
          /* SUM_of_COUNT */
			count (distinct dea_reg_num) as sum_ct
      FROM DEA_5 t1
      GROUP BY T1.DW,
			   T1.STATE,
			   t1.ReporterId,
               t1.YEAR_RECORD_VIN
;
QUIT;




/***********************************************QUARTER*******************************************/
PROC SQL;
   CREATE TABLE DEA_DW_QTR AS 
   SELECT DISTINCT
	      T1.DW,
   		  T1.STATE,
	      t1.ReporterId,
		  YEAR_RECORD_VIN AS YEAR,
		  INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
          /* SUM_of_COUNT */
			count (distinct dea_reg_num) as sum_ct
      FROM DEA_5 t1
      GROUP BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   calculated quarter
;
QUIT;


/**********************************************MONTH***********************************************/
PROC SQL;
   CREATE TABLE DEA_DW_MONTH AS 
   SELECT DISTINCT 
		  T1.DW,
	      T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
		  MONTH_RECORD_VIN AS MONTH,
          /* SUM_of_COUNT */
            (SUM(t1.COUNT)) FORMAT=BEST32. AS SUM_CT
      FROM DEA_5 t1
      GROUP BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   MONTH_RECORD_VIN
;
QUIT;

/*COMBINE ALL*/
DATA DEA_DW_0;
SET DEA_DW_Y DEA_DW_QTR DEA_DW_MONTH;
RUN;


/*JOIN REPORTER ID*/
PROC SQL;
   CREATE TABLE DEA_DW_1 AS 
   SELECT DISTINCT 
		  t1.*, 
		  T2.POP
      FROM DEA_DW_0 t1
		   LEFT JOIN POPEST T2 ON t1.ReporterId=T2.ReporterId AND 
								  T1.YEAR=T2.YEAR
      ORDER BY T1.DW,
			   T1.STATE,
			   t1.ReporterId,
			   T1.YEAR,
			   T1.QUARTER,
			   T1.MONTH
;
QUIT;


/*FORMAT ACCORDING TO THE HCS REQUIREMENT*/
PROC SQL;
   CREATE TABLE DEA_DW_2 AS 
   SELECT DISTINCT 
   		  DW,
	      STATE,
		  ReporterId,
		  CASE WHEN DW='DW-30' THEN '3.2.30' 
		  	   WHEN DW='DW-100' THEN '3.2.100'
			   WHEN DW='DW-275' THEN '3.2.275' 
				END AS MEASUREID,
		  SUM_CT AS NUMERATOR,
		  POP AS DENOMINATOR,
		  MONTH,
		  QUARTER,
		  YEAR,
		  CASE WHEN SUM_CT EQ . THEN 1
		       ELSE 0 END AS IsSuppressed,
		  "This data is from DEA &DEA_VERSION." AS NOTES,
		  '' AS STRATIFICATION
      FROM DEA_dw_1
      ORDER BY DW,
			   REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;


/*DELETE PARTIAL COUNTY WITHOUT A REPORT ID*/
DATA DEA_DW;
SET DEA_DW_2;
WHERE REPORTERID NE '';
/*DROP DW;*/
RUN;


/*COMBINE WITH DEA_ALL*/
DATA DEA32_FINAL_EXCEL;
LENGTH MEASUREID $50.;
SET DEA_ALL DEA_DW;
IF DW='' THEN DW='OVERALL';
RUN;


PROC SQL;
   CREATE TABLE DEA32_FINAL_EXCEL_0 AS 
   SELECT DISTINCT 
		  T1.MEASUREID,
   	      T1.STATE,
		  T2.COMMUNITY AS COUNTY_NAME2,
	      T1.ReporterId,
		  T1.NUMERATOR,
		  T1.DENOMINATOR,
		  T1.MONTH,
		  T1.QUARTER,
		  T1.YEAR,
		  T1.IsSuppressed,
		  T1.NOTES,
		  T1.STRATIFICATION,
		  DW
      FROM DEA32_FINAL_EXCEL AS T1 LEFT JOIN MAP.REPORTER_LIST T2 ON t1.REPORTERID=T2.REPORTERID
      ORDER BY MEASUREID,
			   REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;




