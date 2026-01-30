use  "Scoring results/combined_results.dta", clear

gen by_var = rbinomial(1, 0.5)

graph  hbar, over(score_openai)  over(item_no, gap(0) label(labsize(vsmall)))  over(item_cat) ///
  asyvars    stack   nofill    percentage ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
   bar(1, lcolor(black) lwidth(  vvthin ) fcolor(orange_red))  ///
   bar(2, lcolor(black) lwidth(  vvthin ) fcolor(blue)) ///
   bar(3, lcolor(black) lwidth(  vvthin ) fcolor(    midgreen ))  ///
   title("OpenAI GPT5") name(open_ai, replace) ///
   xsize(6.5) ysize(9)  
   
  graph  hbar, over(score_gemini)  over(item_no, gap(0) label(labsize(vsmall)))  over(item_cat) ///
  asyvars    stack   nofill    percentage ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
   bar(1, lcolor(black)  lwidth(  vvthin ) fcolor(yellow))   ///
   bar(2, lcolor(black) lwidth(  vvthin ) fcolor(orange_red))  ///
   bar(3, lcolor(black) lwidth(  vvthin ) fcolor(blue)) ///
   bar(4, lcolor(black) lwidth(  vvthin ) fcolor(    midgreen )) ///
   title("Gemini Pro") name(gmi, replace) ///
   xsize(6.5) ysize(9)  
   
  graph  hbar, over(score_claude)  over(item_no, gap(0) label(labsize(vsmall)))  over(item_cat) ///
  asyvars    stack   nofill    percentage ///
  legend(pos(6) cols(2)) ///
  graphregion(margin(vsmall)) ///
   bar(1, lcolor(black)  lwidth(  vvthin ) fcolor(yellow))   ///
   bar(2, lcolor(black) lwidth(  vvthin ) fcolor(orange_red))  ///
   bar(3, lcolor(black) lwidth(  vvthin ) fcolor(blue)) ///
   bar(4, lcolor(black) lwidth(  vvthin ) fcolor(    midgreen )) ///
   title("Claude Sonnet") name(cs, replace) ///
   xsize(6.5) ysize(9)  
   






