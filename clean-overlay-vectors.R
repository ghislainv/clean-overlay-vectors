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

# Data directory
dir.create("data")

# 1. Global Administrative Unit Layer from FAO
# http://ref.data.fao.org/map?entryId=f7e7adb0-88fd-11da-a88f-000d939bc5d8
d_gaul <- "https://ndownloader.figshare.com/files/9570037?private_link=104dcfb699b790453ca5"
download.file(url=d_gaul,destfile="data/gaul.zip",method="wget",quiet=TRUE)
unzip("data/gaul.zip", exdir="data")

# 2. Ecozones from FAO
# http://ref.data.fao.org/map?entryId=2fb209d0-fd34-4e5e-a3d8-a13c241eb61b&tab=metadata
d_ecozones <- "https://ndownloader.figshare.com/files/9569974?private_link=d54b972e919c058f70a1"
download.file(url=d,destfile="data/ecozones.zip",method="wget",quiet=TRUE)
unzip("data/ecozones.zip", exdir="data")

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

# Create 1 degree size grid:
system("g.region n=90 s=-90 w=-180 e=180 res=1 -p")
system("v.mkgrid map=grid grid=180,360")

# Overlay country boundaries and grid
system("v.overlay ainput=ctry binput=grid operator=and output=ctry_grid")

# Ecozones
system("v.in.ogr -o input=data/EcozonesWGS84_4classes.shp output=ecozones snap=1e-7")

# Overlay with ecozones
system("v.overlay ainput=ctry_grid binput=ecozones operator=and output=ctry_grid_ecozone")

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

# Zip
ff <- c("output/ctry_grid_ecozone.shx", "output/ctry_grid_ecozone.shp", "output/ctry_grid_ecozone.dbf")
zip(zipfile="output/ctry_grid_ecozone.zip",files=ff)

#==============
# Plots
library(rgdal)
ctry_grid_ecozone <- readOGR("output/ctry_grid_ecozone.shp")
# Country
png("output/ctry.png", width=960, height=240)
par(mar=c(0,0,0,0))
plot(ctry_grid_ecozone, col=ctry_grid_ecozone$ctrycode, lwd=0.5)
dev.off()
# Ecozone
colors <- ctry_grid_ecozone$ecozone
colors[colors==1] <- "darkgreen"
colors[colors==2] <- "orange"
colors[colors==3] <- "yellow"
png("output/ecozone.png", width=960, height=240)
par(mar=c(0,0,0,0))
plot(ctry_grid_ecozone, col=colors, lwd=0.5)
dev.off()

# End
