setwd('C:\\Users\\dwald\\OneDrive\\ZenBook backup\\Blog\\Posts\\Baby Names')
library(data.table)

# total births by year
# (copied from html table at https://www.ssa.gov/oact/babynames/numberUSbirths.html)
dt_births <- fread('births.csv')

# name frequencies by year (from https://www.ssa.gov/oact/babynames/names.zip)
dt_names <- lapply(1880:2017, function(y) {
    dt <- fread(paste0('names/yob', y, '.txt'))
    dt <- dt[, .(year = y, name = V1, sex = tolower(V2), freq = V3)]
  })
dt_names <- rbindlist(dt_names)
dt_names <- dcast(dt_names, year + name ~ sex, value.var = 'freq')
dt_names[is.na(dt_names)] <- 0
dt_names[, tot := m + f]

# match total births to names for overall popularity
dt_names <- dt_births[dt_names, on = 'year']
dt_names[, pctOfBirths := tot / births_tot]

# calculate ambiguity of names
dt_names[, pctF := f / (tot)]
dt_names[, peak := max(pctOfBirths), name]
dt_names <- dt_names[, evenPct := min(ifelse(pctOfBirths > .0005, abs(pctF - .5), .5)), name]

# pick names that were both popular and ambiguous simultaneously
c_unisex <- dt_names[year %in% 1930:2017
                     & evenPct < .15
                     & pctOfBirths > .0005
                     & peak > .001,
                     name]
c_unisex <- c_unisex[!duplicated(c_unisex)]

# write
dt_unisex <- dt_names[name %in% c_unisex]
fwrite(dt_unisex, 'C:\\Users\\dwald\\OneDrive\\ZenBook backup\\Blog\\Admin\\newsite\\unisex-baby-names\\unisex names.csv')
