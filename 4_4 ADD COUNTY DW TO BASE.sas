/*CREATE BASE FILE WITH ID AND TIME*/
PROC SQL;
   CREATE TABLE CTY_DW_0 AS 
   SELECT DISTINCT 
		  T1.COUNTY_NAME2,
		  T1.DW
      FROM DEA32_FINAL_EXCEL_0 T1;
QUIT;

PROC FREQ DATA=CTY_DW_0;
RUN;


/*CREATE EXTRA DW=275 TO FILL THE MISSING*/
DATA CTY_DW275;
SET CTY_DW_0(WHERE=(DW=("OVERALL")));
DW="DW-275";
RUN;

DATA CTY_DW;
SET CTY_DW_0(WHERE=(DW NE ("DW-275"))) 
    CTY_DW275
;
RUN;
PROC FREQ DATA=CTY_DW;
RUN;


PROC SQL;
CREATE TABLE BASE AS 
SELECT * FROM CTY_DW T1, CAL_1
ORDER BY  T1.COUNTY_NAME2,
		  T1.DW,
		  YEAR,
		  QUARTER,
		  MONTH
;
QUIT;

PROC FREQ DATA=BASE;
RUN;


/*ADD FINAL DATA TO BASE*/
PROC SQL;
   CREATE TABLE DEA32_FINAL_EXCEL_1 AS 
   SELECT DISTINCT 
		  CASE WHEN T1.DW='DW-30' THEN '3.2.30' 
		  	   WHEN T1.DW='DW-100' THEN '3.2.100'
			   WHEN T1.DW='DW-275' THEN '3.2.275' 
			   WHEN T1.DW='OVERALL' THEN '3.2'
			   ELSE 'MISSING'
			   END AS MEASUREID,
   	      'NY' AS STATE,
		  T1.COUNTY_NAME2,
	      T3.ReporterId,
		  T2.NUMERATOR AS NUMERATOR_TEMP,
		  CASE WHEN NUMERATOR_TEMP NE . THEN NUMERATOR_TEMP
		       WHEN NUMERATOR_TEMP =.   THEN 0
			   ELSE . END AS NUMERATOR,
		  T4.DENOMINATOR,
		  T1.MONTH,
		  T1.QUARTER,
		  T1.YEAR,
		  CASE WHEN CALCULATED NUMERATOR EQ . THEN 1
		       ELSE 0 END AS IsSuppressed,
		  "This data is from DEA &DEA_VERSION." AS NOTES,
		  '' AS STRATIFICATION,
		  T1.DW
      FROM BASE AS T1 LEFT JOIN DEA32_FINAL_EXCEL_0 AS T2 ON 
	      T1.COUNTY_NAME2=T2.COUNTY_NAME2 AND
		  T1.DW=T2.DW AND 
		  T1.YEAR=T2.YEAR AND
		  T1.QUARTER=T2.QUARTER AND 
		  T1.MONTH=T2.MONTH LEFT JOIN DEA32_FINAL_EXCEL_0 AS T3 ON
	      T1.COUNTY_NAME2=T3.COUNTY_NAME2 LEFT JOIN DEA32_FINAL_EXCEL_0 AS T4 ON
	      T1.COUNTY_NAME2=T4.COUNTY_NAME2 AND
		  T1.YEAR=T4.YEAR

      ORDER BY MEASUREID,
			   REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;

PROC FREQ DATA=DEA32_FINAL_EXCEL_1;
RUN;

/*REORDER*/
PROC SQL;
   CREATE TABLE DEA32_FINAL_1 AS 
   SELECT DISTINCT 
		  ReporterId,
		  MEASUREID,
		  NUMERATOR,
		  DENOMINATOR,
		  MONTH,
		  QUARTER,
		  YEAR,
		  IsSuppressed,
		  NOTES,
		  STRATIFICATION
      FROM DEA32_FINAL_EXCEL_1
      ORDER BY MEASUREID,
			   REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;

/*DELETE QUARTER IF MONTH NOT REACH TO THE LAST MONTH OF THE QUARTER*/


DATA DEA32_FINAL_EXCEL_&DATE.(drop=numerator_temp);
length dw $50.;
SET DW30SW_FINAL_EXCEL_1
	DEA32_FINAL_EXCEL_1 
	;
IF YEAR=2023 AND QUARTER=1 THEN DELETE;
IF YEAR=2023 AND QUARTER=. AND MONTH=. THEN DELETE; 
RUN;

proc freq data=DEA32_FINAL_EXCEL_&DATE.;
run;

DATA DEA32_FINAL_&DATE.;
SET DEA32_FINAL_1;
IF YEAR=2023 AND QUARTER=1 THEN DELETE;
IF YEAR=2023 AND QUARTER=. AND MONTH=. THEN DELETE;
RUN;

PROC FREQ DATA=DEA32_FINAL_EXCEL_&DATE.;
RUN;