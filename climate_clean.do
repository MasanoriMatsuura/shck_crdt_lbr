/*Author: Masanori Matsuura*/

ssc install geonear
clear all
set more off

*set the pathes
global climate = "C:\Users\mm_wi\Documents\research\brac_credit\data\weather"

cd "---"


** match climate data with district

import delimited using $climate\rain_hist.csv, clear
rename v1 nid
save rain_h.dta, replace
import delimited using $climate\rain_survey_year.csv, clear
rename v1 nid
save rain_s.dta, replace

** match using geonear
use upazila, clear

rename (adm2_en adm3_en y x)(district upazila lat lon)

bys upazila (lat lon): gen tag= (lat[1]!=lat[_N])|(lon[1]!=lon[_N])
list upazila lat lon if tag, sepby(district)

** upazila id
sort district upazila
egen id=group(district upazila)
label var id "Upazila ID"
save upazila_id, replace

geonear id lat lon using rain_h.dta, neighbors(nid lat lon) //match GPS coordinates of districts and rainfall.

save climate.dta, replace

use rain_h, clear
joinby nid using climate //merge historical rainfall with sub-district (upazila) data

joinby nid using rain_s.dta //merge survey year rainfall

drop shape_leng shape_area adm1_en adm1_pcode adm0_en adm0_pcode date validon validto tag km_to_nid
save climate, replace
