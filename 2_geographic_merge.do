// package installations
ssc install shp2dta, replace
ssc install geoinpoly, replace

// clear the results window
cls

// dissertation papers - paper 1, foundations
// this .do file creates a set of geographic control data
// Christopher Dougherty
// Last updated: June 8, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255
set scrollbufsize 2048000 
set rmsg on

// open the Postal Code Conversion File (PCCF), used under licence - DO NOT DISTRIBUTE
use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Postal Code Conversion File/PCCF_March2022.dta"

// adapt the PCCF to the data set

	// remove unneeded variables
	keep 	PC ///
			FSA ///
			PR ///
			CSDuid ///
			CSDname ///
			CTname ///
			LAT ///
			LONG
			
	// destring variables
	destring(CTname), replace
	destring(LAT), replace
	destring(LONG), replace
			
	// add the province2 variables
	gen province2 = PR
	
	label var province2 "region: province"
	label values province2 province2
	
	tab2 province province2
	
	// drop if province is not AB or ON
	keep if province2 == 35 | province2 == 48

	tab2 province province2
	
// use geoinpoly to identify electoral districts
	// Alberta provincial 2003
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/AB2003coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/AB2003data.dta"
	drop if LAT == . | LONG == .
	
	drop EDPROV OBJECTID _ID _merge
	rename EDNUMBER 	ED_AB2003_number
	rename EDNAME 		ED_AB2003_name
	
	// Alberta provincial 2010
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/AB2010coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/AB2010data.dta"
	drop if LAT == . | LONG == .
	
	drop _ID SHAPE_Leng SHAPE_Area AUTHORITY _merge
	rename EDNum2010 	ED_AB2010_number
	rename EDName2010 	ED_AB2010_name
	
	// Canada federal 2001
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2001coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2001data.dta"
	drop if LAT == . | LONG == .
	
	drop _ID AREA PERIMETER GFED000B04 GFED000B_1 PRUID _merge
	rename FEDNAME 		ED_CA2001_name
	rename FEDUID		ED_CA2001_number
	
	// Canada federal 2006
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2006coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2006data.dta"
	drop if LAT == . | LONG == .
	
	drop _ID FEDENAME FEDFNAME PRUID first_elect_date jurisdiction _merge
	rename FEDNAME 		ED_CA2006_name
	rename FEDUID		ED_CA2006_number
	
	// Canada federal 2011
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2011coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2011data.dta"
	drop if LAT == . | LONG == .
	
	drop _ID FEDENAME FEDFNAME PRUID PRNAME first_elect_date jurisdiction _merge
	rename FEDNAME 		ED_CA2011_name
	rename FEDUID		ED_CA2011_number
	
	// Canada federal 2016
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2016coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/CA2016data.dta"
	drop if LAT == . | LONG == .
	
	drop _ID FEDENAME FEDFNAME PRUID PRNAME _merge
	rename FEDNAME 		ED_CA2016_name
	rename FEDUID		ED_CA2016_number
	
	// Ontario provincial 2001 - matched federal boundaries
	gen ED_ON2001_name 		= ED_CA2001_name
	gen ED_ON2001_number 	= ED_CA2001_number
	
	// Ontario provincial 2006
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/ON2006coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/ON2006data.dta"
	drop if LAT == . | LONG == .
	
	drop _ID FEDENAME FEDFNAME PRUID first_elect_date jurisdiction _merge
	rename FEDNAME 		ED_ON2006_name
	rename FEDUID		ED_ON2006_number
	
	// Ontario provincial 2011
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/ON2011coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/ON2011data.dta"
	drop if LAT == . | LONG == .
	
	drop _ID FRENCH_NAM ELECTORAL_ LEGAL_DESC VALIDATION EVENT_ID EVENT_STAT LO_REGION_ POLL_OPEN_ KPI* UPDATE_* DATE* DATA* ED_BOUNDAR OBJECTID SHAPE* _merge
	rename ENGLISH_NA	ED_ON2011_name
	rename ED_ID		ED_ON2011_number
	
	// Ontario provincial 2014
	geoinpoly LAT LONG using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/ON2014coor.dta"
	
	sort _ID
	merge m:1 _ID using "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Shape files/StataShp/ON2014data.dta"
	drop if LAT == . | LONG == .	

	drop _ID FRENCH_NAM ELECTORAL_ LEGAL_DESC VALIDATION EVENT_ID EVENT_STAT LO_REGION_ POLL_OPEN_ KPI* UPDATE_* DATE* DATA* ED_BOUNDAR OBJECTID SHAPE* _merge
	rename ENGLISH_NA	ED_ON2014_name
	rename ED_ID		ED_ON2014_number
	
// order and clean the variables
	order 	PC ///
			FSA ///
			PR	///
			province2 ///
			LAT ///
			LONG ///
			CSDuid ///
			CSDname ///
			CTname ///
			
	rename PC postal_code		
	
	order 	ED_*, alphabetic after(CTname)
	
	label variable ED_AB2003_name 	"" 
	label variable ED_AB2003_number "" 
	label variable ED_AB2010_name  	"" 
	label variable ED_AB2010_number "" 
	label variable ED_CA2001_name  	"" 
	label variable ED_CA2001_number "" 
	label variable ED_CA2006_name  	"" 
	label variable ED_CA2006_number "" 
	label variable ED_CA2011_name  	"" 
	label variable ED_CA2011_number "" 
	label variable ED_CA2016_name  	"" 
	label variable ED_CA2016_number "" 
	label variable ED_ON2001_name  	"" 
	label variable ED_ON2001_number "" 
	label variable ED_ON2006_name  	"" 
	label variable ED_ON2006_number "" 
	label variable ED_ON2011_name  	"" 
	label variable ED_ON2011_number "" 
	label variable ED_ON2014_name  	"" 
	label variable ED_ON2014_number ""

	destring (ED_AB2003_number ED_AB2010_number ED_AB2010_number ED_CA2001_number ED_CA2006_number ED_CA2011_number ED_CA2016_number ED_ON2001_number ED_ON2006_number ED_ON2011_number ED_ON2014_number), replace
	
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
	
// save the file
save "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/Postal Code Conversion File/PCCF_March2022.dta", replace
