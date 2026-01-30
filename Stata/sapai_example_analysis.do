clear
set obs 50
gen item = _n
expand 10
bysort item: gen trial = _n
expand 3
bysort item trial: gen model = _n

gen p = model/10 + item/100 + trial/100

gen scored_accurately = rbinomial(1, p)

melogit scored_accurately i.model || trial: // fit models
test _b[2.model]= _b[3.model] = 0 // test for differences between models

mat A = r(table)


margins model // obtain proportions of items scored accurately for each mdoel and 95% CI

gen item_type = item < 40

melogit scored_accurately i.model##i.item_type || trial:
*add test
*add code to get the right probabilities
