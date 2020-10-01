/*JOIN REPORTER ID*/
PROC SQL;
   CREATE TABLE DEA_4_1 AS 
   SELECT DISTINCT 
		  t1.*, 
          t2.ReporterId
      FROM DEA_4_0 t1
           LEFT JOIN MAP.REPORTER_LIST t2 ON T1.COUNTY_NAME2 = propcase(t2.County)
;
QUIT;


PROC SQL;
   CREATE TABLE DEA_4_2 AS 
   SELECT DISTINCT 
		  *, 
		  case when reporterid in ('0371' '0338') then "0368" 
		       when reporterid in ('0372' '0342') then "0369"  
		       when reporterid in ('0373' '0345') then "0370" 
			   ELSE reporterid END AS reporterid_NEW

      FROM DEA_4_1 (WHERE=(REPORTERID IN ('0371' '0338' '0372' '0342' '0373' '0345')))
;
QUIT;

DATA DEA_4_3 (DROP=REPORTERID_NEW);
SET DEA_4_2 (DROP=REPORTERID );
REPORTERID=REPORTERID_NEW;
RUN;

DATA DEA_5;
SET DEA_4_3 DEA_4_1;
RUN;