
capture cd "C:\Users\Ehsan\Dropbox\Iran Inequality Measure, Zahra Shamlou"
capture cd "C:\Users\ehsa7798\Dropbox\Iran Inequality Measure, Zahra Shamlou"

import delimited ".\Data\HIES\HIES(89-98)AggregateNEW.csv",clear

keep if province==23 // Tehran province

cumul rent [aw=weight], generate(Frent) by(year) equal

gen cpi = .
replace cpi = 185.3 if year==98
replace cpi = 137.3 if year==97
replace cpi = 109.6 if year==96
replace cpi = 100.0 if year==95
replace cpi = 91.714 if year==94
replace cpi = 81.948 if year==93
replace cpi = 70.916 if year==92
replace cpi = 52.635 if year==91
replace cpi = 40.321 if year==90
replace cpi = 33.188 if year==89
replace cpi = cpi/100

replace daramad = daramad / cpi 
replace ghazineh = ghazineh / cpi 
replace rent = rent / cpi

gen rentperarea = rent / area
gen logdaramad = log(daramad)
gen logghazineh = log(ghazineh)
gen logrent = log(rent)
gen logrentperarea = log(rentperarea)
gen logdaramadpercapita = log(daramad/tedad)
gen logghazinehpercapita = log(ghazineh / tedad)

label variable logrent "log rent"
label variable logrentperarea "log rent per area"

// ssc install reghdfe
// ssc install ftools
// ssc install estout, replace
// ssc install gtools
// net install binscatter2, from("https://raw.githubusercontent.com/mdroste/stata-binscatter2/master/")

keep if Frent>0.7

eststo clear
eststo: reghdfe logdaramad logrent [aw=weight], absorb(year)
quietly estadd local yearfe "yes", replace
eststo: reghdfe logdaramad logrentperarea [aw=weight], absorb(year)
quietly estadd local yearfe "yes", replace

eststo: reghdfe logdaramadpercapita logrent [aw=weight], absorb(year)
quietly estadd local yearfe "yes", replace
eststo: reghdfe logdaramadpercapita logrentperarea [aw=weight], absorb(year)
quietly estadd local yearfe "yes", replace

eststo: reghdfe logghazineh logrent [aw=weight], absorb(year)
quietly estadd local yearfe "yes", replace
eststo: reghdfe logghazineh logrentperarea [aw=weight], absorb(year)
quietly estadd local yearfe "yes", replace

eststo: reghdfe logghazinehpercapita logrent [aw=weight], absorb(year)
quietly estadd local yearfe "yes", replace
eststo: reghdfe logghazinehpercapita logrentperarea [aw=weight] , absorb(year)
quietly estadd local yearfe "yes", replace

esttab, star(* 0.1 ** 0.05 *** 0.01) label ///
	 stats(yearfe N r2_within, labels("year fixed effect" "N" "R2")) nonumbers se ///
	mgroups("log income" "log income per capita" "log expenditure" "log expenditure per capita", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles 

esttab using "./Figures/Python/A1_3_specifications.tex", star(* 0.1 ** 0.05 *** 0.01) label ///
	 stats(yearfe N r2_within, labels("year fixed effect" "N" "R2")) nonumbers se ///
	mgroups("log income" "log income per capita" "log expenditure" "log expenditure per capita", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles replace 


* ------------------------------------------------------
reghdfe logdaramad logrent if inrange(year,89,93) [aw=weight] , absorb(year)
local coef _b["logrent"]
local se _se["logrent"]
local r2 `e(r2_within)'

binscatter2 logdaramad logrent if inrange(year,89,93) [aw=weight], absorb(year) n(50) ///
	graphregion(color(white)) name("rent1",replace)  lcolor(navy) altcontrols ///
	xtitle("house value (in log)") ytitle("household income (in log)") ///
	text(19.8 18.4 "slope= `: display %5.3f `coef'' (SE= `: display %5.3f `se'')", placement(l)) ///
	text(19.5 18.4 "R2= `: display %5.2f `r2''", placement(l)) ylabel(19.5(0.5)21.5)
graph export "./Figures/Python/A1_1_prediction_top_rent_first_period.pdf", replace

* ------------------------------------------------------
reghdfe logdaramad logrent if inrange(year,94,98) [aw=weight] , absorb(year)
local coef _b["logrent"]
local se _se["logrent"]
local r2 `e(r2_within)'

binscatter2 logdaramad logrent if inrange(year,94,98) [aw=weight], absorb(year) n(50) ///
	graphregion(color(white)) name("ren2",replace) lcolor(navy) altcontrols ///
	xtitle("house value (in log)") ytitle("household income (in log)") ///
	text(19.9 18.5 "slope= `: display %5.3f `coef'' (SE= `: display %5.3f `se'')", placement(l)) ///
	text(19.6 18.5 "R2= `: display %5.2f `r2''", placement(l)) ylabel(19.5(0.5)21.5)
graph export "./Figures/Python/A1_1_prediction_top_rent_second_period.pdf", replace
	
	
* ------------------------------------------------------
** plot the residuals 
reg logdaramad logrent i.year if inrange(year,89,93)
capture drop resid_1
predict resid_1, resid

capture drop resid_1_sq
gen resid_1_sq = sqrt(resid_1^2)
reghdfe resid_1_sq logrent if inrange(year,89,93) , absorb(year) vce(robust)
local coef _b["logrent"]
local se _se["logrent"]

binscatter2 resid_1_sq logrent if inrange(year,89,93) [aw=weight], n(500) ///
	graphregion(color(white)) name("rent1",replace)  lcolor(navy)  ///
	xtitle("house value (in log)") ytitle("household income (in log)") ///
	text(0.35 18.4 "slope= `: display %5.3f `coef'' (SE= `: display %5.3f `se'')", placement(l)) yscale(range(0 1.3)) ylabel(0(0.3)1.2)
graph export "./Figures/Python/A1_1_prediction_residual_first_period.pdf", replace



** right panel
reg logdaramad logrent i.year if inrange(year,94,98) , robust
capture drop resid_2
predict resid_2, resid
capture drop resid_2_sq
gen resid_2_sq = resid_2^2

reghdfe resid_2_sq logrent if inrange(year,94,98) , absorb(year) vce(robust)
local coef _b["logrent"]
local se _se["logrent"]

binscatter2 resid_2_sq logrent if inrange(year,94,98) [aw=weight], n(500) ///
	graphregion(color(white)) name("ren2",replace) lcolor(navy)  ///
	xtitle("house value (in log)") ytitle("household income (in log)") ///
	text(0.35 18.5 "slope= `: display %5.3f `coef'' (SE= `: display %5.3f `se'')", placement(l)) yscale(range(0 1.3)) ylabel(0(0.3)1.2)
graph export "./Figures/Python/A1_1_prediction_residual_second_period.pdf", replace
