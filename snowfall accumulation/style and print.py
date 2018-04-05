from qgis.core import QgsRasterLayer
from qgis.core import QgsColorRampShader
from PyQt4.QtCore import *
from PyQt4.QtGui import *

import datetime
import time
import os
import csv
import numpy as np

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

def styleRaster(filename):
    QgsMapLayerRegistry.instance().removeAllMapLayers()
    
    raster = "C:/Users/dwald/Documents/Blog/Posts/Snowfall/Python/Storms/" + filename + "_cumulative.tif"
    fileInfo = QFileInfo(raster)
    path = fileInfo.filePath()
    baseName = fileInfo.baseName()
    layer1 = QgsRasterLayer(path, baseName)
    QgsMapLayerRegistry.instance().addMapLayer(layer1)
    
    colDic = ['#FFFFFF','#ffffcc','#c7e9b4','#7fcdbb','#41b6c4','#2c7fb8','#253494']
    
    valueList = [0,1,3,6,9,12,24]
    
    lst = [QgsColorRampShader.ColorRampItem(valueList[0], QColor(colDic[0])),\
           QgsColorRampShader.ColorRampItem(valueList[1], QColor(colDic[1])), \
           QgsColorRampShader.ColorRampItem(valueList[2], QColor(colDic[2])), \
           QgsColorRampShader.ColorRampItem(valueList[3], QColor(colDic[3])), \
           QgsColorRampShader.ColorRampItem(valueList[4], QColor(colDic[4])), \
           QgsColorRampShader.ColorRampItem(valueList[5], QColor(colDic[5])), \
           QgsColorRampShader.ColorRampItem(valueList[6], QColor(colDic[6]))]
    
    myRasterShader = QgsRasterShader()
    myColorRamp = QgsColorRampShader()
    
    myColorRamp.setColorRampItemList(lst)
    myColorRamp.setColorRampType(QgsColorRampShader.INTERPOLATED)
    myRasterShader.setRasterShaderFunction(myColorRamp)
    
    myPseudoRenderer = QgsSingleBandPseudoColorRenderer(layer1.dataProvider(), 
                                                        layer1.type(),
                                                        myRasterShader)                                                                    
    layer1.setRenderer(myPseudoRenderer)
    layer1.triggerRepaint()
    
    raster = "C:/Users/dwald/Documents/Blog/Posts/Snowfall/Python/Storms/" + filename + "_hillshade_l.tif"
    fileInfo = QFileInfo(raster)
    path = fileInfo.filePath()
    baseName = fileInfo.baseName()
    layer2 = QgsRasterLayer(path, baseName)
    QgsMapLayerRegistry.instance().addMapLayer(layer2)
    
    # in R: cat(paste0('\'', 0:13, '\':', round((0:13/13 * .6) * 255)), sep = ',')
    
    colDic = {'0':0,'1':12,'2':24,'3':35,'4':47,'5':59,'6':71,'7':82,'8':94,'9':106,'10':118,'11':129,'12':141,'13':153}
    
    valueList =[-99999,1,2,3,4,6,8,10,12,16,20,24,30,99999]
    
    lst = [QgsColorRampShader.ColorRampItem(valueList[0], QColor(255,255,255,colDic['0'])),\
           QgsColorRampShader.ColorRampItem(valueList[1], QColor(255,255,255,colDic['1'])), \
           QgsColorRampShader.ColorRampItem(valueList[2], QColor(255,255,255,colDic['2'])), \
           QgsColorRampShader.ColorRampItem(valueList[3], QColor(255,255,255,colDic['3'])), \
           QgsColorRampShader.ColorRampItem(valueList[4], QColor(255,255,255,colDic['4'])), \
           QgsColorRampShader.ColorRampItem(valueList[5], QColor(255,255,255,colDic['5'])), \
           QgsColorRampShader.ColorRampItem(valueList[6], QColor(255,255,255,colDic['6'])), \
           QgsColorRampShader.ColorRampItem(valueList[7], QColor(255,255,255,colDic['7'])), \
           QgsColorRampShader.ColorRampItem(valueList[8], QColor(255,255,255,colDic['8'])), \
           QgsColorRampShader.ColorRampItem(valueList[9], QColor(255,255,255,colDic['9'])), \
           QgsColorRampShader.ColorRampItem(valueList[10], QColor(255,255,255,colDic['10'])), \
           QgsColorRampShader.ColorRampItem(valueList[11], QColor(255,255,255,colDic['11'])), \
           QgsColorRampShader.ColorRampItem(valueList[12], QColor(255,255,255,colDic['12'])), \
           QgsColorRampShader.ColorRampItem(valueList[13], QColor(255,255,255,colDic['13']))]
    
    myRasterShader = QgsRasterShader()
    myColorRamp = QgsColorRampShader()
    
    myColorRamp.setColorRampItemList(lst)
    myColorRamp.setColorRampType(QgsColorRampShader.INTERPOLATED)
    myRasterShader.setRasterShaderFunction(myColorRamp)
    
    myPseudoRenderer = QgsSingleBandPseudoColorRenderer(layer2.dataProvider(), 
                                                        layer2.type(),
                                                        myRasterShader)                                                                    
    layer2.setRenderer(myPseudoRenderer)
    layer2.triggerRepaint()
    
    raster = "C:/Users/dwald/Documents/Blog/Posts/Snowfall/Python/Storms/" + filename + "_hillshade_d.tif"
    fileInfo = QFileInfo(raster)
    path = fileInfo.filePath()
    baseName = fileInfo.baseName()
    layer3 = QgsRasterLayer(path, baseName)
    QgsMapLayerRegistry.instance().addMapLayer(layer3)
    
    valueList =[-99999,1,2,3,4,6,8,10,12,16,20,24,30,99999]
    
    lst = [QgsColorRampShader.ColorRampItem(valueList[0], QColor(0,0,0,colDic['0'])),\
           QgsColorRampShader.ColorRampItem(valueList[1], QColor(0,0,0,colDic['1'])), \
           QgsColorRampShader.ColorRampItem(valueList[2], QColor(0,0,0,colDic['2'])), \
           QgsColorRampShader.ColorRampItem(valueList[3], QColor(0,0,0,colDic['3'])), \
           QgsColorRampShader.ColorRampItem(valueList[4], QColor(0,0,0,colDic['4'])), \
           QgsColorRampShader.ColorRampItem(valueList[5], QColor(0,0,0,colDic['5'])), \
           QgsColorRampShader.ColorRampItem(valueList[6], QColor(0,0,0,colDic['6'])), \
           QgsColorRampShader.ColorRampItem(valueList[7], QColor(0,0,0,colDic['7'])), \
           QgsColorRampShader.ColorRampItem(valueList[8], QColor(0,0,0,colDic['8'])), \
           QgsColorRampShader.ColorRampItem(valueList[9], QColor(0,0,0,colDic['9'])), \
           QgsColorRampShader.ColorRampItem(valueList[10], QColor(0,0,0,colDic['10'])), \
           QgsColorRampShader.ColorRampItem(valueList[11], QColor(0,0,0,colDic['11'])), \
           QgsColorRampShader.ColorRampItem(valueList[12], QColor(0,0,0,colDic['12'])), \
           QgsColorRampShader.ColorRampItem(valueList[13], QColor(0,0,0,colDic['13']))]
    
    myRasterShader = QgsRasterShader()
    myColorRamp = QgsColorRampShader()
    
    myColorRamp.setColorRampItemList(lst)
    myColorRamp.setColorRampType(QgsColorRampShader.INTERPOLATED)
    myRasterShader.setRasterShaderFunction(myColorRamp)
    
    myPseudoRenderer = QgsSingleBandPseudoColorRenderer(layer3.dataProvider(), 
                                                        layer3.type(),
                                                        myRasterShader)                                                                    
    layer3.setRenderer(myPseudoRenderer)
    layer3.triggerRepaint()
    
    waterStyle = QgsFillSymbolV2.createSimple({'color':'#aabbcc', 'style_border':'no'})
    
    ocean = QgsVectorLayer('ne_50m_ocean/ne_50m_ocean.shp', 'ne_50m_ocean', 'ogr')
    QgsMapLayerRegistry.instance().addMapLayer(ocean)
    ocean.rendererV2().setSymbol(waterStyle)
    ocean.triggerRepaint()
    
    lakes = QgsVectorLayer('ne_50m_lakes/ne_50m_lakes.shp', 'ne_50m_lakes', 'ogr')
    QgsMapLayerRegistry.instance().addMapLayer(lakes)
    lakes.rendererV2().setSymbol(waterStyle)
    lakes.triggerRepaint()
    
    countries = QgsVectorLayer('ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp', 'ne_50m_admin_0_countries', 'ogr')
    QgsMapLayerRegistry.instance().addMapLayer(countries)
    
    prov = countries.dataProvider()
    
    request = '"SOV_A3"=\'US1\''
    countryDel = countries.getFeatures(QgsFeatureRequest().setFilterExpression(request))
    
    prov.deleteFeatures([i.id() for i in countryDel])
    
    countries.rendererV2().setSymbol(waterStyle)
    countries.triggerRepaint()
    
    lineStyle = QgsFillSymbolV2.createSimple({'color_border':'#aabbcc', 'width_border':'hairline', 'style':'no'})
        
    stateLines = QgsVectorLayer('cb_2015_us_state_500k/cb_2015_us_state_500k.shp', 'cb_2015_us_state_500k', 'ogr')
    QgsMapLayerRegistry.instance().addMapLayer(stateLines)
    stateLines.rendererV2().setSymbol(lineStyle)
    stateLines.triggerRepaint()
    
    global filenameG
    filenameG = filename
    
    QTimer.singleShot(10, renderImage)



def renderImage():
    # size = QSize(800, 1200)
    # size = QSize(800, 1200)
    size = QSize(1400, 1200)
    image = QImage(size, QImage.Format_RGB32)
    
    painter = QPainter(image)
    painter.setRenderHint(QPainter.Antialiasing)
    
    settings = iface.mapCanvas().mapSettings()
    
    layers = settings.layers()
    settings.setLayers(layers)
    
    job = QgsMapRendererCustomPainterJob(settings, painter)
    job.renderSynchronously()
    painter.end()
    image.save('C:/Users/dwald/Documents/Blog/Posts/Snowfall/Python/Storms/png/' + filenameG + '.png')


filenameG = ''

filenames = []
for i in range(0,len(stormList)):
    print('i: ' + str(i))
    for j in range(0,len(stormList[i]['files'])):
        print('j: ' + str(j))
        filenames.append(stormList[i]['storm'] + '_' + str(stormList[i]['files'][j]['frame']))



# -158524,-1355071 : 6784827,2037342
# 1:22,467,967
# QSize(800, 1200)

styleRaster(filenames[0])
styleRaster(filenames[1])
styleRaster(filenames[2])
styleRaster(filenames[3])
styleRaster(filenames[4])
styleRaster(filenames[5])
styleRaster(filenames[6])
styleRaster(filenames[7])
styleRaster(filenames[8])
styleRaster(filenames[9])
styleRaster(filenames[10])
styleRaster(filenames[11])
styleRaster(filenames[12])
styleRaster(filenames[13])
styleRaster(filenames[14])
styleRaster(filenames[15])
styleRaster(filenames[16])

styleRaster(filenames[17])
styleRaster(filenames[18])
styleRaster(filenames[19])
styleRaster(filenames[20])
styleRaster(filenames[21])
styleRaster(filenames[22])
styleRaster(filenames[23])
styleRaster(filenames[24])
styleRaster(filenames[25])
styleRaster(filenames[26])
styleRaster(filenames[27])

styleRaster(filenames[28])
styleRaster(filenames[29])
styleRaster(filenames[30])
styleRaster(filenames[31])
styleRaster(filenames[32])
styleRaster(filenames[33])
styleRaster(filenames[34])
styleRaster(filenames[35])
styleRaster(filenames[36])
styleRaster(filenames[37])
styleRaster(filenames[38])
styleRaster(filenames[39])
styleRaster(filenames[40])

styleRaster(filenames[41])
styleRaster(filenames[42])
styleRaster(filenames[43])
styleRaster(filenames[44])
styleRaster(filenames[45])
styleRaster(filenames[46])
styleRaster(filenames[47])
styleRaster(filenames[48])
styleRaster(filenames[49])
styleRaster(filenames[50])
styleRaster(filenames[51])
styleRaster(filenames[52])
styleRaster(filenames[53])

styleRaster(filenames[54])
styleRaster(filenames[55])
styleRaster(filenames[56])
styleRaster(filenames[57])
styleRaster(filenames[58])
styleRaster(filenames[59])
styleRaster(filenames[60])
styleRaster(filenames[61])
styleRaster(filenames[62])
styleRaster(filenames[63])
styleRaster(filenames[64])
styleRaster(filenames[65])
styleRaster(filenames[66])
styleRaster(filenames[67])
styleRaster(filenames[68])
styleRaster(filenames[69])
styleRaster(filenames[70])

styleRaster(filenames[71])
styleRaster(filenames[72])
styleRaster(filenames[73])
styleRaster(filenames[74])
styleRaster(filenames[75])
styleRaster(filenames[76])
styleRaster(filenames[77])
styleRaster(filenames[78])
styleRaster(filenames[79])
styleRaster(filenames[80])
styleRaster(filenames[81])
styleRaster(filenames[82])
styleRaster(filenames[83])

styleRaster(filenames[84])
styleRaster(filenames[85])
styleRaster(filenames[86])
styleRaster(filenames[87])
styleRaster(filenames[88])
styleRaster(filenames[89])
styleRaster(filenames[90])
styleRaster(filenames[91])
styleRaster(filenames[92])
styleRaster(filenames[93])
styleRaster(filenames[94])
styleRaster(filenames[95])
styleRaster(filenames[96])

styleRaster(filenames[97])
styleRaster(filenames[98])
styleRaster(filenames[99])
styleRaster(filenames[100])
styleRaster(filenames[101])
styleRaster(filenames[102])
styleRaster(filenames[103])
styleRaster(filenames[104])
styleRaster(filenames[105])
styleRaster(filenames[106])
styleRaster(filenames[107])
styleRaster(filenames[108])
styleRaster(filenames[109])
styleRaster(filenames[110])
styleRaster(filenames[111])
styleRaster(filenames[112])
styleRaster(filenames[113])

styleRaster(filenames[114])
styleRaster(filenames[115])
styleRaster(filenames[116])
styleRaster(filenames[117])
styleRaster(filenames[118])
styleRaster(filenames[119])
styleRaster(filenames[120])
styleRaster(filenames[121])
styleRaster(filenames[122])
styleRaster(filenames[123])
styleRaster(filenames[124])
styleRaster(filenames[125])
styleRaster(filenames[126])
styleRaster(filenames[127])
styleRaster(filenames[128])
styleRaster(filenames[129])
styleRaster(filenames[130])
styleRaster(filenames[131])
styleRaster(filenames[132])
styleRaster(filenames[133])
styleRaster(filenames[134])
styleRaster(filenames[135])
styleRaster(filenames[136])
styleRaster(filenames[137])
styleRaster(filenames[138])
styleRaster(filenames[139])
styleRaster(filenames[140])
styleRaster(filenames[141])
styleRaster(filenames[142])
styleRaster(filenames[143])
styleRaster(filenames[144])
styleRaster(filenames[145])
styleRaster(filenames[146])

styleRaster(filenames[147])
styleRaster(filenames[148])
styleRaster(filenames[149])
styleRaster(filenames[150])
styleRaster(filenames[151])
styleRaster(filenames[152])
styleRaster(filenames[153])
styleRaster(filenames[154])
styleRaster(filenames[155])
styleRaster(filenames[156])
styleRaster(filenames[157])
styleRaster(filenames[158])
styleRaster(filenames[159])
styleRaster(filenames[160])
styleRaster(filenames[161])
styleRaster(filenames[162])
styleRaster(filenames[163])
styleRaster(filenames[164])
styleRaster(filenames[165])
styleRaster(filenames[166])
styleRaster(filenames[167])
styleRaster(filenames[168])
styleRaster(filenames[169])
styleRaster(filenames[170])
styleRaster(filenames[171])
styleRaster(filenames[172])
styleRaster(filenames[173])
styleRaster(filenames[174])
styleRaster(filenames[175])
styleRaster(filenames[176])
styleRaster(filenames[177])
styleRaster(filenames[178])
styleRaster(filenames[179])
styleRaster(filenames[180])
styleRaster(filenames[181])
styleRaster(filenames[182])
styleRaster(filenames[183])
styleRaster(filenames[184])
styleRaster(filenames[185])
styleRaster(filenames[186])
styleRaster(filenames[187])

styleRaster(filenames[188])
styleRaster(filenames[189])
styleRaster(filenames[190])
styleRaster(filenames[191])
styleRaster(filenames[192])
styleRaster(filenames[193])
styleRaster(filenames[194])
styleRaster(filenames[195])
styleRaster(filenames[196])
styleRaster(filenames[197])
styleRaster(filenames[198])
styleRaster(filenames[199])
styleRaster(filenames[200])
styleRaster(filenames[201])
styleRaster(filenames[202])
styleRaster(filenames[203])
styleRaster(filenames[204])
styleRaster(filenames[205])
styleRaster(filenames[206])
styleRaster(filenames[207])
styleRaster(filenames[208])

styleRaster(filenames[209])
styleRaster(filenames[210])
styleRaster(filenames[211])
styleRaster(filenames[212])
styleRaster(filenames[213])
styleRaster(filenames[214])
styleRaster(filenames[215])
styleRaster(filenames[216])
styleRaster(filenames[217])
styleRaster(filenames[218])
styleRaster(filenames[219])
styleRaster(filenames[220])
styleRaster(filenames[221])
styleRaster(filenames[222])
styleRaster(filenames[223])
styleRaster(filenames[224])
styleRaster(filenames[225])
