// package installations
ssc install fillmissing, replace

// clear the results window
cls

// dissertation papers - paper 3, inddividuals
// this .do file assembles control data for use in paper 3
// Christopher Dougherty
// Last updated: July 9, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255
set scrollbufsize 2048000 
set rmsg on

// set the working directory

cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/"

// use the provincial control data file

	use ControlData_pro.dta
	
	drop if FISYR_NUM < 2003
	drop if FISYR_NUM > 2017
	
	save ControlData_paper3.dta, replace 
	
// merge in PCCF variables with electoral district variables
	joinby province2 using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Postal Code Conversion File/PCCF_March2022.dta" 

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
	
	save ControlData_paper3.dta, replace 
	
// merge in federal control data

	joinby FISYR_NUM using "ControlData_fed.dta"
	
	drop if FISYR_NUM < 2003
	
	save ControlData_paper3.dta, replace 

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
	save ControlData_paper3.dta, replace 
	
// add election electoral district election results to T3010 panel
	// remove spaces from riding names
	global list_ridingnames ED_fed ED_pro

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

	save, replace

	// federal
	sort FISYR_NUM province2 ED_fed last_elec_fed
	joinby FISYR_NUM province2 ED_fed last_elec_fed using "electionresults2000to2017_fed.dta", unmatched(master)
	
	drop if FISYR_NUM < 2003
	drop if FISYR_NUM > 2017
	
	drop _merge

	// provincial 
	sort FISYR_NUM province2 ED_pro last_elec_pro
	joinby FISYR_NUM province2 ED_pro last_elec_pro using "electionresults2000to2017_pro.dta", unmatched(master)

	drop if FISYR_NUM < 2003
	drop if FISYR_NUM > 2017
	
	drop _merge
	
// save
	save ControlData_paper3.dta, replace 
	
// drop unneeded variables
	drop electiondate pol_jurisdiction name_surname name_given name_full trustee pol_candidate pol_donor id reclink_id elected
	
// fill in missing data
	sort postal_code FISYR_NUM
	global list_fill pol_party_fed pol_alignment_fed votes_total_fed votes_share_perc_fed votes_HHI_fed pol_party_pro pol_alignment_pro votes_total_pro votes_share_perc_pro votes_HHI_pro
	
	foreach scenario of global list_fill {
		bysort postal_code (FISYR_NUM): fillmissing `scenario', with(previous)
	}
	
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
	save ControlData_paper3.dta, replace 
