use "Scoring results/unreconciled_data.dta", clear

tabstat score1 score2 score, by(trial) stats(count) // note there is some missing data in first score and second score. Expect 147 scores.

su score1 score2 score // score is the reconciled truth



su scored_accurately1 scored_accurately2 scored_accurately // scored is the reconciled truth

kap score1 score2, wgt(w2) // cohen's kappa with quadratic weights. Quadratic weights are used to account for orindal nature of outcome
kap score1 score2 // unweighted agreement

