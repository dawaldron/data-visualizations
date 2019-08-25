setwd('C:/Users/dwald/OneDrive/ZenBook backup/Blog/Posts/Senators by State/Electoral College/')
library(data.table)
library(magrittr)
library(Hmisc)
library(foreign)

# postal codes
dt_stateabb <- data.table(stateabb = state.abb,
                          statenm = state.name)

# CVAP data by state, with race/ethnicity
dt_race <- fread('CVAP_2012-2016_ACS_csv_files/State.csv') %>%
  .[,
    .(`Total cvap` = sum((LNNUMBER == 1) * CVAP_EST),
      `Race/ethnicity: White, non-Hispanic` = sum((LNNUMBER == 7) * CVAP_EST),
      `Race/ethnicity: Black, non-Hispanic` = sum((LNNUMBER == 5) * CVAP_EST),
      `Race/ethnicity: Hispanic or Latino` = sum((LNNUMBER == 13) * CVAP_EST),
      `Race/ethnicity: Other` = sum((LNNUMBER %in% c(3,4,6,8,9,10,11,12)) * CVAP_EST)),
    .(statefip = substr(GEOID,8,9),
      statenm = GEONAME)]

# census tract shapefile data for density calculations
dt_dens <- read.dbf('Tract_2010Census_DP1/Tract_2010Census_DP1.dbf', as.is = TRUE) %>%
  data.table()

dt_dens[, density := 'Density: Rural']
dt_dens[DP0130001 / (ALAND10 / 2589988) >= 102, density := 'Density: Suburban-sparse']
dt_dens[DP0130001 / (ALAND10 / 2589988) >= 800, density := 'Density: Suburban-dense']
dt_dens[DP0130001 / (ALAND10 / 2589988) >= 2213, density := 'Density: Urban']

# match to CVAP by tract
dt_dens <- fread('CVAP_2012-2016_ACS_csv_files/Tract.csv') %>%
  .[lnnumber == 1,
    .(pop = sum(CVAP_EST)),
    .(GEOID10 = substr(geoid,8,18))] %>%
  .[dt_dens, on = 'GEOID10'] %>%
  .[,
    .(pop = sum(pop, na.rm = TRUE)),
    .(statefip = substr(GEOID10,1,2),
      density)] %>%
  dcast(statefip ~ density, value.var = 'pop', fill = 0)


# Data from Gelman and Kremp article (https://slate.com/news-and-politics/2016/11/here-are-the-chances-your-vote-matters.html)
dt_ec <- fread('ec_gelman.txt') %>%
  .[, .(statenm = State, pVote)] %>%
  dt_race[., on = 'statenm'] %>%
  dt_dens[., on = 'statefip'] %>%
  dt_stateabb[., on = 'statenm'] %>%
  .[, pVoteMed := wtd.quantile(pVote, `Total cvap`, .5)] %>%
  melt(id.vars = c('statefip','stateabb','statenm','pVote','pVoteMed'),
       measure.vars = c('Total cvap',
                        'Race/ethnicity: White, non-Hispanic',
                        'Race/ethnicity: Black, non-Hispanic',
                        'Race/ethnicity: Hispanic or Latino',
                        'Race/ethnicity: Other',
                        'Density: Rural',
                        'Density: Suburban-sparse',
                        'Density: Suburban-dense',
                        'Density: Urban'),
       variable.name = 'group',
       variable.factor = FALSE,
       value.name = 'pop') %>%
  .[, category := substr(group, 1, regexpr(':', group, fixed = TRUE) - 1)] %>%
  .[, group := substr(group, regexpr(':', group, fixed = TRUE) + 2, nchar(group))] %>%
  .[, pVoteRel := pVote / pVoteMed]


# define "high-power" voter
dt_ec[, pVoteThres := '']
dt_ec[log10(pVoteRel) >= (2), pVoteThres := 'hpvoter']

# 2016 two-party percentages
dt_vote16 <- fread('vote16.txt') %>%
  .[, .(statenm, demshare = dem / (dem + rep))]
dt_ec <- dt_vote16[dt_ec, on = 'statenm']

fwrite(dt_ec, 'electoral_college.csv')


# median vote power by group
dt_group <- dt_ec %>%
  .[,
    .(p10 = wtd.quantile(pVote, pop, .10) / median(pVoteMed),
      p25 = wtd.quantile(pVote, pop, .25) / median(pVoteMed),
      p50 = wtd.quantile(pVote, pop, .50) / median(pVoteMed),
      p75 = wtd.quantile(pVote, pop, .75) / median(pVoteMed),
      p90 = wtd.quantile(pVote, pop, .90) / median(pVoteMed)),
    .(group)]

fwrite(dt_group, 'group.csv')


# percent high-power voters by group
dt_group2 <- dt_ec %>%
  .[,
    .(pop = sum(pop)),
    .(category, group, pVoteThres)] %>%
  .[, poptotal := sum(pop), group] %>%
  .[, pcthp := pop / sum(pop), group] %>%
  .[pVoteThres %in% c('hpvoter')] %>%
  .[, poppct := poptotal / sum(poptotal), category] %>%
  .[, poppctcm := cumsum(poppct) - poppct, category] %>%
  .[group == 'Total cvap', `:=`(category = group, group = '')]

fwrite(dt_group2, 'group2.csv')
