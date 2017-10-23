## clean-overlay-vectors

The R/GRASS script is used to overlay country boundaries with a 1-degree grid and ecological zones. This is necessary to compute statistics (in particular forest cover) from Google Earth Engine by geometry and then summarise the results by country and ecozone.

### Data

Source of the data:
- [Global Administrative Unit Layer](http://ref.data.fao.org/map?entryId=f7e7adb0-88fd-11da-a88f-000d939bc5d8) from FAO.
- [Ecozones](http://ref.data.fao.org/map?entryId=2fb209d0-fd34-4e5e-a3d8-a13c241eb61b&tab=metadata) from FAO.

Data can be downloaded [here](https://nextcloud.fraisedesbois.net/index.php/s/ITnfOi8whKQbOi0).

### Data cleaning

Shapefiles provided by FAO need to be cleaned before computing overlays (intersecting polygons). This is done using snap argument while importing data in GRASS location with `v.in.ogr`.

### Results

A shapefile is exported with the following column names in the attribute table:

- cat: identifiant of the polygon.
- ctrycode: country code.
- ctryname: country name.
- ecozone: reclassified ecozone.

Results can be downloaded [here]().