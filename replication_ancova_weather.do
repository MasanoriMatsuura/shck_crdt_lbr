** Replication of JHR ANCOVA with Weather Shocks
** Path: data/stata/replication_ancova_weather.do

clear all
set more off
cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata"

* Define globals for paths and variables
global climate="C:\Users\mm_wi\Documents\research\brac_credit\data\weather"
global end="C:\Users\mm_wi\Documents\research\brac_credit\data\endline"
global base="C:\Users\mm_wi\Documents\research\brac_credit\data\baseline"
global rep="C:\Users\mm_wi\Documents\research\brac_credit\JHR_replication"
global tab = "C:\Users\mm_wi\Documents\research\brac_credit\data\table"
global all_shock all_rshock_aus all_rshock_aman all_rshock_boro
global control female hh_edu hh_age hh_size
global uncertainty cov_aman cov_boro
global weather cov_aman cov_boro haman hboro

use $climate\climate, clear
drop haus1 haman1 hboro1 sdaus1 sdaman1 sdboro1 // aus1 aman1 boro1

foreach v of varlist haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2 adm3_pcode {
	replace `v'="0" if `v'=="NA"
} //aus2 aman2 boro2
destring nid lon lat haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2 adm3_pcode , replace //aus2 aman2 boro2
/*gen rshock_aus = (aus2-haus2)/sdaus2
gen rshock_aman = (aman2-haman2)/sdaman2
gen rshock_boro =  (boro2-hboro2)/sdboro2
label var rshock_aus "Rainfall shock (aus)"
label var rshock_aman "Rainfall shock (aman)"
label var rshock_boro "Rainfall shock (boro)"*/

gen cov_aman = sdaman2/haman2
gen cov_boro = sdboro2/hboro2

label var cov_aman "CoV (Aman)"
label var cov_boro "CoV (Boro)"
rename (haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2)(haus haman hboro sdaus sdaman sdboro)

merge m:1 upazila using geo14, nogen
drop if upzi==.
drop if upazila=="Nawabganj" & district == "Dhaka"
drop if upazila=="Kachua" & district == "Bagerhat"
gen phase=2014
save $rep\climate14, replace

use  rct12, clear
keep dist upzi
decode upzi, gen(upazila)
duplicates drop upzi, force
replace upazila = "Babuganj" if upazila == "Babugonj"
replace upazila = "Bakerganj" if upazila == "Bakergonj"
replace upazila = "Barisal Sadar (Kotwali)" if upazila == "Barisal"
replace upazila = "Gaurnadi" if upazila == "Gournadi"
replace upazila = "Wazirpur" if upazila == "Uzirpur"
replace upazila = "Chandpur Sadar" if upazila == "Chandpur"
replace upazila = "Matlab Uttar" if upazila == "Matlab (N)"
replace upazila = "Burichang" if upazila == "Burichong"
replace upazila = "Nawabganj" if upazila == "Nawabgonj"
replace upazila = "Phultala" if upazila == "Fultala"
replace upazila = "Hossainpur" if upazila == "Hossenpur"
replace upazila = "Kishoreganj" if upazila == "Kishoregonj"
replace upazila = "Madaripur Sadar" if upazila == "Madaripur"
replace upazila = "Shib Char" if upazila == "Shibchar"
replace upazila = "Harirampur" if upazila == "Horirampur"
replace upazila = "Parbatipur" if upazila == "Parbotipur"
replace upazila = "Noakhali Sadar (Sudharam)" if upazila == "Noakhali"
replace upazila = "Baghmara" if upazila == "Bagmara"
replace upazila = "Kalaroa" if upazila == "Kolaroa"
replace upazila = "Basail" if upazila == "Bashail"
replace dist = 3 if upzi == 11 
save geo12, replace

use $climate\climate, clear
drop haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2 //aus2 aman2 boro2

foreach v of varlist haus1 haman1 hboro1 sdaus1 sdaman1 sdboro1 adm3_pcode adm2_pcode {
	replace `v'="0" if `v'=="NA"
} 
destring nid lon lat haus1 haman1 hboro1 sdaus1 sdaman1 sdboro1 adm3_pcode adm2_pcode id , replace //aus1 aman1 boro1


gen cov_aman = sdaman1/haman1
gen cov_boro = sdboro1/hboro1

label var cov_aman "CoV (Aman)"
label var cov_boro "CoV (Boro)"

rename (haus1 haman1 hboro1 sdaus1 sdaman1 sdboro1)(haus haman hboro sdaus sdaman sdboro)
merge m:1 upazila using geo12, nogen
drop if upzi==.
drop if upazila=="Nawabganj" & district == "Dhaka"
drop if upazila=="Kachua" & district == "Bagerhat"

gen phase=2012

save $rep\climate12, replace

use $end/q_impact_assessment, clear
keep idno bocd vill hhno unon upzi dist vocd hbcs ysmm ymst q1414 q1415 q1413 q151 q153 q155 q157 q1513 program phase
save $rep\rct14.dta, replace

use $base/q_impact_assessment__4301, clear
keep idno bocd vill hhno unon upzi dist vocd hbcs ysmm ymst q1414 q1415 q1413 q151 q153 q155 q157 q1513 program phase
save $rep\rct12.dta, replace

* Load data
use "$rep\masterfile.dta", clear
merge 1:1 idno phase using $rep\rct14, nogen
merge 1:1 idno phase using $rep\rct12, nogen update replace
merge m:1 upzi phase using $rep\climate14, nogen 
merge m:1 upzi phase using $rep\climate12, nogen update replace

save $rep\rep_climate, replace

* Create year variable for xtset (mapping phase 2012->1, 2014->2)
capture drop year
gen year = .
replace year = 1 if phase == 2012
replace year = 2 if phase == 2014

global chld_lbr chld_w chld_w_f chld_w_n chld_w_dummy chld_w_f_dummy chld_w_n_dummy // d_nvr_shl 
global edu edu_exp d_stp_schl d_nvr_shl 
global mechanism crdt_bnk crdt_ng crdt_inf crdt_accss bcp_uptake crdt_amt_bnk crdt_amt_ng crdt_amt_inf
global uncertainty cov_aman cov_boro
global weather cov_aman cov_boro haman hboro


**********Table 2: Endline Attrition*********
use "attrition.dta", clear

//Panel A: End line attrition in treatment vs.  control//
gen found_in_baseline=1- attrition
ttest found_in_baseline,by(program)

 egen hh_size=rsum(workingage dependent)
//Panel B: Compositional changes in sample at endline//

reg hh_size program attrition c.program#c.attrition, cluster(bocd)
outreg2 using "attrition.xls",replace
foreach var of varlist    dependent age_head   edu_head female_headed  owned_land clvt  {
    reg `var' program attrition c.program#c.attrition, cluster(bocd)
outreg2 using "attrition.xls",append

	}
	
**********Table 3:Impact of BCUP on Credit Market Participation***********


//Panel A: Credit Market Participation//
xtset idno year
egen any_credit=rowmax(cr_bcup cr_any_ex_bcup)
local cr_institution " cr_bank_cooperative cr_ngo cr_informal cr_any_ex_bcup any_credit"
reg cr_bcup program l.cr_bcup cov_boro, cluster(bocd) 
	qui summ cr_bcup if program == 0 & year==1
outreg2 using "$rep\credit_uptake.xls", addstat("Endline control mean", `r(mean)') replace dec(3)

foreach i of loc cr_institution {
	reg `i' program l.`i' cov_boro, cluster(bocd)
	qui summ `i' if program == 0 & year==1
	outreg2 using "$rep\credit_uptake.xls", append addstat("Endline control mean", `r(mean)') dec(3)

}



//Panel B: Borrowing Amount (in USD)//
xtset idno year
egen amount_any=rsum(amount_any_ex_bcup amount_bcup)
for var amount_bcup amount_bank_cooperative amount_ngo amount_informal amount_any_ex_bcup amount_any:gen X_usd=X/80
local cr_amount " amount_bank_cooperative_usd amount_ngo_usd amount_informal_usd amount_any_ex_bcup_usd amount_any_usd"
reg amount_bcup_usd program l.amount_bcup $uncertainty,  cluster(bocd) 
	qui summ amount_bcup_usd if program == 0 & year==1

outreg2 using "$rep\credit_amount.xls", replace addstat("Endline control mean", `r(mean)') dec(2)

foreach i of loc cr_amount {
	reg `i' program l.`i' $uncertainty,  cluster(bocd)
		qui summ `i' if program == 0 & year==1

	outreg2 using "$rep\credit_amount.xls", append addstat("Endline control mean", `r(mean)') dec(2)

}


**********Table 4:  Impact of credit on Amount of Cultivated Land (in Decimal)*********
use "C:\Users\Amzad\Dropbox\UVA Collaboration\Child_Labor\Replication-JHR\masterfile.dta", clear
xtset idno year
egen rented_in_others=rsum( q415c2 q419c2)
reg q413c2 program l.q413c2  $uncertainty, cluster(bocd)
	qui summ q413c2 if program == 0 & year==1
outreg2 using "$rep\land.xls", replace addstat("Endline control mean", `r(mean)') dec(2)

local land_amount " q417c2 rented_in_others  rentedin owned_land cultivatedland"

foreach i of loc land_amount {
	reg `i' program l.`i'  $uncertainty,  cluster(bocd)
		qui summ `i' if program == 0 & year==1

	outreg2 using "$rep\land.xls", append addstat("Endline control mean", `r(mean)') dec(2)

}

***********Table 5: Impact of Credit on Non-farm Self-Employment Activities***

use "C:\Users\Amzad\Dropbox\UVA Collaboration\Child_Labor\Replication-JHR\masterfile.dta", clear
xtset idno year
gen co12a_usd=co12a/80
gen dum_self_employ_non_firm=(no_of_business!=0)
reg dum_self_employ_non_firm program l.dum_self_employ_non_firm $uncertainty, cluster(bocd)
	qui summ dum_self_employ_non_firm if program == 0 & year==1
outreg2 using "$rep\business.xls", replace addstat("Endline control mean", `r(mean)')

local self_employment "no_of_business co6 co7 co12a_usd "
foreach i of loc self_employment {
	reg `i' program l.`i' $uncertainty,  cluster(bocd)
		qui summ `i' if program == 0 & year==1

		
	outreg2 using "$rep\business.xls", append addstat("Endline control mean", `r(mean)') dec(2)

}


**********Table 6: Impact of Credit on the Probability that Household Employs Child Labor (5-14)******
use "C:\Users\Amzad\Dropbox\UVA Collaboration\Child_Labor\Replication-JHR\masterfile.dta", clear
xtset idno year


*gen dum_child_lab=0 if child_hours_hhprod==0
*replace dum_child_lab=1 if dum_child_lab==.
*gen cat_child_lab=d.dum_child_lab
gen new_child_lab_endline=1 if cat_child_lab==1
replace new_child_lab_endline=0 if new_child_lab_endline==.

reg dum_child_lab program l.dum_child_lab $uncertainty, cluster(bocd)
	qui summ dum_child_lab if program == 0 & year==1
outreg2 using "$rep\child_labor_dummy.xls", replace addstat("Endline control mean", `r(mean)') dec(2)

reg new_child_lab_endline program l.new_child_lab_endline $uncertainty, cluster(bocd)
	qui summ new_child_lab_endline if program == 0 & year==1
outreg2 using "$rep\child_labor_dummy.xls", append addstat("Endline control mean", `r(mean)') dec(2)

reg child_hours_hhprod program l.child_hours_hhprod $uncertainty, cluster(bocd)
	qui summ child_hours_hhprod if program == 0 & year==1
outreg2 using "$rep\child_labor_dummy.xls", append addstat("Endline control mean", `r(mean)') dec(2)




*************Table 7: Impact of Credit on Hours Worked by Children on Different Activities: Time Budget Survey***

use  "$rep\time_budget_hh-with_reading_indivdual.dta", clear

 merge m:1 idno phase using $rep\rep_climate.dta
 keep if _merge==3
 gen xx=1 
 bys idno: egen y=sum(xx)
 drop if y==1
 egen total_hrs=rsum(hr_wage hr_farm_self_employ hr_non_farm_self hr_Salary hr_hh_activities hr_non_econ_act hr_reading hr_oth_service hr_leisure)
 
 keep if age<15
 drop if ( total_hrs <=0 | total_hrs >169)
 gen post=(phase==2014)
 
 egen hr_wage_sal=rsum(hr_wage hr_Salary hr_oth_service)
 egen hr_self_employment=rsum(hr_farm_self_employ hr_non_farm_self)
 gen discrepency=(168-total_hrs)
 egen hr_non_econ_act_rev=rsum(hr_non_econ_act discrepency)

 
 cd "C:\Users\Amzad\Dropbox\UVA Collaboration\Child_Labor\Replication-JHR\Results"
 capture erase "$rep\TB_individual_level_children.xls"
  capture erase "$rep\TB_individual_level_children.txt"

 foreach var in hr_wage_sal hr_self_employment hr_hh_activities hr_reading hr_leisure hr_non_econ_act_rev{
 reg `var' c.post##c.program $uncertainty
 		qui summ `var' if program == 0 & year==1
	outreg2 using "$rep\TB_individual_level_children.xls", append addstat("Endline control mean", `r(mean)') dec(2)

 }
 
  cd "C:\Users\Amzad\Dropbox\UVA Collaboration\Child_Labor\Replication-JHR\Results"
 capture erase "$rep\TB_individual_level_children_male.xls"
  capture erase "$rep\TB_individual_level_children_male.txt"

 foreach var in hr_wage_sal hr_self_employment hr_hh_activities hr_reading hr_leisure hr_non_econ_act_rev{
 reg `var' c.post##c.program $uncertainty if sex==1
 		qui summ `var' if program == 0 & year==1 & sex==1
	outreg2 using "$rep\TB_individual_level_children_male.xls", append addstat("Endline control mean", `r(mean)') dec(2)

 }
 
   cd "C:\Users\Amzad\Dropbox\UVA Collaboration\Child_Labor\Replication-JHR\Results"
 capture erase "$rep\TB_individual_level_children_female.xls"
  capture erase "$rep\TB_individual_level_children_female.txt"

 foreach var in hr_wage_sal hr_self_employment hr_hh_activities hr_reading hr_leisure hr_non_econ_act_rev{
 reg `var' c.post##c.program $uncertainty if sex==2
 		qui summ `var' if program == 0 & year==1 & sex==2
	outreg2 using "$rep\TB_individual_level_children_female.xls", append addstat("Endline control mean", `r(mean)') dec(2)

 }

 



****Table 8: Heterogeneity in the Impact of Credit on the Use of Child Labor (5-14)*************

use $rep\rep_climate, clear
xtset idno year
reg  dum_child_lab program c.program#c.l.workingage  l.dum_child_lab hhsize $uncertainty, cluster(bocd)
qui summ dum_child_lab if program == 0 & year==1
outreg2 using "$rep\child_labor_heterogeneity.xls", replace addstat("Endline control mean", `r(mean)') dec(3)

reg dum_child_lab program c.program#c.l.femalehead l.dum_child_lab hhsize $uncertainty, cluster(bocd)
qui summ dum_child_lab if program == 0 & year==1
outreg2 using "$rep\child_labor_heterogeneity.xls", append addstat("Endline control mean", `r(mean)') dec(3)

reg child_hours_hhprod program c.program#c.l.workingage l.child_hours_hhprod hhsize $uncertainty, cluster(bocd)
qui summ child_hours_hhprod if program == 0 & year==1
outreg2 using "$rep\child_labor_heterogeneity.xls", append addstat("Endline control mean", `r(mean)') dec(3)

reg child_hours_hhprod program c.program#c.femalehead l.child_hours_hhprod hhsize $uncertainty, cluster(bocd)
qui summ child_hours_hhprod if program == 0 & year==1
outreg2 using "$rep\child_labor_heterogeneity.xls", append addstat("Endline control mean", `r(mean)') dec(3)








********Table 9:Impact of Credit on Monthly Education Expenditure*******
use "C:\Users\Amzad\Dropbox\UVA Collaboration\Child_Labor\Replication-JHR\masterfile.dta", clear
xtset idno year

gen edu_exp_usd=edu_exp/80
gen edu_exp_usd_pc=(edu_exp_usd/dependent)*12 
replace edu_exp_usd_pc=0 if edu_exp_usd_pc==.
reg edu_exp_usd_pc program l.edu_exp_usd_pc $uncertainty, cluster(bocd)
qui summ edu_exp_usd_pc if program == 0 & year==1
outreg2 using "$rep\edu_exp.xls", replace dec(2) addstat("Endline control mean", `r(mean)') 

reg edu_exp_usd_pc program l.edu_exp_usd_pc tret_workmem $uncertainty, cluster(bocd)
qui summ edu_exp_usd_pc if program == 0 & year==1
outreg2 using "$rep\edu_exp.xls", append dec(2) addstat("Endline control mean", `r(mean)')

reg edu_exp_usd_pc program l.edu_exp_usd_pc  c.program#c.l.femalehead $uncertainty, cluster(bocd)
qui summ edu_exp_usd_pc if program == 0 & year==1
outreg2 using "$rep\edu_exp.xls", append dec(2) addstat("Endline control mean", `r(mean)') 


*********Table 10: Impact (ITT) of Credit on Child Schooling (Between 5 to 14 Years)*

use "C:\Users\Amzad\Dropbox\Women empowerment\Data and analysis\Revised Analysis\masterfile_women_empowerment.dta", clear
for var never_attended currently_attending stopped_attending: gen X_missing=(X==.)
for var never_attended currently_attending stopped_attending: replace X=0 if X==.
xtset idno year
reg never_attended program l.never_attended, cluster(bocd)
qui summ never_attended if program == 0 & year==1
outreg2 using "$rep\schooling_outcome.xls", replace dec(3) addstat("Endline control mean", `r(mean)') 
reg never_attended program l.never_attended l.workingage c.program#c.l.workingage, cluster(bocd)
qui summ never_attended if program == 0 & year==1
outreg2 using "$rep\schooling_outcome.xls", append dec(3) addstat("Endline control mean", `r(mean)') 
reg never_attended program l.never_attended l.femalehead c.program#c.l.femalehead, cluster(bocd)
qui summ never_attended if program == 0 & year==1
outreg2 using "$rep\schooling_outcome.xls", append dec(3) addstat("Endline control mean", `r(mean)') 

reg stopped_attending program l.stopped_attending , cluster(bocd)
qui summ stopped_attending if program == 0 & year==1
outreg2 using "$rep\schooling_outcome.xls", append dec(3) addstat("Endline control mean", `r(mean)') 
reg stopped_attending program l.stopped_attending l.workingage c.program#c.l.workingage, cluster(bocd)
qui summ stopped_attending if program == 0 & year==1
outreg2 using "$rep\schooling_outcome.xls", append dec(3) addstat("Endline control mean", `r(mean)') 	
reg stopped_attending program l.stopped_attending l.femalehead c.program#c.l.femalehead, cluster(bocd)
qui summ stopped_attending if program == 0 & year==1
outreg2 using "$rep\schooling_outcome.xls", append dec(3) addstat("Endline control mean", `r(mean)') 	

