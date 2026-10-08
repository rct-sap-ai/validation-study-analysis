

cap log close
log using descriptives_by_rater_log.txt, replace text



use "Scoring results/unreconciled_data.dta", clear
drop _merge
rename scored_accurately  scored_accurately0
rename ItemCatgory item_cat

rename score score0
reshape long score scored_accurately, i(trial model item_no) j(rater)

label define rater 0 "Consensus" 1 "Trial Statistician" 2 "Independent"
label values rater rater

gen model_no = .
replace model_no = 1 if model == "claude_sonnet"
replace model_no = 2 if model == "gemini_pro"
replace model_no = 3 if model == "openai_gpt5"

assert model_no != .

tempname postname
tempfile results
postfile `postname' str50(score model1 model2 model3) using `results', replace

**********************************************************************
*Primary analysis
**********************************************************************
count if  model =="openai_gpt5" & scored_accurately !=. & rater == 0
local n_items = r(N)
post `postname' ("") ("OpenAI GPT 5") ("Google Gemini Pro") ("Claude Sonnet") 
post `postname' ("Overall Score (`n_items' items per model)") ("") ("") ("") 


**********************************************************************
* 1. Get Raw Counts (n) where scored_accurately == 1
**********************************************************************

levelsof rater, local(raters)

foreach r in `raters' {
	preserve
	keep if rater == `r'
	
	local lab : label (`: value label rater') `r'
	
	di "Rater: `lab'"
	
	levelsof model, local (models)
	foreach model in `models'{
		di "scored accurately for `model'"
		count if scored_accurately ==1 & model == "`model'"  
		local n = r(N)
		count if model == "`model'" & scored_accurately !=.
		local N = r(N)
		local pct = (`n'/`N')*100
		local pct_str = string(`pct', "%2.0f")
		local `model'_n_pct = "`n'/`N' (`pct_str'%)"
	}




	**********************************************************************
	* 5. Post to Results Table
	**********************************************************************
	* Ensure your postfile was defined with 5 variables to include the p-value column
	post `postname' ("  `lab'") ("`openai_gpt5_n_pct'") ("`gemini_pro_n_pct'") ("`claude_sonnet_n_pct'") 
	restore
}


**********************************************************************
*Secondary analysis
**********************************************************************
count if  model =="openai_gpt5" & scored_accurately !=. & rater == 0 & item_cat == 1
local n_items = r(N)
post `postname' ("Other Items (`n_items' items per model)") ("") ("") ("") 

foreach r in `raters' {
	preserve
	keep if rater == `r'
	
	local lab : label (`: value label rater') `r'
	
	di "Rater: `lab'"

	levelsof model, local (models)
	foreach model in `models'{
		di "scored accurately for `model'"
		count if scored_accurately ==1 & model == "`model'"  & item_cat == 1
		local n = r(N)
		count if model == "`model'" & scored_accurately !=. & item_cat == 1
		local N = r(N)
		local pct = (`n'/`N')*100
		local pct_str = string(`pct', "%2.0f")
		local `model'_n_pct = "`n'/`N' (`pct_str'%)"
	}



*Table goes OAI=3, gemini=2, claude=1

	post `postname' ("  `lab'") ("`openai_gpt5_n_pct'") ("`gemini_pro_n_pct'") ("`claude_sonnet_n_pct'") 
	restore
}

* 3. Handle "Statistical Items" (item_cat == 2)
count if  model =="openai_gpt5" & scored_accurately !=. & rater == 0 & item_cat == 2
local n_items = r(N)
post `postname' ("Statistical Items (`n_items' items per model)") ("") ("") ("") 

foreach r in `raters' {
	preserve
	keep if rater == `r'
	
	local lab : label (`: value label rater') `r'
	
	di "Rater: `lab'"


	levelsof model, local (models)
	foreach model in `models'{
		di "scored accurately for `model'"
		count if scored_accurately ==1 & model == "`model'"  & item_cat == 2
		local n = r(N)
		count if model == "`model'" & scored_accurately !=. & item_cat == 2
		local N = r(N)
		local pct = (`n'/`N')*100
		local pct_str = string(`pct', "%2.0f")
		local `model'_n_pct = "`n'/`N' (`pct_str'%)"
	}

	*Postfile goes openai, google, claude

	post `postname' ("  `lab'") ("`openai_gpt5_n_pct'") ("`gemini_pro_n_pct'") ("`claude_sonnet_n_pct'") 
	restore
}


postclose `postname'
use `results', clear
compress

export excel "descriptive_by_rater.xlsx", replace

log close

