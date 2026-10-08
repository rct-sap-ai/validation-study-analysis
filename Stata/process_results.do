
import excel "Scoring results/scoring_key.xlsx", clear  firstrow
tempfile key
rename Description description
keep if description != ""

tab description
duplicates report description
rename Oursection subsection2

replace description = "Sufficient detail on summarizing safety data" if item_no  == 49 // edit label to avoid merge errors


save `key'

import delimited using "Scoring results/results_v5_fixed.csv", clear varnames(1) 
keep if description != ""
recast  str2045 description

*** Data correction edits***
replace openai_gpt5_f~l = openai_full if spreadsheet_title == "scoring validation_eden" // for one trial the name of the column the openai results are scored in does not match the columns used for other trials. This line corrects this and brings all the data into the same format. 

replace description = "Secondary analysis: Clear which analysis method applies to each secondary outcome, and which analysis population" if description == "Primary analysis: Clear which analysis method applies to each secondary outcome, and which analysis population" 
replace description = "Secondary analysis: Correct model specification" if description == "Secondary: Correct model specification" 

replace description = "Sufficient detail on summarizing safety data" if jama_sap_ == "30" // edit label to avoid merge errors

save  "Scoring results/edited_raw_results1.dta", replace

*The line below replaces the score for an item of attend for which no score was entered. Replacing missing with a 0 for "not covered".
replace claude_sonnet = 0 if ///
	description == "Details of how baseline characteristics will be descriptively summarized" & ///
	claude_sonnet == . & ///
	spreadsheet_title == "scoring validation_attend"
	

merge m:1 description using `key', keepusing(item_no ItemCatgory subsection2)
drop subsection
rename subsection2 subsection

count if _merge ==2
assert r(N) == 0
count if _merge ==1 & our_section != "NA"
assert r(N) == 0

keep if _merge ==3

rename gemini_pro  score_gemini_pro  
rename claude_sonnet  score_claude_sonnet
rename openai_gpt5_f~l  score_openai_gpt5

label var score_gemini_pro "Gemini Pro"
label var score_claude_sonnet "Claude Sonnet"
label var score_openai_gpt5 "OpenAI GPT5"

label define score 1 "Major errors" 2 "Minor Errors" 3 "No Errors" 0 "Not covered"

label values score_gemini_pro score
label values score_claude_sonnet score
label values score_openai_gpt5 score

label define item_cat 1 "Other Items" 2 "Statistical Items"
label values ItemCatgory item_cat
rename ItemCatgory item_cat
save "Scoring results/combined_results.dta", replace


keep item_no item_cat spreadsheet_title score* subsection jama_sap_
gen item_trial_no = _n
reshape long score_, i(item_trial_no) j(model) string
rename score_ score


gen scored_accurately = 0
replace scored_accurately = 1 if score ==3
replace scored_accurately = . if score ==.

drop if score ==.


gen trial = spreadsheet_title
replace trial = subinstr(trial, "validation_", "", 1)
replace trial = subinstr(trial, "scoring", "", 1)
replace trial = strtrim(trial)
tab trial
gen trial_model_item = trial+"_" + model + "_" + string(item_no)

save "Scoring results/combined_results_long.dta", replace
