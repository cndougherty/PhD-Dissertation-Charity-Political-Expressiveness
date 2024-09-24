// package installations
ssc install group_id, replace
ssc install freqindex, replace
ssc install matchit, replace

// clear the results window
cls

// dissertation papers - paper 1, foundations
// this .do file creates a merged set of all political party donors
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

cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Election results/"

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
	
	generate pol_candidate = 1
	label variable pol_candidate "Political Candidate"
	
	generate pol_donor = 0
	label variable pol_donor "Political Donor"
	
	
// save the data file
save politicalcandidates2000to2017.dta, replace

// set up the macro for filenames
global list_filenames "AB20010321.csv AB20041122.csv AB20080303.csv AB20120423.csv AB20150505.csv CA1997-2019.csv ON19990603.csv ON20031002.csv ON20071010.csv ON20111006.csv ON20140612.csv"

// import and save electioncandidate files
foreach scenario of global list_filenames{
	display `"`scenario'"'
	import delimited `"`scenario'"', delimiter(comma) clear
	
	// add the jurisdiction based on the first two letters of the imported filenames
	generate pol_jurisdiction = .
	replace pol_jurisdiction = 0  if substr(`"`scenario'"', 1, 2) == "CA"
	replace pol_jurisdiction = 35 if substr(`"`scenario'"', 1, 2) == "ON"
	replace pol_jurisdiction = 48 if substr(`"`scenario'"', 1, 2) == "AB"
	
	capture confirm variable ElectionDate
	if (_rc == 0){
		format ElectionDate %td
	}
	
	capture confirm variable year
	if (_rc == 0){
		rename year FISYR_NUM
	}
	
	capture confirm variable fisyr_num
	if (_rc == 0){
		rename fisyr_num FISYR_NUM
	}
	
	capture confirm variable Votes
	if (_rc == 0){
		rename Votes votes
	}
	
	capture confirm string variable votes
	if !_rc {
		replace votes = (subinstr(votes), ",", "", 1)
		destring votes, replace
	}
	
	// append the annual short panel file to the full panel data set
	append using politicalcandidates2000to2017, force
	save politicalcandidates2000to2017, replace
}

// add the political candidate flag
replace pol_candidate = 1

// open the data file
use politicalcandidates2000to2017.dta, clear

table (FISYR_NUM) (pol_jurisdiction province2), statistic(frequency) missing

// CLEAN NONSTRING VARIABLES

// convert binary dummy variables to proper dummy variables
	label define yesno ///
		1 "Yes" ///
		0 "No"
	
	label values pol_donor yesno
	label values trustee yesno
	label values pol_candidate yesno

// re-sort the observations by year and bn
sort FISYR_NUM pol_jurisdiction
	
// save the data file
save politicalcandidates2000to2017.dta, replace

// describe the data set
describe

// CLEAN STRING VARIABLES

// basic character cleaning
	// insert an extra space between commas and the next character to make cleaning words easier
	replace candidate = subinstr(candidate, ",", ", ", .)
	replace candidate = subinstr(candidate, ",", ", ", .)
	replace candidate = subinstr(candidate, ",", ", ", .)

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
	foreach var in candidate{
		display `"`var'"'
		display "junior" _continue
		replace `var' = (subinstr(`var'), ", JR", " JR", 1) ///
			if wordcount(`var') > 1
		display "senior" _continue
		replace `var' = (subinstr(`var'), ", SR", " SR", 1) ///
			if wordcount(`var') > 1
	}

// trim spaces and commas from the very end of name strings
foreach var in candidate {
	display `"`var'"'
	replace `var' = strrtrim(`var')
	replace `var' = substr(`var', 1, length(`var') - 1) ///
		if substr(`var', -1, 1) ==  ","
}

// generate destination variables for surnames and given names
	gen name_surname = ""
	gen name_given = ""
	
	// re-order the name variables
	order name_surname, after(candidate)
	order name_given, after(name_surname)
	
// generate name_edit variable 
// name_edit will be used to flag groups of names being cleaned in the current batch of functions
	gen name_edit = .

// single name field
	// split names into one variable for surnames and one variable for given names	
	// deal with names that are entered in last, first format
	replace name_edit = 1 ///
		& strmatch(candidate, "*,?*")
	
	egen name_surname_temp = ends(candidate) ///
		if name_edit == 1 ///
		, punct(",") trim head
		
	egen name_given_temp = ends(candidate) ///
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
		
	replace name_surname = word(candidate, -1) ///
		if name_edit == 2
		
	gen name_given_temp = candidate ///
		if name_edit == 2
		
	replace name_given_temp = subinword(name_given_temp, name_surname, "", .) ///
		if name_edit == 2
		
	replace name_given = name_given_temp ///
		if name_edit == 2
	
	drop name_given_temp
	
// re-order variables and re-sort the observations
	order name_surname, after(count)
	order name_given, after(name_surname)
	sort pol_jurisdiction electiondate name_surname
	
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
save politicalcandidates2000to2017.dta, replace

// describe the data set
describe

// remove observations that are unlikely to be individuals

	// drop anything that has no value in name_given
	drop if name_given == ""
	
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
sort name_full province2 FISYR_NUM
gen id = _n

// identify exactly matching names
group_id id, matchby(name_full)
	
// save the data file
save politicalcandidates2000to2017.dta, replace

// modify variables to match the charity trustee variables

// convert location data to address components
	
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
	
	label var province2 "region: province"
	
	label values province2 province2

	// label jurisdiction of election
	
	label var pol_jurisdiction "Political Jurisdiction"
	label values pol_jurisdiction province2 
	

tab2 province2 pol_jurisdiction, missing

table (FISYR_NUM) (province2 pol_jurisdiction), statistic(frequency) nototals

// save the data file
save politicalcandidates2000to2017.dta, replace

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
	//	99 - Other / Independent
	// last two digits: pol_jurisdiction

	// federal
	table (party) if pol_jurisdiction == 0, statistic(frequency)
	replace pol_party = 1100 	if party == "PROGRESSIVE CONSERVATIVE PARTY" 		& pol_jurisdiction == 0
	replace pol_party = 1200	if party == "REFORM PARTY OF CANADA"				& pol_jurisdiction == 0
	replace pol_party = 1300 	if party == "CANADIAN REFORM CONSERVATIVE ALLIANCE"	& pol_jurisdiction == 0
	replace pol_party = 1300 	if party == "CONSERVATIVE PARTY OF CANADA"			& pol_jurisdiction == 0
	replace pol_party = 2100 	if party == "LIBERAL PARTY OF CANADA"				& pol_jurisdiction == 0
	replace pol_party = 3100 	if party == "NEW DEMOCRATIC PARTY"					& pol_jurisdiction == 0
	replace pol_party = 5100 	if party == "GREEN PARTY OF CANADA"					& pol_jurisdiction == 0
	replace pol_party = 9900	if pol_party == . & pol_jurisdiction == 0

	table (FISYR_NUM) (pol_party) if pol_jurisdiction == 0, statistic(frequency) statistic(sum votes)
	
	// ontario provincial
	table (party) if pol_jurisdiction == 35, statistic(frequency)
	replace pol_party = 1135 	if party == "PC" 									& pol_jurisdiction == 35
	replace pol_party = 1135 	if party == "PCP" 									& pol_jurisdiction == 35
	replace pol_party = 2135 	if party == "L"										& pol_jurisdiction == 35
	replace pol_party = 2135 	if party == "OLP"									& pol_jurisdiction == 35
	replace pol_party = 3135 	if party == "ND"									& pol_jurisdiction == 35
	replace pol_party = 3135 	if party == "NDP"									& pol_jurisdiction == 35
	replace pol_party = 5135 	if party == "GP"									& pol_jurisdiction == 35
	replace pol_party = 5135 	if party == "GPO"									& pol_jurisdiction == 35
	replace pol_party = 9935	if pol_party == . & pol_jurisdiction == 35
	
	table (FISYR_NUM) (pol_party) if pol_jurisdiction == 35, statistic(frequency) statistic(sum votes)
	
	// alberta provincial
	table (party) if pol_jurisdiction == 48, statistic(frequency)
	replace pol_party = 1148 	if party == "PC"									& pol_jurisdiction == 48
	replace pol_party = 1148 	if party == "PROGRESSIVE CONSERVATIVE"				& pol_jurisdiction == 48
	replace pol_party = 1248 	if party == "WILDROSE ALLIANCE PARTY"				& pol_jurisdiction == 48
	replace pol_party = 1248 	if party == "WRP"									& pol_jurisdiction == 48
	replace pol_party = 1348 	if party == "UNITED CONSERVATIVE PARTY"				& pol_jurisdiction == 48
	replace pol_party = 1448 	if party == "ALBERTA ALLIANCE"						& pol_jurisdiction == 48
	replace pol_party = 2148 	if party == "LIB"									& pol_jurisdiction == 48
	replace pol_party = 2148 	if party == "LIBERAL"								& pol_jurisdiction == 48
	replace pol_party = 3148 	if party == "NDP"									& pol_jurisdiction == 48
	replace pol_party = 3148 	if party == "NEW DEMOCRATIC PARTY"					& pol_jurisdiction == 48
	replace pol_party = 4148 	if party == "AP"									& pol_jurisdiction == 48
	replace pol_party = 4148 	if party == "ALBERTA PARTY"							& pol_jurisdiction == 48
	replace pol_party = 5148 	if party == "GPA"									& pol_jurisdiction == 48
	replace pol_party = 9948	if pol_party == . & pol_jurisdiction == 48
	
	table (FISYR_NUM) (pol_party) if pol_jurisdiction == 48, statistic(frequency) statistic(sum votes)
	
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
	
	table (FISYR_NUM) (province2 pol_alignment), statistic(frequency) statistic(sum votes)
	
	// identify elected candidates
	by electiondate riding (votes), sort: replace elected = votes if _n == _N
	replace elected = 0 if elected == .
	replace elected = 1 if elected > 0

	label values elected yesno
	
	// calculate riding level HHI
	by electiondate riding (votes), sort: egen 	votes_total 		= total(votes)
	by electiondate riding (votes), sort: gen 	votes_share_perc 	= (votes / votes_total) * 100
	by electiondate riding (votes), sort: gen 	votes_share_2		= votes_share_perc ^ 2
	by electiondate riding (votes), sort: egen 	votes_HHI			= total(votes_share_2)

	
// save the data file
save "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Election results/politicalcandidates2000to2017.dta", replace

// remove variables that are not needed anymore
keep	FISYR_NUM ///
		electiondate ///
		riding ///
		province ///
		province2 ///
		name_surname ///
		name_given ///
		name_full ///
		trustee ///
		pol_jurisdiction ///
		pol_party ///
		pol_alignment ///
		pol_candidate ///
		pol_donor ///
		id ///
		votes_total ///
		votes_share_perc ///
		votes_HHI
	
// save the data file
save "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Election results/politicalcandidates2000to2017.dta", replace

// reconfigure variables for merging with other data
sort name_surname name_given FISYR_NUM
gen reclink_id = _n

// save the data file
save "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Election results/politicalcandidates2000to2017.dta", replace




