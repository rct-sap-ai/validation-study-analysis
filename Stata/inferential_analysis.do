
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
postfile `postname' str50(score model1 model2 model3 p_value) using `results', replace


cap log close
log using primary_analysis_log.txt, replace text

**********************************************************************
*Primary analysis
**********************************************************************
count if  model =="openai_gpt5" & scored_accurately !=.
local n_items = r(N)
post `postname' ("") ("OpenAI GPT 5") ("Google Gemini Pro") ("Claude Sonnet") ("p-value")
post `postname' ("Overall Score (`n_items' items per model)") ("") ("") ("") ("")


**********************************************************************
* 1. Get Raw Counts (n) where scored_accurately == 1
**********************************************************************
levelsof model, local (models)
foreach model in `models'{
	di "scored accurately for `model'"
	count if scored_accurately ==1 & model == "`model'"  
	local n = r(N)
	count if model == "`model'" & scored_accurately !=.
	local N = r(N)
	local pct = (`n'/`N')*100
	local pct_str = string(`pct', "%2.0f")
	local `model'_n_pct = "`n' (`pct_str'%)"
}


**********************************************************************
* 2. Run Model and Get P-Value
**********************************************************************
melogit scored_accurately i.model_no || trial_no: || item_no: , or
test 1.model_no = 2.model_no = 3.model_no 
local p_str = string(r(p), "%4.2f")

**********************************************************************
* 3. Get Margins and Format Strings
**********************************************************************
margins model_no
matrix A = r(table)

* Claude (Col 1)
local claude_b = string(A[1,1]*100, "%2.0f")
local claude_ll= string(A[5,1]*100, "%2.0f")
local claude_ul= string(A[6,1]*100, "%2.0f")


* Google (Col 2)
local g_b      = string(A[1,2]*100, "%2.0f")
local g_ll     = string(A[5,2]*100, "%2.0f")
local g_ul     = string(A[6,2]*100, "%2.0f")

* OpenAI (Col 3)
local oai_b    = string(A[1,3]*100, "%2.0f")
local oai_ll   = string(A[5,3]*100, "%2.0f")
local oai_ul   = string(A[6,3]*100, "%2.0f")

**********************************************************************
* 4. Construct CI strings
**********************************************************************

* Format: "74% - 83%"
local oai_ci      = "`oai_ll'% - `oai_ul'%"
local g_ci        = "`g_ll'% - `g_ul'%"
local claude_ci   = "`claude_ll'% - `claude_ul'%"

**********************************************************************
* 5. Post to Results Table
**********************************************************************
* Ensure your postfile was defined with 5 variables to include the p-value column
post `postname' ("n (%)") ("`openai_gpt5_n_pct'") ("`gemini_pro_n_pct'") ("`claude_sonnet_n_pct'") ("`p_str'")
post `postname' ("95% CI") ("`oai_ci'") ("`g_ci'") ("`claude_ci'") ("")


**********************************************************************
*Secondary analysis
**********************************************************************


**********************************************************************
* Secondary Analysis: By Item Category
**********************************************************************
melogit scored_accurately i.model_no##i.item_cat || trial_no: || item_no: , or

*Tests
test 2.item_cat
local p_item_cat =  cond(r(p) < 0.001, "<0.001", string(r(p), "%4.3f"))

test 1.model_no = 2.model_no = 3.model_no // test for differences in descriptive items
local p_other = string(r(p), "%4.2f")

test 1.model_no#2.item_cat = 2.model_no#2.item_cat = 3.model_no#2.item_cat // test of interaction terms (unused result)

test 1.model_no+1.model_no#2.item_cat = 2.model_no+2.model_no#2.item_cat = 3.model_no+3.model_no#2.item_cat // test for differences in statistical items
local p_stats = string(r(p), "%4.2f")

*test that all differences between statistical and descriptive items are zero
test _b[2.item_cat] = _b[2.model_no#2.item_cat] = _b[3.model_no#2.item_cat] = 0 // test of zero for all odds ratios comparing stats to descriptive
local p_joint =  cond(r(p) < 0.001, "<0.001", string(r(p), "%4.3f"))

* 1. Get Margins for all combinations
margins item_cat#model_no
matrix A = r(table)

* 2. Handle "Other Items" (item_cat == 1)
* Rows in r(table) for item_cat 1: Col 3 (OAI), Col 2 (Google), Col 1 (Claude)

foreach m in 1 2 3 {
    local ll_`m' = string(A[5,`m']*100, "%2.0f")
    local ul_`m' = string(A[6,`m']*100, "%2.0f")
}

levelsof model, local (models)
foreach model in `models'{
	di "scored accurately for `model'"
	count if scored_accurately ==1 & model == "`model'"  & item_cat == 1
	local n = r(N)
	count if model == "`model'" & scored_accurately !=. & item_cat == 1
	local N = r(N)
	local pct = (`n'/`N')*100
	local pct_str = string(`pct', "%2.0f")
	local `model'_n_pct = "`n' (`pct_str'%)"
}


*m1 = claude_sonnet 
*m2 = gemini_pro  
*m3 = openai_gpt5

*Table goes OAI=3, gemini=2, claude=1
count if item_cat == 1 & model  =="openai_gpt5"
local n_items = r(N)
post `postname' ("Other Items (`n_items' items per model)") ("") ("") ("") ("")
post `postname' ("n (%)") ("`openai_gpt5_n_pct'") ("`gemini_pro_n_pct'") ("`claude_sonnet_n_pct'") ("`p_other'")
post `postname' ("95% CI") ("`ll_3'% - `ul_3'%") ("`ll_2'% - `ul_2'%") ("`ll_1'% - `ul_1'%") ("")

* 3. Handle "Statistical Items" (item_cat == 2)
* Rows in r(table) for item_cat 2: Col 4 (claude), Col 5 (Google), Col 6 (OAI)


foreach m in 1 2 3 {
    local col = `m' + 3 // Offset by 3 because first 3 columns were item_cat 1
    local ll_`m' = string(A[5,`col']*100, "%2.0f")
    local ul_`m' = string(A[6,`col']*100, "%2.0f")
}

levelsof model, local (models)
foreach model in `models'{
	di "scored accurately for `model'"
	count if scored_accurately ==1 & model == "`model'"  & item_cat == 2
	local n = r(N)
	count if model == "`model'" & scored_accurately !=. & item_cat == 2
	local N = r(N)
	local pct = (`n'/`N')*100
	local pct_str = string(`pct', "%2.0f")
	local `model'_n_pct = "`n' (`pct_str'%)"
}



*Postfile goes openai, google, claude
count if item_cat == 2 & model =="openai_gpt5"
local n_items = r(N)
post `postname' ("Statistical Items (`n_items' items per model)") ("") ("") ("") ("")
post `postname' ("n (%)") ("`openai_gpt5_n_pct'") ("`gemini_pro_n_pct'") ("`claude_sonnet_n_pct'") ("`p_stats'")
post `postname' ("95% CI") ("`ll_3'% - `ul_3'%") ("`ll_2'% - `ul_2'%") ("`ll_1'% - `ul_1'%") ("")

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
* 2. Post the Comparison Rows
**********************************************************************

* Header Row
post `postname' ("Comparison: Descriptive vs Stats") ("") ("") ("") ("")

* OR (95% CI) Row
post `postname' ("OR (95% CI)") ("`oai_or'") ("`g_or'") ("`claude_or'") ("")

* p-value Row
post `postname' ("p-value") ("`oai_p'") ("`g_p'") ("`claude_p'") ("`p_joint'")

lincom  _b[2.item_cat] , or // claude
lincom  _b[2.item_cat] +_b[2.model_no#2.item_cat], or // geminai
lincom  _b[2.item_cat] +_b[3.model_no#2.item_cat], or // open ai


*sensitivity analysis
* This is the pre-specified model
melogit scored_accurately i.model_no || trial_no: , or
test _b[2.model_no]= _b[3.model_no] = 0 // test for differences between models
estat icc

* This is an ologit model.
meologit score i.model_no || trial_no: || item_no: , or // fit models
test _b[2.model_no]= _b[3.model_no] = 0 // test for differences between models
estat icc


postclose `postname'
use `results', clear
compress

export excel "results_table.xlsx", replace

log close

