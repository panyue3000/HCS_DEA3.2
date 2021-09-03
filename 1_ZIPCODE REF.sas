/*ZIPCODE FROM BOX FOLDER*/
LIBNAME ZIP "C:\USERS\PANYUE\BOX\1 HEALING COMMUNITIES\DATA_NYS\DEA ANALYSIS";
RUN;

LIBNAME MAP 'C:\Users\panyue\Box\Yue Pan from old laptop 2015\DR FEASTER\Healing Communities\2.14.2 IQVIA';

LIBNAME POP 'C:\Users\panyue\Box\Yue Pan from old laptop 2015\DR FEASTER\Healing Communities\HCS Denominator';

libname prod 'C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\Christmas Eve\Ongoing Production';

libname dan 'C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\Christmas Eve\Ongoing Production';

libname dea 'C:\Users\panyue\Box\Yue Pan from old laptop 2015\DR FEASTER\Healing Communities\3.2 DEA';

/*libname layla 'C:\Users\panyue\Box\Yue Pan from old laptop 2015\DR FEASTER\Healing Communities\HCS Denominator\Layla';*/
libname partial "C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\Denominators\Layla";
libname wonder "C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\Denominators\CDC\Output Data";


/*************************STEP1. ADD CORRECT COUNTY TO ZIP CODE REFERENCE TABLE*/
DATA ZIP_0;
SET ZIP.New_York_State_ZIP;
LENGTH COUNTY_NAME2 $50.;

IF ZIP_CODE IN (
14604
14605
14606
14607
14608
14609
14610
14611
14612
14613
14614
14615
14616
14619
14620
14621
14626
14627
14638
14639
14642
14643
14644
14646
14647
14649
14650
14651
14652
14694
) THEN COUNTY_NAME2='Rochester';

ELSE IF ZIP_CODE IN (
14201
14202
14203
14204
14205
14206
14207
14208
14209
14210
14211
14212
14213
14214
14215
14216
14220
14222
14233
14240
14263
14264
14265
14267
14269
14270
14272
14273
14276
14280
) THEN COUNTY_NAME2='Buffalo';

ELSE IF ZIP_CODE IN (
00501
00544
11713
11715
11719
11720
11727
11733
11738
11742
11755
11763
11764
11766
11772
11776
11770
11777
11778
11779
11782
11784
11786
11789
11790
11794
11934
11940
11941
11949
11950
11951
11953
11955
11961
11967
11973
11980

) THEN COUNTY_NAME2='Brookhaven';

ELSE COUNTY_NAME2=COUNTY_NAME;

IF COUNTY_NAME2 IN 
('Broome',
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

)

;RUN;


PROC  FREQ DATA=ZIP_0;
TABLES County_Name2;
RUN;


DATA ZIP_1;
SET ZIP_0;
ZIP_CODE2=put(ZIP_CODE,5.);
RUN;


/*TRY USE UNIQUE ZIPCODE MAP TO COUNTY*/
PROC SORT DATA=ZIP_1;
BY ZIP_CODE2;
RUN;

DATA ZIP_2;
SET ZIP_1;
BY ZIP_CODE2;
IF FIRST.ZIP_CODE2;
RUN;


/*CHECK ZIPCODE DUPLICATES*/
PROC FREQ DATA=ZIP_1 ;
TABLES ZIP_CODE2 /OUT=ZIP_1_DUP;
RUN;



/*05052020 DAN UPDATE FOR ADDITIONAL ZIPCODE CHECK */
/*C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\Data and Documentation\Zip Code Info\RTIs HCS Community by Zipcode_Draft v1-0_04-20-2020_WIth Dans Annotations*/

DATA ZIP_CHECK_1;
infile cards delimiter='09'x;
INPUT ZIP $5. COUNTY : $20. IND: $3.;
DATALINES;
10940	Orange	YES
10940	Sullivan	No
12414	Greene	Yes
12414	Ulster	No
12428	Sullivan	NO
12428	Ulster	YES
12458	Sullivan	No
12458	Ulster	YES
12463	Greene	YES
12463	Ulster	NO
12477	Greene	No
12477	Ulster	YES
12480	Greene	YES
12480	Ulster	No
12495	Greene	No
12495	Ulster	Yes
12542	Orange	NO
12542	Ulster	Yes
12566	Orange	NO
12566	Sullivan	NO
12566	Ulster	Yes
12586	Orange	YES
12586	Ulster	NO
12589	Orange	No
12589	Ulster	Yes
12721	Orange	NO
12721	Sullivan	YES
12725	Sullivan	No
12725	Ulster	Yes
12729	Orange	YES
12729	Sullivan	NO
12740	Sullivan	NO
12740	Ulster	Yes
12758	Sullivan	YES
12758	Ulster	No
12763	Sullivan	YES
12763	Ulster	No
12780	Orange	YES
12780	Sullivan	No
13045	Cayuga	No
13045	Cortland	Yes
13803	Broome	NO
13803	Cortland	Yes
13835	Broome	No
13835	Cortland	No

;
RUN;


/*replace zipcode*/
PROC SQL;
   CREATE TABLE ZIP_3 AS 
   SELECT DISTINCT 
		  t1.*, 
          t2.county,
		  T2.ind
      FROM ZIP_2 t1
           LEFT JOIN ZIP_CHECK_1(where=(ind in ('YES', 'yes', 'Yes'))) t2 ON T1.zip_code2 = t2.zip

;
QUIT;

/*CHECK*/
PROC FREQ DATA=ZIP_3;
TABLES IND;
RUN;

DATA ZIP;
SET ZIP_3;
IF COUNTY NE '' THEN COUNTY_NAME2=COUNTY;
RUN;



DATA ZIP_FILTER (KEEP=COUNTY ZIP);
SET ZIP(DROP=COUNTY);
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
RENAME COUNTY_NAME2=COUNTY;
RENAME ZIP_CODE2=ZIP;
RUN;

PROC FREQ DATA=ZIP_FILTER;
RUN;

/*PROC SORT DATA=ZIP NODUPKEY DUPOUT=ZIPDUP;*/
/*BY ZIP_CODE2;*/
/*RUN;*/


proc sql;
create table d as
select ZIP_CODE2 from ZIP
group by ZIP_CODE2
having count(ZIP_CODE2) >= 2
;
quit;

