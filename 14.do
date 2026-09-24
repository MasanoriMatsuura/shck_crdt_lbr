**BCUP Endline

**Masanori Matsuura

**2025/07/22

clear all

set more off

global end="C:\Users\mm_wi\Documents\research\brac_credit\data\endline"
global climate="C:\Users\mm_wi\Documents\research\brac_credit\data\weather"

cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata_climate_year"

**Household composition: number of HH members, number of adults, number of dependents, female HH head, HH head's age, Hh head's years of schooling
use $end\q1_1.dta, clear

*number of HH members
sort idno
bysort idno: egen hh_size = count(idno) 
label var hh_size "Number of HH members"
*number of adults 
bysort idno: egen hh_adlt = count(idno) if co5 >= 15
label var hh_adlt "Number of adults (>=15)"

*number of dependents
bysort idno: egen hh_dep = count (idno) if co5 < 15
label var hh_dep "Number of dependents (<15)"
* Replace missing hh_dep if hh_size and hh_adlt are present
replace hh_dep = hh_size - hh_adlt if hh_dep == . & hh_size != . & hh_adlt != .

* Replace missing hh_adlt if hh_size and hh_dep are present
replace hh_adlt = hh_size - hh_dep if hh_adlt == . & hh_size != . & hh_dep != .

* Gender of children aged 6-14
bysort idno: egen num_boys = sum(co4 == 1 & co5 >= 6 & co5 <= 14)
bysort idno: egen num_girls = sum(co4 == 2 & co5 >= 6 & co5 <= 14)
gen boy = 1 if num_boys > num_girls
replace boy = 0 if num_boys <= num_girls
label var boy "More boys(1) or girls(0) aged 6-14"


* Number of children never attended schools
tab co12, gen(schl)
bysort idno: egen nvr_sc = sum(schl1) if co5 < 15 & co5 >= 4
replace nvr_sc = 0 if nvr_sc ==.
bysort idno: egen nvr_schl = sum(nvr_sc)
label var nvr_schl "Number of children never attended schools"

recode nvr_schl (0=0)(nonm=1), gen(d_nvr_shl)
label var d_nvr_shl "Children never attended schools"
* Number of children stopped attending schools
bysort idno: egen stp_sc = sum(schl3) if co5 < 15 & co5 >= 4
replace stp_sc = 0 if stp_sc ==.
bysort idno: egen stp_schl = sum(stp_sc)
label var stp_schl "Number of children stopped attending schools"

recode stp_schl (0=0)(nonm=1), gen(d_stp_schl)
label var d_stp_schl "Children stopped attending schools"

* Dummy for children aged 13 and 14
bysort idno: egen d_child13 = max(co5 == 13)
label var d_child13 "Has child aged 13"
bysort idno: egen d_child14 = max(co5 == 14)
label var d_child14 "Has child aged 14"

* Dummy for children aged 12 and above
bysort idno: egen d_child12plus = max(co5 >= 12 & co5 <= 14)
label var d_child12plus "Has child aged 12+"

*HH gender
recode co4 (1=0)(2=1), gen(female)
label var female "HH head is female"
*HH age
rename co5 hh_age
*HH years of schooling
gen hh_edu = co11
replace hh_edu = 0 if co11 == 91 | co11 == 92 | co11 == 92 | co11 == 93 | co11 == 99 | co11 ==.
label var hh_edu "HH head's years of schooling"
recode co11 (4=1)(nonm=0), gen(hh_lit)
replace hh_lit=0 if hh_lit==.
label var hh_lit "Literacy of HH head"

keep if co2 == 1 & lino == 1
gen adlt_median=0
replace adlt_median=1 if hh_adlt > 3
label var adlt_median "More adults"
keep idno female hh_size hh_adlt hh_dep hh_age hh_edu adlt_median nvr_schl stp_schl d_nvr_shl d_stp_schl boy d_child13 d_child14 d_child12plus hh_lit
save hh14.dta, replace

**Credit participation
use $end\q6_1.dta, clear

recode co4 (1/5=1 "Bank/Co-operatives")(7/13=2 "NGO")(nonm=3 "Informal"), gen(crdt_src)
label var crdt_src "Credit source"
tab crdt_src, gen(crdt)

sort idno
bysort idno: egen crdt_bnk = sum(crdt1)

bysort idno: egen crdt_ng = sum(crdt2)

bysort idno: egen crdt_inf = sum(crdt3)

gen amt_bnk = co5 if crdt_src == 1
gen amt_ng = co5 if crdt_src == 2
gen amt_inf = co5 if crdt_src == 3

bysort idno: egen crdt_amt_bnk = sum(amt_bnk)
bysort idno: egen crdt_amt_ng = sum(amt_ng)
bysort idno: egen crdt_amt_inf = sum(amt_inf)

label var crdt_amt_bnk "Amount from Bank/Co-operatives"
label var crdt_amt_ng "Amount from NGO"
label var crdt_amt_inf "Amount from Informal"

drop amt_bnk amt_ng amt_inf

duplicates drop idno crdt_bnk crdt_ng crdt_inf, force
replace crdt_bnk = 1 if crdt_bnk == 2
replace crdt_ng = 1 if crdt_ng == 2
replace crdt_inf = 1 if crdt_inf == 2 | crdt_inf == 3 | crdt_inf ==4
label var crdt_bnk "Bank/Co-operatives"
label var crdt_ng "NGO"
label var crdt_inf "Informal"


gen crdt_accss=1
label var crdt_accss "Credit access"

gen bcp_uptake=1 if co4==13
replace bcp_uptake=0 if bcp_uptake==.
label var bcp_uptake "BCUP uptake"

bysort idno: egen  bcp_amt = sum(co5) if co4==13
label var bcp_amt "Amount from BCUP"
replace bcp_amt=0 if bcp_amt==.

tab co3 if bcp_uptake==1
keep idno crdt_bnk crdt_ng crdt_inf crdt_amt_bnk crdt_amt_ng crdt_amt_inf crdt_accss bcp_uptake bcp_amt
save crdt14.dta, replace
**Borrowing


**Asset holding: cow, goat


**Land: Owned land, cultivated land, land contract, sharecropping, fixed rent, 
use $end\q4_2_3.dta, clear

* Initialize total production and land for rice (Gross Cropped Area)
gen rice_production = 0
gen rice_land = 0

* Aus
replace rice_production = rice_production + co7 if (co6 == 1 | inrange(co6, 101, 330)) & co7 != .
replace rice_land = rice_land + co2 if (co6 == 1 | inrange(co6, 101, 330)) & co2 != .

* Aman
replace rice_production = rice_production + co10 if (co9 == 1 | inrange(co9, 101, 330)) & co10 != .
replace rice_land = rice_land + co2 if (co9 == 1 | inrange(co9, 101, 330)) & co2 != .

* Robi
replace rice_production = rice_production + co13 if (co121 == 1 | inrange(co121, 101, 330)) & co13 != .
replace rice_land = rice_land + co2 if (co121 == 1 | inrange(co121, 101, 330)) & co2 != .

* Boro
replace rice_production = rice_production + co16 if (co15 == 1 | inrange(co15, 101, 330)) & co16 != .
replace rice_land = rice_land + co2 if (co15 == 1 | inrange(co15, 101, 330)) & co2 != .

bysort idno: egen sum_production = sum(rice_production)
bysort idno: egen sum_land = sum(rice_land)

gen agg_yield = sum_production / sum_land
label var agg_yield "Aggregate rice yield"
keep idno agg_yield
duplicates drop idno, force
save yield14.dta, replace


**Non-farm self employment

**Agricultural practices
use $end\q4_2_3.dta, clear
tab co6
tab co6, nolabel // Aus
recode co6 (101/330=1 "Rice")(2=2 "Betel leaf")(3=3 "Fruits")(4=4 "Wheat")(5=5 "Sugarcane")(6=6 "Potato")(7=7 "Pulse")(8=8 "Vegetables")(9=9 "Tobacco")(10=10 "Oil seeds")(11=11 "Onion/Garlic")(12=12 "Spices")(13=13 "Jute")(14=14 "Maize")(nonm=15 "Others"), gen(crp_aus)
gen temp_rice_aus = (crp_aus==1) 
bysort idno: egen d_rice_aus = max(temp_rice_aus)
label var d_rice_aus "Household cultivates Rice (Aus)"
gen temp_jute_aus = (crp_aus==13)
bysort idno: egen d_jute_aus = max(temp_jute_aus)
label var d_jute_aus "Household cultivates Jute (Aus)"
gen temp_hyv_aus = (inrange(co6, 101, 330))
bysort idno: egen d_hyv_aus = max(temp_hyv_aus)
label var d_hyv_aus "Household cultivates HYV Rice (Aus)"
drop temp_rice_aus temp_jute_aus temp_hyv_aus

tab co9 
tab co9, nolabel // Aman
recode co9 (1 101/330=1 "Rice")(2=2 "Betel leaf")(3=3 "Fruits")(4=4 "Wheat")(5=5 "Sugarcane")(6=6 "Potato")(7=7 "Pulse")(8=8 "Vegetables")(9=9 "Tobacco")(10=10 "Oil seeds")(11=11 "Onion/Garlic")(12=12 "Spices")(13=13 "Jute")(14=14 "Maize")(nonm=15 "Others"), gen(crp_aman)
gen temp_rice_aman = (crp_aman==1) 
bysort idno: egen d_rice_aman = max(temp_rice_aman)
label var d_rice_aman "Household cultivates Rice (Aman)"
gen temp_hyv_aman = (inrange(co9, 101, 330))
bysort idno: egen d_hyv_aman = max(temp_hyv_aman)
label var d_hyv_aman "Household cultivates HYV Rice (Aman)"
drop temp_rice_aman temp_hyv_aman

tab co121 // Robi
recode co121 (1 101/330=1 "Rice")(2=2 "Betel leaf")(3=3 "Fruits")(4=4 "Wheat")(5=5 "Sugarcane")(6=6 "Potato")(7=7 "Pulse")(8=8 "Vegetables")(9=9 "Tobacco")(10=10 "Oil seeds")(11=11 "Onion/Garlic")(12=12 "Spices")(13=13 "Jute")(14=14 "Maize")(nonm=15 "Others"), gen(crp_robi)
gen temp_rice_robi = (crp_robi==1) 
bysort idno: egen d_rice_robi = max(temp_rice_robi)
label var d_rice_robi "Household cultivates Rice (Robi)"
gen temp_hyv_robi = (inrange(co121, 101, 330))
bysort idno: egen d_hyv_robi = max(temp_hyv_robi)
label var d_hyv_robi "Household cultivates HYV Rice (Robi)"
drop temp_rice_robi temp_hyv_robi


tab co15 
tab co15, nolabel // Boro
recode co15 (1 101/330=1 "Rice")(2=2 "Betel leaf")(3=3 "Fruits")(4=4 "Wheat")(5=5 "Sugarcane")(6=6 "Potato")(7=7 "Pulse")(8=8 "Vegetables")(9=9 "Tobacco")(10=10 "Oil seeds")(11=11 "Onion/Garlic")(12=12 "Spices")(13=13 "Jute")(14=14 "Maize")(nonm=15 "Others"), gen(crp_boro)
gen temp_rice_boro = (crp_boro==1) 
bysort idno: egen d_rice_boro = max(temp_rice_boro)
label var d_rice_boro "Household cultivates Rice (Boro)"
gen temp_hyv_boro = (inrange(co15, 101, 330))
bysort idno: egen d_hyv_boro = max(temp_hyv_boro)
label var d_hyv_boro "Household cultivates HYV Rice (Boro)"
drop temp_rice_boro temp_hyv_boro

gen d_hyv = (d_hyv_aus == 1 | d_hyv_aman == 1 | d_hyv_robi == 1 | d_hyv_boro == 1)
label var d_hyv "Household cultivates HYV Rice"

duplicates drop idno d_rice_aus d_jute_aus d_rice_aman d_rice_robi d_rice_boro d_hyv_aus d_hyv_aman d_hyv_robi d_hyv_boro d_hyv, force

keep idno d_rice_aus d_jute_aus d_rice_aman d_rice_robi d_rice_boro d_hyv_aus d_hyv_aman d_hyv_robi d_hyv_boro d_hyv
save crop14.dta, replace

**Child labor
use $end\q5_2.dta, clear
sort idno
drop if co5==0
drop if co5==.

bysort idno: egen chld_w = sum(co5)
label var chld_w "Child labor (6-14)"
replace chld_w = 0 if chld_w ==.

bysort idno: egen chld_w_f = sum(co5) if co1 <=7
label var chld_w_f "Farm child labor (6-14)"
replace chld_w_f = 0 if chld_w_f ==.

bysort idno: egen chld_w_n = sum(co5) if co1 >= 8
label var chld_w_n "Non-farm child labor (6-14)"
replace chld_w_n = 0 if chld_w_n ==.

sort idno

* idno ごとに chld_w_f の最大値を一時変数に格納
bysort idno: egen max_chld_w_f = max(chld_w_f)

* idno ごとに chld_w_n の最大値を一時変数に格納
bysort idno: egen max_chld_w_n = max(chld_w_n)

* chld_w_f と chld_w_n をこの統一された値で置き換える
replace chld_w_f = max_chld_w_f
replace chld_w_n = max_chld_w_n

* 一時変数を削除
drop max_chld_w_f max_chld_w_n

duplicates drop idno, force

keep idno chld_w chld_w_f chld_w_n
recode chld_w (0=0 "No")(nonm=1 "Yes"), gen(chld_w_dummy)
recode chld_w_f (0=0 "No")(nonm=1 "Yes"), gen(chld_w_f_dummy)
recode chld_w_n (0=0 "No")(nonm=1 "Yes"), gen(chld_w_n_dummy)

save chld_w14.dta, replace

**Annual expenditure: Food, non-food, education
use $end\q2_2.dta, clear

bysort idno: egen edu_exp = sum (co2) if co1 == 9 | co1==10 | co1== 11 | co1 == 12 | co1 == 13
replace edu_exp=0 if edu_exp ==.
label var edu_exp "Education expenditure"

keep if co1 == 9 | co1==10 | co1== 11 | co1 == 12 | co1 == 13 
duplicates drop idno edu_exp, force

keep idno edu_exp
save exp14.dta, replace

**Agricultural inputs: Fertilizer and Pesticide
use $end\q4_4_2.dta, clear
egen exp_ag_total = rowtotal(co2 co3 co4 co5 co6 co7)

* Fertilizer expenditure and dummy (chemical fertilizer: co1==3, organic fertilizer: co1==4)
gen exp_fert_temp = exp_ag_total if co1 == 3 | co1 == 4
bysort idno: egen exp_fertilizer = sum(exp_fert_temp)
label var exp_fertilizer "Fertilizer expenditure"

gen d_fertilizer = (exp_fertilizer > 0) if exp_fertilizer != .
label var d_fertilizer "Used fertilizer"

* Pesticide expenditure and dummy (pesticide/herbicide: co1==6)
gen exp_pest_temp = exp_ag_total if co1 == 6
bysort idno: egen exp_pesticide = sum(exp_pest_temp)
label var exp_pesticide "Pesticide expenditure"

gen d_pesticide = (exp_pesticide > 0) if exp_pesticide != .
label var d_pesticide "Used pesticide"

duplicates drop idno exp_fertilizer d_fertilizer exp_pesticide d_pesticide, force
keep idno exp_fertilizer d_fertilizer exp_pesticide d_pesticide
save input14.dta, replace

**Food security


**RCT
use $end/q_impact_assessment, clear
keep idno bocd vill hhno unon upzi dist vocd hbcs ysmm ymst q1414 q1415 q1413 q151 q153 q155 q157 q1513 program phase
save rct14.dta, replace

**weather shocks
use  rct14, clear
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
save geo14, replace

use $climate\climate, clear
drop haus1 haman1 hboro1 sdaus1 sdaman1 sdboro1 //sum_aus1_dummy sum_aman1_dummy sum_boro1_dummy // aus1 aman1 boro1

foreach v of varlist haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2 adm3_pcode  {
	replace `v'="0" if `v'=="NA"
} //aus2 aman2 boro2
destring nid lon lat haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2 adm3_pcode, replace //aus2 aman2 boro2  sum_aman2_dummy sum_boro2_dummy
/*gen rshock_aus = (aus2-haus2)/sdaus2
gen rshock_aman = (aman2-haman2)/sdaman2
gen rshock_boro =  (boro2-hboro2)/sdboro2
label var rshock_aus "Rainfall shock (aus)"
label var rshock_aman "Rainfall shock (aman)"
label var rshock_boro "Rainfall shock (boro)"*/

gen cov_aman = (sdaman2/haman2)
gen cov_boro = (sdboro2/hboro2)

label var cov_aman "CoV (Aman)"
label var cov_boro "CoV (Boro)"
rename (haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2 )(haus haman hboro sdaus sdaman sdboro ) //sum_aman2_dummy sum_boro2_dummy heataman heatboro
//replace heatboro=0 if heatboro==.
//label var heatboro "Num Hot months (Boro)"

merge m:1 upazila using geo14, nogen
drop if upzi==.
drop if upazila=="Nawabganj" & district == "Dhaka"
drop if upazila=="Kachua" & district == "Bagerhat"
save climate14, replace

use $climate\climate_year, clear
drop sd1 ave1 sd1_10yr ave1_10yr sd1_20yr ave1_20yr temp_sd1 temp_ave1 temp_sd1_10yr temp_ave1_10yr temp_sd1_20yr temp_ave1_20yr
capture drop rain_survey_ave1
capture rename rain_survey_ave2 rain_survey_ave
capture label var rain_survey_ave "Survey year rainfall"

foreach v of varlist sd2 ave2 sd2_10yr ave2_10yr sd2_20yr ave2_20yr adm3_pcode adm2_pcode rain_survey_ave {
	capture confirm string variable `v'
	if !_rc {
		replace `v'="0" if `v'=="NA"
	}
}
destring nid lon lat sd2 ave2 sd2_10yr ave2_10yr sd2_20yr ave2_20yr adm3_pcode adm2_pcode id rain_survey_ave, replace

gen cov_year = (ave2/sd2)
gen cov_year_10yr = (ave2_10yr/sd2_10yr)
gen cov_year_20yr = (ave2_20yr/sd2_20yr)

gen temp_cov_year = (temp_ave2/temp_sd2)
gen temp_cov_year_10yr = (temp_ave2_10yr/temp_sd2_10yr)
gen temp_cov_year_20yr = (temp_ave2_20yr/temp_sd2_20yr)

label var cov_year "Rain CoV"
label var cov_year_10yr "Rain CoV (10yr)"
label var cov_year_20yr "Rain CoV (20yr)"
label var temp_cov_year "Temp CoV"
label var temp_cov_year_10yr "Temp CoV (10yr)"
label var temp_cov_year_20yr "Temp CoV (20yr)"

merge m:1 upazila using geo12, nogen
drop if upzi==.
drop if upazila=="Nawabganj" & district == "Dhaka"
drop if upazila=="Kachua" & district == "Bagerhat"
save climate_year14, replace

**merging
use hh14.dta, clear
merge 1:1 idno using crdt14, nogen
merge 1:1 idno using chld_w14, nogen
merge 1:1 idno using exp14, nogen
merge 1:1 idno using rct14, nogen
merge 1:1 idno using yield14.dta, nogen
merge 1:1 idno using crop14.dta, nogen
merge 1:1 idno using input14.dta, nogen
merge m:1 upzi using climate14, nogen
merge m:1 upzi using climate_year14, nogen
foreach var in crdt_bnk crdt_ng crdt_inf crdt_amt_bnk crdt_amt_ng crdt_amt_inf crdt_accss bcp_uptake bcp_amt chld_w chld_w_f chld_w_n edu_exp d_rice_aus d_jute_aus d_rice_aman d_rice_robi d_rice_boro d_hyv_aus d_hyv_aman d_hyv_robi d_hyv_boro d_hyv exp_fertilizer d_fertilizer exp_pesticide d_pesticide {
	replace `var' = 0 if `var' == .
}

save 14.dta, replace