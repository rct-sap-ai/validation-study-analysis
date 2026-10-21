*This file runs the scripts in order to reproduce results for validation of SAPAI

*Importing and processing data
do "Stata/process_results.do"
do "Stata/import_unreconciled_data.do"

*Inter-rater-reliability
do "Stata/an_inter_rater_rel.do"

*Producing analysis tables
do "Stata/inferential_analysis.do"
do "Stata/sensitivity_analysis_ordinal_models.do"
do "Stata/descriptives_by_rater.do"

*Other statitistics
do "Stata/an_primary_error_free.do"
