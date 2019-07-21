# IPUMS-CPS VEP turnout weight correction

The R script reads CPS voter supplement microdata from IPUMS-CPS and implements the corrected weights described at http://www.electproject.org/home/voter-turnout/cps-methodology. This allows for generation of turnout estimates from CPS microdata that are consistent with the VEP turnout rates at http://www.electproject.org. 

Currently runs for years 1980 to 2018. Required variables are:

* YEAR
* WTFINL
* STATFIP
* AGE
* VOTED
* EDUC
* RACE
* HISPAN

Note: VESUPPWT is identical to WTFINL in IPUMS-CPS data