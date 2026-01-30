use  "Scoring results/combined_results_long.dta", clear

gen bin_error = 1
replace bin_error = . if score == .
replace bin_error = 0 if score == 3

gen by_var = rbinomial(1, 0.5)

tab bin_error

graph  hbar bin_error,   over(model, label(labsize(vsmall)))   ///
         nofill     ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
   title("Overall") name(all, replace) ///
   xsize(6.5) ysize(9)  ytitle("Proportion of items with errors") yscale(range(0 1)) ylabel(0 (0.2) 1)
   
   
graph  hbar bin_error if item_cat == 1,   over(model, label(labsize(vsmall)))   ///
         nofill     ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
   title("Other Items") name(cat1, replace) ///
   xsize(6.5) ysize(9)  ytitle("Proportion of items with errors") yscale(range(0 1)) ylabel(0 (0.2) 1)
   
   
   
graph  hbar bin_error if item_cat == 2,   over(model, label(labsize(vsmall)))   ///
         nofill     ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
   title("Statistical Items") name(cat2, replace) ///
   xsize(6.5) ysize(9)  ytitle("Proportion of items with errors")  yscale(range(0 1)) ylabel(0 (0.2) 1)
   
   
   
 graph  hbar if item_cat == 1, over(bin_score)  over(model, gap(0) label(labsize(vsmall)))   ///
         nofill    percentage ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
     bar(1, lcolor(black)  lwidth(  vvthin ) fcolor(yellow))   ///
   bar(2, lcolor(black) lwidth(  vvthin ) fcolor(orange_red))  ///
   bar(3, lcolor(black) lwidth(  vvthin ) fcolor(blue)) ///
   bar(4, lcolor(black) lwidth(  vvthin ) fcolor(    midgreen )) ///
   title("Other Items") name(cat1, replace) ///
   xsize(6.5) ysize(9)  
   
   
graph  hbar if item_cat == 2, over(bin_score)  over(model, gap(0) label(labsize(vsmall)))   ///
         nofill    percentage ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
     bar(1, lcolor(black)  lwidth(  vvthin ) fcolor(yellow))   ///
   bar(2, lcolor(black) lwidth(  vvthin ) fcolor(orange_red))  ///
   bar(3, lcolor(black) lwidth(  vvthin ) fcolor(blue)) ///
   bar(4, lcolor(black) lwidth(  vvthin ) fcolor(    midgreen )) ///
   title("Statistical Items") name(cat2, replace) ///
   xsize(6.5) ysize(9)  
