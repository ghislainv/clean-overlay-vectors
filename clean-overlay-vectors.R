#!/usr/bin/Rscript

# ==============================================================================
# author          :Ghislain Vieilledent
# email           :ghislain.vieilledent@cirad.fr, ghislainv@gmail.com
# web             :https://ghislainv.github.io
# license         :GPLv3
# ==============================================================================

## GRASS GIS 7.2.x is needed to run this script
## https://grass.osgeo.org/

## Libraries
library(rgrass7)

##======================================
## Create new grass location in Lat-Long

# dir.create("grassdata")
# system("grass -c EPSG:4326 -e grassdata/clean-overlay-vectors")  # Ignore errors

## Connect R to grass location
## Make sure that /usr/lib/grass72/lib is in your PATH in RStudio
Sys.setenv(LD_LIBRARY_PATH=paste("/usr/lib/grass72/lib", Sys.getenv("LD_LIBRARY_PATH"),sep=":"))
initGRASS(gisBase="/usr/lib/grass72",home=tempdir(), 
          gisDbase="grassdata",
          location="deforestmap",mapset="PERMANENT",
          override=TRUE)

# ## Download data
# d <- "https://nextcloud.fraisedesbois.net/index.php/s/KebuGpEveB161em/download"
# download.file(url=d,destfile="data/vector_data.zip",method="wget",quiet=TRUE)
# unzip("data/vector_data.zip", exdir="data")

## Import data into GRASS
## Snapping is necessary
## See https://en.wikipedia.org/wiki/Decimal_degrees 
## for correspondance between dd and meters (0.0001 dd ~ 4.3 m)

## Ecozones
system("v.in.ogr -o input=data/EcozonesWGS84_4classes.shp output=ecozone snap=1e-7")

## Continents
system("v.in.ogr -o input=data/Intersect_Gaul2008_Fishnet_AFR.shp output=fishnet_Afr snap=1e-7")
system("v.in.ogr -o input=data/Intersect_Gaul2008_Fishnet_AFR.shp output=fishnet_SAM snap=1e-7")
system("v.in.ogr --o -o input=data/Intersect_Gaul2008_Fishnet_Asia.shp output=fishnet_Asia snap=0.0001")

## Overlays
system("v.overlay ainput=fishnet_Afr binput=ecozone operator=and output=overlay_Afr")
system("v.overlay ainput=fishnet_SAM binput=ecozone operator=and output=overlay_SAM")
