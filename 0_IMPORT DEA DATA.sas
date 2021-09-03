
data redivis_export;
     length record_vintage $ 50;
/* 
	SPECIFY THE PATH TO YOUR DOWNLOADED CSV BELOW:
*/
infile 'C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.2 DEA\Import\DEA_Controlled_Substances_Act_Registrations.csv'  


delimiter = ',' MISSOVER DSD firstobs=2;

	informat dea_reg_num $50. ;
	informat business_activity_code $50. ;
	informat drug_schedules $50. ;
	informat expiration_date 32. ;
	informat name $50. ;
	informat additional_company_info $50. ;
	informat address_1 $50. ;
	informat address_2 $50. ;
	informat city $50. ;
	informat state $50. ;
	informat zip_code $50. ;
	informat busines_activity_sub_code $50. ;
	informat payment_indicator $50. ;
	informat activity $50. ;
	informat degree $50. ;
	informat state_license_number $50. ;
	informat state_cs_license_number $50. ;
	informat record_vintage $50. ;
	

	
input 
	dea_reg_num $
	business_activity_code $
	drug_schedules $
	expiration_date
	name $
	additional_company_info $
	address_1 $
	address_2 $
	city $
	state $
	zip_code $
	busines_activity_sub_code $
	payment_indicator $
	activity $
	degree $
	state_license_number $
	state_cs_license_number $
	record_vintage $
;

	label dea_reg_num='DEA Registration Number';
	label business_activity_code='Business Activity Code';
	label drug_schedules='Drug Schedules';
	label expiration_date='Expiration Date';
	label name='Name';
	label additional_company_info='Additional Company Information';
	label address_1='Address 1';
	label address_2='Address 2';
	label city='City';
	label state='State';
	label zip_code='Zipcode';
	label busines_activity_sub_code='Business Activity Sub Code';
	label payment_indicator='Payment Indicator';
	label activity='Activity';
	label degree='Degree';
	label state_license_number='State License Number';
	label state_cs_license_number='State CS License Number';
	label record_vintage='Record Vintage';



/*Dec3rd 2020 email from Dan*/
/*•	In order to assure that we are capturing all the activity 
	within a month through the new DOJ process, we will be pulling 
	the data on the 1st of the following month. This means that the
	12-1 file that was most recently sent should be used as the NOVEMBER 
	DEA data file. Going forward I will label the files with the month 
	name to avoid any confusion. */

PROC FORMAT;
	VALUE $record_vintagel
		"MA18001" = '2018-01'
		"MA18002" = '2018-02'
		"MA18003" = '2018-03'
		"MA18004" = '2018-04'
		"MA18005" = '2018-05'
		"MA18006" = '2018-06'
		"MA18007" = '2018-07'
		"MA18008" = '2018-08'
		"MA18009" = '2018-09'
		"MA18010" = '2018-10'
		"MA18011" = '2018-11'
		"MA18012" = '2018-12'
		"MA19001" = '2019-01'
		"MA19002" = '2019-02'
		"MA19003" = '2019-03'
		"MA19004" = '2019-04'
		"MA19005" = '2019-05'
		"MA19006" = '2019-06'
		"MA19007" = '2019-07'
		"MA19008" = '2019-08'
		"MA19009" = '2019-09'
		"MA19010" = '2019-10'
		"MA19011" = '2019-11'
		"MA19012" = '2019-12'
		"MA20001" = '2020-01'
		"MA20002" = '2020-02'
		"MA20003" = '2020-03'
		"MA20004" = '2020-04'
		"MA20005" = '2020-05'
		"MA20006" = '2020-06'
		"MA20007" = '2020-07'
		"MA20008" = '2020-08'
		"MA20009" = '2020-09'
		"MA20010" = '2020-10'
		"cs_active_20201201" = '2020-11'
		"cs_active_20210104" = '2020-12'
		"cs_active_20210201" = '2021-01'
		"cs_active_20210226" = '2021-02'
		"cs_active_20210331" = '2021-03'
		"cs_active_20210430" = '2021-04'
		"cs_active_20210531" = '2021-05'
		"cs_active_20210701" = '2021-06'
		"cs_active_20210730" = '2021-07'
		"cs_active_20210901" = '2021-08'
	;
	VALUE $dea_reg_numl
		"0" = 'Chemical Handlers of List 1 (Manufacturer / Distributor / Importer / Exporter)'
		"A" = 'Pharmacy / Hospital/Clinic / Practitioner / Teaching Institution'
		"B" = 'Pharmacy / Hospital/Clinic / Practitioner / Teaching Institution'
		"F" = 'Pharmacy / Hospital/Clinic / Practitioner / Teaching Institution'
		"G" = 'Pharmacy / Hospital/Clinic / Practitioner / Teaching Institution'
		"M" = 'Mid-Level Practitioner (the different approved subcategories of MLPs listed in Business Activity Sub Code)'
		"P" = 'Manufacturer / Distributor / Researcher / Analytical Lab / Importer / Exporter / Reverse Distributor / Narcotic Treatment Program'
		"R" = 'Manufacturer / Distributor / Researcher / Analytical Lab / Importer / Exporter / Reverse Distributor / Narcotic Treatment Program'
	;
	VALUE $business_activity_codel
		"0" = 'Chemical Handlers of List 1 (Manufacturer / Distributor / Importer / Exporter)'
		"A" = 'Pharmacy'
		"B" = 'Hospital/Clinic'
		"F" = 'Practiotioner'
		"G" = 'Teaching institution'
		"M" = ' Mid-Level Practitioner (the different approved subcategories of MLPs listed under business activity subcodes)'
		"P" = 'Manufacturer / Distributor / Researcher / Analytical Lab / Importer / Exporter / Reverse Distributor / Narcotic Treatment Program'
		"R" = 'Manufacturer / Distributor / Researcher / Analytical Lab / Importer / Exporter / Reverse Distributor / Narcotic Treatment Program'
	;
	VALUE $drug_schedulesl
		"1" = 'Schedule 1 Controlled Substances'
		"2" = 'Schedule 2 Narcotic Controlled Substances'
		"3" = 'Schedule 3 Narcotic Controlled Substances'
		"4" = 'Schedule 4 Controlled Substances'
		"5" = ' Schedule 5 Controlled Substances'
		"2N" = 'Schedule 2N Non-Narcotic Controlled Substances'
		"3N" = 'Schedule 3N Non-Narcotic Controlled Substances'
		"L1" = 'List 1 Chemicals'
	;
	VALUE $activityl
		"Active" = 'The registrant is authorized to handle controlled substances in the schedules listed'
		"Inactive" = 'The registrant is not authorized to handle controlled substances in any schedule'
	;	
RUN;
	

data redivis_export;
	retain dea_reg_num business_activity_code drug_schedules expiration_date name additional_company_info address_1 address_2 city state zip_code busines_activity_sub_code payment_indicator activity degree state_license_number state_cs_license_number record_vintage;
set redivis_export;
    

	format record_vintage record_vintagel. ;
	format activity activityl. ;
	format expiration_date BEST32. ;
	format drug_schedules drug_schedulesl. ;
	format business_activity_code business_activity_codel. ;
	format dea_reg_num dea_reg_numl. ;

RUN;
PROC CONTENTS data=redivis_export;
RUN;
QUIT;
	