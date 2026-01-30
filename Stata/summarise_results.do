use  "Scoring results/combined_results.dta", clear

keep item_no item_cat spreadsheet_title score*
gen item_trial_no = _n
reshape long score_, i(item_trial_no) j(model) string
rename score_ score


tempname postname
tempfile results
postfile `postname' str50(score model1 model2 model3) using `results', replace


levelsof model, local (models)
foreach model in `models'{
	di "Overall for `model'"
	count if model == "`model'" & score !=.
	local N_`model' = r(N)
}

post `postname' ("Overall Score") ("OpenAI GPT 5") ("Google Gemini Pro") ("Claude Sonnet")
forvalues i = 3 (-1) 0 {
	local score_label: label score `i'
	levelsof model, local (models)
	foreach model in `models'{
		di "Scores for `model', score `score_label'"
		count if score == `i' & model == "`model'"
		local n_`model' = r(N)
		local per_`model' = round((`n_`model''/`N_`model'')*100)
		local sum_`model' = "`n_`model'' (`per_`model''%)"
	}
	post `postname' ("`score_label'") ("`sum_openai_gpt5'") ("`sum_gemini_pro'")  ("`sum_claude_sonnet'")
}

forvalues cat = 2 (-1) 1 {
	post `postname' ("") ("") ("") ("")
	local cat_label: label item_cat `cat'

	post `postname' ("`cat_label'") ("OpenAI GPT 5") ("Google Gemini Pro") ("Claude Sonnet")

	foreach model in `models'{
		count if model == "`model'" & item_cat == `cat' & score != .
		local N_`model' = r(N)
	}


	forvalues i = 3 (-1) 0 {
		local score_label: label score `i'
		levelsof model, local (models)
		foreach model in `models'{
			count if score == `i' & model == "`model'" & item_cat == `cat'
			local n_`model' = r(N)
			local per_`model' = round((`n_`model''/`N_`model'')*100)
			local sum_`model' = "`n_`model'' (`per_`model''%)"
		}
		post `postname' ("`score_label'") ("`sum_openai_gpt5'") ("`sum_gemini_pro'")  ("`sum_claude_sonnet'")
	}
}


postclose `postname'
use `results', clear
compress

export delimited using "Scoring results/descriptive_results.csv", replace
