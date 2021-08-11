**File cleaning for all Texas Files
*Note - for sites without duplicate case id's in the files which contain case types ("header file")
*code was left in to handle future instances of duplicates, which does not affect non-duplicate cases.

clear all
capture log close

*Save csv files as dta files and save codebooks for all cases.

cd "/home/gq25/LSC/"

local allsites : dir . dirs "*"

di `allsites'

foreach y in `allsites' {

cd "/home/gq25/LSC/`y'/"

local filelist: dir . files "*.csv"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".csv","")

foreach x in `fl'{

import delimited "/home/gq25/LSC/`y'/`x'.csv", bindquote(strict) varnames(1) maxquotedrows(unlimited) clear 

save "`x'",replace

log using "`x'_codebook", replace

codebook

log close

translate /home/gq25/LSC/`y'/`x'_codebook.smcl /home/gq25/LSC/`y'/`x'_codebook.pdf, translator(smcl2pdf) replace

}
}


**********************create eviction files*************************************

***Denton TX

cd "/home/gq25/LSC/texas_denton"

use texas_denton_header, clear

keep if case_type == "Evictions"

tempfile e
save `e'

*Label duplicate case id's

duplicates tag c2dp_case_id, gen(dup)

tab dup 

*Export duplicate case ids. None for denton

keep if dup > 0

tab dup 

if r(N)== 0{

drop *
set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_denton") sheetmodify firstrow(variables)

*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month and day 
variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

capture drop dup date2

tempfile y
save `y'

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

tab case_type
}

***El Paso TX

cd "/home/gq25/LSC/texas_el_paso"

use texas_el_paso_header, clear

keep if case_type == "Evictions"

tempfile e
save `e'

*Export duplicate case ids. No duplicates for El Paso.

duplicates tag c2dp_case_id, gen(dup)

tab dup

sort dup c2dp_case_id

keep if dup > 0

tab dup 

if r(N)== 0{

drop *
set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_el_paso") sheetmodify firstrow(variables)

*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

drop dup date2

tempfile y
save `y'

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

tab case_type

}

***Fort Bend TX

cd "/home/gq25/LSC/texas_fort_bend"

use texas_fort_bend_header, clear

keep if case_type == "Evictions"

tempfile e
save `e'

*Export duplicate case ids. One set of duplicates for fort bend

duplicates tag c2dp_case_id, gen(dup)

tab dup

sort dup c2dp_case_id

keep if dup > 0

tab dup 

if r(N)== 0{

drop *
set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_fort_bend") sheetmodify firstrow(variables)

*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/


duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

drop dup date2

tempfile y
save `y'

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

*Include year month day to ensure that the correct case is kept between duplicate case ids
merge m:1 c2dp_case_id year month day using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

tab case_type

}

*Galveston TX

cd "/home/gq25/LSC/texas_galveston"

use texas_galveston_header, clear

keep if case_type == "Eviction"

tempfile e
save `e'

*Label duplicate case id's. no duplicates for galveston

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

keep if dup > 0

tab dup 

if r(N)== 0{

drop *
set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_galveston") sheetmodify firstrow(variables)

*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

drop dup date2

tempfile y
save `y'

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

tab case_type

}

**Hayes TX

cd "/home/gq25/LSC/texas_hays"

use texas_hays_header, clear

keep if case_type == "Evictions" | case_type=="Eviction Appeal"

tempfile e
save `e'

*Label duplicate case id's. No duplicates for hayes

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

tab dup 

keep if dup > 0

tab dup

if r(N)== 0{

drop *
set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_hays") sheetmodify firstrow(variables)


*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

drop dup date2

tempfile y
save `y'

duplicates report c2dp_case_id

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

tab case_type

}

***Nueces TX

cd "/home/gq25/LSC/texas_nueces"

use texas_nueces_header, clear

keep if case_type == "Evictions" | case_type=="Eviction"

tempfile e
save `e'

tab case_type

*Label duplicate case id's. No duplicates for Nueces

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

tab dup 

keep if dup > 0

tab dup 

if r(N)== 0{

drop *

set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_nueces") sheetmodify firstrow(variables)


*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

drop dup date2

tempfile y
save `y'

duplicates report c2dp_case_id

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

}

***Smith TX

cd "/home/gq25/LSC/texas_smith"

use texas_smith_header, clear

keep if case_type == "Eviction" 

tempfile e
save `e'

tab case_type

*Label duplicate case id's. No duplicates for Smith

duplicates tag c2dp_case_id, gen(dup)

sort dup c2dp_case_id

tab dup 

keep if dup > 0

tab dup 

if r(N)== 0{

drop *

set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_smith") sheetmodify firstrow(variables)

*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

drop dup date2

tempfile y
save `y'

duplicates report c2dp_case_id

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

}

*** Tarrant TX

cd "/home/gq25/LSC/texas_tarrant"

use texas_tarrant_header, clear

keep if case_type == "Evictions" | case_type=="JP Appeal - Forcible Detainer" | case_type=="EFile Evictions"

tempfile e
save `e'

tab case_type

*Label duplicate case id's. No duplicates for Tarrant

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

tab dup 

keep if dup > 0

tab dup 

if r(N)== 0{

drop *

set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_tarrant") sheetmodify firstrow(variables)


*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

capture drop *_s date2 dup

tempfile y
save `y'

duplicates report c2dp_case_id

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

}


*** Travis TX

cd "/home/gq25/LSC/texas_travis_jp"

use texas_travis_jp_header, clear

keep if case_type == "Eviction" | case_type=="Forcible Entry and Detainer"

tempfile e
save `e'

tab case_type

*Label duplicate case ID's. No duplicates for Travis county.

duplicates tag c2dp_case_id, gen(dup)

sort dup c2dp_case_id

tab dup 

keep if dup > 0

tab dup 

if r(N)== 0{

drop *

set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_travis_jp") sheetmodify firstrow(variables)


*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

drop dup date2

tempfile y
save `y'

duplicates report c2dp_case_id

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

}


*** Williamson TX

cd "/home/gq25/LSC/texas_williamson"

use texas_williamson_header, clear

keep if case_type == "Evictions" | case_type=="Forcible Entry and Detainer" |case_type=="JP Appeal Other Real Property (Forcible Detainer)"

tempfile e
save `e'

tab case_type

*Label duplicate case ID's. No duplicates for Williamson.

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

tab dup 

keep if dup > 0

tab dup 

if r(N)== 0{

drop *

set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("texas_williamson") sheetmodify firstrow(variables)


*Create eviction files

use `e', clear

/* Duplicate case ids can be caused by a variety of factors in the case lookup database, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month 
and day variables are different between duplicate case ids). Duplicate cases that were filed second were dropped.
*/

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

capture drop dup date2

tempfile y
save `y'

duplicates report c2dp_case_id

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `y', keepusing(case_type)

keep if _m == 3

drop _m

save `x'_e, replace

}


***Export complete (all variables) duplicates for all eviction files***

cd "/home/gq25/LSC/"

local allsites : dir . dirs "*"

*di `allsites'

foreach y in `allsites' {

cd "/home/gq25/LSC/`y'/"

local filelist: dir . files "*_e.dta"
*di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

capture confirm file `x'

if _rc!=0{

use `x', clear

duplicates tag, gen(dup)

keep if dup > 0

sort dup c2dp_case_id

local a = substr("`x'",-19,19)

di "`a'"

count if dup > 0

if r(N) > 0{

export excel using "/home/gq25/LSC/`y'/`y'_e_d.xlsx" , sheet("`a'") sheetreplace firstrow(variables)

}

count

if r(N) == 0{

drop *
set obs 1
gen duplicates = "No Duplicates"
export excel using "/home/gq25/LSC/`y'/`y'_e_d.xlsx" , sheet("`a'")  sheetreplace firstrow(variables)

}
}
}
}



***Drop cases with 100% missing***

cd "/home/gq25/LSC/"

local allsites : dir . dirs "*"

di `allsites'

foreach y in `allsites' {

cd "/home/gq25/LSC/`y'/"

local filelist: dir . files "*_e.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

capture confirm file "/home/gq25/LSC/`y'/`x'.dta"

if !_rc{

use "/home/gq25/LSC/`y'/`x'.dta", clear

foreach v of varlist *{

tabmiss `v' 

if `r(mean)' == 1 {

drop `v' 

}

save "/home/gq25/LSC/`y'/`x'.dta", replace

}
}
}
}

***Export eviction file codebooks***

cd "/home/gq25/LSC/"

local allsites : dir . dirs "*"

di `allsites'

foreach y in `allsites' {

cd "/home/gq25/LSC/`y'/"

local filelist: dir . files "*_e.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

log using "`x'_codebook", replace

codebook

log close

translate /home/gq25/LSC/`y'/`x'_codebook.smcl /home/gq25/LSC/`y'/`x'_codebook.pdf, translator(smcl2pdf) replace

}
}

***Export missing rates for all variables from all eviction files***

cd "/home/gq25/LSC/"

local allsites : dir . dirs "*"

di `allsites'

foreach y in `allsites' {

cd "/home/gq25/LSC/`y'/"

local filelist: dir . files "*_e.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

capture confirm file "/home/gq25/LSC/`y'/`x'.dta"

if !_rc{

use "/home/gq25/LSC/`y'/`x'.dta", clear

local a = substr("`x'",-19,19)

putexcel set "`y'_missing", sheet(`a', replace) modify

local row=2

foreach v of varlist *{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row' = "`v'"
putexcel B1 = "Percent Missing"
putexcel B`row' = `r(mean)'
putexcel C1 = "Drop"

if `r(mean)'==1{
putexcel C`row' = "Drop"
}
local ++row

}
}
}
}

***Export all cases vs eviction counts***

cd "/home/gq25/LSC/"

local allsites : dir . dirs "*"

di `allsites'

foreach y in `allsites' {

cd "/home/gq25/LSC/`y'/"

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

local row=2

foreach x in `fl'{

capture confirm file "/home/gq25/LSC/`y'/`x'_e.dta"

if !_rc{

use `x', clear

local a = substr("`x'",-19,19)

putexcel set "`y'_counts", modify

count

putexcel A1 = "File"
putexcel A`row' = "`x'"
putexcel B1 = "All Cases Files"
putexcel B`row' = `r(N)'
local ++row

}
}

local row = 2

foreach x in `fl'{

capture confirm file "/home/gq25/LSC/`y'/`x'_e.dta"

if !_rc{

use `x'_e, clear

local a = substr("`x'",-19,19)

putexcel set "`y'_counts", modify

count

putexcel C1 = "Evictions Files"
putexcel C`row' = `r(N)'
local ++row

}
}
}

