# Replication code for Hur and Achen correction

# Using IPUMS-CPS and VEP rates collected from http://www.electproject.org
# on 2019-07-17

# Hur and Achen correction:
# For repondents reporting not voting (VOTED == 1), compute correction = (1-VEP)/(1-CPS state level turnout rate)
# For repondents reporting voting (VOTED == 2), compute correction = VEP/CPS state level turnout rate excluding missing data, using WTFINL, the CPS individual rate
# multiply correction, multiplying by WTFINL to produce new weight

library(data.table)
library(magrittr)

# VEP highest office turnout from electproject.org
dt_vep <- fread('electproj_turnout.txt')

# FIPS-ICPSR crosswalk
dt_fips <- fread('state_icpsr_fips.txt')

# IPUMS-CPS extract link to recreate:
# https://cps.ipums.org/cps-action/extract_requests/5215536/revise
dt_cps <- fread('cps_00053.csv') %>%
  .[AGE >= 18 & VOTED != 99]

# calculate turnout with VOTED (PES1 in Census file)
# and match to electproject VEP turnout
dt_turnout <- dt_cps %>%
  .[,
    .(cps_turnout = sum(WTFINL * (VOTED == 2)) / sum(WTFINL * (VOTED %in% c(1,2)))),
    .(YEAR, STATEFIP)] %>%
  dt_fips[., on = 'STATEFIP', nomatch = 0] %>%
  dt_vep[., on = c('YEAR','STATEICP','STATENM'), nomatch = 0]

# apply correction factors to CPS file
dt_corrections <- dt_turnout %>%
  .[,
    .(YEAR,
      STATEFIP,
      STATENM,
      correction1 = (1 - VEPHO) / (1 - cps_turnout),
      correction2 = VEPHO / cps_turnout)]

dt_cps <- dt_corrections[dt_cps, on = c('YEAR','STATEFIP'), nomatch = 0]

dt_cps[, WTFINL2 := 0]
dt_cps[VOTED == 1, WTFINL2 := correction1 * WTFINL]
dt_cps[VOTED == 2, WTFINL2 := correction2 * WTFINL]

# recode education
dt_cps[, educattain := 'Less than HS']
dt_cps[EDUC == 73, educattain := 'HS diploma']
dt_cps[EDUC %in% c(80,81,90,91,92,100), educattain := 'Some college, no BA']
dt_cps[EDUC %in% c(110,111,121,122,123,124,125), educattain := 'Bachelor\'s degree']

# recode age
dt_cps[, agegrp := paste0(floor((AGE - 18) / 4) * 4 + 18, '-',
                          floor((AGE - 18) / 4) * 4 + 21)]

# recode race/ethnicity
dt_cps[, race := 'Other']
dt_cps[RACE == 100 & HISPAN == 0, race := 'White, non-Hispanic']
dt_cps[RACE == 200 & HISPAN == 0, race := 'Black, non-Hispanic']
dt_cps[!HISPAN %in% c(0,901,902), race := 'Hispanic']

# turnout by year, state (check that numbers match electproject.org)
dt_state <- dt_cps %>%
  .[,
    .(turnout = round(100 * sum(WTFINL2 * (VOTED == 2)) / sum(WTFINL2 * (VOTED %in% c(1,2))), 1)),
    .(YEAR, STATEFIP, STATENM)] %>%
  dcast(YEAR ~ STATENM, value.var = 'turnout')

fwrite(dt_state, 'state.csv')

# turnout by year, educ
dt_educ <- dt_cps %>%
  .[,
    .(turnout = round(100 * sum(WTFINL2 * (VOTED == 2)) / sum(WTFINL2 * (VOTED %in% c(1,2))), 1)),
    .(YEAR, educattain)] %>%
  dcast(YEAR ~ educattain, value.var = 'turnout')

fwrite(dt_educ, 'educ.csv')

# turnout by year, race
dt_race <- dt_cps %>%
  .[,
    .(turnout = round(100 * sum(WTFINL2 * (VOTED == 2)) / sum(WTFINL2 * (VOTED %in% c(1,2))), 1)),
    .(YEAR, race)] %>%
  dcast(YEAR ~ race, value.var = 'turnout')

fwrite(dt_race, 'race.csv')

# turnout by year, age
dt_age <- dt_cps %>%
  .[,
    .(turnout = round(100 * sum(WTFINL2 * (VOTED == 2)) / sum(WTFINL2 * (VOTED %in% c(1,2))), 1)),
    .(YEAR, agegrp)] %>%
  dcast(YEAR ~ agegrp, value.var = 'turnout')

fwrite(dt_age, 'age.csv')


