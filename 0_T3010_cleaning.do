// package installations
// ssc install collin, replace // https://stats.oarc.ucla.edu/stat/stata/ado/analysis/

// clear the results window
cls

// dissertation papers - paper 1, foundations
// Christopher Dougherty
// Last updated: June 3, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255 
set rmsg on

// open the data file

use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T3010CharityReturn/MERGED_2017_to_2000_with_final_arrangements.dta"

// CAUTION only run this section if starting with the complete data set from Nathan

// only keep variables of interest
keep bn /// 
	fpe	/// 
	FISYR_NUM /// 
	legal_name /// 
	registration_date ///
	_1510_subordinate ///
	_1510_bn ///
	mailing_address ///
	city ///
	province ///
	postal_code ///
	country_code ///
	designation_code ///
	category_code ///
	_1200_program_area_code ///
	_1200_percentage ///
	_1210_program_area_code ///
	_1210_percentage ///
	_1220_program_area_code ///
	_1220_percentage ///
	_2000 ///
	_2400 ///
	_2700 ///
	_3200 ///
	_4400 ///
	_3400 ///
	_3900 ///
	_4200 ///
	_4350 ///
	_4560 ///
	_4550 ///
	_4540 ///
	_4570 ///
	_4571 ///
	_4575 ///
	_4500 ///
	_4530 ///
	_4630 ///
	_5450 ///
	_4510 ///
	_4580 ///
	_4600 ///
	_4610 ///
	_4620 ///
	_4640 ///
	_4650 ///
	_4700 ///
	_4800 ///
	_4860 ///
	_4880 ///
	_5460 ///
	_5000 ///
	_5010 ///
	_5020 ///
	_5030 ///
	_5031 ///
	_5040 ///
	_5050 ///
	_5100 ///
	_300 ///
	_370 ///
	_380 ///
	_390

// GEOGRAPHY
// province
tab1 province

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
	replace province2 = 99	if country_code != "CA" 
	
	label var province2 "region: province"
	label define province2 	10 "Atlantic: Newfoundland and Labrador" ///
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
	label values province2 province2
	
	tab2 province province2
	
	// drop if province is not AB or ON
	keep if province2 == 35 | province2 == 48

	tab2 province province2
	
// urban or rural
gen rural = 0
	order rural, after (postal_code)
	replace rural = 1 if substr(postal_code,2,1) == "0"
	
	label var rural "rural postal code?"
	label define rural 	0 "urban" ///
						1 "rural"
	label values rural rural
	
	tab2 province2 rural


// AREAS OF ACTIVITY	
// organizational type - operating charity or foundation?
label var designation_code "charitable designation"
	replace designation_code = "1" if designation_code == "A"
	replace designation_code = "2" if designation_code == "B"
	replace designation_code = "0" if designation_code == "C"
	destring designation_code, replace
	
	drop if designation_code == . 
	
	label define designation_code 0 "charitable organization" ///
							1 "public foundation" ///
							2 "private foundation"
	label values designation_code designation_code
	
// organizational type - category codes
label var 	category_code "charitable purpose"
	label define category_code ///
							1 	"Welfare: organizations providing care other than treatment" ///
							2 	"Welfare: disaster funds" ///
							3 	"Welfare: charitable corporations" ///
							5 	"Welfare: charitable trusts" ///
							9 	"Welfare: welfare organizations not else classified" ///
							10	"Health: hospitals" ///
							11	"Health: services other than hospitals" ///
							13	"Health: charitable corporations" ///
							15	"Health: charitable trusts" ///
							19	"Health: health organizations not else classified" ///
							20	"Education: teaching institutions or institutions of learning" ///
							21	"Education: support of schools and education" ///
							22	"Education: cultural activities" ///
							23	"Education: charitable corporations" ///
							25	"Education: charitable trusts" ///
							29	"Education: education organizations not else classified" ///
							30	"Religion: Christian: Anglican" ///
							31	"Religion: Christian: Baptist" ///
							32	"Religion: Christian: Lutheran" ///
							33	"Religion: Baha'ia" ///
							34	"Religion: Christian: Mennonite" ///
							35	"Religion: Buddhist" ///
							36	"Religion: Christian: Pentecostal" ///
							37	"Religion: Christian: Presbyterian" ///
							38	"Religion: Christian: Roman Catholic" ///
							39	"Religion: congregations not else classified" ///
							40	"Religion: Christian: Salvation Army" ///
							41	"Religion: Christian: Seventh Day Adventist" ///
							42	"Religion: Jewish" ///
							43	"Religion: charitable organizations" ///
							44	"Religion: Christian: United Church" ///
							45	"Religion: charitable trusts" ///
							46	"Religion: convents and monastaries" ///
							47	"Religion: missionary organizations" ///
							48	"Religion: Hindu" ///
							49	"Religion: religious organizations not else classified" ///
							50	"Benefits to Community: libraries and museums" ///
							51	"Benefits to Community: military units" ///
							52	"Benefits to Community: preservation of beauty and historical sites" ///
							53	"Benefits to Community: charitable corporations" ///
							54	"Benefits to Community: protection of animals" ///
							55	"Benefits to Community: charitable trusts" ///
							56	"Benefits to Community: recreation, playgrounds, and vacation camps" ///
							57	"Benefits to Community: temperance associations" ///
							59	"Benefits to Community: community organizations not else classified" ///
							60	"Religion: Islam" ///
							61	"Religion: Christian: Jehovah's Witnesses" ///
							62	"Religion: Sikh" ///
							63	"Other: service clubs and fraternal societies charitable corporations" ///
							65	"Other: service clubs and fraternal societies projects" ///
							75	"Other: employee's charity trusts" ///
							80 	"Other: RCAAA - Registered Canadian Amateur Athletic Association" ///
							81	"Other: RNASO - Registered National Arts Service Organization" ///
							83	"Other: corporation funding RCAAA" ///
							85	"Other: trust funding RCAAA" ///
							99	"Other: miscellaneous"
	label values category_code category_code
	
// organizational type - charitable head
gen charitable_head = 0
	order charitable_head, after (category_code)
	replace charitable_head = 1 if category_code >= 10 & category_code <= 19
	replace charitable_head = 2 if category_code >= 20 & category_code <= 29
	replace charitable_head = 3 if category_code >= 30 & category_code <= 49
	replace charitable_head = 3 if category_code >= 60 & category_code <= 62
	replace charitable_head = 4 if category_code >= 50 & category_code <= 59
	replace charitable_head = 5 if category_code >= 63 & category_code <= 75
	replace charitable_head = 6 if category_code >= 80 & category_code <= 85
	replace charitable_head = 5 if category_code == 99
	replace charitable_head = 98 if designation_code == 1
	replace charitable_head = 99 if designation_code == 2
	
	label var charitable_head "charitable head"
	label define charitable_head ///
							0 	"Welfare" ///
							1 	"Health" ///
							2 	"Education" ///
							3 	"Religion" ///
							4 	"Commun. Benefits" ///
							5 	"Other" ///
							6 	"RCAAA / RNASO" ///
							98	"Publ. Foundation" ///
							99 	"Priv. Foundation"
	label values charitable_head charitable_head
	
	// drop the RCAAA organizations
	drop if charitable_head == 6
	
	// drop the public foundations
	drop if charitable_head == 98
	
	table (province2 FISYR_NUM) (charitable_head), statistic(frequency) nototals
	
// organizational activities - program area codes

	foreach var in _1200_program_area_code _1210_program_area_code _1220_program_area_code {
		display `"`var'"'
		replace `var' = (subinstr(`var'), "A", "1.", 1)
		replace `var' = (subinstr(`var'), "B", "2.", 1)
		replace `var' = (subinstr(`var'), "C", "3.", 1)
		replace `var' = (subinstr(`var'), "D", "4.", 1)
		replace `var' = (subinstr(`var'), "E", "5.", 1)
		replace `var' = (subinstr(`var'), "F", "6.", 1)
		replace `var' = (subinstr(`var'), "G", "7.", 1)
		replace `var' = (subinstr(`var'), "H", "8.", 1)
		replace `var' = (subinstr(`var'), "I", "9.", 1)
		replace `var' = (subinstr(`var'), ".1", ".01", 1) if strlen(`var') == 3
		replace `var' = (subinstr(`var'), ".2", ".02", 1)
		replace `var' = (subinstr(`var'), ".3", ".03", 1)
		replace `var' = (subinstr(`var'), ".4", ".04", 1)
		replace `var' = (subinstr(`var'), ".5", ".05", 1)
		replace `var' = (subinstr(`var'), ".6", ".06", 1)
		replace `var' = (subinstr(`var'), ".7", ".07", 1)
		replace `var' = (subinstr(`var'), ".8", ".08", 1)
		replace `var' = (subinstr(`var'), ".9", ".09", 1)
		
		destring `var', replace
		drop if `var' > 10
		replace `var' = round(`var' * 100)
	}
	
	label var 	_1200_program_area_code "1200: program code"
	label var 	_1210_program_area_code "1210: program code"
	label var 	_1220_program_area_code "1220: program code"
	label define program_area_code ///
							101 "A1: Housing (seniors, low-income persons, and those with disabilities)" ///
							102 "A2: Food or clothing banks, soup kitchens, hostels" ///
							103 "A3: Employment preparation and training" ///
							104	"A4: Legal assistance and services" ///
							105 "A5: Other services for low income persons" ///
							106	"A6: Seniors services" ///
							107	"A7: Services for the physically or mentally challenged" ///
							108	"A8: Children and youth services, housing" ///
							109	"A9: Services for Aboriginal people" ///
							110	"A10: Emergency shelter" ///
							111	"A11: Family and crisis counselling, financial counselling" ///
							112	"A12: Immigrant aid" ///
							113	"A13: Rehabilitation of offenders" ///
							114	"A14: Disaster relief" ///
							201	"B1: Social services" ///
							202	"B2: Infrastructure development" ///
							203	"B3: Agriculture programs" ///
							204	"B4: Medical services" ///
							205	"B5: Literacy, education, training programs" ///
							206	"B6: Disaster, war relief" ///
							301	"C1: Scholarships, bursaries, awards" ///
							302	"C2: Support of schools and education (for example, parent-teacher groups)" ///
							303	"C3: Universities and colleges" ///
							304	"C4: Public schools and boards" ///
							305	"C5: Independent schools and boards" ///
							306	"C6: Nursery programs, schools" ///
							307	"C7: Vocational and technical training (not delivered by universities, colleges, schools)" ///
							308	"C8: Literacy programs" ///
							309	"C9: Cultural programs, including heritage languages" ///
							310	"C10: Public education, other study programs" ///
							311	"C11: Research (scientific, social science, medical, environmental, etc)" ///
							312	"C12: Learned societies (for example, Royal Astronomical Society of Canada)" ///
							313	"C13: Youth groups (for example, Girl Guides, cadets, 4-H clubs, etc)" ///
							401	"D1: Museums, galleries, concert halls, etc" ///
							402	"D2: Festivals, performing groups, musical ensembles" ///
							403	"D3: Arts schools, grants and awards for artists" ///
							404	"D4: Cultural centres and associations" ///
							405	"D5: Historical sites, heritage societies" ///
							501	"E1: Places of worship, congregations, parishes, dioceses, fabriques, etc." ///
							502	"E2: Missionary organizations, evangelism" ///
							503	"E3: Religious publishing and broadcasting" ///
							504	"E4: Seminaries and other religious colleges" ///
							505	"E5: Social outreach, religious fellowship, and auxiliary organizations" ///
							601	"F1: Hospitals" ///
							602	"F2: Nursing homes" ///
							603	"F3: Clinics" ///
							604	"F4: Services for the sick" ///
							605	"F5: Mental health services and support groups" ///
							606	"F6: Addiction services and support groups" ///
							607	"F7: Other mutual-support groups (for example, cancer patients)" ///
							608	"F8: Promotion and protection of health, including first-aid and information services" ///
							609 "F9: Specialized health organizations, focusing on specific diseases/conditions" ///
							701	"G1: Nature, habitat conservation groups" ///
							702	"G2: Preservation of species, wildlife protection" ///
							703	"G3: General environmental protection, recycling sevices" ///
							801	"H1: Agricultural and horticultural societies" ///
							802	"H2: Welfare of domestic animals" ///
							803	"H3: Parks, botanical gardens, zoos, aquariums, etc" ///
							804	"H4: Community recreation facilities, trails, etc" ///
							805	"H5: Community halls" ///
							806	"H6: Libraries" ///
							807	"H7: Cemeteries" ///
							808	"H8: Summer camps" ///
							809	"H9: Day care, after-school care" ///
							810	"H10: Crime prevention, public safety, preservation of law and order" ///
							811	"H11: Ambulance, fire, rescue, and other emergency services" ///
							812	"H12: Human rights" ///
							813	"H13: Mediation services" ///
							814	"H14: Consumer protection" ///
							815	"H15: Support and services for charitable sector" ///
							901	"I1: Other write-in"
	label values _1200_program_area_code  program_area_code
	label values _1210_program_area_code  program_area_code
	label values _1220_program_area_code  program_area_code
	
	tab2 _1200_program_area_code province2
	tab2 _1210_program_area_code province2
	tab2 _1220_program_area_code province2
	
// clean the binary variables
	label define yesno ///
		1 "Yes" ///
		0 "No"
		
	label var 	_1510_subordinate	"1510: subordinate to another charity?"
	label var 	_2000				"2000: any gifts to qualified donees?"
	label var 	_2400				"2400: any political activities?"
	label var 	_2700				"2700: any use of external fundraisers?"
	label var 	_3200				"3200: any compensation paid to non-arms length parties?"
	label var 	_3400				"3400: any compensation paid to employees?"
	label var 	_3900				"3900: any gifts over $10K from a foreign donor?"
	label var 	_4400				"4400: any borrowing, loaning, or investing from non-arms length parties?"

	foreach var in _1510_subordinate _2000 _2400 _2700 _3200 _3400 _3900 _4400 {
		
		replace `var' = "1" ///
			if `var' == "Y"
		replace `var'= "0" ///
			if `var' == "N"
			
		// convert to a numeric variable	
		destring `var', replace
		
		// if a response to a yes/no question is missing, assume no
		replace `var' = 0 ///
			if `var' == .
			
		label values `var' yesno
		order `var', before(_5450)
		table (FISYR_NUM) (province2 `var' ), statistic(frequency) nototals
	
	}
	
// clean the financial variables
	label var 	_4200				"4200: as: TOTAL, 2017CAD ,000s"
	label var 	_4350				"4350: li: TOTAL, 2017CAD ,000s"
	label var 	_4560				"4560: rv: mun govt (sched 6), 2017CAD ,000s"
	label var 	_4550				"4550: rv: pro govt (sched 6), 2017CAD ,000s"	
	label var 	_4540				"4560: rv: fed govt (sched 6), 2017CAD ,000s"
	label var 	_4570				"4570: rv: govt TOTAL, 2017CAD ,000s"
	label var 	_4571				"4571: rv: foreign tax-receipted, 2017CAD ,000s"
	label var 	_4575				"4575: rv: foreign non-receipted, 2017CAD ,000s"	
	label var 	_4500				"4500: rv: gifts tax-receipted, 2017CAD ,000s"
	label var 	_4530				"4530: rv: gifts non-receipted, 2017CAD ,000s"
	label var 	_4630				"4630: rv: gifts non-receiptable, 2017CAD ,000s"
	label var 	_5450				"5450: rv: raised by external fundraisers, 2017CAD ,000s"
	label var 	_4510				"4510: rv: gifts from charities, 2017CAD ,000s"
	label var	_4580				"4580: rv: interest and investment (sched 6), 2017CAD ,000s"
	label var	_4600				"4600: rv: net proceeds from sale of assets (sched 6), 2017CAD ,000s"
	label var	_4610				"4610: rv: property rental (sched 6), 2017CAD ,000s"
	label var 	_4620				"4620: rv: memberships and dues (sched 6), 2017CAD ,000s"
	label var 	_4640				"4640: rv: sale of goods and services, 2017CAD ,000s"
	label var 	_4650				"4650: rv: other, 2017CAD ,000s"
	label var	_4700 				"4700: rv: TOTAL, 2017CAD ,000s"
	label var 	_4800				"4800: ex: advertising and promotion (sched 6), 2017CAD ,000s"
	label var 	_4860				"4860: ex: professional and consulting fees, 2017CAD ,000s"
	label var 	_4880				"4880: ex: compensation (sched 6), 2017CAD ,000s"
	label var 	_390 				"390: ex: compensation TOTAL, 2017CAD ,000s"
	label var 	_380 				"380: ex: compensation to PT employees, 2017CAD ,000s"
	label var 	_5460				"5460: ex: retained or paid to external fundraisers, 2017CAD ,000s"
	label var 	_5000				"5000: funcex: charitable activities, 2017CAD ,000s"
	label var 	_5010				"5010: funcex: mgmt and admin, 2017CAD ,000s"
	label var 	_5020				"5020: funcex: fundraising, 2017CAD ,000s"
	label var 	_5030				"5030: funcex: political activities, 2017CAD ,000s"
	label var 	_5031				"5031: funcex: gifts to QDs for political activities, 2017CAD ,000s"
	label var 	_5040				"5040: funcex: other, 2017CAD ,000s"
	label var 	_5050				"5050: funcex: gifts to QDs, 2017CAD ,000s"
	label var 	_5100 				"5100: ex: TOTAL, 2017CAD ,000s"
	
	foreach var in _4200 _4350 _4560 _4550 _4540 _4570 _4571 _4575 _4500 _4530 _4630 _5450 _4510 _4580 _4600 _4610 _4620 _4640 _4650 _4700 _4800 _4860 _4880 _390 _380 _5460 _5000 _5010 _5020 _5030 _5031 _5040 _5050 _5100 {

		// if the financial variable is a string, convert to numeric
		capture confirm string variable `var'
                if !_rc {
					replace `var' = subinstr(`var',"$","",.)
					replace `var' = subinstr(`var',",","",.)
					destring `var', replace
				}
				
		// if a value is missing, assume that it is 0
		replace `var' = 0 if `var' == .
	
		order `var', before(_300)
		
		// inflation adjust financial variables to 2017CAD ,000s
		replace `var' = `var' * 1.36 / 1000 if FISYR_NUM == 2000
		replace `var' = `var' * 1.33 / 1000 if FISYR_NUM == 2001
		replace `var' = `var' * 1.30 / 1000 if FISYR_NUM == 2002
		replace `var' = `var' * 1.27 / 1000 if FISYR_NUM == 2003
		replace `var' = `var' * 1.25 / 1000 if FISYR_NUM == 2004
		replace `var' = `var' * 1.21 / 1000 if FISYR_NUM == 2005
		replace `var' = `var' * 1.20 / 1000 if FISYR_NUM == 2006
		replace `var' = `var' * 1.18 / 1000 if FISYR_NUM == 2007
		replace `var' = `var' * 1.13 / 1000 if FISYR_NUM == 2008
		replace `var' = `var' * 1.14 / 1000 if FISYR_NUM == 2009
		replace `var' = `var' * 1.12 / 1000 if FISYR_NUM == 2010
		replace `var' = `var' * 1.08 / 1000 if FISYR_NUM == 2011
		replace `var' = `var' * 1.07 / 1000 if FISYR_NUM == 2012
		replace `var' = `var' * 1.06 / 1000 if FISYR_NUM == 2013
		replace `var' = `var' * 1.04 / 1000 if FISYR_NUM == 2014
		replace `var' = `var' * 1.03 / 1000 if FISYR_NUM == 2015
		replace `var' = `var' * 1.02 / 1000 if FISYR_NUM == 2016
		replace `var' = `var' * 1.00 / 1000 if FISYR_NUM == 2017
	}


// clean the numeric variables
	label var 	FISYR_NUM			"FYE in calendar year"
	label var 	_300				"FT employees"
	label var 	_370				"PT employees"
	label var 	_1200_percentage	"1200: program code percentage"
	label var 	_1210_percentage	"1200: program code percentage"
	label var 	_1220_percentage	"1200: program code percentage"
	
	
	foreach var in FISYR_NUM _300 _370 _1200_percentage _1210_percentage _1220_percentage {

		// if the numeric variable is a string, convert to numeric
		capture confirm string variable `var'
                if !_rc {
					replace `var' = subinstr(`var',",","",.)
					destring `var', replace
				}
				
		// if a value is missing, assume that it is 0
		replace `var' = 0 if `var' == .
		
		// make sure that all values are positive
		replace `var' = abs(`var')
	
		order `var', after(country_code)
	}	
	
	// for the program code percentages, deal with numbers greater than 100 percent by dividing by 10 (assume data entry error involving decimal)
	foreach var in _1200_percentage _1210_percentage _1220_percentage {
				
		replace `var' = `var'/10 if `var' > 100

	}
	
	order _1200_percentage, after(_1200_program_area_code)
	order _1210_percentage, after(_1210_program_area_code)
	order _1220_percentage, after(_1220_program_area_code)
	
// clean the business numbers
	label var 	bn 					"business number"
	label var 	_1510_bn			"business number of parent charity"
	
	foreach var in bn _1510_bn {

		capture confirm string variable `var'
                if !_rc {
					replace `var' = subinstr(`var',"RR",".",.)
					destring `var', replace
					format `var' %15.4f
					
					// destringed bn should be nine digits plus four digits, if it's shorter then it is (i)ncomplete
					replace `var' = .i if `var' < 100000000
				}
	
		order `var', after(country_code)
	}	
		
	
// describe the data set
describe

// save the data set
save "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/2017_to_2000_working.dta", replace

// trim the private foundation data by size

	// check maximum asset size over the length of the panel
	egen _4200_max = max(_4200), by(bn)
		label var 	_4200_max 	"max 4200: as: TOTAL, 2017CAD ,000s"
		order 		_4200_max, 	after(_4200)
	
	// check maximum disbursements to other charities over the length of the panel
	egen _5050_max = max(_5050), by(bn)
		label var 	_5050_max 	"max 5050: funcex: gifts to QDs, 2017CAD ,000s"
		order 		_5050_max, 	after(_5050)
		
	// drop private foundtaions if maximum asset size is less than $5,000K and max disbursements less than $175K (3.5% of $5M)
	drop if designation_code == 2 ///
			& _4200_max < 5000 ///
			& _5050_max < 175
	
	// counts after dropping small foundations
	dtable i.province2 i.FISYR_NUM, by(designation_code)
	
	// drop foundations that are clearly: 
	// controlled by incorporated entities (not families); 
	// community foundations registered as private foundations;
	// churches, fraternal, or religious orders; or 
	// employee, union foundations
	drop if   bn == 	107797383.0103 ///ONTARIO CONFERENCE OF THE SEVENTH-DAY ADVENTIST CHURCH
			| bn == 	108079229.0001 ///THE COUNSELLING FOUNDATION OF CANADA
			| bn == 	118780717.0001 ///ALBERTA ELKS FOUNDATION
			| bn == 	118974914.0001 ///JOHN DEERE FOUNDATION OF CANADA
			| bn == 	119044121.0001 ///Molson Coors Canada Donations Fund - Fonds de bienfaisance Molson Coors Canada
			| bn == 	119122117.0001 ///Rockwell Automation Canadian Trust
			| bn == 	119129013.0001 ///BROOKFIELD RES CHARITABLE FOUNDATION
			| bn == 	119212033.0001 ///THE ALLSTATE FOUNDATION OF CANADA
			| bn == 	119217990.0001 ///CO-OP COMMUNITY FOUNDATION
			| bn == 	119223758.0493 ///THE CHURCH OF JESUS CHRIST OF LATTER-DAY SAINTS IN CANADA
			| bn == 	119230118.0001 ///THE DOMINION GROUP FOUNDATION
			| bn == 	119230944.0001 ///THE EDMONTON CIVIC EMPLOYEES CHARITABLE ASSISTANCE FUND
			| bn == 	119268100.0001 ///TOYOTA CANADA FOUNDATION/FONDATION TOYOTA CANADA
			| bn == 	119303477.0001 ///THE WOODLAWN ARTS FOUNDATION
			| bn == 	123813800.0001 ///THE GREAT GULF HOMES CHARITABLE FOUNDATION
			| bn == 	133702845.0001 ///TD FRIENDS OF THE ENVIRONMENT FOUNDATION
			| bn == 	137929451.0002 ///Canadian Tire Jumpstart Charities/Oeuvre Bon Depart de Canadian Tire
			| bn == 	140803917.0001 ///HUDSON'S BAY COMPANY HISTORY FOUNDATION
			| bn == 	817387277.0001 ///Mastercard Foundation
			| bn == 	818431348.0001 ///TOTEM CHARITABLE FOUNDATION
			| bn == 	831440631.0001 ///The Tamarack Charitable Foundation Inc.
			| bn == 	850595471.0001 ///SASKATCHEWAN OBLATE TRUST FUND
			| bn == 	864266234.0001 ///DESTINY HEALTH & WELLNESS FOUNDATION
			| bn == 	864324041.0001 ///OUR LADY QUEEN OF PEACE RANCH (NORTHERN ALBERTA) LTD.
			| bn == 	868207564.0001 ///LONDON LIFE INSURANCE COMPANY EMPLOYEES' CHARITY TRUSTS
			| bn == 	868273087.0001 ///MCCARTHY TETRAULT FOUNDATION FONDATION MCCARTHY TETRAULT
			| bn == 	870034014.0001 ///THE POPPY FUND
			| bn == 	870302619.0001 ///THE WESTERN COMMUNITIES FOUNDATION
			| bn == 	872672134.0001 ///CO-OPERATORS FIFTIETH ANNIVERSARY COMMUNITY FUND
			| bn == 	880933627.0001 ///GORE MUTUAL INSURANCE COMPANY FOUNDATION
			| bn == 	887996296.0001 ///DELOITTE FOUNDATION CANADA/LA FONDATION DELOITTE CANADA
			| bn == 	888086758.0001 ///IMPERIAL OIL FOUNDATION/FONDATION PETROLIERE IMPERIALE
			| bn == 	889548970.0001 ///JASPER PLACE WELLNESS CENTRE
			| bn == 	890381882.0001 ///SUNCOR ENERGY FOUNDATION/FONDATION SUNCOR ENERGIE
			| bn == 	890599640.0001 ///SONY CANADA CHARITABLE FOUNDATION
			| bn == 	890629538.0001 ///MAPLE LODGE FARMS FOUNDATION
			| bn == 	890643273.0001 ///BEARSPAW BENEVOLENT FOUNDATION
			| bn == 	891653446.0001 ///The Ontario Paper Thorold Foundation
			| bn == 	892546342.0001 ///BROOKFIELD PARTNERS FOUNDATION
			| bn == 	892704859.0001 ///RBC FOUNDATION/RBC FONDATION
			| bn == 	893352963.0001 ///THE GLAXOSMITHKLINE FOUNDATION / LA FONDATION GLAXOSMITHKLINE
			| bn == 	893993196.0001 ///LOCAL 444 CANADIAN AUTO WORKERS SOCIAL JUSTICE FUND
			| bn == 	896114048.0001 // MLSE FOUNDATION
	
	
	// counts after dropping non-family foundations
	table (FISYR_NUM) (province2 designation_code), statistic(frequency) nototals
	
// save the data set
save "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/2017_to_2000_working.dta", replace

// generate paper 1 table 1
table (FISYR_NUM) (province2 designation_code), nototals nformat(%12.0fc)
