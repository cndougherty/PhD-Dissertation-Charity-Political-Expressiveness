// package installations


// clear the results window
cls

// dissertation papers - paper 2, governments
// this .do file uses 2003_to_2017_panelforanalysis_paper2.dta to run tests and regressions for paper 2
// Christopher Dougherty
// Last updated: JAugust 5, 2024

// template commands
capture log close
clear all
macro drop _all
set linesize 255
set scrollbufsize 2048000 
set rmsg on

// set the working directory

cd "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/"

// set up the file for the panel

use "/Users/christopher/Library/CloudStorage/Dropbox/School - Carleton PhD/--- THESIS ---/DATA/2003_to_2017_panelforanalysis_paper1.dta"

	save 2003_to_2017_panelforanalysis_paper2.dta, replace

	// remove stuff not needed for this paper
	// private foundations
	
	drop if designation_code == 2
	drop 	bn ///
			associated ///
			totalgifts ///
			giftforpoliticalactivities ///
			politicalactivitiesgiftamount ///
			province2 ///
			ED_fed ///
			ED_pro ///
			pol_donor_number_fed_bybn ///
			pol_alignment_fed_bybn ///
			pol_donor_number_pro_bybn ///
			pol_alignment_pro_bybn ///
			share_ED_fed ///
			share_ED_pro ///
			foundation_funded ///
			pol_alignment_fed_ever ///
			pol_alignment_pro_ever ///
			pol_alignment_fed_inter ///
			pol_alignment_pro_inter ///
			give_flag ///
			pol_alignment_fed_abovemedian
			
	// NOTE, keeping the two variables for the averaged annual political alignment of foundaiton funding from private family foundations
	// pol_alignment_fed_donee ///
	// pol_alignment_pro_donee ///
	
	save 2003_to_2017_panelforanalysis_paper2.dta, replace 
	
// use the data for the panel

	use 2003_to_2017_panelforanalysis_paper2.dta

// set up flags for multilevel analysis

	sort doneeprovince FISYR_NUM donee_ED_fed donee_ED_pro doneebn

	egen justone_pro 	= tag(doneeprovince FISYR_NUM)
	egen justone_ED_fed = tag(doneeprovince FISYR_NUM donee_ED_fed)
	egen justone_ED_pro = tag(doneeprovince FISYR_NUM donee_ED_pro)
	egen justone_bn		= tag(doneeprovince FISYR_NUM doneebn)
	
	save, replace
	
// add in new government flags
	
	gen newgov_fed 			= 0
	replace newgov_fed 		= 1 if FISYR_NUM == 2006
	replace newgov_fed 		= 1 if FISYR_NUM == 2016	
	
	gen newgov_pro_ON 		= 0
	replace newgov_pro_ON 	= 1 if FISYR_NUM == 2004
	
	gen newgov_pro_AB		= 0
	replace newgov_pro_AB	= 1	if FISYR_NUM == 2016
	
	save, replace
	
// modify the government financial variables to millions of dollars
	replace GovBudgetRev2017dollars_fed 	= GovBudgetRev2017dollars_fed 		/ 1000000
	replace GovBudgetExp2017dollars_fed 	= GovBudgetExp2017dollars_fed 		/ 1000000
	replace GovBudgetSurplus2017dollars_fed = GovBudgetSurplus2017dollars_fed 	/ 1000000
	replace GovToCharity2017dollars_fed 	= GovToCharity2017dollars_fed 		/ 1000000
	
	replace GovBudgetRev2017dollars_pro 	= GovBudgetRev2017dollars_pro 		/ 1000000
	replace GovBudgetExp2017dollars_pro 	= GovBudgetExp2017dollars_pro 		/ 1000000
	replace GovBudgetSurplus2017dollars_pro = GovBudgetSurplus2017dollars_pro 	/ 1000000
	replace GovToCharity2017dollars_pro		= GovToCharity2017dollars_pro 		/ 1000000
	
	save, replace
	
// run the provincial level analysis using just the control data

	preserve 

	// use the control data file
	use ControlData.dta
	
	// adjust financial variables to millions of dollars
	replace GovBudgetRev2017dollars 		= GovBudgetRev2017dollars			/ 1000000
	replace GovBudgetExp2017dollars 		= GovBudgetExp2017dollars			/ 1000000
	replace GovBudgetSurplus2017dollars 	= GovBudgetSurplus2017dollars		/ 1000000
	replace GovTransfersToCharity2017dollars = GovTransfersToCharity2017dollars	/ 1000000
	gen HHI2 = LegHHI^2
	gen HHI3 = LegHHI^3
	
	// set up panel
	xtset Jurisdiction0Fed1On2Ab GovFiscalYearEndMarch31

	// panel regression
	xtreg GovTransfersToCharity2017dollars ///
		il(0/2).GeneralElectionYear ///
		il(0/2).GovChange ///
		i.PartyInPower1Cons2Lib3NDP ///
		i.StrengthOfPower3Maj2Min1Coa ///
		LegHHI ///
		GDPperCapita2017dollars ///
		, fe vce(robust) allbase
	
	restore
	
// run electoral district level analysis using the panel data
	
	use 2003_to_2017_panelforanalysis_paper2.dta
	
	// identify and remove duplicate returns
	duplicates drop FISYR_NUM doneebn, force
	
	
	// CHANGE THE DATASET TO SIMPLIFY ANALYSIS BASED ON JULY 12 CONVERSATION WITH NATHAN
		// collapse support of education into education
		replace subsector = 3 if subsector == 2
		
		// drop disaster relief due to small number of observations
		drop if subsector == 15

	// generate riding level transfer to charity values in millions of 2017 dollars
	
	egen gov_trans_charity_fed_fedED 		= total(_4560), by (FISYR_NUM donee_ED_fed)
		replace gov_trans_charity_fed_fedED = gov_trans_charity_fed_fedED / 1000
	egen gov_trans_charity_pro_fedED 		= total(_4550), by (FISYR_NUM donee_ED_fed)
		replace gov_trans_charity_pro_fedED = gov_trans_charity_pro_fedED / 1000
	egen gov_trans_charity_mun_fedED 		= total(_4540), by (FISYR_NUM donee_ED_fed)
		replace gov_trans_charity_mun_fedED = gov_trans_charity_mun_fedED / 1000
	
	egen gov_trans_charity_fed_proED 		= total(_4560), by (FISYR_NUM donee_ED_pro)
		replace gov_trans_charity_fed_proED = gov_trans_charity_fed_proED / 1000
	egen gov_trans_charity_pro_proED 		= total(_4550), by (FISYR_NUM donee_ED_pro)
		replace gov_trans_charity_pro_proED = gov_trans_charity_pro_proED / 1000
	egen gov_trans_charity_mun_proED 		= total(_4540), by (FISYR_NUM donee_ED_pro)
		replace gov_trans_charity_mun_proED = gov_trans_charity_mun_proED / 1000
	
	// generate riding level transfer to charity EXCLUDING POST-SECONDARY (1) AND HOSPITALS (13) in millions of 2017 dollars
	
	egen gov_trans_charity_fed_fedEDxPSH 		= total(_4560) if subsector != 1 & subsector != 13, by (FISYR_NUM donee_ED_fed)
		replace gov_trans_charity_fed_fedEDxPSH = gov_trans_charity_fed_fedEDxPSH / 1000
	egen gov_trans_charity_pro_fedEDxPSH 		= total(_4550) if subsector != 1 & subsector != 13, by (FISYR_NUM donee_ED_fed)
		replace gov_trans_charity_pro_fedEDxPSH = gov_trans_charity_pro_fedEDxPSH / 1000
	egen gov_trans_charity_mun_fedEDxPSH 		= total(_4540) if subsector != 1 & subsector != 13, by (FISYR_NUM donee_ED_fed)
		replace gov_trans_charity_mun_fedEDxPSH = gov_trans_charity_mun_fedEDxPSH / 1000
	
	egen gov_trans_charity_fed_proEDxPSH 		= total(_4560) if subsector != 1 & subsector != 13, by (FISYR_NUM donee_ED_pro)
		replace gov_trans_charity_fed_proEDxPSH = gov_trans_charity_fed_proEDxPSH / 1000
	egen gov_trans_charity_pro_proEDxPSH 		= total(_4550) if subsector != 1 & subsector != 13, by (FISYR_NUM donee_ED_pro)
		replace gov_trans_charity_pro_proEDxPSH = gov_trans_charity_pro_proEDxPSH / 1000
	egen gov_trans_charity_mun_proEDxPSH 		= total(_4540) if subsector != 1 & subsector != 13, by (FISYR_NUM donee_ED_pro)
		replace gov_trans_charity_mun_proEDxPSH = gov_trans_charity_mun_proEDxPSH / 1000
	
	save, replace
	
	// generate organizational level log values of transfers from governments
	replace _4540 = 1 if _4540 < 1
	gen _4540log = ln(_4540)
	
	replace _4550 = 1 if _4550 < 1
	gen _4550log = ln(_4550)
	
	replace _4560 = 1 if _4560 < 1
	gen _4560log = ln(_4560)
	
	save, replace
	
	// set up panel 
	xtset doneebn FISYR_NUM
	
	collect create FED_PRO, replace 
	
	// federal transfers to Ontario charities
	quietly: collect get _r_b _r_p e(), tag(models["FED-ON"]): xtreg gov_trans_charity_fed_fedED ///
		l.gov_trans_charity_fed_fedED /// 
		il(0/1).elec_year_fed ///
		il(0/1).newgov_fed /// 
		i.govt_fed ///
		i.pol_party_fed ///
		votes_HHI_fed ///
		ib1.ingov_fed ///
		if doneeprovince == 35 ///
		& justone_ED_fed == 1 ///
		, fe vce(robust) allbase
		
	// federal transfers to Ontario charities EXCLUDE HOSPITALS AND POSTSECONDARY
	quietly: collect get _r_b _r_p e(), tag(models["FED-ONxPSH"]): xtreg gov_trans_charity_fed_fedEDxPSH ///
		l.gov_trans_charity_fed_fedEDxPSH ///
		il(0/1).elec_year_fed ///
		il(0/1).newgov_fed /// 
		i.govt_fed ///
		i.pol_party_fed ///
		votes_HHI_fed ///
		ib1.ingov_fed ///
		if doneeprovince == 35 ///
		& justone_ED_fed == 1 ///
		, fe vce(robust) allbase
	
	// federal transfers to Alberta charities 
	quietly: collect get _r_b _r_p e(), tag(models["FED-AB"]): xtreg gov_trans_charity_fed_fedED ///
		l.gov_trans_charity_fed_fedED ///
		il(0/1).elec_year_fed ///
		il(0/1).newgov_fed /// 
		i.govt_fed ///
		i.pol_party_fed ///
		votes_HHI_fed ///
		ib1.ingov_fed ///
		if doneeprovince == 48 ///
		& justone_ED_fed == 1 ///
		, fe vce(robust) allbase
		
	// federal transfers to Alberta charities EXCLUDE HOSPITALS AND POSTSECONDARY
	quietly: collect get _r_b _r_p e(), tag(models["FED-ABxPSH"]): xtreg gov_trans_charity_fed_fedEDxPSH ///
		l.gov_trans_charity_fed_fedEDxPSH ///
		il(0/1).elec_year_fed ///
		il(0/1).newgov_fed /// 
		i.govt_fed ///
		i.pol_party_fed ///
		votes_HHI_fed ///
		ib1.ingov_fed ///
		if doneeprovince == 48 ///
		& justone_ED_fed == 1 ///
		, fe vce(robust) allbase
		
	// results table
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
	collect style showbase factor
	collect style header, title(hide) level(label)
	collect style column, width(asis)
	collect style row stack, binder(":")
	collect style cell result[_r_b r2_w r2_b r2_o rho], nformat(%-9.4f)
	
	collect levelsof models
	collect layout (colname#result[_r_b]) (models) 
	collect layout (result[r2_w r2_b r2_o rho N_g]) (models)	
	
	// clear the collect data
	collect drop _all
	
	// PROVINCIAL TRANSFERS TO CHARITIES
	collect create PRO_PRO, replace
	
	// provincial transfers to Ontario charities
	quietly: collect get _r_b _r_p e(), tag(models["PRO-ON"]): xtreg gov_trans_charity_pro_proED ///
		l.gov_trans_charity_pro_proED ///
		il(0/1).elec_year_pro ///
		il(0/1).newgov_pro_ON ///
		i.govt_pro ///
		i.pol_party_pro ///
		ib1.ingov_pro ///
		votes_HHI_pro ///
		if doneeprovince == 35 ///
		& justone_ED_pro == 1 ///
		, fe vce(robust) allbase
		
	// provincial transfers to Ontario charities EXCLUDE HOSPITALS AND POSTSECONDARY
	quietly: collect get _r_b _r_p e(), tag(models["PRO-ONxPSH"]): xtreg gov_trans_charity_pro_proEDxPSH ///
		l.gov_trans_charity_pro_proEDxPSH ///
		il(0/1).elec_year_pro ///
		il(0/1).newgov_pro_ON ///
		i.govt_pro ///
		i.pol_party_pro ///
		ib1.ingov_pro ///
		votes_HHI_pro ///
		if doneeprovince == 35 ///
		& justone_ED_pro == 1 ///
		, fe vce(robust) allbase
		
	// results table
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
	collect style showbase factor
	collect style header, title(hide) level(label)
	collect style column, width(asis)
	collect style row stack, binder(":")
	collect style cell result[_r_b r2_w r2_b r2_o rho], nformat(%-9.4f)
	
	collect levelsof models
	collect layout (colname#result[_r_b]) (models) 
	collect layout (result[r2_w r2_b r2_o rho N_g]) (models)
	
	// clear the collect data
	collect drop _all
	
	// provincial transfers to Alberta charities 
	quietly: collect get _r_b _r_p e(), tag(models["PRO-AB"]): xtreg gov_trans_charity_pro_proED ///
		l.gov_trans_charity_pro_proED ///
		il(0/1).elec_year_pro ///
		il(0/1).newgov_pro_AB ///
		i.govt_pro ///
		i.pol_party_pro ///
		ib1.ingov_pro ///
		votes_HHI_pro ///
		if doneeprovince == 48 ///
		& justone_ED_pro == 1 ///
		, fe vce(robust) allbase
	
	// provincial transfers to Alberta charities EXCLUDE HOSPITALS AND POSTSECONDARY
	quietly: collect get _r_b _r_p e(), tag(models["PRO-ABxPSH"]): xtreg gov_trans_charity_pro_proEDxPSH ///
		l.gov_trans_charity_pro_proEDxPSH ///
		il(0/1).elec_year_pro ///
		il(0/1).newgov_pro_AB ///
		i.govt_pro ///
		i.pol_party_pro ///
		ib1.ingov_pro ///
		votes_HHI_pro ///
		if doneeprovince == 48 ///
		& justone_ED_pro == 1 ///
		, fe vce(robust) allbase	
		
	// results table
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
	collect style showbase factor
	collect style header, title(hide) level(label)
	collect style column, width(asis)
	collect style row stack, binder(":")
	collect style cell result[_r_b r2_w r2_b r2_o rho], nformat(%-9.4f)
	
	collect levelsof models
	collect layout (colname#result[_r_b]) (models) 
	collect layout (result[r2_w r2_b r2_o rho N_g]) (models)
	
	// clear the collect data
	collect drop _all
	
// run organization level analysis, segmented by subsector

	levelsof subsector, local(levels)
	
	// loop through subsectors in Ontario
	collect create _4540_ON, replace
	foreach l of local levels {
		
		// federal government revenue
		display `"`l'"'
		display "federal to Ontario" _continue
		
		quietly: collect get _r_b _r_p e(), tag(models[`l']): xtreg _4540log ///
			l._4540log ///
			il(0/1).elec_year_fed ///
			il(0/1).newgov_fed /// 
			i.govt_fed ///
			i.pol_party_fed ///
			ib1.ingov_fed ///
			votes_HHI_fed ///
			if doneeprovince == 35 ///
			& subsector == `l' ///
			, fe vce(robust) allbase	
		
	}
	
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
	collect style showbase factor
	collect style header, title(hide) level(label)
	collect style column, width(asis)
	collect style row stack, binder(":")
	collect style cell result[_r_b r2_w r2_b r2_o rho], nformat(%-9.4f)
	
	collect levelsof models
	collect layout (colname#result[_r_b]) (models) 
	collect layout (result[r2_w r2_b r2_o rho N_g]) (models)
	
	// clear the collect data
	collect drop _all
	
	// loop through subsectors in Ontario
	collect create _4550_ON, replace
	foreach l of local levels {
		
		// provincial and municipal government revenue
		display `"`l'"'
		display "provincial to Ontario" _continue
		quietly: collect get _r_b _r_p e(), tag(models[`l']): xtreg _4550log ///
			l._4550log ///
			il(0/1).elec_year_pro ///
			il(0/1).newgov_pro_ON ///
			_4560log ///
			i.govt_pro ///
			i.pol_party_pro ///
			ib1.ingov_pro ///
			votes_HHI_pro ///
			if doneeprovince == 35 ///
			& subsector == `l' ///
			, fe vce(robust) allbase		
		
	}
	
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
	collect style showbase factor
	collect style header, title(hide) level(label)
	collect style column, width(asis)
	collect style row stack, binder(":")
	collect style cell result[_r_b r2_w r2_b r2_o rho], nformat(%-9.4f)
	
	collect levelsof models
	collect layout (colname#result[_r_b]) (models) 
	collect layout (result[r2_w r2_b r2_o rho N_g]) (models)
	
	// clear the collect data
	collect drop _all
	
	// loop through subsectors in Alberta
	collect create _4540_AB, replace
	foreach l of local levels {
		
		capture assert `l' != 15
		
		if (_rc) {
			
			continue
			
		}
		
		// federal government revenue
		display `"`l'"'
		display "federal to Alberta" _continue
		quietly: collect get _r_b _r_p e(), tag(models[`l']): xtreg _4540log ///
			l._4540log ///
			il(0/1).elec_year_fed ///
			il(0/1).newgov_fed /// 
			i.govt_fed ///
			i.pol_party_fed ///
			ib1.ingov_fed ///
			votes_HHI_fed ///
			if doneeprovince == 48 ///
			& subsector == `l' ///
			, fe vce(robust) allbase
		
	}
	
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
	collect style showbase factor
	collect style header, title(hide) level(label)
	collect style column, width(asis)
	collect style row stack, binder(":")
	collect style cell result[_r_b r2_w r2_b r2_o rho], nformat(%-9.4f)
	
	collect levelsof models
	collect layout (colname#result[_r_b]) (models) 
	collect layout (result[r2_w r2_b r2_o rho N_g]) (models)
	
	// clear the collect data
	collect drop _all
	
	// loop through subsectors in Alberta
	collect create _4550_AB, replace
	foreach l of local levels {
		
		capture assert `l' != 15
		
		if (_rc) {
			
			continue
			
		}
		
		// provincial and municipal government revenue
		display `"`l'"'
		display "provincial to Alberta" _continue
		quietly: collect get _r_b _r_p e(), tag(models[`l']): xtreg _4550log ///
			l._4550log ///
			il(0/1).elec_year_pro ///
			il(0/1).newgov_pro_AB ///
			_4560log ///
			i.govt_pro ///
			i.pol_party_pro ///
			ib1.ingov_pro ///
			votes_HHI_pro ///
			if doneeprovince == 48 ///
			& subsector == `l' ///
			, fe vce(robust) allbase
		
	}
		
	collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
	collect style showbase factor
	collect style header, title(hide) level(label)
	collect style column, width(asis)
	collect style row stack, binder(":")
	collect style cell result[_r_b r2_w r2_b r2_o rho], nformat(%-9.4f)
	
	collect levelsof models
	collect layout (colname#result[_r_b]) (models) 
	collect layout (result[r2_w r2_b r2_o rho N_g]) (models)
	
	// clear the collect data
	collect drop _all
