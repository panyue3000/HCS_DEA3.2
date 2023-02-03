

/*test*/
data dea_5_fiscal;
set dea_5;

fiscal_date=intnx('month', mdy(month_record_vin,01,year_record_vin), 6);

format fiscal_date yymms7.;

run;

proc freq data=dea_5_fiscal;
table name dea_reg_num;
run;


/**************************************fiscal YEAR overall**********************************/

PROC SQL;
   CREATE TABLE DEA_Y_fiscal_0 AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  year(fiscal_date) AS YEAR,
		  "3.2" as measureid, 
/*		  MONTH_RECORD_VIN,*/
/*		  . AS MONTH,*/
          /* SUM_of_COUNT */
/*            (SUM(t1.COUNT)) FORMAT=BEST32. AS SUM_CT,*/
			count (distinct dea_reg_num) as sum_ct
/*			count (distinct address_1) as count_address_1,*/
/*			count (distinct dea_reg_num) as count_dea_reg_num*/
      FROM DEA_5_fiscal t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               calculated YEAR 
/*			   T1.MONTH_RECORD_VIN*/
;
QUIT;

proc freq data=DEA_Y_fiscal_0;
tables reporterid*year;
run;


/**************************************fiscal YEAR by dw**********************************/
PROC SQL;
   CREATE TABLE DEA_FY_0 AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  year(t1.fiscal_date) AS YEAR,
  		    t1.dw,
		    t1.dw_num,
			t1.dea_reg_num
/*			count (distinct address_1) as count_address_1,*/
/*			count (distinct dea_reg_num) as count_dea_reg_num*/
      FROM DEA_5_fiscal t1
      order BY t1.reporterid,
			   calculated year,
			   t1.dea_reg_num, 
			   t1.dw_num desc
/*			   T1.MONTH_RECORD_VIN*/
;
QUIT;

data DEA_FY_1;
set DEA_FY_0;
by reporterid year dea_reg_num descending dw_num;
if first.dea_reg_num;
run;


PROC SQL;
   CREATE TABLE DEA_DW30_SW_Y_fiscal AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  t1.year,
		  CASE WHEN t1.DW='DW-30' THEN '3.2.30' 
		  	   WHEN t1.DW='DW-100' THEN '3.2.100'
			   WHEN t1.DW='DW-275' THEN '3.2.275' 
			   ELSE 'MISSING'
				END AS MEASUREID,

/*		  MONTH_RECORD_VIN,*/
/*		  . AS MONTH,*/
          /* SUM_of_COUNT */
/*            (SUM(t1.COUNT)) FORMAT=BEST32. AS SUM_CT,*/
			count (distinct dea_reg_num) as sum_ct
/*			count (distinct address_1) as count_address_1,*/
/*			count (distinct dea_reg_num) as count_dea_reg_num*/
      FROM DEA_FY_1 t1
      GROUP BY t1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR 
/*			   T1.MONTH_RECORD_VIN*/
;
QUIT;

proc freq data=DEA_DW30_SW_Y_fiscal;
tables reporterid*year*measureid;
run;



/*CREATE EXTRA DW=275 TO FILL THE MISSING USING DW=3.2*/

PROC SQL;
   CREATE TABLE DEA275_Y_fiscal AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  T1.YEAR,
		  "3.2.275" as measureid, 
		  T2.sum_ct
      FROM DEA_Y_fiscal_0 t1 LEFT JOIN DEA_DW30_SW_Y_fiscal(WHERE=(measureid = ("3.2.275"))) T2 ON 
	      T1.STATE=T2.STATE AND
		  T1.reporterid=T2.reporterid AND
		  T1.YEAR=T2.YEAR
;
QUIT;



/*COMBINE ALL MEASUREID*/
DATA DEA_Y_fiscal;
length measureid $20;
SET DEA_Y_fiscal_0
	DEA_DW30_SW_Y_fiscal(WHERE=(measureid NE ("3.2.275"))) 
    DEA275_Y_fiscal
;
RUN;
PROC FREQ DATA=DEA_Y_fiscal;
RUN;





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
		  MEASUREID,
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
      ORDER BY MEASUREID,
			   REPORTERID,
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

/*there were no one in the dataset with a waiver at that level?  If so, we should recode to zero. */
if NUMERATOR=. then numerator=0;

/*0 remove year 2023 if we are still in 2022*/
IF YEAR=2023 THEN DELETE;

/*1.)	for the Fiscal year we need to put the year in a 2 year format: */
if Year eq 2023 then year=20222023;
if Year eq 2022 then year=20212022;
if Year eq 2021 then year=20202021;
if Year eq 2020 then year=20192020;
if Year eq 2019 then year=20182019;
if Year eq 2018 then year=20172018;

/*2.)	RTI does not recognize our additional areas, so for RTI we need to skip those recordids*/
if reporterid in ('0368','0369','0370','0371','0372','0373') then delete;
/*3.)	RTI has decided that we should not pass population denominators since that is a new measure itself so;*/
Denominator=.;


RUN;





proc freq data=DEA32_FINAL_fiscal_&DATE.;
tables year*measureid;
run;

data DEA32_FINAL_comb_fiscal_&DATE.;
set DEA32_FINAL_fiscal_&DATE. DEA32_FINAL_&DATE.;
run;


/*EXPORT */

%csv_export(DEA32_FINAL_fiscal_&DATE.);

%csv_export(DEA32_FINAL_comb_fiscal_&DATE.);
