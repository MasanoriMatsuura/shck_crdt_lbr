**BCUP baseline

**Masanori Matsuura

**2025/4/21

clear all

set more off

global base="C:\Users\mm_wi\Documents\research\brac_credit\data\baseline"

cd "C:\Users\mm_wi\Documents\research\brac_credit\data\stata"

**Household composition: number of HH members, number of adults, number of dependents, female HH head, HH head's age, Hh head's years of schooling

use $base\q1_1.dta, clear

recode co4 (1=0)(2=1), gen(female)

**Credit participation


**Borrowing


**Asset holding: cow, goat


**Land: Owned land, cultivated land, land contract, sharecropping, fixed rent, 


**Non-farm self employment


**Child labor
use $base\q5_2.dta, clear
sort idno
drop if co5==0
drop if co5==.
bysort idno: egen chil_h = sum(co5)
**Annual expenditure: Food, non-food


**Food security


**Schooling

