/* Adam Finch Data Assignment 3 -- do file

The first step was to set the current directory to the folder where all of the
data was saved, and open a log to track all of my STATA data. */


cd "C:\Users\afinch99\OneDrive - Brigham Young University\ECON 388\Data Assignment 3"
log using log_DA3, replace 

/* I saved three data sets in that folder as CSV files. The first was the NYT 
COVID data that tracked COVID deaths and cases by county. The second was the 
census data showing population by county. Finally, the third was the Housing 
Price Data found on the fhfa website. I used excel to ensure that the FIPS 
variable was formatted the same for all of the data sets in order to make the 
merging process go smoothly. I have posted the final versions of all of the 
excel spreadsheets in my github folder that is linked to my final submission 
for this assignment */

import delimited using "County_Level_Population_2020", clear 
drop v10
drop sumlev region division state county
save "County_Level_Population_with_fips", replace 
import delimited using "NYTcoviddeaths", clear 

/* Because the data set contained daily information regarding cases and deaths,
I needed to collapse the data so it was aggregated for the year 2020. */

collapse (sum) deaths cases, by (geoid)
rename geoid fips 
save "NYT_Deaths_bycountyfips", replace
use "NYT_Deaths_bycountyfips", clear 

/* Next I merged the County Population data set to the NYT Covid deaths data 
set using the common variable fips, which is a unique idenfication code for 
each US County */

merge 1:1 fips using "County_Level_Population_with_fips"
keep if _merge==3
drop _merge
save "Deaths_pop_merged", replace 

/* Next I imported the third data set into STATA in order to prepare to
merge it with the other two */

import delimited "2020_2021_HPI_with_FIPS", clear 
rename fipscode fips 
rename hpi hpiyearone
rename v5 hpiyeartwo
drop v6 v7
gen hpichange = (hpiyeartwo - hpiyearone)
gen hpipercentchange = (hpichange / hpiyearone) * 100
save "HPI_with_fips", replace 
use "Deaths_pop_merged", clear 
merge 1:m fips using "HPI_with_fips"
keep if _merge == 3 
drop _merge 
rename popestimate2020 population
gen mortalityrate = (deaths/population)*100
save "FinalDataSetMerged", replace 

/* Now that the data set had been merged, I needed to generate a new variable 
for the mortality rate */

reg hpichange mortalityrate
twoway scatter hpichange mortalityrate || lfit hpichange mortalityrate 
sum mortalityrate hpichange deaths 
encode(state), gen(statenum)
reg hpichange mortalityrate i.statenum 
sum hpipercentchange
gen logmortalityrate = ln(mortalityrate)
reg hpipercentchange logmortalityrate
gen loghpichange = ln(hpichange)
reg loghpichange logmortalityrate




