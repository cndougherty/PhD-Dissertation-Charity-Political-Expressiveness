
// package installations
ssc install group_id, replace
ssc install freqindex, replace
ssc install matchit, replace

// clear the results window
cls

// dissertation papers - paper 1, foundations
// this .do file creates a merged set of all political party donors and candidates
// Christopher Dougherty
// Last updated: May 21, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255
set scrollbufsize 2048000 
set rmsg on

// set the working directory

cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Contributions/"

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
	
	generate trustee = 0
	label variable trustee "Charity Trustee"
	
	generate pol_jurisdiction = .
	label variable pol_jurisdiction "Political Jurisdiction"
	
	generate pol_party = .
	label variable pol_party "Political Party"
	
	generate pol_candidate = .
	label variable pol_candidate "Political Candidate"
	
	generate pol_donor = .
	label variable pol_donor "Political Donor"
	
	generate NPindex = .
	label variable NPindex "National Post Follow the Money Index Value"
	
	generate NPname_donor_full = ""
	label variable NPname_donor_full "Donor Full Name"
	
	generate NPpolitical_party = ""
	label variable NPpolitical_party "National Post Political Party"
	
	generate NPpolitical_entity = ""
	label variable NPpolitical_entity "National Post Political Entity"
	
	generate NPrecipient = ""
	label variable NPrecipient "National Post Recipient"
	
	generate NPregion = ""
	label variable NPregion "National Post Region"
	
	generate NPdonor_location = ""
	label variable NPdonor_location "National Post Donor Location"
	
	generate NPdonor_type = ""
	label variable NPdonor_type "National Post Donor Type"
	
	generate NPelectoral_event = ""
	label variable NPelectoral_event "National Post Electoral Event"
	
	generate NPyear = .
	label variable NPyear "Donation Calendar Year"
	
	generate NPdonation_amount = .
	label variable NPdonation_amount "Donation Amount, 2017CAD ,000s"
	
// save the data file
save politicaldonors2000to2017.dta, replace

// IMPORT NATIONAL POST FOLLOW THE MONEY POLITICAL DONOR DATA
// set up the macro for filenames
global list_filenames "1993-2003.csv 2004-2008.csv 2009-2011.csv 2012-2013.csv 2014-2015.csv 2016-2018.csv"

// import and save annual trustee files
foreach scenario of global list_filenames{
	display `"`scenario'"'
	import delimited `"`scenario'"', delimiter(comma) clear
	
	// check if each possible variable exists, rename and label if it does
	capture confirm variable Index
	if (_rc == 0){
		rename Index NPindex
	}
	
	capture confirm variable index
	if (_rc == 0){
		rename index NPindex
	}
	
	capture confirm variable Donor
	if (_rc == 0){
		rename Donor NPname_donor_full
	}
	
	capture confirm variable donor
	if (_rc == 0){
		rename donor NPname_donor_full
	}
	
	capture confirm variable PoliticalParty
	if (_rc == 0){
		rename PoliticalParty NPpolitical_party
	}
	
	capture confirm variable politicalparty
	if (_rc == 0){
		rename politicalparty NPpolitical_party
	}
	
	capture confirm variable PoliticalEntity
	if (_rc == 0){
		rename PoliticalEntity NPpolitical_entity
	}
	
	capture confirm variable politicalentity
	if (_rc == 0){
		rename politicalentity NPpolitical_entity
	}
	
	capture confirm variable Recipient
	if (_rc == 0){
		rename Recipient NPrecipient
	}
	
	capture confirm variable recipient
	if (_rc == 0){
		rename recipient NPrecipient
	}
	
	capture confirm variable Region
	if (_rc == 0){
		rename Region NPregion
	}
	
	capture confirm variable region
	if (_rc == 0){
		rename region NPregion
	}
	
	capture confirm variable DonorLocation
	if (_rc == 0){
		rename DonorLocation NPdonor_location
	}
	
	capture confirm variable donorlocation
	if (_rc == 0){
		rename donorlocation NPdonor_location
	}
	
	capture confirm variable DonorType
	if (_rc == 0){
		rename DonorType NPdonor_type
	}
	
	capture confirm variable donortype
	if (_rc == 0){
		rename donortype NPdonor_type
	}
	
	capture confirm variable ElectoralEvent
	if (_rc == 0){
		rename ElectoralEvent NPelectoral_event
	}
	
	capture confirm variable electoralevent
	if (_rc == 0){
		rename electoralevent NPelectoral_event
	}
	
	capture confirm variable Year
	if (_rc == 0){
		rename Year NPyear
	}
	
	capture confirm variable year
	if (_rc == 0){
		rename year NPyear
	}
	
	capture confirm string variable NPyear
	if !_rc {
		replace NPyear = (subinstr(NPyear), "N/A", "", 1)
		destring NPyear, replace
	}
	
	capture confirm variable DonationAmount
	if (_rc == 0){
		rename DonationAmount NPdonation_amount
	}
	
	capture confirm variable donationamount
	if (_rc == 0){
		rename donationamount NPdonation_amount
	}
	
	// append the annual short panel file to the full panel data set
	append using politicaldonors2000to2017, force
	save politicaldonors2000to2017, replace
}

// open the data file
use politicaldonors2000to2017.dta, clear

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
	order trustee, after(atyearend)
	order pol_jurisdiction, after(trustee)
	order pol_party, after(pol_jurisdiction)
	order pol_candidate, after(pol_party)
	order pol_donor, after(pol_candidate)
	order NPindex, after(pol_donor)
	order NPname_donor_full, after(NPindex)
	order NPpolitical_party, after(NPname_donor_full)
	order NPpolitical_entity, after(NPpolitical_party)
	order NPrecipient, after(NPpolitical_entity)
	order NPregion, after(NPrecipient)
	order NPdonor_location, after(NPregion)
	order NPdonor_type, after(NPdonor_location)
	order NPelectoral_event, after(NPdonor_type)
	order NPyear, after(NPelectoral_event)
	order NPdonation_amount, after(NPelectoral_event)

// CLEAN NONSTRING VARIABLES

// convert binary dummy variables to proper dummy variables
	label define yesno ///
		1 "Yes" ///
		0 "No"
	
	label values pol_donor yesno
	label values trustee yesno
	label values pol_candidate yesno
	
// set pol_donor flag
	replace pol_donor = 1
	replace pol_candidate = 0

// convert dates to dates
	// NPyear
	drop if NPyear == .
	
	// make the FISYR_NUM the NPyear
	replace FISYR_NUM = NPyear

// re-sort the observations by year and bn
sort NPyear NPregion
	
// save the data file
save politicaldonors2000to2017.dta, replace

// describe the data set
describe

// TRIM DATA SET BEFORE CLEANING STRINGS
		
// drop observations outside the time period of interest
drop if 	NPyear < 2000 | ///
			NPyear > 2017

// drop observations if the donor is classified as an organization
drop if 	NPdonor_type == "Corporations"
drop if		NPdonor_type == "Donations in Kind"
drop if		NPdonor_type == "Other" 
drop if		NPdonor_type == "Unions" 

// CLEAN FINANCIAL VARIABLES

// if the financial variable is a string, convert to numeric
	capture confirm string variable NPdonation_amount
		if !_rc {
			replace NPdonation_amount = subinstr(NPdonation_amount,"$","",.)
			replace NPdonation_amount = subinstr(NPdonation_amount,",","",.)
			destring NPdonation_amount, replace
			
			// inflation adjust donations to 2017CAD ,000s
			replace NPdonation_amount = NPdonation_amount * 1.36 / 1000 if FISYR_NUM == 2000
			replace NPdonation_amount = NPdonation_amount * 1.33 / 1000 if FISYR_NUM == 2001
			replace NPdonation_amount = NPdonation_amount * 1.30 / 1000 if FISYR_NUM == 2002
			replace NPdonation_amount = NPdonation_amount * 1.27 / 1000 if FISYR_NUM == 2003
			replace NPdonation_amount = NPdonation_amount * 1.25 / 1000 if FISYR_NUM == 2004
			replace NPdonation_amount = NPdonation_amount * 1.21 / 1000 if FISYR_NUM == 2005
			replace NPdonation_amount = NPdonation_amount * 1.20 / 1000 if FISYR_NUM == 2006
			replace NPdonation_amount = NPdonation_amount * 1.18 / 1000 if FISYR_NUM == 2007
			replace NPdonation_amount = NPdonation_amount * 1.13 / 1000 if FISYR_NUM == 2008
			replace NPdonation_amount = NPdonation_amount * 1.14 / 1000 if FISYR_NUM == 2009
			replace NPdonation_amount = NPdonation_amount * 1.12 / 1000 if FISYR_NUM == 2010
			replace NPdonation_amount = NPdonation_amount * 1.08 / 1000 if FISYR_NUM == 2011
			replace NPdonation_amount = NPdonation_amount * 1.07 / 1000 if FISYR_NUM == 2012
			replace NPdonation_amount = NPdonation_amount * 1.06 / 1000 if FISYR_NUM == 2013
			replace NPdonation_amount = NPdonation_amount * 1.04 / 1000 if FISYR_NUM == 2014
			replace NPdonation_amount = NPdonation_amount * 1.03 / 1000 if FISYR_NUM == 2015
			replace NPdonation_amount = NPdonation_amount * 1.02 / 1000 if FISYR_NUM == 2016
			replace NPdonation_amount = NPdonation_amount * 1.00 / 1000 if FISYR_NUM == 2017
		}
				
		// if a value is missing, assume that it is 0
		replace NPdonation_amount = 0 if NPdonation_amount == .

// CLEAN STRING VARIABLES

// basic character cleaning
	// fix surnames where a comma has been entered instead of an apostrophe
	replace NPname_donor_full = subinstr(NPname_donor_full, "D,", "D'", .)
	replace NPname_donor_full = subinstr(NPname_donor_full, "L,", "L'", .)
	replace NPname_donor_full = subinstr(NPname_donor_full, "O,", "O'", .)
	replace NPname_donor_full = subinstr(NPname_donor_full, "D,", "D'", .)
	replace NPname_donor_full = subinstr(NPname_donor_full, "L,", "L'", .)
	replace NPname_donor_full = subinstr(NPname_donor_full, "O,", "O'", .)
	
	// insert an extra space between commas and the next character to make cleaning words easier
	replace NPname_donor_full = subinstr(NPname_donor_full, ",", ", ", .)
	replace NPname_donor_full = subinstr(NPname_donor_full, ",", ", ", .)
	replace NPname_donor_full = subinstr(NPname_donor_full, ",", ", ", .)

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
	
	// remove commas before JR for junior and SR for senior
	foreach var in NPname_donor_full{
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
	foreach var in NPname_donor_full {
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
	foreach var in NPname_donor_full {
		display `"`var'"'
		replace `var' = (subinword(`var'), "`scenario'", "", 1) ///
			if wordcount(`var')  > 1
		replace `var' = (subinword(`var'), "`scenario',", "", 1) ///
			if wordcount(`var')  > 1
	}
}

// trim spaces and commas from the very end of name strings
foreach var in NPname_donor_full {
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

// 2single name field
	// split names into one variable for surnames and one variable for given names	
	// deal with names that are entered in last, first format
	replace name_edit = 1 ///
		& strmatch(NPname_donor_full, "*,?*")
	
	egen name_surname_temp = ends(NPname_donor_full) ///
		if name_edit == 1 ///
		, punct(",") trim head
		
	egen name_given_temp = ends(NPname_donor_full) ///
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
		if name_edit != 1 
		
	replace name_surname = word(NPname_donor_full, -1) ///
		if name_edit == 2
		
	gen name_given_temp = NPname_donor_full ///
		if name_edit == 2
		
	replace name_given_temp = subinword(name_given_temp, name_surname, "", .) ///
		if name_edit == 2
		
	replace name_given = name_given_temp ///
		if name_edit == 2
	
	drop name_given_temp
	
// re-order variables and re-sort the observations
	order name_surname, after(count)
	order name_given, after(name_surname)
	sort NPyear NPregion name_surname
	
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
	
	// remove parenthesis
	replace name_surname = subinstr(name_surname, `"("', "", .)
	replace name_given = subinstr(name_given, `"("', "", .)
	replace name_surname = subinstr(name_surname, `")"', "", .)
	replace name_given = subinstr(name_given, `")"', "", .)
	
	// remove apostrophes and quotations
	replace name_surname = subinstr(name_surname, "'", "", .)
	replace name_given = subinstr(name_given, "'", "", .)
	replace name_surname = subinstr(name_surname, `"""', "", .)
	replace name_given = subinstr(name_given, `"""', "", .)
	
	
// save the data file
save politicaldonors2000to2017.dta, replace

// describe the data set
describe

// remove observations that are unlikely to be individuals

	// drop anything that has no value in name_given
	drop if name_given == ""
	
	// drop anything that starts with strings identified as not individuals during visual inspection of the data
	global list_start_surname ACADEMY ACC ACOUST ACTRA ACUPUNCTURE ADMINISTRATION ADVENTURE ADVERTISING ADVISORS ADVOCIS AEFO AESTHETICS AFFAIRS AFL AGENCIES AGENCY AGRICULTURE AIRPORT AMERICA ANONYMOUS APARTMENT APEGA APEGGA APES APEX ARTISTS ARTS ASSOCIAT ASTRAZENECA BELLALIANT BOARD BREWERIES BREWERS BREWERY BROADCASTING BROKER BUILDERS BUILDING BUILERS BUSINESS CANACCORD CANAD CARPENTERS CENTRAL CENTRE CFLRA CFTPA COLLEGE COMPONENT CONNECTION CONSTRUCTION CONSULT CONTRACT CONTRIBUTIONS CONTROL CONVENIENCE CORP COUNCIL COUNSEL COUNTRY CREDIT DIV ELECTR EMPLOY ENER ENGINEER EQUIPMENT FARMING FARMS FEED FIGHTER FM FUND FUNERAL FURNITURE GMC GROUP HOLDINGS HOSPITAL HQ INC INDUSTR INSPECT INSTALL INSTITUTE INSULAT INSURANCE INTEL INTERFOR INTERIOR INTERNATIONAL INTRACORP INVERT INVEST LABOUR LABRADOR LANDSCAP LEADERS LEAFS LEAG LEAGUE LICENSEES LIMITED LIUNA LLC LLP LOCAL LP LTD LTEE MAINTENANCE MANUFACTUR MARKET MILLWORK MILLWRIGHT MOTEL NATION NATIONAL NATIONS NEWFOUNDLAND NORTHEASTERN OFCANADA OFFICE OFFICE OFONTARIO OFTORONTO OIL OKANAGAN ONTARIO OPT ORGANI OTTAWA OUTFIT OUTLET PARTNERSHIP  PHARMAC PHOTO PIPEA PIPEF PIPELIN PIZZA PLAZA POLICE POLICY PRODUC PROFESSION PROGRAM PROJECT PROMOTION PROPANE PROPERTIES PROVIDERS REGION "RENT-" RENTA RESORT RESOURCE RESTAUR RETAIL RETIRE ROAD SCOTIA SECRETARIAT SECTION SECTOR SECURIT SERVEO SERVI SKILLS SOLICIT SPECIAL STAMPEDE STORES SURVEY TEACH TECH TELUS TERRITORIES TRADE TRADI TRAIL TRAINING TRAVEL TRUCK TRUST ULC UNION UNIT UNIV UNLIM VANCOUVER VICINITY VN105188 WESTMINSTER WHOLESALE WORKERS "_" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "-" "(" ")" "*" "&" "#" "<" `"""' "'"
	
	foreach scenario of global list_start_surname{
		display `"`scenario'"'
		drop if strpos(name_surname, `"`scenario'"') == 1
	}
	
	// drop anything where the whole surname identfied as not individuals during visual inspection of data
	global list_whole_surname BANK BC BRANCH BURNABY BUS CACDS CIBC CONFECTIONARY CONST CUP CUPE "CUPE-NL" DELI II III IND INN LOC MART MYLANPHARMACEUTICALSULC NL OECTA OF "OF)" ON ONT OPP OPPA OPSEU OSSTF PAC PEI PIPE PLACE PLUS PRINT PRINTERS PRINTING RAIL RAILWAY RENT SERV SOLIC SPA STORE
	
	foreach scenario of global list_whole_surname{
		display `"`scenario'"'
		drop if name_surname == `"`scenario'"'
	}
	
	// drop anything where any words indicating organizations appear in any part of the name
	global list_word_anyname ALLIANCE ASSN ASSOCIATES ASSOCIATION BROKERS BROKERS CAPITAL CANADA CANADIAN CENTRE CHAPTER CLINIC CLUB "CLUB1-500" CLUBINC CLUBS CLUBS CO "CO-OP" COALITION COMMISSION COMMITTEE COMMUNICATIONS COMMUNITIES COMMUNITY COMPANIES COMPANY CONFERENCE CONGRESS CONSORTIUM CONSTRUCTION CONTRACTORS CONTRIBUTIONS CORPORATION COUNCIL DEALER DEVELOP DEVELOPMENTS DIVISION EDUCATION "EMPLOYEES'UNION" ENERGY ENGINEERING ENGINEERS ENTERPRISES ENTERTAINMENT ENVIRONMENTAL EQUITIES EQUITY ESTATE FEDERATION FISHERIES GROUP HOLDINGS HOTEL INC INDUSTRY INTERNATIONAL INVESTMENTS LABOUR LEAGUE LIMITED LLC LLP LOC LOCAL LP LTD LTEE MUNICIPALITY OF OFFICIALS PARTNERSHIP PRODUCTION PROFESSIONAL PROFESSIONALS PROPERTIES REALTY RESTAURANT SCHOOL UNION UNITED
	
	foreach scenario of global list_word_anyname{
		display `"`scenario'"'
		drop if strpos(name_surname, `"`scenario'"') > 0
		drop if strpos(name_given, `"`scenario'"') > 0
	}
	
	// drop anything containing a number or special character in a name field
	global list_nonalpha_anyname "0 1 2 3 4 5 6 7 8 9 & / ?" 
	
	foreach scenario of global list_nonalpha_anyname{
		display `"`scenario'"'
		drop if strpos(name_surname, `"`scenario'"') > 0
		drop if strpos(name_given, `"`scenario'"') > 0
	}
	
// fix names where a middle initial has been identified as a surnames
	gen name_edit = .
	replace name_edit = 1 if strlen(name_surname) == 1
	
	replace name_given 		= name_given + " " + name_surname 				if name_edit == 1
	replace name_surname 	= word(name_given, 1)							if name_edit == 1
	replace name_given		= subinword(name_given, name_surname, "", 1)	if name_edit == 1
	
	drop name_edit
	
// remove leading trailing and extra internal spaces from string variables
	ds, has(type string)
	foreach var of varlist `r(varlist)' {
		display `"`var'"'
		replace `var' = stritrim(strtrim(ustrtrim(strupper(`var'))))
	}
	
// concatenate names for matching
replace name_full = name_given + " " + name_surname
sort name_full NPregion FISYR_NUM
gen id = _n

// identify exactly matching names
group_id id, matchby(name_full)
	
// save the data file
save politicaldonors2000to2017.dta, replace

// modify variables to match the charity trustee variables

// convert location data to address components
	// convert n/a to empty
	replace NPdonor_location = "" if NPdonor_location == "N/A"

	// extract the city
	egen city = ends(NPdonor_location), punct(",") trim head
	order city, after(FISYR_NUM)
	
	// set up provincial labels
	label define province2 	0  "Federal" ///
						10 "Atlantic: Newfoundland and Labrador" ///
						11 "Atlantic: Prince Edward Island" ///
						12 "Atlantic: Nova Scotia" /// 
						13 "Atlantic: New Brunswick" ///
						24 "Quebec" /// 
						35 "Ontario" /// 
						46 "Prairies: Manitoba" /// 
						47 "Prairies: Saskatchewan" ///
						48 "Prairies: Alberta" /// 
						59 "British Columbia" /// 
						60 "Territories: Yukon" ///
						61 "Territories: Northwest Territories" /// 
						62 "Territories: Nunavut" /// 
						99 "Outside Canada"
	
	gen province = ""
	order province, after(city)
	replace province = "NL"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "A"
	replace province = "PE"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "C"
	replace province = "NS"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "B"
	replace province = "NB"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "E"
	replace province = "QC"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "G"
	replace province = "QC"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "H"
	replace province = "QC"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "J"
	replace province = "ON"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "K"
	replace province = "ON"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "L"
	replace province = "ON"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "M"
	replace province = "ON"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "N"
	replace province = "ON"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "P"
	replace province = "MB"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "R"
	replace province = "SK"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "S"
	replace province = "AB"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "T"
	replace province = "BC"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "V"
	replace province = "YT"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 1) == "Y"
	replace province = "NU"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 3) == "X0A"
	replace province = "NT"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 3) == "X1A"
	replace province = "NU"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 3) == "X0B"
	replace province = "NU"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 3) == "X0C"
	replace province = "NT"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 3) == "X0E"
	replace province = "NT"	if strpos(NPdonor_location, ",") > 0 & substr(NPdonor_location, -3, 3) == "X0G"
	
	gen province2 = . 
	order province2, after (province)
	replace province2 = 10 	if province == "NL"
	replace province2 = 11 	if province == "PE"
	replace province2 = 12 	if province == "NS"
	replace province2 = 13 	if province == "NB"
	replace province2 = 24 	if province == "QC"
	replace province2 = 35 	if province == "ON" 
	replace province2 = 46 	if province == "MB"
	replace province2 = 47 	if province == "SK"
	replace province2 = 48 	if province == "AB"
	replace province2 = 59 	if province == "BC"
	replace province2 = 60 	if province == "YT"
	replace province2 = 61 	if province == "NT"
	replace province2 = 62	if province == "NU"
	label var province2 "region: province"
	
	label values province2 province2

	// convert region of contribution to categorical
	replace NPregion = "0"	if NPregion == "FEDERAL"
	replace NPregion = "10"	if NPregion == "NEWFOUNDLAND AND LABRADOR"
	replace NPregion = "11"	if NPregion == "PRINCE EDWARD ISLAND"
	replace NPregion = "12"	if NPregion == "NOVA SCOTIA"
	replace NPregion = "13"	if NPregion == "NEW BRUNSWICK"
	replace NPregion = "24"	if NPregion == "QUEBEC"
	replace NPregion = "35"	if NPregion == "ONTARIO" 
	replace NPregion = "46"	if NPregion == "MANITOBA"
	replace NPregion = "47"	if NPregion == "SASKATCHEWAN"
	replace NPregion = "48"	if NPregion == "ALBERTA"
	replace NPregion = "59"	if NPregion == "BRITISH COLUMBIA"
	replace NPregion = "60"	if NPregion == "YUKON"
	replace NPregion = "61"	if NPregion == "NORTHWEST TERRITORIES"
	replace NPregion = "62" if NPregion == "NUNAVUT"
	destring NPregion, replace
	
	label var NPregion "region of donation"
	label values NPregion province2 
	
	// extract the postal code FSA
	gen postal_code_FSA = substr(NPdonor_location, -3, 3) if strpos(NPdonor_location, ",") > 0 
	order postal_code_FSA, after(province)
	
	order NPregion, after(province2)
	order NPdonor_location, after(NPregion)
	
// remove observations from regions not relevant to the study

keep if NPregion == 0 ///
		| NPregion == 35 ///
		| NPregion == 48

replace province2 = NPregion ///
		if province2 == . ///
		& NPregion != 0

drop if NPregion == 0 ///
		& province2 == .

keep if province2 == 35 ///
		| province2 == 48

tab2 province2 NPregion, missing

table (FISYR_NUM) (province2 NPregion), statistic(frequency) nototals

// save the data file
save politicaldonors2000to2017.dta, replace

// sort out the political parties
	// parties given four digit codes
	// first two digits:
	//	11 - Conservative - PC
	//	12 - Conservative - Protest
	//	13 - Conservative - United
	//	14 - Conservative - Other
	//	21 - Liberal
	//	31 - New Democratic Party
	//	41 - Progressive - Protest
	//	51 - Green
	//	99 - Other / Independent (Less than 1% of total number or total value of donations over panel period)
	// last two digits: NPregion

	// federal
	table (NPpolitical_party) if NPregion == 0, statistic(frequency) statistic(sum NPdonation_amount)
	replace pol_party = 1100 	if NPpolitical_party == "PROGRESSIVE CONSERVATIVE PARTY OF CANADA" & NPregion == 0
	replace pol_party = 1300 	if NPpolitical_party == "CANADIAN REFORM CONSERVATIVE ALLIANCE"	& NPregion == 0
	replace pol_party = 1300 	if NPpolitical_party == "CONSERVATIVE PARTY OF CANADA"			& NPregion == 0
	replace pol_party = 2100 	if NPpolitical_party == "LIBERAL PARTY OF CANADA"				& NPregion == 0
	replace pol_party = 3100 	if NPpolitical_party == "NEW DEMOCRATIC PARTY"					& NPregion == 0
	replace pol_party = 5100 	if NPpolitical_party == "GREEN PARTY OF CANADA"					& NPregion == 0
	replace pol_party = 5100 	if NPpolitical_party == "THE GREEN PARTY OF CANADA"				& NPregion == 0
	replace pol_party = 9900	if pol_party == . & NPregion == 0

	table (pol_party) if NPregion == 0, statistic(frequency) statistic(sum NPdonation_amount)
	
	// ontario provincial
	table (NPpolitical_party) if NPregion == 35, statistic(frequency) statistic(sum NPdonation_amount)
	replace pol_party = 1135 	if NPpolitical_party == "PROGRESSIVE CONSERVATIVE PARTY OF ONTARIO" & NPregion == 35
	replace pol_party = 2135 	if NPpolitical_party == "LIBERAL PARTY"							& NPregion == 35
	replace pol_party = 2135 	if NPpolitical_party == "LIBERAL PARTY OF ONTARIO"				& NPregion == 35
	replace pol_party = 2135 	if NPpolitical_party == "ONTARIO LIBERAL PARTY"					& NPregion == 35
	replace pol_party = 3135 	if NPpolitical_party == "NEW DEMOCRATIC PARTY"					& NPregion == 35
	replace pol_party = 3135 	if NPpolitical_party == "NEW DEMOCRATIC PARTY OF ONTARIO"		& NPregion == 35
	replace pol_party = 5135 	if NPpolitical_party == "GREEN PARTY OF ONTARIO"				& NPregion == 35
	replace pol_party = 9935	if pol_party == . & NPregion == 35
	
	table (pol_party) if NPregion == 35, statistic(frequency) statistic(sum NPdonation_amount)
	
	// alberta provincial
	table (NPpolitical_party) if NPregion == 48, statistic(frequency) statistic(sum NPdonation_amount)
	replace pol_party = 1148 	if NPpolitical_party == "PROGRESSIVE CONSERVATIVE ASSOCIATION OF ALBERTA"	& NPregion == 48
	replace pol_party = 1248 	if NPpolitical_party == "WILDROSE ALLIANCE PARTY"				& NPregion == 48
	replace pol_party = 1248 	if NPpolitical_party == "WILDROSE PARTY"						& NPregion == 48
	replace pol_party = 1348 	if NPpolitical_party == "UNITED CONSERVATIVE PARTY"				& NPregion == 48
	replace pol_party = 1448 	if NPpolitical_party == "ALBERTA ALLIANCE PARTY"				& NPregion == 48
	replace pol_party = 2148 	if NPpolitical_party == "ALBERTA LIBERAL PARTY"					& NPregion == 48
	replace pol_party = 3148 	if NPpolitical_party == "ALBERTA NEW DEMOCRATIC PARTY"			& NPregion == 48
	replace pol_party = 4148 	if NPpolitical_party == "ALBERTA PARTY"							& NPregion == 48
	replace pol_party = 4148 	if NPpolitical_party == "ALBERTA PARTY POLITICAL ASSOCIATION"	& NPregion == 48
	replace pol_party = 5148 	if NPpolitical_party == "ALBERTA GREENS"						& NPregion == 48
	replace pol_party = 9948	if pol_party == . & NPregion == 48
	
	table (pol_party) if NPregion == 48, statistic(frequency) statistic(sum NPdonation_amount)
	
	// destring parties
	destring pol_party, replace
	
	// label parties
	label define pol_party 1100 "Con:PC Fed" ///
						1135 "Con:PC ON" ///
						1148 "Con:PC AB" ///
						1200 "Con:Protest Fed" ///
						1235 "Con:Protest ON" ///
						1248 "Con:Protest AB" ///
						1300 "Con:United Fed" ///
						1335 "Con:United ON" ///
						1348 "Con:United AB" ///
						1400 "Con:Other Fed" ///
						1435 "Con:Other ON" ///
						1448 "Con:Other AB" ///
						2100 "Lib Fed" ///
						2135 "Lib ON" ///
						2148 "Lib AB" ///
						3100 "NDP Fed" ///
						3135 "NDP ON" ///
						3148 "NDP AB" ///
						4100 "Prog Fed" ///
						4135 "Prog ON" ///
						4148 "Prog AB" ///
						5100 "Grn Fed" ///
						5135 "Grn ON" ///
						5148 "Grn AB" ///
						9900 "Other Fed" ///
						9935 "Other ON" ///
						9948 "Other AB"
	label values pol_party pol_party
	
	// create alignment categories
	gen pol_alignment = .
	order pol_alignment, after(pol_party)
	replace pol_alignment = 3 if pol_party < 1999
	replace pol_alignment = 2 if pol_party > 1999 & pol_party < 2999
	replace pol_alignment = 1 if pol_party > 2999 & pol_party < 8999
	
	label define pol_alignment 3 "RoC" ///
						2 "Cen" ///
						1 "LoC"
	label values pol_alignment pol_alignment
	
	table (FISYR_NUM) (NPregion pol_alignment), statistic(frequency) statistic(sum NPdonation_amount)

// remove variables that are not needed anymore
keep	bn ///
		fpe ///
		FISYR_NUM ///
		city ///
		province ///
		province2 ///
		postal_code_FSA ///
		name_surname ///
		name_given ///
		name_full ///
		trustee ///
		pol_jurisdiction ///
		pol_party ///
		pol_alignment ///
		pol_candidate ///
		pol_donor ///
		id
		
// make sure that variables have NO special characters

	
// save the data file
save politicaldonors2000to2017.dta, replace

// reconfigure variables for merging with other data
sort name_surname name_given FISYR_NUM
gen reclink_id = _n

// save the data file
cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Contributions/"
save politicaldonors2000to2017.dta, replace

