** Analysis of Weather Variables at Upazila Level
** Masanori Matsuura / Research Project
clear all
set more off

global fig = "C:\Users\mm_wi\Documents\research\brac_credit\data\fig_year"
global tab = "C:\Users\mm_wi\Documents\research\brac_credit\data\table_year"
cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata_climate_year"

* 1. Create Upazila-level panel dataset (N = 40 upazilas x 2 phases = 80 obs)
use panel_year.dta, clear

collapse (mean) rain_survey_ave cov_year cov_year_10yr cov_year_20yr ///
                temp_cov_year temp_cov_year_10yr temp_cov_year_20yr ///
                temp_ave1_20yr temp_ave2_20yr program lon lat ///
                (first) district upazila, by(upzi phase year)

label var upzi "Upazila ID"
label var year "Survey Round (1=2012, 2=2014)"
label var phase "Survey Year"
label var rain_survey_ave "Survey Year Average Monthly Rainfall (mm)"
label var cov_year_20yr "Rainfall CoV (20-year Historical)"
label var cov_year_10yr "Rainfall CoV (10-year Historical)"
label var cov_year "Rainfall CoV (2-year Historical)"
label var temp_cov_year_20yr "Temperature CoV (20-year Historical)"
label var program "BCUP Program Exposure (Share)"

save weather_upazila.dta, replace
display "weather_upazila.dta created with " _N " observations."

* 2. Summary Statistics at Upazila Level
summarize rain_survey_ave cov_year_20yr cov_year_10yr cov_year temp_cov_year_20yr

* 3. Regression Analysis
eststo clear

* Model 1: Survey Rain vs Both Rain CoV and Temp CoV
eststo m1: wcbregress rain_survey_ave c.cov_year_20yr##c.cov_year_20yr c.cov_year_20yr##c.temp_cov_year_20yr c.temp_cov_year_20yr##c.temp_cov_year_20yr i.upzi i.year , group(upzi)


* Display regression results
esttab m1, b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitle("Pooled Rain" "2012 Rain" "2014 Rain" "Temp->Rain" "Temp->RainCoV" "Both")

* Export regression table if outreg2 or esttab is available
capture esttab m1 using "$tab\weather_upazila_reg.rtf", replace ///
    b(3) se(3) r2(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label nogaps title("Upazila-Level Regressions of Weather Variables")
