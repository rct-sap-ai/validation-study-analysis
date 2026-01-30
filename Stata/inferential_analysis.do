gen scored_accurately = 0
replace scored_accurately = 1 if score_ ==3
replace scored_accurately = . if score_ ==.
encode spreadsheet_title, gen(trial_no)
encode model, gen(model_no)

  melogit scored_acchelpurately i.model_no || trial_no: // fit models
test _b[2.model]= _b[3.model] = 0 // test for differences between models

mat A = r(table)


margins model_no // obtain proportions of items scored accurately for each mdoel and 95% CI


melogit scored_accurately i.model_no##i.ItemCatgory || trial_no:
margins model_no ItemCatgory // obtain proportions of items scored accurately for each mdoel and 95% CI
