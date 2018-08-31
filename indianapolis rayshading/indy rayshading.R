library(lidR)
library(rayshader)
library(magrittr)
library(suncalc)
library(raster)
library(ggmap)
library(lubridate)
library(data.table)

# read laz file downwloaded from opentopography
las_indy <- readLAS('points.laz')

# copied from the internet. can't explain it, but it works to make a DSM
th = c(0,2,5,10,15)
edge = c(0, 1.5)
chm = grid_tincanopy(las_indy, thresholds = th, max_edge = edge)

# convert to raster
rst_indy <- as.raster(chm)

# reproject
crs(rst_indy) <- las_indy@crs
rst_indy <- projectRaster(rst_indy, crs = '+init=epsg:26973')

# raster to matrix
elmat = matrix(extract(rst_indy, extent(rst_indy), buffer=1000),
               nrow=ncol(rst_indy), ncol=nrow(rst_indy))

# cut down on the size
elmat = elmat[!(1:nrow(elmat) %% 3), !(1:ncol(elmat) %% 3)]

# get sun positions
mapcenter <- geocode('indianapolis')
suntimes <- getSunlightTimes(date = as.Date('2018-12-21'), mapcenter$lat, mapcenter$lon)
selectTime <- seq.POSIXt(suntimes$nauticalDawn, suntimes$nauticalDusk, 900)
angle <- lapply(selectTime, getSunlightPosition, lat = mapcenter$lat, lon = mapcenter$lon)
angle <- rbindlist(angle)

angle$alt <- angle$altitude * 180 / pi
angle$az <- 180 + angle$azimuth * 180 / pi
z.scale <- 3 * .6134

# calculate rayshades
l_rays <- list()
for (i in 1:nrow(angle)) {
  print(angle[i,]$date)
  alt <- angle[i,]$alt
  az <- angle[i,]$az
  elmat.rs <- ray_shade(elmat, anglebreaks = alt, sunangle = az, maxsearch = 150, zscale = z.scale, lambert = FALSE)
  l_rays[[i]] <- elmat.rs
}

# average frames
dt_rays <- Reduce('+', l_rays) / length(l_rays)
write_png(dt_rays, 'ray avg winter.png')
