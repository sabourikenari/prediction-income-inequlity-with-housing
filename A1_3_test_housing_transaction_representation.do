** ------------------------------------------------------------------------
** ------------------------------------------------------------------------
cd "C:\Users\Ehsan\Dropbox\Iran Inequality Measure, Zahra Shamlou\Python"

import delimited "D:\nemone_2_darsadi_1402.csv", encoding(UTF-8) clear

// binscatter cardpermonth_1402 daramad if id==parent_id & cardpermonth_1402>0 & daramad>0

keep if sabteahval_countyname  == "تهران"

keep if id == parent_id

rename dashboard_postalcode7digits postalCode

tostring postalCode, gen(loc) format(%10.0f)
gen region6 = real(substr(loc,1,6))
// drop postalCode
gen region2 = substr(loc,1,2)
destring region2, replace
gen region3 = substr(loc,1,3)
destring region3, replace
gen region4 = substr(loc,1,4)
destring region4, replace
gen region5 = substr(loc,1,5)
destring region5, replace

preserve 
rename region5 region
gcollapse (count) pop_count=id, by(region) fast
gcollapse (sum) pop_total = pop_count, fast merge
gen pop_share = pop_count / pop_total
sum pop_share
drop pop_total
save ".\..\Data\A1_3_pop_share.dta", replace

restore


** ------------------------------------------------------------------------
**	Data cleaning 
** ------------------------------------------------------------------------

* loading house transaction data

use ".\..\Data\Real estate Transaction\IranHousePrice.dta", clear

keep if prov==8		// extracting transaction of Tehran Province

keep if (usingType == 1) // Residentioal real estate

* drop outlier based on house area
keep if (area>10) & (area<250)
drop if age>25

* transforming price to million Toman
replace totalPrice = totalPrice /10000
replace price  = price /10000

* drop outliers
keep if area < 1000
keep if age < 70

label variable totalPrice "total price"
label variable price "price per m^2" 
label variable area "Area"
label variable age "Age"


* define the Jalali month and year
split dateShamsi, generate(var) parse(/) destring
rename var1 yearJalali
rename var2 monthJalali
rename var3 dayJalali


tostring postalCode, gen(loc) format(%10.0f)
gen region6 = real(substr(loc,1,6))
drop postalCode
rename region6 postalCode
gen region2 = substr(loc,1,2)
destring region2, replace
gen region3 = substr(loc,1,3)
destring region3, replace
gen region4 = substr(loc,1,4)
destring region4, replace
gen region5 = substr(loc,1,5)
destring region5, replace

** location of each transaction
// merge m:1 postalCode using "./../Data/Metro/M0_1 metro station distance calculation.dta", keep(master match)



** ------------------------------------------------------------------------
** ------------------------------------------------------------------------

preserve 

    ** share of transaction at each postal code region
    gen region = region5
    gcollapse (count) trans_count = id (mean) totalPrice, by(region yearJalali) fast 
    gcollapse (sum) trans_yearly = trans_count, by(yearJalali) fast merge
    gen trans_share = trans_count / trans_yearly

    hashsort yearJalali totalPrice 
    by yearJalali: gen rank_price = _n/_N

    * create new var that is the share of the previous year
    hashsort region yearJalali
    by region: gen trans_n = trans_share[_n+1] if _n<_N & (yearJalali[_n] == yearJalali[_n+1] - 1)
    replace trans_n=0 if mi(trans_n)

    drop if trans_count < 10

    merge m:1 region using ".\..\Data\A1_3_pop_share.dta", keep(master match) keepusing(pop_share pop_count)

    ** graph the share of transactions and population share
    reg trans_share pop_share if yearJalali==1398 
    local coef _b["pop_share"] 
    binscatter trans_share pop_share if yearJalali==1398, name("a",replace) n(30) ///
        graphregion(color(white)) lcolor(navy) ///
        xtitle("population share") ytitle("transactions share") ///
        text(0.0004 0.0015 "slope= `: display %5.3f `coef''", placement(l) size(medthick)) ///
        legend(off)
    graph addplot function y=x, range(0 0.0026) lcolor(dkorange) lpattern(dash) lwidth(thick) 
    graph export "../Figures/Python/A1_3_pop_trans_all.pdf", replace


    reg trans_share pop_share if yearJalali==1398 & rank_price>=0.8
    local coef _b["pop_share"]
    binscatter trans_share pop_share if yearJalali==1398 & rank_price>=0.8, name("b",replace) n(30) ///
        graphregion(color(white)) lcolor(navy) ///
        xtitle("population share") ytitle("transactions share") ///
        text(0.0004 0.0015 "slope= `: display %5.3f `coef''", placement(l) size(medthick)) ///
        legend(off)
    graph addplot function y=x, range(0 0.0022) lcolor(dkorange) lpattern(dash) lwidth(thick)
    graph export "../Figures/Python/A1_3_pop_trans_top.pdf", replace


    count if yearJalali==1398

restore

reg totalPrice region4 if yearJalali==1398


