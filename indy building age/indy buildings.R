library(foreign)
library(data.table)

# parcel data from city
parcels <- data.table(read.dbf('Parcels/Parcels.dbf'))
parcels <- parcels[, .(PARCEL_TAG, PARCEL_I)]

# building footprints from city
buildings <- data.table(read.dbf('Buildings/Buildings.dbf'))
buildings <- buildings[, .(PARCEL_TAG)]

# counter book data from Renew Indy
counter <- fread('counter_book_2017/tmp/counter_book_2017.csv')
counter <- counter[, .(parcel_number, street_address_1, parcel_city, parcel_zip, year_built)]
counter[nchar(year_built) != 4 | year_built < '1500' | year_built > '2017', year_built := '']

# match files
counter <- merge(counter, parcels, by.x = 'parcel_number', by.y = 'PARCEL_I')
counter <- counter[!duplicated(PARCEL_TAG)]
buildings2 <- merge(buildings, counter[, .(PARCEL_TAG, year_built)], by = 'PARCEL_TAG', all.x = T)
buildings2[, year_built := as.numeric(year_built)]
buildings2[is.na(year_built), year_built := 0]
buildings2 <- buildings2[order(OBJECTID)]

# write new attribute table for building footprints
write.dbf(buildings2, 'Buildings/Buildings.dbf')

# summarize by township and decade
buildings2[year_built != 0 & year_built < 1900, year_built := 1890]
townships <- buildings2[year_built != 0 & !is.na(TOWNSHIP),
                        .(count = length(PARCEL_TAG)),
                        .(TOWNSHIP, decade_built = as.character(paste0(floor(year_built/10)*10,'s')))]

# variable to set position on 3x3 grid
townships[TOWNSHIP=='PIKE', rank := 1]
townships[TOWNSHIP=='WASHINGTON', rank := 2]
townships[TOWNSHIP=='LAWRENCE', rank := 3]
townships[TOWNSHIP=='WAYNE', rank := 4]
townships[TOWNSHIP=='CENTER', rank := 5]
townships[TOWNSHIP=='WARREN', rank := 6]
townships[TOWNSHIP=='DECATUR', rank := 7]
townships[TOWNSHIP=='PERRY', rank := 8]
townships[TOWNSHIP=='FRANKLIN', rank := 9]

townships <- townships[order(rank, decade_built)]
townships[decade_built == "1890s", decade_built := "< 1900"]
write.csv(townships, 'townships.csv', row.names = F)

city <- townships[, .(count = sum(count)), .(decade_built)]
write.csv(city, 'city.csv', row.names = F)