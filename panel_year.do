clear all
set more off
cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata_climate_year"

** append 2012 and 2014
use 12.dta, replace
append using 14.dta

gen edu_exp_p = edu_exp/hh_dep
label var edu_exp_p "Education expenditure per child"

replace bcp_uptake=0 if bcp_uptake==.

label var chld_w_dummy "Child labor (dummy)"
label var chld_w_f_dummy "Farm child labor (dummy)"
label var chld_w_n_dummy "Non-farm child labor (dummy)"
foreach dum in chld_w_dummy chld_w_f_dummy chld_w_n_dummy{
	replace `dum'=0 if `dum'==.
}

label var hh_age "Age of HH head"

egen amnt_any=rsum(crdt_amt_bnk crdt_amt_ng crdt_amt_inf bcp_amt)
label var amnt_any "Any credit including BCUP"

recode phase (2012=0 "Pre")(2014=1 "Post"), gen(post)
gen treat = program*post
label var treat "Treatment" 

* education
sort post
gen higher_edu=1 if hh_edu > 2 & post==0
replace higher_edu=1 if hh_edu > 4 & post==1
replace higher_edu=0 if higher_edu==.

* Create new weather-related variables

gen t_cov_year = cov_year*treat
label var t_cov_year "CoV*Credit"

capture drop year
gen year = .
replace year = 1 if phase == 2012
replace year = 2 if phase == 2014

capture merge 1:1 idno phase using "C:\Users\mm_wi\Documents\research\brac_credit\JHR_replication\masterfile.dta", keepusing(q415c2 q417c2 q419c2 q413c2 rentedin owned_land cultivatedland co12a no_of_business co6 co7)
if _rc != 0 {
	merge 1:1 idno year using "C:\Users\mm_wi\Documents\research\brac_credit\JHR_replication\masterfile.dta", keepusing(q415c2 q417c2 q419c2 q413c2 rentedin owned_land cultivatedland co12a no_of_business co6 co7)
}
drop _merge

egen rented_in_others=rsum( q415c2 q419c2)
gen co12a_usd=co12a/80
gen dum_self_employ_non_firm=(no_of_business!=0)

label var program "Exposure to credit access"

gen ln_fertilizer=log(exp_fertilizer+1)
gen ln_pesticide=log(exp_pesticide+1)

xtset idno year
foreach lag of varlist cov_year_20yr chld_w_dummy chld_w edu_exp d_stp_schl d_nvr_shl bcp_uptake crdt_bnk crdt_ng crdt_inf crdt_accss bcp_amt crdt_amt_bnk crdt_amt_ng crdt_amt_inf amnt_any q413c2 q417c2 rented_in_others  rentedin owned_land cultivatedland d_hyv d_fertilizer d_pesticide ln_fertilizer ln_pesticide exp_fertilizer exp_pesticide boy adlt_median hh_lit {
	gen L_`lag' = L.`lag'
}

save panel_year.dta, replace


