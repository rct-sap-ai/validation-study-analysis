
use  "Scoring results/combined_results_long.dta", clear

drop if score ==.

encode spreadsheet_title, gen(trial_no)


gen model_no = .
replace model_no = 1 if model == "claude_sonnet"
replace model_no = 2 if model == "gemini_pro"
replace model_no = 3 if model == "openai_gpt5"

assert model_no != .

tempname postname
tempfile results
postfile `postname' str100(score model1 model2 model3) using `results', replace


cap log close
log using sensitivity_analysis_log.txt, replace text

**********************************************************************
*Primary analysis
**********************************************************************
count if  model =="openai_gpt5" & score !=.
local n_items = r(N)
post `postname' ("") ("OpenAI GPT 5") ("Google Gemini Pro") ("Claude Sonnet") 
post `postname' ("Overall Score (`n_items' items per model)") ("") ("") ("") 


**********************************************************************
* Get Raw Counts (n) 
**********************************************************************
levelsof model, local (models)
foreach model in `models'{
	count if model == "`model'" & score !=.
	local N = r(N)
	forvalues i = 0 (1) 3 {
		di "scored `i' for `model'"
		count if score ==`i' & model == "`model'"  
		local n = r(N)

		local pct = (`n'/`N')*100
		local pct_str = string(`pct', "%2.0f")
		local `model'_`i'_n_pct = "`n' (`pct_str'%)"
	}
}


**********************************************************************
* Run Model and Get P-Value
**********************************************************************
meologit score i.model_no || trial_no: || item_no: , or
test 1.model_no = 2.model_no = 3.model_no 
local p_str = string(r(p), "%4.2f")




**********************************************************************
* Post to Results Table
**********************************************************************
* Ensure your postfile was defined with 5 variables to include the p-value column
forvalues i = 0 (1) 3 {
	post `postname' ("n scored `i' (%)") ("`openai_gpt5_`i'_n_pct'") ("`gemini_pro_`i'_n_pct'") ("`claude_sonnet_`i'_n_pct'") 
}
post `postname' ("p-value for test of equal performance by model") ("`p_str'") ("") ("") 

**********************************************************************
*Secondary analysis
**********************************************************************


**********************************************************************
* Secondary Analysis: By Item Category
**********************************************************************
meologit score i.model_no##i.item_cat || trial_no: || item_no: , or

*Tests
test 2.item_cat
local p_item_cat =  cond(r(p) < 0.001, "<0.001", string(r(p), "%4.3f"))

test 1.model_no = 2.model_no = 3.model_no // test for differences in descriptive items
local p_other = string(r(p), "%4.2f")

test 1.model_no#2.item_cat = 2.model_no#2.item_cat = 3.model_no#2.item_cat // test of interaction term (unused result)

test 1.model_no+1.model_no#2.item_cat = 2.model_no+2.model_no#2.item_cat = 3.model_no+3.model_no#2.item_cat // test for differences in statistical items
local p_stats = string(r(p), "%4.2f")


levelsof model, local (models)
foreach model in `models'{
	count if model == "`model'" & score !=. & item_cat == 1
	local N = r(N)
	forvalues i = 0 (1) 3 {
		di "scored `i' for `model' , item cat 1"
		count if score ==`i' & model == "`model'"   & item_cat == 1
		local n = r(N)
		local pct = (`n'/`N')*100
		local pct_str = string(`pct', "%2.0f")
		local `model'_`i'_n_pct = "`n' (`pct_str'%)"
	}
}


*m1 = claude_sonnet 
*m2 = gemini_pro  
*m3 = openai_gpt5

*Table goes OAI=3, gemini=2, claude=1
count if item_cat == 1 & model  =="openai_gpt5"
local n_items = r(N)
post `postname' ("Other Items (`n_items' items per model)") ("") ("") ("") 
forvalues i = 0 (1) 3 {
	post `postname' ("n scored `i' (%)") ("`openai_gpt5_`i'_n_pct'") ("`gemini_pro_`i'_n_pct'") ("`claude_sonnet_`i'_n_pct'") 
}
post `postname' ("p-value for test of equal performance by model for descriptive items") ("`p_other'") ("") ("") 

* 3. Handle "Statistical Items" (item_cat == 2)

levelsof model, local (models)
foreach model in `models'{
	count if model == "`model'" & score !=. & item_cat == 2
	local N = r(N)
	forvalues i = 0 (1) 3 {
		di "scored `i' for `model', item cat 2"
		count if score ==`i' & model == "`model'"   & item_cat == 2
		local n = r(N)
		local pct = (`n'/`N')*100
		local pct_str = string(`pct', "%2.0f")
		local `model'_`i'_n_pct = "`n' (`pct_str'%)"
	}
}





*Postfile goes openai, google, claude
count if item_cat == 2 & model =="openai_gpt5"
local n_items = r(N)
post `postname' ("Statistical Items (`n_items' items per model)") ("") ("") ("") 
forvalues i = 0 (1) 3 {
	post `postname' ("n scored `i' (%)") ("`openai_gpt5_`i'_n_pct'") ("`gemini_pro_`i'_n_pct'") ("`claude_sonnet_`i'_n_pct'")
}
post `postname' ("p-value for test of equal performance by model for statistical items") ("`p_stats'") ("") ("") 

**********************************************************************
* Secondary Analysis: Comparison of Descriptive vs Statistical
**********************************************************************
*melogit scored_accurately i.model_no##i.item_cat || trial_no: || item_no: , or

* 1. Calculate ORs and p-values using lincom
* We store them in locals to post them all at once in a single row later.

* OpenAI (Model 3, Item_cat 2 vs 1)
lincom 2.item_cat + 3.model_no#2.item_cat, or
local oai_or = string(r(estimate), "%4.2f") + " (" + string(r(lb), "%4.2f") + " - " + string(r(ub), "%4.2f") + ")"
local oai_p  = cond(r(p) < 0.001, "<0.001", string(r(p), "%4.3f"))

* Google (Model 2, Item_cat 2 vs 1)
lincom 2.item_cat + 2.model_no#2.item_cat, or
local g_or = string(r(estimate), "%4.2f") + " (" + string(r(lb), "%4.2f") + " - " + string(r(ub), "%4.2f") + ")"
local g_p  = cond(r(p) < 0.001, "<0.001", string(r(p), "%4.3f"))

* Claude (Model 1, Item_cat 2 vs 1)
lincom 2.item_cat + 1.model_no#2.item_cat, or
local claude_or = string(r(estimate), "%4.2f") + " (" + string(r(lb), "%4.2f") + " - " + string(r(ub), "%4.2f") + ")"
local claude_p  = cond(r(p) < 0.001, "<0.001", string(r(p), "%4.3f"))

**********************************************************************
* Post the Comparison Rows
**********************************************************************

* Header Row
post `postname' ("Comparison: Descriptive vs Stats") ("") ("") ("") 

* OR (95% CI) Row
post `postname' ("OR (95% CI)") ("`oai_or'") ("`g_or'") ("`claude_or'") 

* p-value Row
post `postname' ("p-value") ("`oai_p'") ("`g_p'") ("`claude_p'") // ("`p_item_cat'")

lincom  _b[2.item_cat] , or // claude
lincom  _b[2.item_cat] +_b[2.model_no#2.item_cat], or // geminai
lincom  _b[2.item_cat] +_b[3.model_no#2.item_cat], or // open ai




postclose `postname'
use `results', clear
compress

export excel "results_table_ordinal.xlsx", replace

log close

