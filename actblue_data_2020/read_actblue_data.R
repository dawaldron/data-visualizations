setwd('C:/Users/dwald/OneDrive/ZenBook backup/Blog/Data/FEC/')
library(data.table)
library(magrittr)
library(readxl)
library(LaF)

# downloadFEC <- function(x) {
#   download.file(paste0('https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/electronic/', x, '.zip'),
#                 paste0('fecfile/', x, '.zip'))
# }
# c_dates <- seq.Date(as.Date('2018-12-01'), as.Date('2019-08-05'), by = 'day') %>%
#   format('%Y%m%d')
# lapply(c_dates, downloadFEC)



#-----------------------------------------#
##### Load the ActBlue donations file #####
#-----------------------------------------#

laf <- laf_open_csv("fecfile/20190801/1344765.fec",
                    column_types = c('character'),
                    sep = '▣')

dt_ab <- data.table(chunk = 0,
                    fname = '',
                     lname = '',
                     zip = '',
                     employer = '',
                     occupation = '',
                     memo = '')[0]

for(i in 1:floor((nrow(laf)/1e5))){
  print(i)
  dt_cur <- next_block(laf, nrows=1e5)
    
  dt_cur <- do.call(rbind, strsplit(dt_cur[,1],'\034',fixed=T)) %>%
    data.table() %>%
    .[V6 == 'IND',
      .(chunk = i,
        lname = V8,
        fname = V9,
        zip = substr(V17,1,5),
        employer = V24,
        occupation = V25,
        memo = V44)] %>%
    .[!duplicated(.[, .(lname, fname, zip, memo)])]
    
  dt_ab <- rbind(dt_ab, dt_cur)
}

dt_ab <- dt_ab[!duplicated(cbind(lname, fname, zip, memo))]


#---------------------------------#
##### Attach candidate names ######
#---------------------------------#


# file from https://github.com/BuzzFeedNews/2019-08-actblue-donations/blob/master/data/candidates.csv
dt_cand <- fread('candidates.txt') %>%
  .[,
    .(candnm = `Candidate Name`,
      commnm = `Committee Name`,
      candid = `Candidate ID`,
      commid = `Committee ID`)]

dt_ab <- dt_ab[grepl(' (C', memo, fixed = TRUE)] %>%
  .[!duplicated(.[, .(lname, fname, zip, memo)])]
dt_ab[, commid := substr(memo, nchar(memo) - 9, nchar(memo) - 1)]
dt_ab <- dt_cand[dt_ab, on = 'commid', nomatch = 0]

fwrite(dt_ab, 'actblue_2020.csv')