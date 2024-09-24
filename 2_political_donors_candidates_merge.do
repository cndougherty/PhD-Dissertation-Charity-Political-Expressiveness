
// package installations
ssc install reclink, replace
ssc install groups, replace

// clear the results window
cls

// dissertation papers - paper 1, foundations
// this .do file creates a merged set of federal and provincial political donors and candidates from years 2000 through 2017
// Christopher Dougherty
// Last updated: June 6, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255
set scrollbufsize 2048000 
set rmsg on

// use the private foundation trustee list for matching
cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/"
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/trustees2000to2017-privatefoundations.dta"

// collapse the data so that it's just unique names
collapse (firstnm) name_full name_surname name_given, by (bn id province2)
gen idmaster = _n
save trustees2000to2017-privatefoundations-uniquenames.dta, replace

// match private foundation trustee list to political donors
	use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Contributions/politicaldonors2000to2017.dta"

	reclink name_given name_surname province2 using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/trustees2000to2017-privatefoundations-uniquenames.dta", idmaster(reclink_id) idusing(idmaster) gen(reclink_trustee) wmatch(5 10 20) minscore(0.9) orblock(province2)

	// remove unlikely matches
	// threshold for dropping probababilistic matches based on visual inspection of data
	drop if reclink_trustee < 0.9958 
	drop if reclink_trustee == .
	
	// drop if surname first letter doesn't match
	drop if substr(name_surname, 1, 1) != substr(Uname_surname, 1, 1) 
	
	// drop if middle initial doesn't match
	drop if (substr(name_given, -2, 1) == " ") & (substr(name_given, -1, .) != substr(Uname_given, -1, .)) 
	
	// fix the missing political jurisdiction
	replace pol_jurisdiction = mod(pol_party, 100) 
	
	// add in variables for working with individual donors
	egen pol_donor_count = total(pol_donor), by(id)
	egen pol_donor_justone = tag(id)
	
	// save a matching donor - trustee data file
	save "matched-privatefoundationtrustee-politicaldonor.dta", replace

	// create tables for the paper
	table (FISYR_NUM) (province2 pol_jurisdiction pol_alignment), nototals
	
	table () (province2 pol_jurisdiction pol_alignment ) if pol_donor_justone == 1, nototals statistic(count pol_donor_justone) statistic(mean pol_donor_count) statistic(min pol_donor_count) statistic(q1 pol_donor_count) statistic(median pol_donor_count) statistic(q3 pol_donor_count) statistic(max pol_donor_count)
	
	tabstat pol_alignment, statistics(n mean sd) by(id)
	bysort province2 pol_jurisdiction: tabstat pol_alignment, statistics(n mean sd) by(id)


// match private foundation trustee list to political candidates
	use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Election results/politicalcandidates2000to2017.dta"

	reclink name_given name_surname province2 using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/trustees2000to2017-privatefoundations-uniquenames.dta", idmaster(reclink_id) idusing(idmaster) gen(reclink_trustee) wmatch(5 10 20) minscore(0.9) orblock(province2)

	// remove unlikely matches
	// threshold for dropping probababilistic matches based on visual inspection of data
	drop if reclink_trustee < 0.9958 
	drop if reclink_trustee == .
	
	// drop if surname first letter doesn't match
	drop if substr(name_surname, 1, 1) != substr(Uname_surname, 1, 1) 
	
	// drop if middle initial doesn't match
	drop if (substr(name_given, -2, 1) == " ") & (substr(name_given, -1, .) != substr(Uname_given, -1, .)) 
	
	// save a matching donor - trustee data file
	save "matched-privatefoundationtrustee-politicalcandidate.dta", replace

	table (province2 pol_jurisdiction pol_alignment) FISYR_NUM, nototals
