# snowfall accumulation

Inspired by a Washington Post graphic from March 26th, I created map animations of snowfall accumulation for various storms in the 2017-18 winter season.

**stormlist.csv** contains a list of the periods to download. There are three columns (no header): storm name, start (yyyymmddhh), end (yyyymmddhh). The start and end dates tell which raster files to download from the NOHRSC website (nohrsc.noaa.gov/snowfall/).

**snowfall rasters.py** downloads the files and calculates new cumulative raster files, as well as a pair of corresponding hillshade files. One hillshade file will be used to lighten, and the other to darken.

**style and print.py** uses PyQGIS to add the created layers, as well as some layers from http://www.naturalearthdata.com (oceans, lakes, countries), and the Census Bureau (state borders). The layers are styled then saved to images.

**ffmpeg.txt** contains the commands used to stitch the images into mp4 videos and crop. Note that the dimensions of the images are dependent on the canvas view in QGIS at the time the images were saved.
