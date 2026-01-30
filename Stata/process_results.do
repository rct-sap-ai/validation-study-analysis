 cd "/Users/k1811974/Library/CloudStorage/OneDrive-King'sCollegeLondon/Grants/MhAPS School Grant/sapai"

import excel "Scoring results/scoring_key.xlsx", clear  firstrow
tempfile key
rename Description description
keep if description != ""

tab description
duplicates report description

save `key'

import delimited using "Scoring results/prelim_results_v2.csv", clear varnames(1) 
keep if description != ""
recast  str2045 description
merge m:1 description using `key', keepusing(item_no ItemCatgory )

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


keep item_no item_cat spreadsheet_title score*
gen item_trial_no = _n
reshape long score_, i(item_trial_no) j(model) string
rename score_ score

save "Scoring results/combined_results_long.dta", replace
