/*Author: Masanori Matsuura*/

//ssc install geonear
clear all
set more off

*set the pathes
global climate = "C:\Users\mm_wi\Documents\research\brac_credit\data\weather"
cd "$climate"


** match  data with district

* 1. import survey year rainfall (baseline: 2011Aug-2012July, endline: 2013Aug-2014July)
import delimited using "$climate\rain_survey_year.csv", clear
gen nid = _n
label var rain_survey_ave1 "Survey year average monthly rainfall (Round 1)"
label var rain_survey_ave2 "Survey year average monthly rainfall (Round 2)"
save rain_s.dta, replace

* 2. import annual historical rainfall & temperature, and merge survey year rainfall
import delimited using "$climate\rain_year.csv", clear
gen nid = _n
merge 1:1 nid using rain_s.dta, nogen keepusing(rain_survey_ave1 rain_survey_ave2)
save rain_year.dta, replace

/** match temperature data with district

import delimited using $climate\tmax_hist.csv, clear
//rename v1 nid
save tmax_h.dta, replace
*/


** match using geonear
use upazila, clear

//rename (adm2_en adm3_en y x)(district upazila lat lon)

bys upazila (lat lon): gen tag= (lat[1]!=lat[_N])|(lon[1]!=lon[_N])
list upazila lat lon if tag, sepby(district)

** upazila id
sort district upazila
egen id=group(district upazila)
label var id "Upazila ID"
save upazila_id, replace

geonear id lat lon using rain_year.dta, neighbors(nid lat lon) //match GPS coordinates of districts and rainfall.

save climate_year.dta, replace

use rain_year, clear
joinby nid using climate_year //merge historical and survey year rainfall with sub-district (upazila) data


//merge 1:1 lat lon using tmax_h.dta //merge historical temperature

drop shape_leng shape_area adm1_en adm1_pcode adm0_en adm0_pcode date validon validto tag km_to_nid
save climate_year, replace
