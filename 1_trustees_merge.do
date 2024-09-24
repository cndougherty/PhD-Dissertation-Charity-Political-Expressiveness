
// package installations
ssc install group_id, replace
ssc install freqindex, replace
ssc install matchit, replace

// clear the results window
cls

// dissertation papers - paper 1, foundations
// this .do file creates a merged set of all registered charity trustees from years 2000 through 2017
// Christopher Dougherty
// Last updated: May 19, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255
set scrollbufsize 2048000 
set rmsg on

// set the working directory

cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/"

// generate variables for appending and matching
	generate bn = ""
	label variable bn "BN/Registration Number"
	
	generate fpe = ""
	label variable fpe "Fiscal Period End"
	
	generate FISYR_NUM = .

	generate form_id = .
	label variable form_id "Form ID"
	
	generate count = .
		
	generate name_full = ""
	label variable name_full "Full Name"
	
	generate name_last = ""
	label variable name_last "Last Name"
			
	generate name_first = ""
	label variable name_first "First Name"
			
	generate name_middle = ""
	label variable name_middle "Middle Name"
			
	generate name_initials = ""
	label variable name_initials "Initials"
			
	generate position = ""
	label variable position "Position"
	
	generate armslength = ""
	label variable armslength "At Arm's Length?"
			
	generate date_appointed = ""
	label variable date_appointed "Date Appointed"
	
	generate atyearend = ""
	label variable atyearend "At Year End?"
			
	generate date_ceased = ""
	label variable date_ceased "Date Ceased"
	
	generate trustee = 1
	label variable trustee "Charity Trustee"
	
// save the data file
save trustees2000to2017.dta, replace

// IMPORT
// set up the macro for filenames
global list_filenames `" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2000.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2001.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2002.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2003.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2004.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2005.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2006.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2007.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2008.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2009.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2010.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2011.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2012.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2013.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2014.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2015.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2016.csv" "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1235Trustees/Trustee2017.csv" "'

// import and save annual trustee files
foreach scenario of global list_filenames{
	display `"`scenario'"'
	import delimited `"`scenario'"', delimiter(comma) clear
	
	// check if each possible variable exists, rename and label if it does
	capture confirm variable bnregistrationnumber 
	if (_rc == 0){
		rename bnregistrationnumber bn
	}
	
	capture confirm variable bn
	if (_rc == 0){
		label variable bn "BN/Registration Number"
	}
	
	capture confirm variable fiscalperiodend
	if (_rc == 0){
		rename fiscalperiodend fpe
	}
	
	capture confirm variable fpe
	if (_rc == 0){
		label variable fpe "Fiscal Period End"
	}
	
	// add fiscal year
	gen FISYR_NUM = substr(fpe,1,4)
	destring FISYR_NUM, replace
	order FISYR_NUM, after(fpe)
	
	capture confirm variable v3
	if (_rc == 0){
		rename v3 count
	}

	capture confirm variable formid
	if (_rc == 0){
			rename formid form_id
			label variable form_id "Form ID"
	}
	
	capture confirm variable fullname
	if (_rc == 0){
		rename fullname name_full
		label variable name_full "Full Name"
	}
	
	capture confirm position
	if (_rc == 0){
		label variable position "Position"
	}
	
	capture confirm variable lastname
	if (_rc == 0){
		rename lastname name_last
		label variable name_last "Last Name"
	}

	capture confirm variable firstname
	if (_rc == 0){
		rename firstname name_first
		label variable name_first "First Name"
	}
	
	capture confirm variable middlename
	if (_rc == 0){	
		rename middlename name_middle
		label variable name_middle "Middle Name"
	}
	
	capture confirm variable initial
	if (_rc == 0){
		rename initial name_initials
		label variable name_initials "Initials"
	}

	capture confirm variable atarmslength
	if (_rc == 0){
		rename atarmslength armslength
		label variable armslength "At Arm's Length?"
	}

	capture confirm variable atyearend
	if (_rc == 0){
		label variable atyearend "At Year End?"
	}
	
	capture confirm variable appointeddate
	if (_rc == 0){
		rename appointeddate date_appointed
		label variable date_appointed "Date Appointed"
	}
	
	capture confirm variable ceaseddate
	if (_rc == 0){
		rename ceaseddate date_ceased
		label variable date_ceased "Date Ceased"
	}
	
	// append the annual file to the panel data set
	append using trustees2000to2017, force
	save trustees2000to2017, replace
}

// open the data file
use trustees2000to2017.dta, clear

// re-order variables
	order bn, first
	order fpe, after(bn)
	order FISYR_NUM, after(fpe)
	order form_id, after(FISYR_NUM)
	order count, after(form_id)
	order name_full, after(count)
	order name_last, after(name_full)
	order name_first, after(name_last)
	order name_middle, after(name_first)
	order name_initials, after(name_middle)
	order position, after(name_initials)
	order armslength, after(position)
	order date_appointed, after(armslength)
	order date_ceased, after(date_appointed)
	order atyearend, after(date_ceased)

// CLEAN NONSTRING VARIABLES
// delete empty variables created during merged
drop v10 v11

// convert binary dummy variables to proper dummy variables
	label define yesno ///
		1 "Yes" ///
		0 "No"
	
	replace armslength = "1" ///
		if armslength == "Y"
	replace armslength = "0" ///
		if armslength == "N"
	destring armslength, replace
	label values armslength yesno
	
	replace atyearend = "1" ///
		if atyearend == "Y"
	replace atyearend = "0" ///
		if atyearend == "N"
	destring atyearend, replace
	label values atyearend yesno
	
// convert dates to dates
	// fpe
	// trim times
	gen fpe_temp = substr(fpe, 1, strpos(fpe, " ") - 1)
	replace fpe_temp = fpe if wordcount(fpe) == 1
	replace fpe_temp = trim(fpe_temp)
	
	// convert from string to date
	gen double fpe_temp2 = date(fpe_temp, "YMD")
	
	// replace the original variable and drop the temporary one
	drop fpe
	drop fpe_temp
	rename fpe_temp2 fpe
	label variable fpe "Fiscal Period End"
	order fpe, after(bn)
	format fpe %td
	
	// date_appointed
	// trim times
	gen date_appointed_temp = substr(date_appointed, 1, strpos(date_appointed, " ") - 1)
	replace date_appointed_temp = date_appointed if wordcount(date_appointed) == 1
	replace date_appointed_temp = trim(date_appointed_temp)
	
	// convert from string to date
	gen double date_appointed_temp2 = date(date_appointed_temp, "YMD")
	
	// replace the original variable and drop the temporary one
	drop date_appointed
	drop date_appointed_temp
	rename date_appointed_temp2 date_appointed
	label variable date_appointed "Date Appointed"
	format date_appointed %td
	
	// date_ceased
	// trim times
	gen date_ceased_temp = substr(date_ceased, 1, strpos(date_ceased, " ") - 1)
	replace date_ceased_temp = date_ceased if wordcount(date_ceased) == 1
	replace date_ceased_temp = trim(date_ceased_temp)
	
	// convert from string to date
	gen double date_ceased_temp2 = date(date_ceased_temp, "YMD")
	
	// replace the original variable and drop the temporary one
	drop date_ceased
	drop date_ceased_temp
	rename date_ceased_temp2 date_ceased
	label variable date_ceased "Date Ceased"
	format date_ceased %td

// convert bn to a numeric variable
capture confirm string variable bn
	if !_rc {
		replace bn = subinstr(bn,"RR",".",.)
		destring bn, replace
		format bn %15.4f
					
		// destringed bn should be nine digits plus four digits, if it's shorter then it is (i)ncomplete
		replace bn = .i if bn < 100000000
	}	
	
// re-sort the observations by year and bn
sort FISYR_NUM bn
	
// save the data file
save trustees2000to2017.dta, replace

// describe the data set
describe

// CLEAN STRING VARIABLES

// turn name byte variables into strings
	tostring name_middle, replace force
	tostring name_initials, replace force

// basic character cleaning
	// fix surnames where a comma has been entered instead of an apostrophe
	replace name_last = subinstr(name_last, "D,", "D'", .)
	replace name_last = subinstr(name_last, "L,", "L'", .)
	replace name_last = subinstr(name_last, "O,", "O'", .)
	replace name_full = subinstr(name_full, "D,", "D'", .)
	replace name_full = subinstr(name_full, "L,", "L'", .)
	replace name_full = subinstr(name_full, "O,", "O'", .)
	
	// insert an extra space between commas and the next character to make cleaning words easier
	replace name_last = subinstr(name_last, ",", ", ", .)
	replace name_first = subinstr(name_first, ",", ", ", .)
	replace name_full = subinstr(name_full, ",", ", ", .)

	// remove leading trailing and extra internal spaces from string variables
	// remove accents
	// make upper case
	// remove periods
	ds, has(type string)
	foreach var of varlist `r(varlist)' {
		display `"`var'"'
		display "trim spaces    " _continue
		replace `var' = stritrim(strtrim(ustrtrim(strupper(`var'))))
		display "special chars  " _continue
		replace `var' = upper(ustrto(ustrnormalize(`var', "nfd"), "ascii", 2))
		display "remove periods " _continue
		replace `var' = subinstr(`var', ".", "", .)
	}
	
	// remove any remaining spaces after hyphens and apostrophes
	ds, has(type string)
	foreach var of varlist `r(varlist)' {
		display `"`var'"'
		display "trim space after apostrophe " _continue
		replace `var' = subinstr(`var', "' ", "'", .)
		display "trim space after hyphens    " _continue
		replace `var' = subinstr(`var', "- ", "-", .)
	}	
	
// clarify specific ambiguous words
	// SR for SISTER honourific and for SENIOR postnominal
	foreach var in name_last name_first name_full{
		display `"`var'"'
		replace `var' = (subinword(`var'), "SR", "SISTER", 1) ///
			if wordcount(`var') > 1
	}
	
	// BISHOP for honourific and surname
	foreach var in name_last name_first name_full{
		display `"`var'"'
		replace `var' = (subinword(`var'), "BISHOP", "BSHP", 1) ///
			if wordcount(`var')  > 1
	}
	
	// remove commas before JR for junior and SR for senior
	foreach var in name_last name_first name_full{
		display `"`var'"'
		display "junior" _continue
		replace `var' = (subinstr(`var'), ", JR", " JR", 1) ///
			if wordcount(`var') > 1
		display "senior" _continue
		replace `var' = (subinstr(`var'), ", SR", " SR", 1) ///
			if wordcount(`var') > 1
	}
	
// CLEAN NAMES

// set up the macro for postnominals
// list of postnominals is in reverse order of precedence as lower precedence appear last
// list of postnominals includes national honours, academic degrees, academic societies, professional qualifications, religious orders, and ham radio callsigns
global list_postnominals VE4YQ VE4XQ VE4XN VE4SY VE4SR VE4KT VE4KQ VE4GS VE4DG VE4DC VE4BAE VE4AFC WSHS VG SSST SFA PTRE PBYM IBUM FDLS CSSR OFM SV STM SSS SSCJ SSA SNJM SJ SGM SCO SC SBC RSCJ OSU OP OMI "OFM CONV" OCD OC MRE MIC MAATO FCA ELDER DVM DMI DMD DM CSC CSB CR CONV CND CJM AOM AMJ "P ENG" ENG GNC "DIP SPORT MED" "C PSYCH" TEP STRUCENG SLS RSW RSE RRT RRM RPSGT RPP RPM RPH RPF RPBIO RP ROHT ROH RO RN RMT RMC RKIN RISIA RGD RET RDT RDH RD RCIC QMED QARB PTECH PRP PPHYS PMP PLOG PHN PGEOPH PGEOL PGEO PENG PCP PAG OLS OCT OCELT OBHF NP MRT MMP MLT MLS ME LPN LET ISP ICDD GSI GSC GISP FEA FCIP EP EIT DD CTM CTC CSC CRST CRSP CRM CPMHN CPHI CPA CMGR CMED CMC CMA CLS CIRP CIM CIC CIA CHRP CHE CGA CFP CFF CFA CET CET CDT CDP CDIR CDC CCS CCPE CCPA CCP CCLP CCHEM CCE CBV CBHF CBET CBET CARB CAPM CAMA CAE CA "C TECH" BCLS ALS ACCDIR ASCT RMC RCA OAA MSRC MRAIC MIAM MCIP MCIC MCFP MAIBC LRHSC FRSC FRSA FRHSC FRCSC FRCPC FRCNA FRCGS FRCD FRCCO FRCA FRAIC FONA FIAM FEIC FEC FCSI FCMS FCIS FCIP FCIM FCIC FCGMA FCFP FCASI FCAMPT FCAHS FCAE DRCPSC DIPSPORTMED DCAPM CSLA CPSYCH CPMHN CCFP BCSLA ARIDO ARCT ACIS ACIC ESQ CS CR QC KC JA CJ CJA CJC BMUS BMASC BBA BCOM BACYC BSW BSOCSCI BSCN BSC BMGMT BCS BMATH BAHONS BFA BA LLL LLB "LL B" BED BCL BENG BASC MDIV MMM MMUS MPA MFIN MACC MBA MES MPP MJ MSCI MSC MRES MMATH MM MFA MENG MED MASC LLM PSYD PHARMD OD JD DVM DSW DC DNP DDS DMIN MD SJD LLD JSD ENGD EDD DSOCSCI DLITT DD DBA PHD "PH D" MHA MLA MNA MPP MP ECA ECNS PC QPO KPO QHC KHC QHN QHNS KHN KHNS QHDS KHDS QHP KHP QHS KHS ADEC ADC CD RVM MSM MB MMV CSM MSC SC SMV OY OTNO ONWT ONU SVM OMC ONL ONS ONB OM OPEI AOE OBC OONT SOM CQ OQ GOQ MVO MOM MMM LVO OOM OMM CVO COM CMM OC OM CV VC

// clean out postnominals
foreach scenario of global list_postnominals{
	display `"`scenario'"'
	foreach var in name_last name_first name_full{
		display `"`var'"'
		replace `var' = (subinword(`var'), "`scenario'", "", 1) ///
			if wordcount(`var')  > 1
		replace `var' = (subinword(`var'), "`scenario',", "", 1) ///
			if wordcount(`var')  > 1
	}
}

// set up the macro for honourifics
global list_honourifics THE MOST RIGHT RT ARCHBISHOP ARCHBP ASSISTANT ASSOCIATE ASSOC BSHP BR BROTHER CHERCHEUSE COORDONATRICE DEACON DOCTEUR DOCTOR DR EVANGELIST FATHER FRERE FR HONORABLE HONOURABLE "L'HONORABLE" HON MADAME MAITRE MONSIEUR PROFESSOR PROFESSEUR PROF REVEREND REV "(REV)" MONSIGNOR MSGR MRS MR MS MISS MME PASTOR PERE PERER PTR RABBI RETIRED RETRAITE RETRAITEE SISTER SOEUR 

// clean out honourifics
foreach scenario of global list_honourifics{
	display `"`scenario'"'
	foreach var in name_last name_first name_full{
		display `"`var'"'
		replace `var' = (subinword(`var'), "`scenario'", "", 1) ///
			if wordcount(`var')  > 1
		replace `var' = (subinword(`var'), "`scenario',", "", 1) ///
			if wordcount(`var')  > 1
	}
}

// trim spaces and commas from the very end of name strings
foreach var in name_last name_first name_full{
	display `"`var'"'
	replace `var' = strrtrim(`var')
	replace `var' = substr(`var', 1, length(`var') - 1) ///
		if substr(`var', -1, 1) ==  ","
}

// generate destination variables for surnames and given names
	gen name_surname = ""
	gen name_given = ""
	
// generate name_edit variable 
// name_edit will be used to flag groups of names being cleaned in the current batch of functions
	gen name_edit = .

// 2003 onwards - separate variables for surnames and given names
	// some full names appear in the name_last variable
	replace name_edit = 0 ///
		if FISYR_NUM > 2002 ///
		& strmatch(name_last, "*,?*") ///
		& name_first == ""
	
	egen name_surname_temp = ends(name_last) ///
		if name_edit == 0 ///
		, punct(",") trim head
		
	egen name_given_temp = ends(name_last) ///
		if name_edit == 0 ///
		, punct(",") trim tail
	
	replace name_surname = name_surname_temp ///
		if name_edit == 0
		
	replace name_given = name_given_temp ///
		if name_edit == 0
	
	drop name_surname_temp ///
		name_given_temp
	
	// otherwise move name_last to name_surname and concatenate given names into name_given
	replace name_surname = name_last ///
		if FISYR_NUM > 2002 ///
		& name_edit == .
		
	replace name_given = name_first + " " + name_middle + " " + name_initials ///
		if FISYR_NUM > 2002 ///
		& name_edit == .
	
// 2000, 2001, 2002	- single name field
	// split names into one variable for surnames and one variable for given names	
	// 2000, 2001, 2002 use a single name field
	// deal with names that are entered in last, first format
	replace name_edit = 1 ///
		if FISYR_NUM < 2003 ///
		& strmatch(name_full, "*,?*")
	
	egen name_surname_temp = ends(name_full) ///
		if name_edit == 1 ///
		, punct(",") trim head
		
	egen name_given_temp = ends(name_full) ///
		if name_edit == 1 ///
		, punct(",") trim tail
	
	replace name_surname = name_surname_temp ///
		if name_edit == 1
		
	replace name_given = name_given_temp ///
		if name_edit == 1
	
	drop name_surname_temp ///
		name_given_temp
	
	// deal with names that are in first last format
	replace name_edit = 2 ///
		if FISYR_NUM < 2003 ///
		& name_edit != 1 
		
	replace name_surname = word(name_full, -1) ///
		if name_edit == 2
		
	gen name_given_temp = name_full ///
		if name_edit == 2
		
	replace name_given_temp = subinword(name_given_temp, name_surname, "", .) ///
		if name_edit == 2
		
	replace name_given = name_given_temp ///
		if name_edit == 2
	
	drop name_given_temp
	
// re-order variables and re-sort the observations
	order name_surname, after(count)
	order name_given, after(name_surname)
	sort FISYR_NUM bn name_surname
	
// remove leading trailing and extra internal spaces from string variables
	ds, has(type string)
	foreach var of varlist `r(varlist)' {
		display `"`var'"'
		replace `var' = stritrim(strtrim(ustrtrim(strupper(`var'))))
	}
	
// drop name_edit
	drop name_edit
	
// remove artifacts from cleaning functions
	// remove remaining commas
	replace name_surname = subinstr(name_surname, ","," ", . )
	replace name_given = subinstr(name_given, ","," ", . )
	
	// drop if name variables empty
	drop if name_surname == "" ///
		& name_given == ""
		
// concatenate names for matching
replace name_full = name_given + " " + name_surname
sort name_full FISYR_NUM
gen id = _n

// identify exactly matching names
group_id id, matchby(name_full)
	
// identify founders
	gen founder = 0
	replace founder = 1 if strmatch(position, "*FOUNDER*") ///
		| strmatch(position, "*FONDATRICE*") ///
		| strmatch(position, "*FONDATEUR*")
	

// merge in province and postal code from T3010 
	merge m:m 	bn FISYR_NUM ///
				using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/2017_to_2000_working.dta" ///
				, keepusing(province2 postal_code designation_code )

	// drop anything that is not matched to the T3010
	drop if _merge < 3
	
	// check number of remaining trustees
	tab2 FISYR_NUM province2 
	
// save the data file
save trustees2000to2017.dta, replace

// describe the data set
describe

// generate variables used in matching processes
gen pol_candidate 	= 0
gen pol_donor		= 0
gen pol_jurisdiction = .
gen pol_party		= .
gen pol_alignment	= .

// trim the data set to only the variables of interest
keep ///
	id ///
	bn ///
	designation_code ///
	FISYR_NUM ///
	name_surname ///
	name_given ///
	name_full ///
	province ///
	province2 ///
	postal_code ///
	pol_candidate ///
	pol_donor ///
	trustee ///
	position ///
	founder ///
	armslength ///
	pol_jurisdiction ///
	pol_party ///
	pol_alignment
	
order id ///
	bn ///
	designation_code ///
	FISYR_NUM ///
	name_surname ///
	name_given ///
	name_full ///
	province ///
	province2 ///
	postal_code ///
	pol_candidate ///
	pol_donor ///
	trustee ///
	position ///
	founder ///
	armslength ///
	pol_jurisdiction ///
	pol_party ///
	pol_alignment
	
format 	id %-010.0f
sort 	id

// save the data file
save trustees2000to2017.dta, replace

// generate a list of trustees of ONLY private foundations
keep if designation_code == 2

// save a list of ONLY private foundation trustees2000to2017
save trustees2000to2017-privatefoundations.dta, replace
