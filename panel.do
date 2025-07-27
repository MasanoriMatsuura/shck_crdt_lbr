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

label var flood_rshock_aus "Flood in Aus"
label var flood_rshock_aman "Flood in Aman" 
label var flood_rshock_boro "Flood in Boro"
label var drought_rshock_aus "Drought in Aus"
label var drought_rshock_aman "Drought in Aman"
label var drought_rshock_boro "Drought in Boro"

gen aus_t = rshock_aus*treat
label var aus_t "Rainfall shock in Aus×Treatment"
gen aman_t = rshock_aman*treat
label var aman_t "Rainfall shock in Aman×Treatment"
gen boro_t = rshock_boro*treat
label var boro_t "Rainfall shock in Boro×Treatment"

gen aus_d_t = drought_rshock_aus*treat
label var aus_d_t "Drought in Aus×Treatment"
gen aman_d_t = drought_rshock_aman*treat
label var aman_d_t "Drought in Aman×Treatment"
gen boro_d_t = drought_rshock_boro*treat
label var boro_d_t "Drought in Boro×Treatment"
gen aus_f_t = flood_rshock_aus*treat
label var aus_f_t "Flood in Aus×Treatment"
gen aman_f_t = flood_rshock_aman*treat
label var aman_f_t "Flood in Aman×Treatment"
gen boro_f_t = flood_rshock_boro*treat
label var boro_f_t "Flood in Boro×Treatment"

save panel.dta, replace

** Analysis
global control female hh_edu hh_age

global outcome chld_w chld_w_f chld_w_n edu_exp d_stp_schl // d_nvr_shl 

global mechanism crdt_bnk crdt_ng crdt_inf crdt_accss 
global shock flood_rshock_aus flood_rshock_aman flood_rshock_boro drought_rshock_aus drought_rshock_aman drought_rshock_boro

global variability rshock_aus rshock_aman rshock_boro

** Descriptive statistics
eststo clear

estpost summarize $outcome $control  if program==0 & phase==2012, listwise
esttab using $tab\table1_1.rtf, cells("mean sd min max") nomtitle nonumber b(%4.3f) se replace nogaps label
eststo clear

estpost ttest  $outcome $control  if phase==2012, by(program)
esttab using $tab\table1_2.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons wide nonumber mtitle("diff.")
eststo clear


eststo: regress program $outcome $control if phase==2012, vce(cluster upzi)
esttab using $tab\table1_3.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons wide nonumber
eststo clear

**Impact of shocks on child labor

foreach out of varlist $outcome {
    eststo: reghdfe `out' $variability, a(idno phase) vce(cluster upzi)
}
esttab using $tab\table2.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $outcome {
    eststo: reghdfe `out' $shock, a(idno phase) vce(cluster upzi)
}
esttab using $tab\table2.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

**Impact of microcredit on child labor
foreach out of varlist $outcome {
    reg `out' 2014.phase#1.program 1.program 2014.phase, vce(cluster upzi)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase $shock, a(idno phase) vce(cluster upzi)
}

foreach out of varlist $outcome {
   eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase $variability, a(idno phase) vce(cluster upzi)
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
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_f_t aman_f_t boro_f_t aus_d_t aman_d_t boro_d_t $shock, a(idno phase) vce(cluster upzi)
}

esttab using $tab\table3.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

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
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t aman_t boro_t $variability, a(idno phase) vce(cluster upzi)
}
esttab using $tab\table3.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t aman_t boro_t $variability $control, a(idno phase) vce(cluster upzi)
}

*** take-up credit
foreach out of varlist $mechanism {
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_f_t aman_f_t boro_f_t aus_d_t aman_d_t boro_d_t $shock, a(idno phase) vce(cluster upzi)
}
esttab using $tab\table4.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $mechanism {
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t aman_t boro_t $variability, a(idno phase) vce(cluster upzi)
}
esttab using $tab\table4.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear
