** Masanori Matsuura

** BCUP analysis

** 2025/July/25

clear all

set more off


global fig = "C:\Users\mm_wi\Documents\research\brac_credit\data\figure"
global tab = "C:\Users\mm_wi\Documents\research\brac_credit\data\table"

cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata"

** append 2012 and 2014

use 12.dta, replace
append using 14.dta

gen edu_exp_p = edu_exp/hh_dep
label var edu_exp_p "Education expenditure per child"

*** shock variables
recode phase (2012=0 "Pre")(2014=1 "Post"), gen(post)
gen treat = program*post
label var treat "Treatment" 

foreach shock of varlist rshock_aus rshock_aman rshock_boro{
	gen flood_`shock' =1 if `shock'>1 
	replace flood_`shock' = 0 if flood_`shock' ==.
}
foreach shock of varlist rshock_aus rshock_aman rshock_boro{
	gen drought_`shock' =1 if `shock'< -1 
	replace drought_`shock' = 0 if drought_`shock' ==.
}

gen aus_t = rshock_aus*treat
gen aman_t = rshock_aman*treat
gen boro_t = rshock_boro*treat

gen aus_d_t = drought_rshock_aus*treat
gen aman_d_t = drought_rshock_aman*treat
gen boro_d_t = drought_rshock_boro*treat

gen aus_f_t = flood_rshock_aus*treat
gen aman_f_t = flood_rshock_aman*treat
gen boro_f_t = flood_rshock_boro*treat

save panel.dta, replace

** Analysis
global control female hh_edu hh_age

global outcome crdt_bnk crdt_ng crdt_inf crdt_accss chld_w chld_w_f chld_w_n edu_exp d_nvr_shl d_stp_schl

global shock flood_rshock_aus flood_rshock_aman flood_rshock_boro drought_rshock_aus drought_rshock_aman drought_rshock_boro

global variability rshock_aus rshock_aman rshock_boro

**Impact of shocks on child labor
foreach out of varlist $outcome {
    reg `out' $variability, vce(cluster upzi)
}
foreach out of varlist $outcome {
    reg `out' $shock, vce(cluster upzi)
}
**Impact of microcredit on child labor
foreach out of varlist $outcome {
    reg `out' 2014.phase#1.program 1.program 2014.phase, vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase $shock, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase $variability, a(idno phase) vce(cluster upzi)
}

** Seasonal effect of microcredit on child labor
*** Shocks
foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_d_t aus_f_t $shock, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aman_d_t aman_f_t $shock, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase boro_d_t boro_f_t$shock, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_f_t aman_f_t boro_f_t aus_d_t aman_d_t boro_d_t $shock, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_f_t aman_f_t boro_f_t aus_d_t aman_d_t boro_d_t $shock $control, a(idno phase) vce(cluster upzi)
}

*** Variability
foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t $variability, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aman_t $variability, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase boro_t $variability, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t aman_t boro_t $variability, a(idno phase) vce(cluster upzi)
}
