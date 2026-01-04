** Analysis
** 2025/12/23
** Masanori Matsuura

global fig = "C:\Users\mm_wi\Documents\research\brac_credit\data\figure"
global tab = "C:\Users\mm_wi\Documents\research\brac_credit\data\table"

cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata"

use panel.dta, clear

global control female hh_edu hh_age

global outcome chld_w chld_w_f chld_w_n edu_exp d_stp_schl // d_nvr_shl 

global mechanism crdt_bnk crdt_ng crdt_inf crdt_accss bcp_uptake
global shock flood_rshock_aus flood_rshock_aman flood_rshock_boro drought_rshock_aus drought_rshock_aman drought_rshock_boro

global boro_shock flood_rshock_boro drought_rshock_boro
global variability rshock_aus rshock_aman rshock_boro

**Table 1: Descriptive statistics
eststo clear

estpost summarize $outcome $control  if program==0 & phase==2012, listwise
esttab using $tab\table2_1.rtf, cells("mean sd min max") nomtitle nonumber b(%4.3f) se replace nogaps label
eststo clear

estpost ttest  $outcome $control  if phase==2012, by(program)
esttab using $tab\table2_2.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons wide nonumber mtitle("diff.")
eststo clear

**Table 2: balance test
eststo: regress program $outcome $control if phase==2012, vce(cluster bocd)
esttab using $tab\table3.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons wide nonumber

esttab using $tab\table3.tex, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons wide nonumber substitute("<" "$<$")
eststo clear

**Table 4: Impact of shocks on child labor

foreach out of varlist $outcome {
    eststo: reghdfe `out' $variability $control, a(idno phase) vce(cluster bocd)
}
esttab using $tab\table2.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $outcome {
    eststo: reghdfe `out' $shock $control, a(idno phase) vce(cluster bocd)
}
esttab using $tab\table2.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $outcome {
    eststo: reghdfe `out' $boro_shock, a(idno phase) vce(cluster bocd)
}
foreach out of varlist $outcome {
    eststo: reghdfe `out' rshock_boro, a(idno phase) vce(cluster bocd)
}
//esttab using $tab\table2.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear


***Table 3: take-up credit
foreach out of varlist $mechanism {
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_f_t aman_f_t boro_f_t aus_d_t aman_d_t boro_d_t $shock, a(idno phase) vce(cluster bocd)
}
esttab using $tab\table4.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $mechanism {
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t aman_t boro_t $variability, a(idno phase) vce(cluster bocd)
}
esttab using $tab\table4.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear


**Table 5: Impact of microcredit on child labor
foreach out of varlist $outcome {
    reg `out' 2014.phase#1.program 1.program 2014.phase, vce(cluster bocd)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase $shock, a(idno phase) vce(cluster bocd)
}

foreach out of varlist $outcome {
   eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase $variability, a(idno phase) vce(cluster bocd)
}

** Mitigating effects of microcredit on child labor
*** Shocks
foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_d_t aus_f_t $shock, a(idno phase) vce(cluster bocd)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aman_d_t aman_f_t $shock, a(idno phase) vce(cluster bocd)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase boro_d_t boro_f_t $shock, a(idno phase) vce(cluster bocd)
}

foreach out of varlist $outcome {
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_f_t aman_f_t boro_f_t aus_d_t aman_d_t boro_d_t $shock, a(idno phase) vce(cluster bocd)
}

esttab using $tab\table3.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_f_t aman_f_t boro_f_t aus_d_t aman_d_t boro_d_t $shock $control, a(idno phase) vce(cluster bocd)
}

*** Variability
foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t $variability, a(idno phase) vce(cluster bocd)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aman_t $variability, a(idno phase) vce(cluster bocd)
}

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase boro_t $variability, a(idno phase) vce(cluster bocd)
}

foreach out of varlist $outcome {
    eststo: reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t aman_t boro_t $variability, a(idno phase) vce(cluster bocd)
}
esttab using $tab\table3.rtf, b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons nonumber
eststo clear

foreach out of varlist $outcome {
    reghdfe `out' 2014.phase#1.program 1.program 2014.phase aus_t aman_t boro_t $variability $control, a(idno phase) vce(cluster bocd)
}