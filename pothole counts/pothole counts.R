setwd('C:/Users/dwald/Documents/Blog/Posts/Indianapolis Potholes 2')
library(data.table)

# function for moving average
ma <- function(x,n=5){filter(x,rep(1/n,n), sides=2)}

# get MAC data
mac.data <- fread('http://opendata.arcgis.com/agol/arcgis/d2fda038f9c1448a985fb55647593499/3.csv?')
potholes <- mac.data[KEYWORD__C == "Chuckhole" & SUBCATEGORY__C == 'Street (Chuckhole)',
                     .(CASENUMBER,
                       STATUS,
                       CREATEDDATE = as.Date(CREATEDDATE, format = "%Y-%m-%dT%H:%M:%S.000Z"),
                       CLOSEDDATE = as.Date(CLOSEDDATE, format = "%Y-%m-%dT%H:%M:%S.000Z"))]

# create date sequence
daylist <- seq(min(potholes[!is.na(CREATEDDATE), CREATEDDATE]),
               max(potholes[!is.na(CREATEDDATE), CREATEDDATE]), 'days')

# function to calculate number of open potholes on each day
countOpen <- function(day.i, data) {
  data[, .(date = day.i,
           newpotholes = sum(CREATEDDATE == day.i),
           closedpotholes = sum(!is.na(CLOSEDDATE) & CLOSEDDATE == day.i),
           potholes = sum(CREATEDDATE <= day.i & (is.na(CLOSEDDATE) | CLOSEDDATE >= day.i)))]
}

# calculate
daily.potholes <- rbindlist(lapply(daylist, countOpen, data = potholes))

# climate data requested from https://www.ncdc.noaa.gov/cdo-web/search
# last updated 2018-04-05, current through 2018-03-31
weather <- fread('1303915.csv')
weather <- weather[STATION == 'USW00093819',
                   .(date = as.Date(DATE),
                     TMIN, 
                     TAVG, 
                     TMAX, 
                     PRCP,
                     TMINavg = ma(TMIN, 14), 
                     TAVGavg = ma(TAVG, 14), 
                     TMAXavg = ma(TMAX, 14), 
                     PRCPavg = ma(PRCP, 14))]


# match potholes to weather data
daily.potholes <- weather[daily.potholes, on = 'date']

# weekly open/close counts
weekly.potholes <- daily.potholes[, lapply(.SD, sum),
                                  .(week = floor_date(date - 1, "weeks") + 1),
                                  .SDcols = c('newpotholes', 'closedpotholes')]

# write files
write.csv(daily.potholes, 'open_potholes.csv', row.names = F)
write.csv(weekly.potholes, 'weekly_potholes.csv', row.names = F)

# this prints the number of new street chuckholes for each month
new.monthly <- daily.potholes[, .(newpotholes = sum(newpotholes)),
                              .(year = year(date), month = month(date))][
                                order(year, month)]

write.csv(new.monthly, 'new_potholes_monthly.csv', row.names = F)
