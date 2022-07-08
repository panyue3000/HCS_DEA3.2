

/*test*/
data dea_5_fiscal;
set dea_5;

fiscal_date=mdy(month_record_vin,1,year_record_vin)+210;
format fiscal_date yymms7.;


run;


/**************************************fiscal YEAR**********************************/
PROC SQL;
   CREATE TABLE DEA_Y_fiscal AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  year(fiscal_date) AS YEAR,
/*		  MONTH_RECORD_VIN,*/
/*		  . AS MONTH,*/
          /* SUM_of_COUNT */
/*            (SUM(t1.COUNT)) FORMAT=BEST32. AS SUM_CT,*/
			count (distinct name) as sum_ct
/*			count (distinct address_1) as count_address_1,*/
/*			count (distinct dea_reg_num) as count_dea_reg_num*/
      FROM DEA_5_fiscal t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               calculated YEAR 
/*			   T1.MONTH_RECORD_VIN*/
;
QUIT;



/*DATA DEA_ALL_0_fiscal(drop=sum_ct1);*/
/*SET DEA_Y_fiscal ;*/
/*RUN;*/


/*JOIN REPORTER ID*/
PROC SQL;
   CREATE TABLE DEA_ALL_1_fiscal AS 
   SELECT DISTINCT 
		  t1.*, 
		  T2.POP
      FROM DEA_Y_fiscal t1
           LEFT JOIN POPEST T2 ON t1.ReporterId=T2.ReporterId AND 
								  T1.YEAR=T2.YEAR
      ORDER BY T1.STATE,
			   t1.ReporterId,
			   T1.YEAR
/*			   T1.QUARTER,*/
/*			   T1.MONTH*/
;
QUIT;


/*FORMAT ACCORDING TO THE HCS REQUIREMENT*/
PROC SQL;
   CREATE TABLE DEA_ALL_2_fiscal AS 
   SELECT DISTINCT 
/*   	      STATE,*/
		  ReporterId,
		  '3.2' AS MEASUREID,
		  SUM_CT AS NUMERATOR,
		  POP AS DENOMINATOR,
		  . as MONTH,
		  . as QUARTER,
		  YEAR,
		  CASE WHEN SUM_CT EQ . THEN 1
		       ELSE 0 END AS IsSuppressed,
		  "This data is from DEA &DEA_VERSION. (Fiscal Year)" AS NOTES,
		  '' AS STRATIFICATION
      FROM DEA_ALL_1_fiscal
      ORDER BY REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;

proc freq data=DEA_ALL_2_fiscal;
tables year*measureid;
run;

DATA DEA32_FINAL_fiscal_&DATE.;
SET DEA_ALL_2_fiscal;
IF YEAR=2023 THEN DELETE;
RUN;

/*EXPORT */

%csv_export(DEA32_FINAL_fiscal_&DATE.);
