***Philadelphia file cleaning


cd "/home/gq25/phila-lt-data/"

**Import attorney names

import delimited "/home/gq25/phila-lt-data/attorney-names.txt", varnames(1) clear 
tempfile attorney_names
save `attorney_names'

***Export missingness to excel

putexcel set "phila_review", sheet(attorney names missingness) replace

local row=2
foreach v of varlist id attorney party party_type{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}

*Export freq to excel

putexcel set "phila_review", sheet(attorney names freq) modify

putexcel A1 = "Variable" B1="Value" C1="Freq" D1="Percent" 

encode party_type, gen(party_type_num)
tab party_type_num, matcell(freq) matrow(names)

local row = 2
local rows = rowsof(names)

forvalues i = 1/`rows' {
 
        local val = names[`i',1]
        local val_lab : label (party_type_num) `val'
	
	local freq_val = freq[`i',1]

putexcel A`row' = "party_type"
putexcel B`row' = "`val_lab'"
putexcel C`row' = matrix(`freq_val')
putexcel D`row' = matrix(`freq_val'/r(N))
local ++row
}


****Import docket-entries
*all variables have too many entries to tabulate except entrytype

import delimited "/home/gq25/phila-lt-data/docket-entries.txt", varnames(1) clear 
tempfile docket_entries
save `docket_entries'

*Export missing to excel

putexcel set "phila_review", sheet(docket entries missingness) modify

local row=2
foreach v of varlist id indexno effdate entrytype docketentry filer docid{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}

*Export freq to excel

putexcel set "phila_review", sheet(docket entries freq) modify

putexcel A1 = "Variable" B1="Value" C1="Freq" D1="Percent" 

local row = 2

foreach v of var indexno effdate entrytype docketentry filer docid {

capture by `v', sort: gen `v'_vals= _n == 1 
count if `v'_vals

if r(N)<500{

capture encode `v', gen(`v'_num)
tab `v'_num, matcell(freq) matrow(names)

local rows = rowsof(names)

forvalues i = 1/`rows' {
 
        local val = names[`i',1]
        local val_lab : label (`v'_num) `val'
	
	local freq_val = freq[`i',1]

putexcel A`row' = "`v'"
putexcel B`row' = "`val_lab'"
putexcel C`row' = matrix(`freq_val')
putexcel D`row' = matrix(`freq_val'/r(N))
local ++row
}
}
}

drop *_vals

**** import party-names-addresses
* 0% missing id
import delimited "/home/gq25/phila-lt-data/party-names-addresses.txt", varnames(1) clear 
tempfile party_name_addresses
save `party_name_addresses'

*Export to excel

putexcel set "phila_review", sheet(party name addresses) modify

local row=2
foreach v of varlist id role name alias_one alias_two address_one address_two address_three{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}

*export freqs

putexcel set "phila_review", sheet(party name addresses freq) modify

putexcel A1 = "Variable" B1="Value" C1="Freq" D1="Percent" 

local row = 2
foreach v of var id role name alias_one alias_two address_one address_two address_three{ 

capture by `v', sort: gen `v'_vals= _n == 1 
count if `v'_vals

if r(N)<500{

capture encode `v', gen(`v'_num)
tab `v'_num, matcell(freq) matrow(names)


local rows = rowsof(names)

forvalues i = 1/`rows' {
 
        local val = names[`i',1]
        local val_lab : label (`v'_num) `val'
	
	local freq_val = freq[`i',1]

putexcel A`row' = "`v'"
putexcel B`row' = "`val_lab'"
putexcel C`row' = matrix(`freq_val')
putexcel D`row' = matrix(`freq_val'/r(N))
local ++row
}
}
}

drop *_vals

**** import property addresses
* 0% missing id

import delimited "/home/gq25/phila-lt-data/property-addresses.txt", varnames(1) clear 
tempfile property_addresses
save `property_addresses'

*Export to excel

putexcel set "phila_review", sheet(property addresses) modify

local row=2
foreach v of varlist indexno section id revid address{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}

*import tenant addresses cleaned

import delimited "/home/gq25/phila-lt-data/tenant-addresses-cleaned.txt", varnames(1) clear 
tempfile tenant_address_cleaned
save `tenant_address_cleaned'

*Export to excel

putexcel set "phila_review", sheet(tenant addresses cleaned) modify

local row=2
foreach v of varlist id premises lat lon prenum number street city state zip{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}

*import tenant addresses opa
import delimited "/home/gq25/phila-lt-data/tenant-addresses-opa.txt", varnames(1) clear 
tempfile tenant_addresses_opa
save `tenant_addresses_opa'

*Export to excel

putexcel set "phila_review", sheet(tenant addresses opa) modify

local row=2
foreach v of varlist id d_filing parcel_number latitude longitude{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}


***Clean summary-table

*import value labels

import excel "/home/gq25/phila-lt-data/column-definitions.xlsx", sheet("Column Definitions") firstrow clear

keep if Table == "summary-table"

replace Explanation = subinstr(Explanation, `"""', "",.) 

forvalues i = 1/`=_N' {
    local varname = Column[`i']       //variable name
    local `varname'l = Explanation[`i'] //variable label
}

import delimited "/home/gq25/phila-lt-data/summary-table.txt", clear 


*label variables

foreach v of varlist * {
    capture label variable `v' "``v'l'"
}

*check missing id cases

egen miss = rownonmiss(year-promisezone), strok
drop miss

*drop cases with missing id

drop if id=="" | id=="Unknown"


*egen idmiss = rownonmiss(url-promisezone), strok

*All cases with missing id have null/misisng data for all fields
*tab idmiss if missing(id)

*export percent missing

cd "/home/gq25/phila-lt-data/"

putexcel set "Philadelphia_Percent_Missing.xlsx", replace

local row=2

foreach v of varlist id url year month d_filing a b c a_only b_only c_only commercial amt_sought plaintiff plaintiff_represented plaintiff_atty_name plaintiff_address plaintiff_alias service defendant defendant_address defendant_represented defendant_atty_name defendant_alias attorneys no_of_continuances dates_heard first_date_heard second_date_heard third_date_heard last_date_heard no_of_hearing_dates default_on_hearing_number default_on_continuance_number defendant_default_date withdrawn jba jba_date jba_substance jba_substance_additional judge court_order complaint_fee award_total_amount_due award_in_the_amount_of award_costs award_other_fees award_attorney_fees award_physical_damages minutes judgment_for_defendant judgment_for_plaintiff substance_of_court_order won_lost_not_known_unclear writ_of_possession alias_writ alias_writ_served alias_writ_served_date petition_to_open appeal premises breach total_rent utilities attorney_fees physical_damage other_fees court_costs ongoing_rent gas electric water_sewer late_fees hearing_date_and_time hearing_room housing_inspection jba_breach possession_sought money_judgment_sought lease_start lease_type lease_term non_residential fitness unaware noncompliance refuses_to_surrender date_of_notice_to_vacate vacate_by_date waiver_of_notice_to_vacate lead_certification_provided lead_property_old lead_lease_old lead_subsidized lead_child_present lead_institution rental_license_expiration_date rental_license_effective_date zip months low_rent publichousing first_hearing_dow latitude longitude clean_address firstname lastname gender census satisfied promisezone{

tabmiss `v' 

putexcel A1 = "Variable"
putexcel A`row'="`v'"
putexcel B1 = "Percent Missing"
putexcel B`row'=`r(mean)'
local ++row
}

*** Drop pii variables

drop id /*plaintiff plaintiff_atty_name*/ plaintiff_address /*plaintiff_alias*/ defendant ///
defendant_atty_name defendant_address defendant_alias attorneys premises /*zip*/ latitude longitude ///
clean_address firstname lastname

*export variable frequencies

putexcel set "Phiadelphia_Frequencies.xlsx", replace

putexcel A1 = "Variable" B1="Value" C1="Freq" D1="Percent" 

local row = 2

foreach v of var url year month d_filing a b c a_only b_only c_only ///
commercial amt_sought plaintiff_represented service defendant_represented ///
no_of_continuances dates_heard first_date_heard second_date_heard third_date_heard ///
last_date_heard no_of_hearing_dates default_on_hearing_number default_on_continuance_number ///
defendant_default_date withdrawn jba jba_date jba_substance jba_substance_additional judge ///
court_order complaint_fee award_total_amount_due award_in_the_amount_of award_costs award_other_fees ///
award_attorney_fees award_physical_damages minutes judgment_for_defendant judgment_for_plaintiff ///
substance_of_court_order won_lost_not_known_unclear writ_of_possession alias_writ alias_writ_served ///
alias_writ_served_date petition_to_open appeal breach total_rent utilities attorney_fees ///
 physical_damage other_fees court_costs ongoing_rent gas electric water_sewer late_fees ///
 hearing_date_and_time hearing_room housing_inspection jba_breach possession_sought ///
 money_judgment_sought lease_start lease_type lease_term non_residential fitness unaware ///
 noncompliance refuses_to_surrender date_of_notice_to_vacate vacate_by_date ///
 waiver_of_notice_to_vacate lead_certification_provided lead_property_old ///
 lead_lease_old lead_subsidized lead_child_present lead_institution rental_license_expiration_date ///
 rental_license_effective_date zip months low_rent publichousing first_hearing_dow ///
 gender census satisfied promisezone{

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



