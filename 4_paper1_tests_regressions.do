// package installations


// clear the results window
cls

// dissertation papers - paper 1, foundations
// this .do file uses 2003_to_2017_panelforanalysis_paper1.dta to run tests and regressions for paper 1
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

// H1
// HYPOTHESIS 1 (H1): Political donations by individual private foundation trustees will reflect a consistent partisan alignment over time.

	use "matched-privatefoundationtrustee-politicaldonor.dta"

	// create tables for the paper
	table (FISYR_NUM) (province2 pol_jurisdiction pol_alignment), nototals
	
	table () (province2 pol_jurisdiction pol_alignment ) if pol_donor_justone == 1, nototals statistic(count pol_donor_justone) statistic(mean pol_donor_count) statistic(min pol_donor_count) statistic(q1 pol_donor_count) statistic(median pol_donor_count) statistic(q3 pol_donor_count) statistic(max pol_donor_count)
	
	tabstat pol_alignment, statistics(n mean sd) by(id)
	bysort province2 pol_jurisdiction: tabstat pol_alignment, statistics(n mean sd) by(id)

// H2, H3

	// use the file
	use "2003_to_2017_panelforanalysis_paper1.dta"
	
	// check the economic controls
	pwcorr CADUSDExchange TSXCompositeIndexCloseMarch31 WTIUSDMarch12017dollars GDPperCapita2017dollars_pro totalgifts if foundation_funded == 1, star(.01)
	
// HYPOTHESIS 2 (H2): Charitable grants between private family foundations where trustees support the same political party will be to similar organizations, reflecting a network of in-group donees.

	// set the panel
	// year is left out here as there are multiple observations per bn per year
	// see: https://journals.sagepub.com/doi/10.1177/1536867X231162020
	xtset doneebn
	
	// federal
	xtreg pol_alignment_fed_donee i.pol_alignment_fed_abovemedian i.province2 ib10.subsector i.elec_year_fed, vce(robust) allbase 
	
	// provincial
	xtreg pol_alignment_pro_donee i.pol_alignment_pro_abovemedian i.province2 ib10.subsector i.elec_year_fed, vce(robust) allbase
	
	// donor-donee alignment correlations
	pwcorr pol_alignment_fed_inter pol_alignment_pro_inter pol_alignment_fed_donee pol_alignment_pro_donee

// HYPOTHESIS 3 (H3): Charitable grants by private family foundations where trustees support a political party will include regular grants to post-secondary schools, non-school education charities including those that conduct and disseminate research, and religious organizations with a missionary focus.

	// set the panel
	// year is left out here as there are multiple observations per bn per year
	// see: https://journals.sagepub.com/doi/10.1177/1536867X231162020
	xtset doneebn

	xtlogit give_flag b10.subsector i.FISYR_NUM TSXCompositeIndexCloseMarch31 if (pol_alignment_fed_ever == 0 & pol_alignment_pro_ever == 0), vce(robust) or allbase
	xtlogit give_flag b10.subsector i.FISYR_NUM TSXCompositeIndexCloseMarch31 if (pol_alignment_fed_ever == 1 | pol_alignment_pro_ever == 1), vce(robust) or allbase

// HYPOTHESIS 4 (H4): There will be an increase in charitable grants by private family foundations where trustees support a political party to post-secondary schools, non-school education charities including those that conduct and disseminate research, and religious organizations with a missionary focus after the party loses power.

	xtset doneebn

	xtreg totalgifts b10.subsector i.govt_fed subsector#i.govt_fed TSXCompositeIndexCloseMarch31 if pol_alignment_fed_ever == 1 & pol_alignment_fed_abovemedian == 0, fe vce(robust) allbase
	
	xtreg totalgifts b10.subsector i.govt_fed subsector#i.govt_fed TSXCompositeIndexCloseMarch31 if pol_alignment_fed_ever == 1 & pol_alignment_fed_abovemedian == 1, fe vce(robust) allbase


// FROM NATHAN
// *** pool by time to pick up signals as timing could be noisy *** !!!!!!!!!!!!! no reason to expect that aligned giving will happen by fiscal year
// *** regress pooled amount as DV with interacting political alignment of gifts and subsector in the IV
// *** these models need fixing up, make sure that it's the political alignment of the donor, not the government or riding
bysort bn doneebn: egen totalgifts_fullpanel = sum(totalgifts)

xtset bn

xtreg totalgifts_fullpanel ib10.subsector i.pol_alignment_fed_abovemedian i.pol_alignment_fed_abovemedian#ib10.subsector if (pol_alignment_fed < .), vce(robust) allbase

xtreg totalgifts_fullpanel ib10.subsector i.pol_alignment_pro_abovemedian i.pol_alignment_pro_abovemedian#ib10.subsector if (pol_alignment_pro < .), vce(robust) allbase
