// package installations


// clear the results window
cls

// dissertation papers - paper 1, foundations
// Christopher Dougherty
// Last updated: June 11, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255 
set rmsg on

// open the data file

use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1236QualifiedDoneeWorksheet/T1236QualifiedDonneeWorksheet2000to2017.dta"

// move variables to the correct fields
	replace bn = 		bnregistrationnumber 	if bn 			== ""
	replace doneebn = 	doneebusinessnumber		if doneebn 		== ""
	
	tostring totalgifts, replace
	tostring specifiedgifts, replace
	replace totalgifts =	""						if totalgifts	== "."
	replace totalgifts =	totalamountofgifts		if totalgifts 	== ""
	replace totalgifts =	specifiedgifts			if totalgifts	== "0" | totalgifts == ""
	replace totalgifts =	amountofspecifiedgifts	if totalgifts	== "0" | totalgifts == ""
	
	tostring giftforpoliticalactivities, replace

// clean the business numbers
	label var 	bn 			"business number"
	label var 	doneebn		"business number of donee"
	
	foreach var in bn doneebn {

		capture confirm string variable `var'
                if !_rc {
					replace `var' = subinstr(`var',"O","0",.)
					replace `var' = subinstr(`var',"RR",".",.)
					replace `var' = subinstr(`var',"R",".",.)
					replace `var' = subinstr(`var',"P","",.)
					replace `var' = subinstr(`var',"-","",.)
					replace `var' = subinstr(`var'," ","",.)
					destring `var', replace force
					format `var' %15.4f
					
					// destringed bn should be nine digits plus four digits, if it's not then it is (i)ncomplete
					replace `var' = .i if `var' < 100000000
					replace `var' = .i if `var' > 999999999.9999
				}
	
	}

// clean the fiscal year number
	destring FISYR_NUM, replace
	drop if FISYR_NUM < 2000
	drop if FISYR_NUM > 2017

// clean the binary variables
	label define yesno ///
		1 "Yes" ///
		0 "No"

	foreach var in associated giftforpoliticalactivities {
		
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
	
	}
	
// clean the financial variables

	foreach var in totalgifts specifiedgifts totalamountofgifts amountofspecifiedgifts amountofenduringproperty amountofgiftsinkind politicalactivitiesgiftamount{

		// if the financial variable is a string, convert to numeric
		capture confirm string variable `var'
                if !_rc {
					replace `var' = subinstr(`var',"$","",.)
					replace `var' = subinstr(`var',",","",.)
					destring `var', replace
				}
				
		// if a value is missing, assume that it is 0
		replace `var' = 0 if `var' == .
		
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

save "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/T1236QDworksheet.dta", replace

// keep just the variables of interest

	keep 	bn ///
			doneebn ///
			associated ///
			totalgifts ///
			FISYR_NUM ///
			giftforpoliticalactivities ///
			politicalactivitiesgiftamount
			
// add in the province

	merge m:m FISYR_NUM bn using "2017_to_2000_working.dta", ///
		keepusing(province2 designation_code)
		
	// keep only gifts from private foundations
	keep if designation_code == 2
		
	drop if _merge != 3
	drop _merge

// save

	save, replace
