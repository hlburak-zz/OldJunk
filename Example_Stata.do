
set more off
* Change the working directory
cd "N:\Transfer\HBurak\Specs task"

* Start a log
log using "N:\Transfer\HBurak\Specs task\Example_Stata.log", replace

* Change the default graphics settings
set scheme s1mono

*Read in district data
import delimited using ag092a.txt

*Flag districts with over 30,000 students
gen over30k = .
replace over30k = 1 if pk1209 >= 30000
replace over30k = 0 if pk1209 < 30000

tab over30k, mi

drop if over30k == 0

sort leaid
save readdistricts, replace
clear

*Read in school data
import delimited using sc092a.txt

sort leaid
save readschools, replace

*Merge the datasets
use readschools
merge m:1 leaid using readdistricts, keepusing(leaid over30k)
tabulate _merge

*Subset the merged dataset
drop if _merge == 1
drop _merge
save schools_largedist, replace

*check variables
drop if g0309 < 1 | g0409 < 1 | g0509 < 1
sum g0309 g0409 g0509

*add variables of interest
gen totalstud = g0309 + g0409 + g0509
sum totalstud

gen more_300 = .
replace more_300 = 1 if totalstud > 300
replace more_300 = 0 if totalstud <= 300
sum more_300

*Find average number of students in grades 3-5
gen avgstud_3to5 = .
replace avgstud_3to5 = totalstud/3
sum avgstud_3to5

*Find percent of students by race
drop if hi03m09 < 0 | hi03f09 < 0 | bl03m09  < 0 | bl03f09  < 0 | wh03m09 < 0 |  wh03f09 < 0 |  hi04m09 < 0 |  hi04f09 < 0 |  bl04m09 < 0 | ///
 				bl04f09 < 0 | wh04m09 < 0 |  wh04f09 < 0 |  hi05m09 < 0 | hi05f09 < 0 |  bl05m09 < 0 |  bl05f09 < 0 |  wh05m09 < 0 |  wh05f09 < 0
sum hi03m09 hi03f09 bl03m09 bl03f09 wh03m09 wh03f09 hi04m09 hi04f09 bl04m09 bl04f09 ///
		wh04m09 wh04f09 hi05m09 hi05f09 bl05m09 bl05f09 wh05m09 wh05f09

gen per_hispanic = .
gen per_white = .
gen per_black = .
 
replace per_hispanic = (hi03m09 + hi03f09 + hi04m09 + hi04f09 + hi05m09 + hi05f09) / totalstud
replace per_white = (wh03m09 + wh03f09 + wh04m09 + wh04f09 + wh05m09 + wh05f09)/ totalstud
replace per_black = (bl03m09 + bl03f09 + bl04m09 + bl04f09 + bl05m09 + bl05f09)/ totalstud 
                            
*May need to do some renaming before saving                                                              
*Save complete schools dataset
rename fipst state
rename schno schid
rename schnam09 schoolname
rename leanm09 lea_name
save schools, replace

keep leaid lea_name state schid schoolname avgstud_3to5 totalstud more_300 per_hispanic per_white per_black
save schoolsout, replace
clear

*generate school level counts
use schools

gen totalhi = .
replace totalhi = (hi03m09 + hi03f09 + hi04m09 + hi04f09 + hi05m09 + hi05f09)
gen totalwh = .
replace totalwh = (wh03m09 + wh03f09 + wh04m09 + wh04f09 + wh05m09 + wh05f09)
gen totalbl = .
replace totalbl = (bl03m09 + bl03f09 + bl04m09 + bl04f09 + bl05m09 + bl05f09)

gen totalhi_300p = .
replace totalhi_300p = (hi03m09 + hi03f09 + hi04m09 + hi04f09 + hi05m09 + hi05f09) if more_300 == 1
replace totalhi_300p = 0 if more_300 == 0
gen totalwh_300p = .
replace totalwh_300p = (wh03m09 + wh03f09 + wh04m09 + wh04f09 + wh05m09 + wh05f09) if more_300 == 1
replace totalwh_300p = 0 if more_300 == 0
gen totalbl_300p = .
replace totalbl_300p = (bl03m09 + bl03f09 + bl04m09 + bl04f09 + bl05m09 + bl05f09) if more_300 == 1
replace totalbl_300p = 0 if more_300 == 0
gen totalstud_300p = .
replace totalstud_300p = totalstud if more_300 == 1
replace totalstud_300p = 0 if more_300 == 0

*Generate district level counts
sort leaid

by leaid: gen dist_totalstud = sum(totalstud)
by leaid: gen dist_totalstud_300p = sum(totalstud_300p)
by leaid: gen dist_totalhi = sum(totalhi)
by leaid: gen dist_totalwh = sum(totalwh)
by leaid: gen dist_totalbl = sum(totalbl)
by leaid: gen dist_totalhi_300p = sum(totalhi_300p)
by leaid: gen dist_totalwh_300p = sum(totalwh_300p)
by leaid: gen dist_totalbl_300p = sum(totalbl_300p)

list leaid schid totalstud dist_totalstud totalhi dist_totalhi in 1/50

*Generate district level file
by leaid: drop if _n != _N

list leaid schid totalstud dist_totalstud totalstud_300p totalhi dist_totalhi in 1/5

*create the new district level variables
gen avg_hispanic_all = .
replace avg_hispanic_all =  dist_totalhi/dist_totalstud
gen avg_white_all = .
replace avg_white_all = dist_totalwh/dist_totalstud
gen avg_black_all = .
replace avg_black_all = dist_totalbl/dist_totalstud 
gen avg_hispanic_300p = .
replace avg_hispanic_300p = dist_totalhi_300p/dist_totalstud_300p 
gen avg_white_300p = .
replace avg_white_300p = dist_totalwh_300p/dist_totalstud_300p 
gen avg_black_300p = .
replace avg_black_300p = dist_totalbl_300p/dist_totalstud_300p 

*Save completed districts file

keep leaid lea_name state avg_hispanic_all avg_white_all avg_black_all avg_hispanic_300p avg_white_300p avg_black_300p
sort leaid

sum avg_hispanic_all avg_white_all avg_black_all avg_hispanic_300p avg_white_300p avg_black_300p
save districts, replace 

