** Analysis
** 2026/8/30
** Masanori Matsuura
** ssc install boottest, replace
** ssc install winsor2 
global fig = "C:\Users\mm_wi\Documents\research\brac_credit\data\fig_year"
global tab = "C:\Users\mm_wi\Documents\research\brac_credit\data\table_year"

cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata_climate_year"

use panel_year.dta, clear

global control l.female l.hh_lit l.hh_age l.boy l.hh_adlt
global control1 female hh_lit hh_age boy hh_adlt treat 



**Table 2:Descriptive statistics and Balance test (Baseline Means/SDs and Difference)
eststo clear
eststo control: estpost summarize cov_year cov_year_20yr cov_year_10yr chld_w_f chld_w_n edu_exp d_stp_schl $control  if program==0 & phase==2012
eststo treated: estpost summarize cov_year cov_year_20yr cov_year_10yr chld_w_f chld_w_n edu_exp d_stp_schl $control  if program==1 & phase==2012
eststo diff: estpost ttest cov_year cov_year_20yr cov_year_10yr chld_w_f chld_w_n edu_exp d_stp_schl $control if phase==2012, by(program)

esttab treated control  diff using $tab\table2_1.rtf, ///
    cells("mean(pattern(1 1 0) fmt(3)) b(pattern(0 0 1) star fmt(3))" ///
          "sd(pattern(1 1 0) par fmt(3)) se(pattern(0 0 1) par fmt(3))") ///
    label nogaps replace ///
    mtitles("Treatment" "Control" "Difference") ///
    title("Balance Test")
eststo clear


**Table A2: balance test
eststo clear
regress program cov_year chld_w_f chld_w_n edu_exp d_stp_schl $control if phase==2012, vce(cluster bocd)

outreg2 using "$tab\table2.xls", replace label dec(2) side

eststo clear

** Table 2: Impact of BCUP and rainfall variability on Child Labor 
eststo clear
xtset idno year
winsor2 chld_w , replace cuts(0 99.5) trim

wcbregress chld_w_dummy c.L_cov_year_20yr c.program L_chld_w_dummy, group(bocd) // $control
qui summ chld_w_dummy if program == 0 & year==1
outreg2 using "$tab\table2.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr c.program L_chld_w, group(bocd) // $control
qui summ chld_w if program == 0 & year==1
outreg2 using "$tab\table2.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w_dummy c.L_cov_year_20yr##c.program L_chld_w_dummy, group(bocd) // $control
qui summ chld_w_dummy if program == 0 & year==1
outreg2 using "$tab\table2.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr##c.program L_chld_w, group(bocd) // $control
qui summ chld_w if program == 0 & year==1
outreg2 using "$tab\table2.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

eststo clear


** Table 3 Heterogeneity in the Impact of Credit on the Use of Child Labor across gender (6-14)**
eststo clear
xtset idno year

wcbregress chld_w_dummy c.L_cov_year_20yr##c.program L_chld_w_dummy  if L_boy==1, group(bocd)
qui summ chld_w_dummy if program == 0 & year==1 & boy==1
outreg2 using "$tab\table3.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr##c.program L_chld_w if L_boy==1, group(bocd)
qui summ chld_w if program == 0 & year==1 & boy==1
outreg2 using "$tab\table3.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w_dummy c.L_cov_year_20yr##c.program L_chld_w_dummy  if L_boy==0, group(bocd)
qui summ chld_w_dummy if program == 0 & year==1 & boy==0
outreg2 using "$tab\table3.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr##c.program L_chld_w  if L_boy==0, group(bocd)
qui summ chld_w if program == 0 & year==1 & boy==0
outreg2 using "$tab\table3.xls", append label addstat("Endline control mean", `r(mean)') dec(2)


** Table 4: Heterogeneity in the Impact of Credit on the Use of Child Labor across parental education (5-14)**
eststo clear
xtset idno year

wcbregress chld_w_dummy c.L_cov_year_20yr##c.program L_chld_w_dummy if L_hh_lit==1, group(bocd)
qui summ chld_w_dummy if program == 0 & year==1 & higher_edu==1
outreg2 using "$tab\table4.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr##c.program L_chld_w if L_hh_lit==1, group(bocd)
qui summ chld_w if program == 0 & year==1 & higher_edu==1
outreg2 using "$tab\table4.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w_dummy c.L_cov_year_20yr##c.program L_chld_w_dummy if L_hh_lit==0, group(bocd)
qui summ chld_w_dummy if program == 0 & year==1 & hh_lit==0
outreg2 using "$tab\table4.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr##c.program L_chld_w if L_hh_lit==0, group(bocd)
qui summ chld_w if program == 0 & year==1 & higher_edu==0
outreg2 using "$tab\table4.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

** Table 5: Heterogeneity in the Impact of Credit on the Use of Child Labor across number of adults**
eststo clear
xtset idno year

wcbregress chld_w_dummy c.L_cov_year_20yr##c.program L_chld_w_dummy  if L_adlt_median==1, group(bocd)
qui summ chld_w_dummy if program == 0 & year==1 & adlt_median==1
outreg2 using "$tab\table5.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr##c.program L_chld_w if L_adlt_median==1, group(bocd)
qui summ chld_w if program == 0 & year==1 & adlt_median==1
outreg2 using "$tab\table5.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w_dummy c.L_cov_year##c.program L_chld_w_dummy if L_adlt_median==0, group(bocd)
qui summ chld_w_dummy if program == 0 & year==1 & adlt_median==0
outreg2 using "$tab\table5.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w c.L_cov_year_20yr##c.program L_chld_w if L_adlt_median==0, group(bocd)
qui summ chld_w if program == 0 & year==1 & adlt_median==0
outreg2 using "$tab\table5.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

eststo clear

** Table 6: Impact of rainfall variability and credit on schooling
use panel_year.dta, clear

eststo clear
xtset idno year

winsor2 edu_exp, replace cuts(0 99.5) trim

wcbregress edu_exp c.L_cov_year##c.program L_edu_exp, group(bocd)
qui summ edu_exp if program == 0 & year==1
outreg2 using "$tab\table6.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)

foreach out in d_stp_schl d_nvr_shl {
	wcbregress	`out' c.L_cov_year##c.program L_`out' , group(bocd)
    qui summ `out' if program == 0 & year==1
	outreg2 using "$tab\table6.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

}

** Heterogeneity parental schooling
eststo clear
xtset idno year
wcbregress edu_exp c.L_cov_year_20yr##c.program L_edu_exp if l.hh_lit==1, group(bocd)
qui summ edu_exp if program == 0 & year==1 & higher_edu==1
outreg2 using "$tab\table5.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)

foreach out in d_stp_schl d_nvr_shl {
	wcbregress `out' c.L_cov_year_20yr##c.program  L_`out'  if L_hh_lit==1, group(bocd)
    qui summ `out' if program == 0 & year==1 & higher_edu==1
	outreg2 using "$tab\table5.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

}

wcbregress edu_exp c.L_cov_year_20yr##c.program  L_edu_exp  if L.hh_lit==0, group(bocd)
qui summ edu_exp if program == 0 & year==1 & higher_edu==0
outreg2 using "$tab\table5.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

foreach out in  d_stp_schl d_nvr_shl {
	wcbregress `out' c.L_cov_year_20yr##c.program L_`out' if L_hh_lit==0, group(bocd)
    qui summ `out' if program == 0 & year==1 & higher_edu==0
	outreg2 using "$tab\table5.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

}

** Figure 2: Rainfall Shock Distributions by Phase
** Note: Using continuous rshock variables. Overlaid 2012 vs 2014.

twoway (kdensity cov_year if phase==2012) (kdensity cov_year if phase==2014), ///
    title("CoV") name(g1, replace) legend(label(1 "2012") label(2 "2014"))
twoway (kdensity cov_year2 if phase==2012) (kdensity cov_year2 if phase==2014), ///
    title("Boro") name(g2, replace) legend(label(1 "2012") label(2 "2014"))

graph combine g1 g2 , rows(2) //title("") //g3
graph export "$fig\figure2.png", replace

** Figure 3: Rainfall Shock Distributions by Phase
** Note: Using continuous rshock variables. Overlaid 2012 vs 2014.

twoway (kdensity temp_cov_year if phase==2012) (kdensity temp_cov_year if phase==2014), ///
    title("CoV") name(g1, replace) legend(label(1 "2012") label(2 "2014"))
twoway (kdensity cov_year2 if phase==2012) (kdensity cov_year2 if phase==2014), ///
    title("Boro") name(g2, replace) legend(label(1 "2012") label(2 "2014"))

graph combine g1 g2 , rows(2) //title("") //g3
graph export "$fig\figure3.png", replace


** Mechanism

***Table 7: Impact of rainfall variability and credit on Credit Market Participation
use panel_year.dta, clear

xtset idno year

eststo clear
local cr_institution "crdt_bnk crdt_ng crdt_inf crdt_accss"
wcbregress bcp_uptake c.L_cov_year_20yr##c.program L_bcp_uptake , group(bocd)
qui summ bcp_amt if program == 0 & year==1
outreg2 using "$tab\table7_a.xls", replace label addstat("Endline control mean", `r(mean)') dec(3)

foreach out of loc cr_institution {
     wcbregress `out' c.L_cov_year_20yr##c.program L_`out' , group(bocd)
	 qui summ `out' if program == 0 & year==1
	 outreg2 using "$tab\table7_a.xls", append label addstat("Endline control mean", `r(mean)') dec(3)

}
eststo clear


xtset idno year
local cr_amount "crdt_amt_bnk crdt_amt_ng crdt_amt_inf amnt_any"

winsor2 bcp_amt, replace cuts(0 99.5) trim
wcbregress bcp_amt c.L_cov_year_20yr##c.program L_bcp_uptake , group(bocd)
qui summ bcp_amt if program == 0 & year==1
outreg2 using "$tab\table7_b.xls", replace label addstat("Endline control mean", `r(mean)') dec(3)

foreach out of loc cr_amount {
    use panel_year.dta, clear
	xtset idno year
	winsor2 `out', replace cuts(0 99.5) trim
	wcbregress `out' c.L_cov_year_20yr##c.program L_`out' , group(bocd)
	 qui summ `out' if program == 0 & year==1
	 outreg2 using "$tab\table7_b.xls", append label addstat("Endline control mean", `r(mean)') dec(3)

}


eststo clear


** Table 8: Impact of uncertainty and credit on Amount of Cultivated Land (in Decimal)
use panel_year.dta, clear

eststo clear
xtset idno year

winsor2 q413c2, replace cuts(0 99.5) trim

wcbregress q413c2 c.L_cov_year_20yr##c.program L_q413c2 , group(bocd)
	qui summ q413c2 if program == 0 & year==1
outreg2 using "$tab\table8.xls", replace label addstat("Endline control mean", `r(mean)') dec(3)

local land_amount " q417c2 rented_in_others  rentedin owned_land cultivatedland"

foreach out of loc land_amount {
	use panel_year.dta, clear
	xtset idno year
    winsor2 `out', replace cuts(0 99.5) trim
	wcbregress `out' c.L_cov_year_20yr##c.program L_`out', group(bocd)
	qui summ `out' if program == 0 & year==1
    outreg2 using "$tab\table8.xls", append label addstat("Endline control mean", `r(mean)') dec(3)
}

eststo clear

** Table 8: Impact of uncertainty and access to credit on agricultural input
use panel_year.dta, clear

eststo clear
xtset idno year

wcbregress d_hyv c.L_cov_year_20yr##c.program L_d_hyv , group(bocd) //$control
	qui summ d_hyv if program == 0 & year==1
outreg2 using "$tab\aginput.xls", replace label addstat("Endline control mean", `r(mean)') dec(3)

local input "d_fertilizer d_pesticide ln_fertilizer ln_pesticide exp_fertilizer exp_pesticide"

foreach out of loc input {
   	use panel_year.dta, clear
	xtset idno year
	winsor2 `out', replace cuts(0 99.5) trim
	wcbregress `out' c.L_cov_year_20yr##c.program L_`out' , group(bocd)
	qui summ `out' if program == 0 & year==1
    outreg2 using "$tab\aginput.xls", append label addstat("Endline control mean", `r(mean)') dec(3)
} //$control

eststo clear

** Appendix
*** Table A1 Disentangling Income Shocks from Income Uncertainty:  Effect of rainfall Variability on agricultural outcome and treatment status

use panel_year.dta, clear
eststo clear
xtset idno year

gen L_agg_yield = L.agg_yield

areg agg_yield c.cov_year_20yr##c.cov_year_20yr female hh_lit hh_age hh_adlt  i.year, absorb(idno) vce(cluster bocd)
//##c.cov_year_20yr c.cov_year_20yr##c.temp_cov_year_20yr c.temp_cov_year_20yr##c.temp_cov_year_20yr
* 2. Immediately execute boottest
boottest c.cov_year_20yr, reps(200)
boottest c.cov_year_20yr#c.cov_year_20yr, reps(200)

outreg2 using "$tab\table_a1.xls", replace dec(2) label stats(coef se)

areg c.cov_year_20yr treat female hh_lit hh_age hh_adlt i.year, absorb(idno) vce(cluster bocd)
boottest treat, reps(200)
outreg2 using "$tab\table_a1.xls", append dec(2) label stats(coef se)

 
** Robustness checks
** Table A3 Temperature uncertainty and credit on Child Labor 
use panel_year.dta, clear
eststo clear

gen L_temp_cov_year_20yr = L.temp_cov_year_20yr
xtset idno year
winsor2 chld_w , replace cuts(0 99.5) trim

wcbregress chld_w_dummy L_temp_cov_year_20yr program L_chld_w_dummy , group(bocd)
qui summ chld_w_dummy if program == 0 & year==1
outreg2 using "$tab\table_a3.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)


wcbregress chld_w L_temp_cov_year_20yr program L_chld_w, group(bocd)
qui summ chld_w if program == 0 & year==1
outreg2 using "$tab\table_a3.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

wcbregress chld_w_dummy c.L_temp_cov_year_20yr##c.program L_chld_w_dummy , group(bocd)
qui summ chld_w_dummy if program == 0 & year==1
outreg2 using "$tab\table_a3.xls", append label addstat("Endline control mean", `r(mean)') dec(2)


wcbregress chld_w c.L_temp_cov_year_20yr##c.program L_chld_w, group(bocd)
qui summ chld_w if program == 0 & year==1
outreg2 using "$tab\table_a3.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

eststo clear

**Table A4 Impact of uncertainty and credit on Child Labor 
** Using rainfall variabilitiy in 10 years
use panel_year.dta, clear
xtset idno year
winsor2 chld_w , replace cuts(0 99.5) trim

reg chld_w_dummy c.L.cov_year_10yr##c.program l.chld_w_dummy, cluster(bocd)
qui summ chld_w_dummy if program == 0 & year==1
outreg2 using "$tab\table_a2_a.xls", replace label addstat("Endline control mean", `r(mean)') dec(2)

reg chld_w_dummy c.L.cov_year_20yr##c.program l.chld_w_dummy , cluster(bocd)
qui summ chld_w_dummy if program == 0 & year==1
outreg2 using "$tab\table_a2_a.xls", append label addstat("Endline control mean", `r(mean)') dec(2)

foreach cov in cov_year_10yr cov_year_20yr {
    reg chld_w c.L.`cov'##c.program l.chld_w, cluster(bocd)
    qui summ chld_w if program == 0 & year==1
	outreg2 using "$tab\table_a2_a.xls", append label addstat("Endline control mean", `r(mean)') dec(2)
}

eststo clear

