
import delimited "D:\nemone_2_darsadi_1402.csv", encoding(UTF-8) 

// binscatter cardpermonth_1402 daramad if id==parent_id & cardpermonth_1402>0 & daramad>0

keep if sabteahval_provincename == "تهران"

gen carplusstock = carsprice + bourse_netportfovalue

replace daramad = 0 if mi(daramad)
replace carplusstock=0 if mi(carplusstock)
replace carplusstock=0 if mi(carplusstock)

gcollapse (sum) cardpermonth_1402 (sum) daramad (sum) carplusstock , by(parent_id) fast

cumul cardpermonth_1402, generate(Fy)
cumul daramad, generate(FRent)
cumul carplusstock, generate(Fcarplusstock)

keep cardpermonth_1402 daramad Fy FRent carplusstock Fcarplusstock

save "D:\df_cleaned_refah.dta", replace


