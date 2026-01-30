
use  "Scoring results/combined_results_long.dta", clear

gen scored_accurately = 0
replace scored_accurately = 1 if score ==3
replace scored_accurately = . if score ==.
encode spreadsheet_title, gen(trial_no)
encode model, gen(model_no)

  melogit scored_accurately i.model_no || trial_no: // fit models
test _b[2.model]= _b[3.model] = 0 // test for differences between models

mat A = r(table)


margins model_no // obtain proportions of items scored accurately for each mdoel and 95% CI


melogit scored_accurately i.model_no##i.item_cat || trial_no:
margins item_cat#model_no  // obtain proportions of items scored accurately for each mdoel and 95% CI

test _b[2.model]= _b[3.model] = 0 // other items
test _b[2.model] +_b[2.model_no#2.item_cat]= _b[3.model] + _b[3.model_no#2.item_cat] = 0 // stats modelling

lincom  _b[2.item_cat] , or
lincom  _b[2.item_cat] +_b[2.model_no#2.item_cat], or
lincom  _b[2.item_cat] +_b[3.model_no#2.item_cat], or
