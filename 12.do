**BCUP baseline

**Masanori Matsuura

**2025/4/21

clear all

set more off

global base="C:\Users\mm_wi\Documents\research\brac_credit\data\baseline"
global climate="C:\Users\mm_wi\Documents\research\brac_credit\data\weather"

cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata"

**Household composition: number of HH members, number of adults, number of dependents, female HH head, HH head's age, Hh head's years of schooling
use $base\q1_1.dta, clear

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

*HH gender
recode co4 (1=0)(2=1), gen(female)
label var female "HH head is female"
*HH age
rename co5 hh_age
*HH years of schooling
gen hh_edu = co11
replace hh_edu = 0 if co11 == 91 | co11 == 92 | co11 == 92 | co11 == 93 | co11 == 95 | co11 ==.
label var hh_edu "HH head's years of schooling"

keep if co2 == 1 & lino == 1
keep idno female hh_size hh_adlt hh_dep hh_age hh_edu nvr_schl stp_schl d_nvr_shl d_stp_schl
save hh12.dta, replace

**Credit participation
use $base\q6_1_base.dta, clear

recode co4 (1/5=1 "Bank/Co-operatives")(7/13=2 "NGO")(nonm=3 "Informal"), gen(crdt_src)
label var crdt_src "Credit source"
tab crdt_src, gen(crdt)

sort idno
bysort idno: egen crdt_bnk = sum(crdt1)

bysort idno: egen crdt_ng = sum(crdt2)

bysort idno: egen crdt_inf = sum(crdt3)
duplicates drop idno crdt_bnk crdt_ng crdt_inf, force
replace crdt_bnk = 1 if crdt_bnk == 2
replace crdt_ng = 1 if crdt_ng == 2
replace crdt_inf = 1 if crdt_inf == 2 | crdt_inf == 3 | crdt_inf ==4
label var crdt_bnk "Bank/Co-operatives"
label var crdt_ng "NGO"
label var crdt_inf "Informal"

gen crdt_accss=1
label var crdt_accss "Credit access"

keep idno crdt_bnk crdt_ng crdt_inf crdt_accss
save crdt12.dta, replace
**Borrowing


**Asset holding: cow, goat


**Land: Owned land, cultivated land, land contract, sharecropping, fixed rent, 


**Non-farm self employment


**Child labor
use $base\q5_2.dta, clear
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

duplicates drop id, force

keep idno chld_w chld_w_f chld_w_n
save chld_w.dta, replace
**Annual expenditure: Food, non-food, education
use $base\q2_2.dta, clear

bysort idno: egen edu_exp = sum (co2) if co1 == 9 | co1==10 | co1== 11 | co1 == 12 | co1 == 13
replace edu_exp=0 if edu_exp ==.
label var edu_exp "Education expenditure"

keep if co1 == 9 | co1==10 | co1== 11 | co1 == 12 | co1 == 13 
duplicates drop idno edu_exp, force

keep idno edu_exp
save exp12.dta, replace
**Food security


**RCT
use $base/q_impact_assessment__4301, clear
keep idno bocd vill hhno unon upzi dist vocd hbcs ysmm ymst q1414 q1415 q1413 q151 q153 q155 q157 q1513 program phase
save rct12.dta, replace

**weather shocks
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
drop haus2 haman2 hboro2 sdaus2 sdaman2 sdboro2 aus2 aman2 boro2
destring nid lon lat haus1 haman1 hboro1 sdaus1 sdaman1 sdboro1 adm3_pcode adm2_pcode id aus1 aman1 boro1, replace
gen rshock_aus = (aus1-haus1)/sdaus1
gen rshock_aman = (aman1-haman1)/sdaman1
gen rshock_boro =  (boro1-hboro1)/sdboro1
label var rshock_aus "Rainfall shock (aus)"
label var rshock_aman "Rainfall shock (aman)"
label var rshock_boro "Rainfall shock (boro)"

merge m:1 upazila using geo12, nogen
drop if upzi==.
drop if upazila=="Nawabganj" & district == "Dhaka"
drop if upazila=="Kachua" & district == "Bagerhat"
save climate12, replace


**merging
use hh12.dta, clear
merge 1:1 idno using crdt12, nogen
merge 1:1 idno using chld_w, nogen
merge 1:1 idno using exp12, nogen
merge 1:1 idno using rct12, nogen
merge m:1 upzi using climate12, nogen
foreach var in crdt_bnk crdt_ng crdt_inf crdt_accss chld_w chld_w_f chld_w_n edu_exp{
	replace `var' = 0 if `var' == .
}
save 12.dta, replace