#!/usr/bin/Rscript

# ==============================================================================
# author          :Ghislain Vieilledent
# email           :ghislain.vieilledent@cirad.fr, ghislainv@gmail.com
# web             :https://ghislainv.github.io
# license         :GPLv3
# ==============================================================================

# GRASS GIS 7.2.x is needed to run this script
# https://grass.osgeo.org/

# Libraries
library(rgrass7)

#======================================
# Download data

dir.create("data")
d <- "https://nextcloud.fraisedesbois.net/index.php/s/ITnfOi8whKQbOi0/download"
download.file(url=d,destfile="data/data_ctry_ecozones_FAO.zip",method="wget",quiet=TRUE)
unzip("data/data_ctry_ecozones_FAO.zip", exdir="data")

# Data includes 
# 1. Global Administrative Unit Layer from FAO
# http://ref.data.fao.org/map?entryId=f7e7adb0-88fd-11da-a88f-000d939bc5d8
# 2. Ecozones from FAO
# http://ref.data.fao.org/map?entryId=2fb209d0-fd34-4e5e-a3d8-a13c241eb61b&tab=metadata

#======================================
# Create new grass location in Lat-Long

# dir.create("grassdata")
# system("grass -c EPSG:4326 -e grassdata/clean-overlay-vectors")  # Ignore errors

# Connect R to grass location
# Make sure that /usr/lib/grass72/lib is in your PATH in RStudio
Sys.setenv(LD_LIBRARY_PATH=paste("/usr/lib/grass72/lib", Sys.getenv("LD_LIBRARY_PATH"),sep=":"))
initGRASS(gisBase="/usr/lib/grass72",home=tempdir(), 
          gisDbase="grassdata",
          location="deforestmap",mapset="PERMANENT",
          override=TRUE)

#======================================
# Import and compute overlays

# Import ctry country data into GRASS
# Snapping is necessary
# See https://en.wikipedia.org/wiki/Decimal_degrees 
# for correspondance between dd and meters (0.0001 dd ~ 4.3 m)
system("v.in.ogr --o -o input=data/G2013_2012_0.shp output=ctry snap=0.0001")
system("g.region n=90 s=-90 w=-180 e=180 res=1 -p")

# Create 1 degree size grid:
system("v.mkgrid map=grid grid=180,360")

# Overlay country boundaries and grid
system("v.overlay ainput=ctry binput=grid operator=and output=ctry_grid")

# Ecozones
system("v.in.ogr -o input=data/EcozonesWGS84_4classes.shp output=ecozone snap=1e-7")

# Overlay with ecozones
system("v.overlay ainput=ctry_grid binput=ecozone operator=and output=ctry_grid_ecozone")

#======================================
# Export

# Rename columns
system("v.info -c ctry_grid_ecozone")
system("v.db.renamecolumn ctry_grid_ecozone column=a_a_ADM0_CODE,ctrycode")
system("v.db.renamecolumn ctry_grid_ecozone column=a_a_ADM0_NAME,ctryname")
system("v.db.renamecolumn ctry_grid_ecozone column=b_Reclass,ecozone")

# Export
dir.create("output")
system("v.out.ogr input=ctry_grid_ecozone output=output/ctry_grid_ecozone.shp")

# End
