***Maricopa County File Cleaning

**Append years 2015-2020

forval i=2015(1)2020{

import excel "/home/gq25/Maricopa_AZ/2015-2020 Evictions Maricopa County.xlsx", sheet("`i'") firstrow clear

gen year_cjdc=`i'

foreach v of var *{
capture confirm format string `v'
if _rc!=0{

tostring `v', format(%50.0f)replace

}
}

tempfile `i'
save ``i''

}

forval i=2015(1)2019{

append using ``i''

}


label var year " CJDC created: Year of the file that the case came from"

capture gen FilePurged = 0

capture replace FilePurged = 1 if casenumber== "FILE PURGED"

label var FilePurged "CJDC created variable: CaseNumber indicated 'File Purged'"


**Align variable names across years

replace WritDate = WritOfRestitutionDate if missing(WritDate) & !missing(WritOfRestitutionDate)

label var WritDate "Writ of Restitution Date"

drop WritOfRestitutionDate

*label variable WritDate "Writ of restitution date"

replace PltLegalRep = PlaintiffLegalRepresented if missing(PltLegalRep) & !missing(PlaintiffLegalRepresented)

drop PlaintiffLegalRepresented

*label Variable PltLegalRep "Plaintiff legally represented"

replace DefLegalRep = DefendantLegalRepresented if missing(DefLegalRep) & !missing(DefendantLegalRepresented)

drop DefendantLegalRepresented

*label variable DefLegalRep "Defendant legally represented"

replace Def1Zip = Defendant1Zip if missing(Def1Zip) & !missing(Defendant1Zip) 

drop Defendant1Zip

*label var Def1Zip"Defendant 1 zipcode"

replace Def1Email = Defendant1Email if missing(Def1Email) & !missing(Defendant1Email)

drop Defendant1Email

*label var Def1Email "Defendant 1 email"

rename Deft1Ph Def1Ph

replace Def1Ph = Defendant1Ph if missing(Def1Ph) & !missing(Defendant1Ph)

drop Defendant1Ph

*label var Deft1ph"Defendant 1 phone number"

rename DefFTA Def1FTA

replace Def1FTA = Defendant1FTA if missing(Def1FTA) & !missing(Defendant1FTA)

drop Defendant1FTA

*label var DefFTA "Defendant"

replace Def2Email = Defendant2Email if missing(Def2Email) & !missing(Defendant2Email) 

drop Defendant2Email
 
replace Def2Ph = Defendant2Ph if missing(Def2Ph) & !missing(Defendant2Ph)

drop Defendant2Ph

rename Plaintiff1Name Plt1Name

replace Plt1Name = PlaintiffName if missing(Plt1Name) & !missing(PlaintiffName)

drop PlaintiffName

replace Address = AddressStreet if missing(Address) & !missing(AddressStreet)

drop AddressStreet

rename Plaint1Zip Plt1Zip

replace Plt1Zip = Plaintiff1Zip if missing(Plt1Zip) & !missing(Plaintiff1Zip)

drop Plaintiff1Zip

rename PltFTA Plt1FTA

replace Plt1FTA = Plaintiff1FTA if missing(Plt1FTA) & !missing(Plaintiff1FTA)

drop Plaintiff1FTA

replace zipcode = zip if missing(zipcode) & !missing(zip)

drop zip

encode MonetaryJudgment, gen(MJ)

replace JudgmentAmount = MJ if missing(JudgmentAmount) & !missing(MJ)

drop MonetaryJudgment MJ

replace CaseNumber = casenumber if missing(CaseNumber) & !missing(casenumber)

drop casenumber

rename Defendant1Address Def1Address

rename Defendant1Name Def1Name

rename Defendant2Name Def2Name

rename Plaintiff1Address Plt1Address

rename Plaintiff1Email Plt1Email

rename Plaintiff1Ph Plt1PH 

rename Plaintiff2Email Plt2Email

rename Plaintiff2Name  Plt2Name

rename Plaintiff2Ph Plt2Ph

save "/home/gq25/Maricopa_AZ/Maricopa_2015_2020.dta", replace

**Export percent missing

*use "/home/gq25/Maricopa_AZ/Maricopa_2015_2020.dta", clear

cd "/home/gq25/Maricopa_AZ/"

putexcel set "Maricopa_Percent_Missing.xlsx", replace

local row=2

foreach v of varlist FileDate CaseNumber SubCategory Immediate Court CaseStatus ///
CaseStatusDate JudgmentFor Address Zip WritDate PltLegalRep DefLegalRep ClaimAmount ///
BenchTrial Def1Name Def1Address Def1Zip Def1Email Def1Ph Def1FTA Def2Name Def2Email ///
Def2Ph Plt1Address Plt1Zip Plt1Email Plt1PH Plt1FTA Plt2Name Plt2Email Plt2Ph year ///
JudgmentAmount Plt1Name FilePurged{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}

**Redact PII for Sharing
/*
drop CaseNumber Address Def1Name Def1Address Def1Zip Def1Email Def1Ph Def1FTA Def2Name ///
Def2Email Def2Ph Plt1Address Plt1Zip Plt1Email Plt1PH Plt1FTA Plt2Email Plt2Ph 

save "/home/gq25/Maricopa_AZ/Maricopa_Pew.dta", replace
*/

**Export variable frequencies

putexcel set "Maricopa_Frequencies.xlsx", replace

putexcel A1 = "Variable" B1="Value" C1="Freq" D1="Percent" 

local row = 2

foreach v of var FileDate SubCategory Immediate Court CaseStatus CaseStatusDate JudgmentFor Zip WritDate PltLegalRep DefLegalRep ClaimAmount BenchTrial Plt2Name year JudgmentAmount Plt1Name FilePurged{

capture by `v', sort: gen `v'_v= _n == 1 
count if `v'_v

if r(N)<100{

capture encode `v', gen(`v'_n)
capture confirm var `v'_n
if _rc==0{
drop `v'
rename `v'_n `v'
}

tab `v', matcell(freq) matrow(names)

local rows = rowsof(names)

forvalues i = 1/`rows' {
 
        local val = names[`i',1]
        local val_lab : label (`v') `val'
	
	local freq_val = freq[`i',1]

putexcel A`row' = "`v'"
putexcel B`row' = "`val_lab'"
putexcel C`row' = matrix(`freq_val')
putexcel D`row' = matrix(`freq_val'/r(N))
local ++row
}
}
}


**Export variable missing rates

cd "/home/share/arizona_maricopa/"

use "/home/share/arizona_maricopa/arizona_maricopa_e_2015-2020.dta", clear

local a = substr("`x'",-19,19)

putexcel set "arizona_maricopa_missing", sheet(2015-2020, replace) modify

local row = 2

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

**Export codebook

cd "/home/share/arizona_maricopa/"

use "/home/share/arizona_maricopa/arizona_maricopa_e_2015-2020.dta", clear

log using "arizona_maricopa_e_2015-2020_codebook", replace

codebook

log close

translate /home/share/arizona_maricopa/arizona_maricopa_e_2015-2020_codebook.smcl /home/share/arizona_maricopa/arizona_maricopa_e_2015-2020_codebook.pdf, translator(smcl2pdf) replace

**Export duplicates for 2015-2020

use "/home/share/arizona_maricopa/arizona_maricopa_e_2015-2020.dta", clear

duplicates tag, gen(dup)

keep if dup > 0

sort dup CaseNumber

local a = substr("`x'",-19,19)

di "`a'"

count if dup > 0

if r(N) > 0{

export excel using "/home/share/arizona_maricopa/arizona_maricopa_e_d.xlsx" , sheet("2015-2020") sheetreplace firstrow(variables)

}

count

if r(N) == 0{

drop *
set obs 1
gen duplicates = "No Duplicates"
export excel using "/home/share/arizona_maricopa/arizona_maricopa_e_d.xlsx" , sheet("2015-2020")  sheetreplace firstrow(variables)

}


**Convert limited data file for 2000-2019

forval i=2000(1)2019{

import excel "/home/share/arizona_maricopa/2000-2019 Evictions Maricopa County - limited data.xlsx", sheet("`i'") firstrow allstring clear 

gen year_cjdc=`i'

capture confirm variable MonetaryJudgment

if !_rc{

tostring MonetaryJudgment, replace format(%20.2f)

rename MonetaryJudgment JudgmentAmount

}

foreach v of var *{

capture confirm format string `v'
if _rc!=0{

tostring `v', format(%20.0f)replace

}
}


save `i'_limited

}

forval i=2000(1)2019{

use `i'_limited, clear

duplicates report CaseNumber

}

use 2000_limited, clear

forval i=2001(1)2019{

append using `i'_limited

}

save "/home/share/arizona_maricopa/arizona_maricopa_e_2000-2019_limited", replace

**Create codebook

cd "/home/share/arizona_maricopa/"

use "/home/share/arizona_maricopa/arizona_maricopa_e_2000-2019_limited", clear

log using "arizona_maricopa_e_2000-2019_limited", replace

codebook

log close

translate /home/share/arizona_maricopa/arizona_maricopa_e_2000-2019_limited.smcl /home/share/arizona_maricopa/arizona_maricopa_e_2000-2019_limited.pdf, translator(smcl2pdf) replace


*Export variable missing rates

cd "/home/share/arizona_maricopa/"

use "/home/share/arizona_maricopa/arizona_maricopa_e_2000-2019_limited.dta", clear

local a = substr("`x'",-19,19)

putexcel set "arizona_maricopa_missing", sheet(2000-2019_limited, replace) modify

local row = 2

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


**Export duplicates for all files

use "/home/share/arizona_maricopa/arizona_maricopa_e_2000-2019_limited.dta", clear

duplicates tag, gen(dup)

keep if dup > 0

sort dup CaseNumber

local a = substr("`x'",-19,19)

di "`a'"

count if dup > 0

if r(N) > 0{

export excel using "/home/share/arizona_maricopa/arizona_maricopa_e_d.xlsx" , sheet("2000-2019_limited") sheetreplace firstrow(variables)

}

count

if r(N) == 0{

drop *
set obs 1
gen duplicates = "No Duplicates"
export excel using "/home/share/arizona_maricopa/arizona_maricopa_e_d.xlsx" , sheet("2000-2019_limited")  sheetreplace firstrow(variables)

}

