

PROC FREQ DATA=partial.PARTIAL_POPULATIONS_FULL_2018;
TABLES YEAR*COUNTY county group;
RUN;

/*sum pop > 18*/
PROC SQL;
   CREATE TABLE POPEST_LAYLA_0 AS 
   SELECT DISTINCT 
		  *,
		  sum(sumest) as pop18
      FROM partial.PARTIAL_POPULATIONS_FULL_2018 (where=((race="all_races") and group not in ("NA", "Female 0-4", "Female 5-9", "Female 10-14", "Female 15-17", 
																		"Male 0-4", "Male 5-9", "Male 10-14", "Male 15-17")))
	  group by county,
	  	       year
      ORDER BY COUNTY,
		  YEAR,
		  group,
		  POP
;
QUIT;

PROC SQL;
   CREATE TABLE POPEST_LAYLA_1 AS 
   SELECT DISTINCT 
		  COUNTY,
		  YEAR,
		  pop18 as pop
      FROM POPEST_LAYLA_0
      ORDER BY COUNTY,
		  YEAR,
		  POP
;
QUIT;

DATA POPEST_2019;
SET POPEST_LAYLA_1;
YEAR=YEAR+1;
IF YEAR NE 2019 THEN DELETE;
RUN;

DATA POPEST_2020;
SET POPEST_LAYLA_1;
YEAR=YEAR+2;
IF YEAR NE 2020 THEN DELETE;
RUN;

/*ADD POP FROM WONDER*/

DATA WONDER_2020;
SET WONDER.popge18_county;
YEAR=YEAR+1;
IF YEAR NE 2020 THEN DELETE;
RUN;


DATA POPEST_0;
SET POPEST_LAYLA_1 POPEST_2019 POPEST_2020 
    WONDER.popge18_county(RENAME=(SUM_POP=POP)) /*UP TO 2019*/
	WONDER_2020(RENAME=(SUM_POP=POP)) ;
;
RUN;




/***********************************************************************************************************************/


/*From Dan 05142020 we would need to subtract the partial from the full to get the outer area*/
/*(ERIE (Buffalo), Monroe(Rochester) and Suffolk (Brookhaven Township)*/
PROC SQL;
   CREATE TABLE POPEST_1 AS 
   SELECT DISTINCT 
		  t1.COUNTY,
		  t1.YEAR,
		  t1.pop,
		  case when t1.county="Suffolk" then t2.pop 
		       when t1.county="Monroe" then t3.pop 
		       when t1.county="Erie" then t4.pop 
			   else 0	end as poppart,

		  t1.pop - calculated poppart as popnew,
		  t5.ReporterId
      FROM POPEST_0 AS T1 LEFT JOIN POPEST_0(WHERE=(COUNTY IN ("Brookhaven"))) as t2 on t1.year=t2.year
	   					  LEFT JOIN POPEST_0(WHERE=(COUNTY IN ("Rochester"))) as t3 on t1.year=t3.year
	   				      LEFT JOIN POPEST_0(WHERE=(COUNTY IN ("Buffalo"))) as t4 on t1.year=t4.year
						  LEFT JOIN MAP.REPORTER_LIST t5 ON (propcase(t1.COUNTY) = propcase(t5.county)) 
	  ORDER BY t1.COUNTY,
		       t2.YEAR
;
QUIT;


/*CREATE POPULATION FOR FULL COUNTIES*/
PROC SQL;
   CREATE TABLE POPEST_2 (WHERE=(ReporterId IN ('0371', '0372', '0373'))) AS 
   SELECT DISTINCT 
		  COUNTY,
		  YEAR,
		  pop AS POPNEW,
		  ReporterId,
		  case when county="Suffolk" then '0370' 
		       when county="Monroe" then '0369' 
		       when county="Erie" then '0368'
			   ELSE REPORTERID END AS REPORTERID_NEW,
		  case when county="Suffolk" then "Suffolk-FULL" 
		       when county="Monroe" then "Monroe-FULL"  
		       when county="Erie" then "Erie-FULL" 
			   ELSE county END AS county_NEW

      FROM POPEST_1
      ORDER BY COUNTY,
		  YEAR
;
QUIT;

DATA POPEST_3;
SET POPEST_2 (KEEP=county_NEW  YEAR POPNEW REPORTERID_NEW);
RENAME REPORTERID_NEW=REPORTERID;
RENAME COUNTY_NEW=county;
RUN;


/*COMBNIE BOTH*/
DATA POPEST (RENAME=(POPNEW=POP));
LENGTH COUNTY $ 50;
FORMAT COUNTY $50.;
SET POPEST_3 POPEST_1;
DROP POP;
RUN;