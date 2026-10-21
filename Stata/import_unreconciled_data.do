**********************************************************************
* Combine "first score" and "second score" sheets from every
* spreadsheet in a folder into one long dataset.
**********************************************************************

local dir "Unreconciled scoring results"   // <- folder containing the spreadsheets

local files : dir "`dir'" files "*.xls*"       // catches .xls, .xlsx, .xlsm

tempfile combined
local first = 1


foreach file of local files {
	if strpos("`file'", "~") > 0 continue
	di _newline "Reading `file'"
    foreach sheet in "first score" "second score" {

        import excel using "`dir'/`file'", sheet("`sheet'") firstrow  cellrange(A10:K67) clear allstring
		
		di "`sheet'"
		count
		
        gen spreadsheet_title = "`file'"
        gen sheet_name        = "`sheet'"

        if `first' {
            save `combined', replace
            local first = 0
        }
        else {
            append using `combined'
            save `combined', replace
        }
    }
}

use `combined', clear

local numeric_vars openAI_gpt5_full gemini_pro claude_sonnet openAI_full


foreach v in openAI_gpt5_full gemini_pro claude_sonnet {
    di as text "---- `v' ----"
    list spreadsheet_title sheet_name `v' if real(`v') == . & `v' != "", noobs
}

foreach v of local numeric_vars {
    destring `v', replace force
}

save "Scoring results/combined_all.dta", replace 

import excel "Scoring results/scoring_key.xlsx", clear  firstrow
tempfile key
rename Description description
keep if description != ""
replace description = "Sufficient detail on summarizing safety data" if item_no  == 49 // edit label to avoid merge errors
duplicates report description
rename Oursection subsection2
save `key'

use "Scoring results/combined_all.dta", clear


tab spreadsheet_title

gen trial = spreadsheet_title
replace trial = subinstr(trial, "validation_", "", 1)
replace trial = subinstr(trial, "unreconciled", "", 1)
replace trial = subinstr(trial, "scoring", "", 1)
replace trial = subinstr(trial, ".xlsx", "", 1)
replace trial = strtrim(trial)
 
tab trial 
 
rename Description description
replace openAI_gpt5_full =  openAI_full if  openAI_gpt5_full ==.
drop openAI_full
rename openAI_gpt5_full openai_gpt5
replace description = "Secondary analysis: Clear which analysis method applies to each secondary outcome, and which analysis population" if description == "Primary analysis: Clear which analysis method applies to each secondary outcome, and which analysis population" 
replace description = "Secondary analysis: Correct model specification" if description == "Secondary: Correct model specification" 

merge m:1 description using `key', keepusing(item_no ItemCatgory subsection2)
drop subsection
rename Subsection subsection
count if _merge ==2
assert r(N) == 0
count if _merge ==1 & Oursection != "NA"
assert r(N) == 0

keep if _merge ==3


keep trial sheet_name JAMASAP description openai_gpt5 gemini_pro claude_sonnet  Comment   item_no ItemCatgory


rename openai_gpt5 score_openai_gpt5
rename gemini_pro score_gemini_pro
rename claude_sonnet score_claude_sonnet

reshape long score_ , i(trial sheet_name description) j(model) string
rename score_ score
drop if score ==.
order trial sheet_name model description score

tab trial sheet_name
*There is some missing data where items were not rated
*This is picked up in the checking

gen rater = .
replace rater = 1 if sheet_name == "first score"
replace rater = 2 if sheet_name == "second score"
drop  Comment sheet_name
gen scored_accurately = 0
replace scored_accurately = 1 if score == 3
reshape wide score scored_accurately, i(trial model item_no) j(rater) 

gen trial_model_item = trial+"_" + model + "_" + string(item_no)

merge 1:1 trial_model_item using "Scoring results/combined_results_long.dta", keepusing(score scored_accurately)
count if _merge != 3
assert r(N) == 0
save "Scoring results/unreconciled_data.dta", replace


