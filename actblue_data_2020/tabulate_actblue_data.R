setwd('C:/Users/dwald/OneDrive/ZenBook backup/Blog/Data/FEC/')
library(data.table)
library(magrittr)
library(readxl)

dt_ab <- fread('actblue_2020.csv')

#------------------------------#
##### Summary by candidate #####
#------------------------------#

dt_ab[, weight := 1 / .N, .(fname, lname, zip)]
dt_sumAll <- dt_ab %>%
  .[,
    .(freq = sum(weight)),
    .(candnm)] %>%
  .[, pct := freq / sum(freq)]

fwrite(dt_sumAll, 'actblue_sum.csv')


#-----------------------------------------#
##### Read title/O*NET code crosswalk #####
#-----------------------------------------#

dt_titleXW <- fread('titleocc_xw_final.csv') %>%
  .[, .(source, onetcode, onettitle, occupation)]

dt_indocc <- dt_ab[dt_titleXW, on = 'occupation', nomatch = 0]
dt_indocc[, weight := 1 / .N, .(fname, lname, zip)]


# load ACS educational attainment data from BLS
dt_epEduc <- read_excel('occupation.XLSX',
                        sheet = 'Table 5.3',
                        skip = 1) %>%
  data.table() %>%
  .[,
    .(soccode = X__1,
      baPct = (`Bachelor's degree` + `Master's degree` + `Doctoral or professional degree`) / 100)]

# load BLS 2026 projections
dt_epProj <- read_excel('occupation.XLSX',
                        sheet = 'Table 1.7',
                        skip = 2) %>%
  data.table() %>%
  .[X__3 == 'Line item',
    .(soctitle = X__1,
      soccode = X__2,
      emp16 = `2016`,
      emp26 = `2026`,
      educreq = X__7,
      medwage = as.numeric(X__6))] %>%
  dt_epEduc[., on = 'soccode']


#-------------------------------------------#
##### Summary by major occupation group #####
#-------------------------------------------#

dt_occgrpnm <- fread('occgrpnm.csv')[, 1:2]

dt_sumOccGrp <- dt_epProj %>%
  .[,
    .(baPct = sum(baPct * emp16) / sum(emp16)),
    .(occgrpcd = paste0(substr(soccode,1,2), '-0000'))]

dt_sumOccGrp <- read_excel('occupation.XLSX',
                           sheet = 'Table 1.7',
                           skip = 2) %>%
  data.table() %>%
  .[X__3 == 'Summary',
    .(occgrpnm = X__1,
      occgrpcd = X__2,
      emp16 = `2016`,
      emp26 = `2026`,
      medwage = as.numeric(X__6))] %>%
  .[dt_sumOccGrp, on = 'occgrpcd'] %>%
  .[dt_occgrpnm, on = 'occgrpcd']


dt_sumOccGrp <- dt_indocc %>%
  .[,
    .(freq = sum(weight)),
    .(occgrpcd = paste0(substr(onetcode,1,2), '-0000'),
      candnm)] %>%
  .[dt_sumOccGrp, on = 'occgrpcd'] %>%
  .[, occtotal := sum(freq), occgrpcd] %>%
  .[, occpct := freq / occtotal, occgrpcd] %>%
  .[, candtotal := sum(freq), candnm] %>%
  .[, candpct := candtotal / sum(freq)] %>%
  .[, occqt := occpct / candpct, candnm]

fwrite(dt_sumOccGrp, 'actblue_occgrp.csv')


#----------------------------------------#
##### Summary by detailed occupation #####
#----------------------------------------#

dt_sumOccDet <- dt_indocc %>%
  .[,
    .(freq = sum(weight)),
    .(soccode = substr(onetcode, 1, 7), candnm)] %>%
  .[dt_epProj, on = 'soccode', nomatch = 0] %>%
  dt_taaocc[., on = 'soccode'] %>%
  .[, occtotal := sum(freq), soccode] %>%
  .[, occpct := freq / occtotal, soccode] %>%
  .[dt_sumAll[, .(candnm, candtotal = freq, candpct = pct)], on = 'candnm'] %>%
  .[, occqt := occpct / candpct, candnm]

dt_sumOccDet[, ln.occpct := log(occpct)]
dt_sumOccDet[, proj := emp26 / emp16 - 1]

fwrite(dt_sumOccDet, 'actblue_occdet.csv')

calcEducTrnd <- function(x) {
  lm(ln.occpct ~ baPct,
     dt_sumOccDet[candnm == x]) %>%
    .$coefficients %>%
    data.table(candnm = x,
               occpct = exp(.[1] + (1:50 / 50) * .[2]),
               baPct = 1:50 / 50) %>%
    .[,2:4]
}

dt_educTrnd <- lapply(dt_sumOccDet[!duplicated(candnm), candnm],
                      calcEducTrnd) %>%
  rbindlist()

fwrite(dt_educTrnd, 'actblue_eductrend.csv')

calcWageTrnd <- function(x) {
  lm(ln.occpct ~ medwage,
     dt_sumOccDet[candnm == x & !is.na(medwage)]) %>%
    .$coefficients %>%
    data.table(candnm = x,
               occpct = exp(.[1] + seq(20000,200000,5000) * .[2]),
               medwage = seq(20000,200000,5000)) %>%
    .[,2:4]
}

dt_wageTrnd <- lapply(dt_sumOccDet[!duplicated(candnm), candnm],
                      calcWageTrnd) %>%
  rbindlist()

fwrite(dt_wageTrnd, 'actblue_wagetrend.csv')


#-----------------------------------------#
##### Summary by selected occupations #####
#-----------------------------------------#

dt_sumOccSelc <- fread('soc_aggregations.csv') %>%
  .[socagg == '', socagg := soctitle]

dt_sumOccSel <- fread('selected_occs.csv') %>%
  .[dt_sumOccSelc, on = 'socagg'] %>%
  .[is.na(selected), selected := 0] %>%
  dt_epProj[., on = 'soccode'] %>%
  .[,
    .(emp16 = sum(emp16),
      emp26 = sum(emp26),
      proj26 = sum(emp26) / sum(emp16) - 1,
      baPct = sum(baPct * emp16) / sum(emp16)),
    .(socagg,
      selected)]

dt_sumOccSel2 <- dt_indocc %>%
  .[,
    .(freq = sum(weight)),
    .(soccode = substr(onetcode,1,7),
      candnm)] %>%
  .[dt_sumOccSelc, on = 'soccode'] %>%
  .[,
    .(freq = sum(freq)),
    .(socagg,
      candnm)] %>%
  dt_sumOccSel[., on = 'socagg'] %>%
  .[, occtotal := sum(freq), socagg] %>%
  .[, occpct := freq / occtotal, socagg] %>%
  .[dt_sumAll[, .(candnm, candtotal = freq, candpct = pct)], on = 'candnm'] %>%
  .[, occqt := occpct / candpct, candnm] %>%
  .[socagg != '']

fwrite(dt_sumOccSel2, 'actblue_occsel.csv')