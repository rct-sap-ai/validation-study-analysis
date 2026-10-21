cap log close
log using "primary_error_free.txt", replace text

use "Scoring results/combined_results_long.dta", clear

*Checking for trials where primary analysis specified error free.


*items relating to primary analysis 

*items relating to primary outcome: 35 to 38
*items relating to secondary outcome: 39 to 42

gen no_major_errors = 0
replace no_major_errors = 1 if score > 1
tab score no_major_errors, missing


bysort subsection trial model: egen section_major_error_free = min(no_major_errors)
bysort subsection trial model: gen pickone = _n
keep if pickone ==1

bysort model: tabstat section_major_error_free if subsection == "Primary Analysis Methods", by(trial) stats(mean)

log close
