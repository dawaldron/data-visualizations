# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 22:03:15 2018

@author: dwald
"""

import os
import gdal
import ogr

import numpy as np
import subprocess
import copy
import datetime
import urllib
import csv

os.chdir('C:/Users/dwald/Documents/Blog/Posts/Snowfall/Python/Storms')

stormList = []
with open('stormlist.csv', 'rt') as f:
    reader = csv.reader(f)
    for row in reader:
        start = datetime.datetime.strptime(row[1][:10], "%Y%m%d%H")
        end = datetime.datetime.strptime(row[2][:10], "%Y%m%d%H")
        hourdiff = (end-start).days * 24 + (end-start).seconds / 3600
        timeList = [start + datetime.timedelta(hours = x) for x in np.arange(0, hourdiff + 1, 6)]
        fileList = []
        for i in range(0, len(timeList)):
            tm = timeList[i]
            fileList.append({'frame':i,'url':'https://www.nohrsc.noaa.gov/snowfall/data/' + tm.strftime('%Y%m') + '/sfav2_CONUS_6h_' + tm.strftime('%Y%m%d%H') + '.tif'})
        stormList2 = {'storm':row[0], 'files':fileList}
        stormList.append(stormList2)

for i in range(0,len(stormList)):
    print('i: ' + str(i))
    for j in range(0,len(stormList[i]['files'])):
        print('j: ' + str(j))
        filename = stormList[i]['storm'] + '_' + str(stormList[i]['files'][j]['frame'])
        urllib.request.urlretrieve(stormList[i]['files'][j]['url'],
                                   filename + '.tif')

        input_file = filename + '.tif'
        cumulative_file = filename + '_cumulative.tif'
        reproj_file = filename + '_albers.tif'
        hillshade_file = filename + '_hillshade.tif'
        hillshade_file_l = filename + '_hillshade_l.tif'
        hillshade_file_d = filename + '_hillshade_d.tif'
        
        pixel_values = []
        raster = []
        for k in range(0,j+1):
            raster.append(gdal.Open(stormList[i]['storm'] + '_' + str(k) + '.tif'))
            pixel_values.append(raster[k].ReadAsArray())
            pixel_values[k][pixel_values[k] < 0] = 0
        
        pixels = sum(pixel_values)
        
        print(raster)
        
        driver = gdal.GetDriverByName('GTiff')
        raster_out = driver.CreateCopy(cumulative_file, raster[j])
        raster_out.GetRasterBand(1).WriteArray(pixels)
        raster_out = None
        
        # reproject to albers usa
        gdal.Warp(reproj_file, cumulative_file, dstSRS='EPSG:102003')
        
        # calculate hillshade
        subprocess.call(["gdaldem", "hillshade", reproj_file, \
             hillshade_file, "-z", "500.0", "-s", "1.0", \
             "-az", "315.0", "-alt", "45.0"])
        
        hillshade = gdal.Open(hillshade_file)
        
        pixel_values = hillshade.ReadAsArray()
        
        hsmode = np.bincount(np.ravel(pixel_values)).argmax()
        
        pixel_values_l = copy.deepcopy(pixel_values)
        pixel_values_l[pixel_values_l < hsmode + 0.5] = hsmode
        pixel_values_l = pixel_values_l - hsmode
        
        driver = gdal.GetDriverByName('GTiff')
        raster_out = driver.CreateCopy(hillshade_file_l, hillshade)
        raster_out.GetRasterBand(1).WriteArray(pixel_values_l)
        raster_out = None
        
        pixel_values_d = copy.deepcopy(pixel_values)
        pixel_values_d[pixel_values_d > hsmode - 0.5] = 181
        pixel_values_d = hsmode - pixel_values_d
        
        driver = gdal.GetDriverByName('GTiff')
        raster_out = driver.CreateCopy(hillshade_file_d, hillshade)
        raster_out.GetRasterBand(1).WriteArray(pixel_values_d)
        raster_out = None


