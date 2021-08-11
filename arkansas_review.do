**Arkansas file cleaning

clear all
capture log close

*Unzip arkansas

cd "/home/share/LSC/"

unzipfile "arkansas.zip"

*save csv files as dta files

cd "/home/share/LSC/arkansas/"

local filelist: dir . files "*.csv"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".csv","")

foreach x in `fl'{

import delimited "`x'.csv", varnames(1) clear

save `x', replace

}

*Restrict case types to eviction cases

use "/home/share/LSC/arkansas/arkansas_case_description.dta", clear

keep if type == "UD - LANDLORD/TENANT UNLAWFULDETAIN" | type == "UO - LANDLORD/TENANT OTHER" | type == "SJ - SC-EVICTION SMALL CLAIMS"

*There are no duplicate case ids in the evictions case types file

duplicates report case_id

tempfile z
save `z'

*Export duplicate case id's

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

keep if dup > 0

tab dup 

if r(N)== 0{

drop *

set obs 1

generate str no_duplicates = "no duplicates" in 1

}

export excel using "/home/gq25/LSC/lsc_evictions_duplicate_case_ids.xlsx", sheet("arkansas") sheetmodify firstrow(variables)

/* Duplicate case ids can be caused by a variety of factors in the case lookup repository, such as
cases being transferred or cases being related. However, due to the scraping algorithm, only the case that
was filed first between duplicate case ids has information reflected in the data (only the year month and day variables are different between duplicate case ids). Consequently, we dropped the 3 duplicate entries that were filed second.
*/

use `z', clear

duplicates tag c2dp_case_id, gen(dup)
sort dup c2dp_case_id

*Create date variable out of existing variables for comparison

capture drop date2
gen date2 = mdy(month,day,year)
format date2 %d

drop if c2dp_case_id[_n] == c2dp_case_id[_n+1] & date2[_n] > date2[_n+1]
drop if c2dp_case_id[_n] == c2dp_case_id[_n-1] & date2[_n] > date2[_n-1]

capture drop date2 dup

*restrict other files to eviction cases

cd "/home/share/LSC/arkansas/"

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

local row=2

foreach x in `fl'{

use `x', clear

merge m:1 c2dp_case_id using `e', keepusing(type)

keep if _m == 3

drop _m

save `x'_e, replace

}

*Export all cases vs eviction counts

cd "/home/share/LSC/arkansas/"

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

local row = 2

foreach x in `fl'{

capture confirm file "/home/share/LSC/arkansas/`x'_e.dta"

if !_rc{

use `x', clear

local a = substr("`x'",-19,19)

putexcel set "arkansas_counts", modify

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

capture confirm file "/home/share/LSC/arkansas/`x'_e.dta"

if !_rc{

use `x'_e, clear

local a = substr("`x'",-19,19)

putexcel set "arkansas_counts", modify

count

putexcel C1 = "Evictions Files"
putexcel C`row' = `r(N)'
local ++row

}
}

*Export missing rates for eviction file variables

cd "/home/share/LSC/arkansas/"

local filelist: dir . files "*_e.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

capture confirm file "/home/share/LSC/arkansas/`x'.dta"

if !_rc{

use "/home/share/LSC/arkansas/`x'.dta", clear

local a = substr("`x'",-19,19)

putexcel set "arkansas_missing", sheet(`a', replace) modify

local row=2

foreach v of varlist *{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row' = "`v'"
putexcel B1 = "Percent Missing"
putexcel B`row' = `r(mean)'
putexcel C1 = "Drop"

if `r(mean)' == 1 {

putexcel C`row' = "Drop"

}

local ++row

}
}
}

*Drop variables with complete missingness

cd "/home/share/LSC/arkansas/"

local filelist: dir . files "*_e.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

capture confirm file "/home/share/LSC/arkansas/`x'.dta"

if !_rc{

use "/home/share/LSC/arkansas/`x'.dta", clear

foreach v of varlist *{

tabmiss `v' 

if `r(mean)'==1{

drop `v'

}

save `x', replace

}
}
}


*Create codebooks for all cases and evictions files

cd "/home/share/LSC/arkansas/"

local filelist: dir . files "*.dta"
di `filelist'

local fl = ustrregexra(`"`filelist'"', ".dta","")

foreach x in `fl'{

use `x', clear

log using "`x'_codebook", replace

codebook

log close

translate /home/share/LSC/arkansas/`x'_codebook.smcl /home/share/LSC/arkansas/`x'_codebook.pdf, translator(smcl2pdf) replace

}


*Export complete (all variables) duplicates for all eviction files for evaluation

cd "/home/share/LSC/delaware/"

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

export excel using "/home/share/LSC/delaware/delaware_e_d.xlsx" , sheet("`a'") sheetreplace firstrow(variables)

}

count

if r(N) == 0{

drop *
set obs 1
gen duplicates = "No Duplicates"
export excel using "/home/share/LSC/delaware/delaware_e_d.xlsx" , sheet("`a'")  sheetreplace firstrow(variables)

}
}
}


