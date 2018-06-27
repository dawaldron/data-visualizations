# indy building age

Match property tax data to parcels and building footprints to make map of building age. Demo here: https://www.waldrn.com/indy-building-age-map/.

**indy buildings.R** Matches various data sources and produces output files, including new attribute table for building footprints shapefile, and two csv files for the summary charts.

Shapefile is styled in TileMill, exported to mbtiles, the written to an xyz tiles which are hosted and rendered with leaflet.js