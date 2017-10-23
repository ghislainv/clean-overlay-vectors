# clean-overlay-vectors

The R/GRASS script is used to overlay country boundaries with a 1-degree grid and ecological zones. This is necessary to compute statistics (in particular forest cover) from Google Earth Engine by geometry and then summarise the results by country and ecozone.

### Data

Source of the data:
- [Global Administrative Unit Layer](https://figshare.com/s/104dcfb699b790453ca5) from FAO.
- [Ecozones](https://figshare.com/s/d249aa1c5485e3ad4273) from FAO.

### Data cleaning

Shapefiles provided by FAO need to be cleaned before computing overlays (intersecting polygons). This is done using the `snap` argument while importing data in GRASS location with `v.in.ogr`.

### Results

A shapefile is exported with the following column names in the attribute table:

- `cat`: identifiant of the polygon.
- `ctrycode`: country code.
- `ctryname`: country name.
- `ecozone`: reclassified ecozone.

Results can be downloaded [here]().