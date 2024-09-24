// package installations
ssc install mipolate, replace

// clear the results window
cls

// dissertation papers - paper 1, foundations
// this .do file creates the data set for regressions
// Christopher Dougherty
// Last updated: August 3, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255
set scrollbufsize 2048000 
set rmsg on

// set the working directory

cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/"

// prep the political candidates file
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Election results/politicalcandidates2000to2017.dta"

	// clean the riding names for merging
	replace riding = substr(riding, 1, strpos(riding, "/") - 1)  if strpos(riding, "/")
	replace riding = subinstr(riding, "--", "-", .)
	replace riding = subinstr(riding, " -", "", .)
	replace riding = subinstr(riding, "-", " ", .)
	forval n = 0/9{
		replace riding = subinstr(riding, "`n'", "", .)
	}
	replace riding = stritrim(strtrim(ustrtrim(strupper(riding))))
	replace riding = subinstr(riding, " ", "", .)
	
	// identified elected candidates
	gsort FISYR_NUM riding -votes_share_perc
	capture confirm variable elected 
	if (_rc != 0){
		egen elected = tag(FISYR_NUM riding)
	}	
	
	save, replace
	
	// create a federal electoral district file
	preserve 
	
		drop if pol_jurisdiction > 0
		drop if elected == 0
		
		gen last_elec_fed = FISYR_NUM
		rename riding 			ED_fed
		rename pol_party		pol_party_fed
		rename pol_alignment	pol_alignment_fed
		rename votes_total		votes_total_fed
		rename votes_share_perc votes_share_perc_fed	
		rename votes_HHI 		votes_HHI_fed
		
		duplicates drop province2 ED_fed FISYR_NUM, force	
		
		save electionresults2000to2017_fed.dta, replace
		
	restore
	
	// create a provincial electoral district file
	preserve 
	
		drop if pol_jurisdiction == 0
		drop if elected == 0
		
		gen last_elec_pro = FISYR_NUM
		rename riding 			ED_pro
		rename pol_party		pol_party_pro
		rename pol_alignment	pol_alignment_pro
		rename votes_total		votes_total_pro
		rename votes_share_perc votes_share_perc_pro	
		rename votes_HHI 		votes_HHI_pro
		
		duplicates drop province2 ED_pro FISYR_NUM, force	
		
		save electionresults2000to2017_pro.dta, replace
		
	restore
		
// prep the geographic file
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Postal Code Conversion File/PCCF_March2022.dta"

	global list_ridingnames ED_AB2003_name ED_AB2010_name ED_CA2001_name ED_CA2006_name ED_CA2011_name ED_CA2016_name ED_ON2001_name ED_ON2006_name ED_ON2011_name ED_ON2014_name

	// clean the riding names for merging
	foreach scenario of global list_ridingnames {
		replace `scenario' = substr(`scenario', 1, strpos(`scenario', "/") - 1)  if strpos(`scenario', "/")
		replace `scenario' = subinstr(`scenario', "--", "-", .)
		replace `scenario' = subinstr(`scenario', " -", "", .)
		replace `scenario' = subinstr(`scenario', "-", " ", .)
		forval n = 0/9{
			replace `scenario' = subinstr(`scenario', "`n'", "", .)
		}
		replace `scenario' = stritrim(strtrim(ustrtrim(strupper(`scenario'))))
		replace `scenario' = subinstr(`scenario', " ", "", .)
	}
	
	duplicates drop postal_code, force

	save, replace
	
// prep the private family foundation political contributions file
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/trustees2000to2017-privatefoundations-uniquenames.dta"
	sort idmaster
	save, replace

use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/matched-privatefoundationtrustee-politicaldonor.dta"

	drop _merge
	save, replace
	
	// merge in charity bn
	preserve
	
		drop Uprovince2 Uname_surname Uname_given reclink_id reclink_trustee id
		destring bn, replace
		collapse (count) pol_donor (mean) pol_alignment, by(FISYR_NUM idmaster pol_jurisdiction)
		duplicates tag idmaster FISYR_NUM, generate(duplicate)
		
		list idmaster FISYR_NUM if duplicate > 0
		
		sort idmaster
		save politicaldonor-individualscores-all.dta, replace
		
	restore
	
	use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/politicaldonor-individualscores-all.dta"
	
	preserve
	
		// create a federal alignment score file
		drop if pol_jurisdiction > 0
		
		// individual trustee alignment scores
		sort idmaster
		merge m:1 idmaster using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/trustees2000to2017-privatefoundations-uniquenames.dta", keepusing (bn)
		
		drop if _merge != 3
		drop _merge 
		
		save politicaldonor-individualscores-fed.dta, replace
		
		// bn level trustee alignment scores
		collapse (count) pol_donor (mean) pol_alignment, by(FISYR_NUM bn)
		rename pol_donor pol_donor_number_fed_bybn
		rename pol_alignment pol_alignment_fed_bybn
		
		sort FISYR_NUM bn
		
		save politicaldonor-bnscores-fed.dta, replace
		
	restore
	preserve
	
		// create a provincial alignment score file
		drop if pol_jurisdiction == 0
		
		// individual trustee alignment scores
		sort idmaster
		merge m:1 idmaster using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/trustees2000to2017-privatefoundations-uniquenames.dta", keepusing (bn)
		
		drop if _merge != 3
		drop _merge 
		
		save politicaldonor-individualscores-pro.dta, replace
		
		// bn level trustee alignment scores
		collapse (count) pol_donor (mean) pol_alignment, by(FISYR_NUM bn)
		rename pol_donor pol_donor_number_pro_bybn
		rename pol_alignment pol_alignment_pro_bybn
		
		sort FISYR_NUM bn
		
		save politicaldonor-bnscores-pro.dta, replace
		
	restore	

// add geographic information and election results to T3010 panel
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/2017_to_2000_working.dta"

	// merge in PCCF variables with electoral district variables
	merge m:1 postal_code using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Postal Code Conversion File/PCCF_March2022.dta"
	drop if bn == .
	drop _merge
	
	// move PCCF variables to one per jurisdiction per observation
	gen ED_fed = ""
	gen ED_pro = ""
	
	replace ED_fed = ED_CA2001_name if FISYR_NUM < 2006
	replace ED_fed = ED_CA2006_name if FISYR_NUM > 2005 & FISYR_NUM < 2011
	replace ED_fed = ED_CA2011_name if FISYR_NUM > 2010
	
	replace ED_pro = ED_ON2001_name if FISYR_NUM < 2007						& province2 == 35
	replace ED_pro = ED_ON2006_name if FISYR_NUM > 2006 & FISYR_NUM < 2011	& province2 == 35
	replace ED_pro = ED_ON2011_name if FISYR_NUM > 2010 & FISYR_NUM < 2014	& province2 == 35
	replace ED_pro = ED_ON2011_name if FISYR_NUM > 2013						& province2 == 35
	
	replace ED_pro = ED_AB2003_name if FISYR_NUM < 2012						& province2 == 48
	replace ED_pro = ED_AB2010_name if FISYR_NUM > 2011						& province2 == 48
	
	drop PR ED_AB2003_name ED_AB2003_number ED_AB2010_name ED_AB2010_number ED_CA2001_name ED_CA2001_number ED_CA2006_name ED_CA2006_number ED_CA2011_name ED_CA2011_number ED_CA2016_name ED_CA2016_number ED_ON2001_name ED_ON2001_number ED_ON2006_name ED_ON2006_number ED_ON2011_name ED_ON2011_number ED_ON2014_name ED_ON2014_number
	
	save, replace

// political parties
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
	
// add federal elections to T3010 panel
	gen last_elec_fed = .
		replace last_elec_fed = 2000 if FISYR_NUM < 2004
		replace last_elec_fed = 2004 if FISYR_NUM > 2003 & FISYR_NUM < 2006
		replace last_elec_fed = 2006 if FISYR_NUM > 2005 & FISYR_NUM < 2008
		replace last_elec_fed = 2008 if FISYR_NUM > 2007 & FISYR_NUM < 2011
		replace last_elec_fed = 2011 if FISYR_NUM > 2010 & FISYR_NUM < 2015
		replace last_elec_fed = 2015 if FISYR_NUM > 2014
		
	gen elec_year_fed = 0
		replace elec_year_fed = 1 if last_elec_fed == FISYR_NUM
	
	gen govt_fed = .
		replace govt_fed = 2100 if last_elec_fed == 2000
		replace govt_fed = 2100 if last_elec_fed == 2004
		replace govt_fed = 1300 if last_elec_fed == 2006
		replace govt_fed = 1300 if last_elec_fed == 2008
		replace govt_fed = 1300 if last_elec_fed == 2011
		replace govt_fed = 2100 if last_elec_fed == 2015
	
	gen govt_fed_HHI = .
		replace govt_fed_HHI = 0.39 if last_elec_fed == 2000
		replace govt_fed_HHI = 0.33 if last_elec_fed == 2004
		replace govt_fed_HHI = 0.31 if last_elec_fed == 2006
		replace govt_fed_HHI = 0.32 if last_elec_fed == 2008
		replace govt_fed_HHI = 0.41 if last_elec_fed == 2011
		replace govt_fed_HHI = 0.40 if last_elec_fed == 2015
		
// add provincial elections to T3010 panel 
	gen last_elec_pro = .
		// Ontario 2003, 2007, 2011, 2014
		replace last_elec_pro = 2003 if FISYR_NUM < 2007					& province2 == 35
		replace last_elec_pro = 2007 if FISYR_NUM > 2006 & FISYR_NUM < 2011	& province2 == 35
		replace last_elec_pro = 2011 if FISYR_NUM > 2010 & FISYR_NUM < 2014	& province2 == 35
		replace last_elec_pro = 2014 if FISYR_NUM > 2013 					& province2 == 35
		
		// Alberta 2011, 2004, 2008, 2012, 2015
		replace last_elec_pro = 2001 if FISYR_NUM < 2004					& province2 == 48
		replace last_elec_pro = 2004 if FISYR_NUM > 2003 & FISYR_NUM < 2008	& province2 == 48
		replace last_elec_pro = 2008 if FISYR_NUM > 2007 & FISYR_NUM < 2012	& province2 == 48
		replace last_elec_pro = 2012 if FISYR_NUM > 2011 & FISYR_NUM < 2015	& province2 == 48
		replace last_elec_pro = 2015 if FISYR_NUM > 2014 					& province2 == 48
	
	gen elec_year_pro = 0
		replace elec_year_pro = 1 if last_elec_pro == FISYR_NUM
	
	gen govt_pro = .
		// Ontario 2003, 2007, 2011, 2014
		replace govt_pro = 2135 if last_elec_pro == 2003 & province2 == 35
		replace govt_pro = 2135 if last_elec_pro == 2007 & province2 == 35
		replace govt_pro = 2135 if last_elec_pro == 2011 & province2 == 35
		replace govt_pro = 2135 if last_elec_pro == 2014 & province2 == 35
		
		// Alberta 2001, 2004, 2008, 2012, 2015
		replace govt_pro = 1148 if last_elec_pro == 2001 & province2 == 48
		replace govt_pro = 1148 if last_elec_pro == 2004 & province2 == 48
		replace govt_pro = 1148 if last_elec_pro == 2008 & province2 == 48
		replace govt_pro = 1148 if last_elec_pro == 2012 & province2 == 48
		replace govt_pro = 3148 if last_elec_pro == 2015 & province2 == 48
	
	gen govt_pro_HHI = .
		// Ontario 2003, 2007, 2011, 2014
		replace govt_pro_HHI = 0.55 if last_elec_pro == 2003 & province2 == 35
		replace govt_pro_HHI = 0.51 if last_elec_pro == 2007 & province2 == 35
		replace govt_pro_HHI = 0.39 if last_elec_pro == 2011 & province2 == 35
		replace govt_pro_HHI = 0.40 if last_elec_pro == 2014 & province2 == 35
		
		// Alberta 2001, 2004, 2008, 2012, 2015
		replace govt_pro_HHI = 0.80 if last_elec_pro == 2001 & province2 == 48
		replace govt_pro_HHI = 0.60 if last_elec_pro == 2004 & province2 == 48
		replace govt_pro_HHI = 0.76 if last_elec_pro == 2008 & province2 == 48
		replace govt_pro_HHI = 0.54 if last_elec_pro == 2012 & province2 == 48
		replace govt_pro_HHI = 0.46 if last_elec_pro == 2015 & province2 == 48
		
// save
	save, replace
	
// add election electoral district election results to T3010 panel
	// federal
	sort province2 ED_fed last_elec_fed
	merge m:1 province2 ED_fed last_elec_fed using "electionresults2000to2017_fed.dta", ///
		keepusing(pol_party_fed pol_alignment_fed votes_total_fed votes_share_perc_fed votes_HHI_fed elected)
		
	drop if _merge != 3
	drop _merge

	// provincial 
	sort province2 ED_pro last_elec_pro
	merge m:1 province2 ED_pro last_elec_pro using "electionresults2000to2017_pro.dta", ///
		keepusing(pol_party_pro pol_alignment_pro votes_total_pro votes_share_perc_pro votes_HHI_pro elected)

	drop if _merge != 3
	drop _merge
	
// save
	save, replace
	
// add whether the local representative is in government or opposition
	label values govt_fed pol_party

	gen ingov_fed = 0
	replace ingov_fed = 1 if govt_fed == pol_party_fed
	label values ingov_fed yesno
	
	label values govt_pro pol_party
	
	gen ingov_pro = 0 
	replace ingov_pro = 1 if govt_pro == pol_party_pro
	label values ingov_pro yesno
	
// save
	save, replace
	
// add bn level board trustee political alignment scores
	sort FISYR_NUM bn
	merge m:1 FISYR_NUM bn using "politicaldonor-bnscores-fed.dta", ///
		keepusing(pol_donor_number_fed_bybn pol_alignment_fed_bybn)
		
	drop _merge
	
	sort FISYR_NUM bn
	merge m:1 FISYR_NUM bn using "politicaldonor-bnscores-pro.dta", ///
		keepusing(pol_donor_number_pro_bybn pol_alignment_pro_bybn)
		
	drop _merge
	
	drop if bn == .
	
// save
	save, replace
	
// generate table summarizing bn level political alignments
table (province2 FISYR_NUM) () ///
	if designation_code == 2 ///
	& (pol_donor_number_fed_bybn < . | pol_donor_number_pro_bybn < .) ///
	, nototals ///
	statistic (mean pol_donor_number_fed_bybn pol_alignment_fed_bybn) ///
	statistic (count pol_donor_number_fed_bybn) /// 
	statistic (mean pol_donor_number_pro_bybn pol_alignment_pro_bybn) ///
	statistic (count pol_donor_number_pro_bybn)
	
// add in economic control variables

	// federal
	merge m:1 FISYR_NUM using "ControlData_fed.dta", ///
		keepusing(CADUSDExchange TSXCompositeIndexCloseMarch31 WTIUSDMarch12017dollars Population_fed GDPperCapita2017dollars GovBudgetRev_fed GovBudgetRev2017dollars_fed GovBudgetExp2017dollars_fed GovBudgetSurplus2017dollars_fed GovToCharity2017dollars_fed)
	
	drop _merge
	
	// provincial
	merge m:1 FISYR_NUM province2 using "ControlData_pro.dta", ///
		keepusing(Population_pro GDPperCapita2017dollars_pro GovBudgetRev2017dollars_pro GovBudgetExp2017dollars_pro GovBudgetSurplus2017dollars_pro GovToCharity2017dollars_pro)	
		
	drop if _merge != 3	
	drop _merge

// save
	save, replace
	
	
// create a private foundations only dataset
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/2017_to_2000_working.dta"

	preserve
		
		// drop the file down to just the private family foundations
		keep if designation_code == 2

		sort province2 bn FISYR_NUM
		merge m:m province2 bn FISYR_NUM using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1236QDworksheet.dta"
		drop if _merge == 2
		drop _merge
	
		save "2003_to_2017_working_privatefoundations_withgrants.dta", replace
		
	restore 

// create a charitable organizations only dataset
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/2017_to_2000_working.dta"

	preserve
		
		// drop the file down to just the private family foundations
		keep if designation_code == 0
		rename 	bn 			doneebn
		rename	province2	doneeprovince
		rename 	ED_fed		donee_ED_fed
		rename	ED_pro		donee_ED_pro
		
		sort doneebn FISYR_NUM
		merge m:m doneebn FISYR_NUM using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1236QDworksheet.dta"
		drop if _merge == 2
		drop _merge
	
		save "2003_to_2017_working_charitiess_withgrants.dta", replace
		
		// add subsector categories
		gen subsector = 0
		order subsector, after(charitable_head)
		
		label define subsector ///
			1 	"Post-secondary" /// 
			2	"Support of schools" ///
			3	"Education" ///
			4	"Religion: Christian" ///
			5	"Religion: Muslim" ///
			6	"Religion: Jewish" ///
			7	"Religion: Other" ///
			8	"Religion: Missionary" ///
			9	"Service clubs" ///
			10	"Social services" ///
			11	"Arts and culture" ///
			12	"Parks and environment" ///
			13	"Hospitals" ///
			14	"Health exc. hospitals" ///
			15	"Disaster funds" ///
			16	"Animal welfare" ///
			17	"Other" ///
			, replace
		
		replace subsector = 1 if ///
			category_code == 20
		
		replace subsector = 2 if ///
			category_code == 21
		
		replace subsector = 3 if ///
			category_code == 23 | ///
			category_code == 25 | ///
			category_code == 29
			
		replace subsector = 4 if ///
			category_code == 30 | ///
			category_code == 31 | ///
			category_code == 32 | ///
			category_code == 34 | ///
			category_code == 36 | ///
			category_code == 37 | ///
			category_code == 38 | ///
			category_code == 40 | ///
			category_code == 41 | ///
			category_code == 44 | ///
			category_code == 46 | ///
			category_code == 61
			
		replace subsector = 5 if ///
			category_code == 60
			
		replace subsector = 6 if ///
			category_code == 42
			
		replace subsector = 7 if ///
			category_code == 33 | ///
			category_code == 35 | ///
			category_code == 39 | ///
			category_code == 43 | ///
			category_code == 45 | ///
			category_code == 62
			
		replace subsector = 8 if ///
			category_code == 47
			
		replace subsector = 9 if ///
			category_code == 63 | ///
			category_code == 65
			
		replace subsector = 10 if ///
			category_code == 1 | ///
			category_code == 3 | ///
			category_code == 5
			
		replace subsector = 11 if ///
			category_code == 22 | ///
			category_code == 50 | ///
			category_code == 52 | ///
			category_code == 81
			
		replace subsector = 12 if ///
			category_code == 56
			
		replace subsector = 13 if ///
			category_code == 10
			
		replace subsector = 14 if ///
			category_code == 11 | ///
			category_code == 13 | ///
			category_code == 15 | ///
			category_code == 19 | ///
			category_code == 57
			
		replace subsector = 15 if ///
			category_code == 2
			
		replace subsector = 16 if ///
			category_code == 54
			
		replace subsector = 17 if ///
			subsector == 0 
			
		label values subsector subsector
		
		table (subsector)(FISYR_NUM)(doneeprovince), nototals statistic(sum totalgifts) statistic(count totalgifts)
		
		save "2003_to_2017_working_charitiess_withgrants.dta", replace	
		
	restore 

// merge in donor foundation data to charitable organization dataset 
use "2003_to_2017_working_charitiess_withgrants.dta"

	sort province2 doneebn bn FISYR_NUM totalgifts
	drop province2 pol_donor_number_fed_bybn pol_alignment_fed_bybn pol_donor_number_pro_bybn pol_alignment_pro_bybn
	merge m:m doneebn bn FISYR_NUM totalgifts using "2003_to_2017_working_privatefoundations_withgrants.dta", ///
		keepusing (province2 ED_fed ED_pro pol_donor_number_fed_bybn pol_alignment_fed_bybn pol_donor_number_pro_bybn pol_alignment_pro_bybn)
	drop if _merge == 2
	drop _merge
	
	// identify if the donor and donee are in the same electoral districts
	gen share_ED_fed = 0
	replace share_ED_fed = 1 if ED_fed == donee_ED_fed
	label values share_ED_fed yesno

	gen share_ED_pro = 0
	replace share_ED_pro = 1 if ED_pro == donee_ED_pro
	label values share_ED_pro yesno
	
	// create a flag for receiving a gift from a foundation
	gen foundation_funded = 0
	replace foundation_funded = 1 if bn < .
	
	// create flags for foundations ever having a poltiical alignment during the full panel
	// federal
	egen pol_alignment_fed_ever = total(pol_donor_number_fed_bybn), by(bn)
	replace pol_alignment_fed_ever = 1 if pol_alignment_fed_ever > 0
	
	// provincial
	egen pol_alignment_pro_ever = total(pol_donor_number_pro_bybn), by(bn)
	replace pol_alignment_pro_ever = 1 if pol_alignment_pro_ever > 0
	
	// fill in missing alignment dataset
	// federal
	mipolate pol_alignment_fed_bybn FISYR_NUM if pol_alignment_fed_ever == 1, generate(pol_alignment_fed_inter) nearest
	
	// provincial
	mipolate pol_alignment_pro_bybn FISYR_NUM if pol_alignment_pro_ever == 1, generate(pol_alignment_pro_inter) nearest
	
	// create a flag for above or below the median federal political alignment
	gen pol_alignment_fed_abovemedian = 0
	replace pol_alignment_fed_abovemedian = 1 if pol_alignment_fed_inter >  2.417407
	label values pol_alignment_fed_abovemedian yesno
	
	// create a flag for abover or below the median provincial political alignment
	gen pol_alignment_pro_abovemedian = 0
	replace pol_alignment_pro_abovemedian = 1 if pol_alignment_pro_inter >  2.867958 & province2 == 35
	replace pol_alignment_pro_abovemedian = 1 if pol_alignment_pro_inter >  2.867958 & province2 == 48
	label values pol_alignment_pro_abovemedian yesno
	
	// describe the new variables
	table (foundation_funded)(FISYR_NUM), ///
		statistic(count pol_alignment_fed_ever pol_alignment_pro_ever) ///
		statistic(mean pol_alignment_fed_inter pol_alignment_pro_inter) ///
		nototals
	
	// create a dichotomous flag for giving
	gen give_flag = 0
	replace give_flag = 1 if totalgifts > 0
	
// create a political alignment of donors variable for foundation funded operating charities

	sort doneebn FISYR_NUM
	
	// provincial
	egen pol_alignment_fed_donee = mean(pol_alignment_fed_inter), by(doneebn FISYR_NUM)
	
	// federal
	egen pol_alignment_pro_donee = mean(pol_alignment_pro_inter), by(doneebn FISYR_NUM)
	
	
save "2003_to_2017_panelforanalysis_paper1.dta", replace
