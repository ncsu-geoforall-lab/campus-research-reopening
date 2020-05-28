#!/bin/bash

set -e
set -x

# OGR datasource
SPATIAL_INPUT="/vsizip/./data/BLDGSCAMPUS.zip/BLDGSCAMPUS.shp"
TABULAR_INPUT="data/CGA_052620.xlsx"

GRASS_OUTPUT="buildings_grass.geojson"
OUTPUT="buildings.geojson"

xlsx2csv "$TABULAR_INPUT" > "raw_building_counts.csv"
./fix_building_number.py "raw_building_counts.csv" "building_counts_corrected.csv"

grass --tmp-location "EPSG:3358" --exec \
    ./grass_process.sh $SPATIAL_INPUT "building_counts_corrected.csv" $GRASS_OUTPUT

ogr2ogr -wrapdateline -lco "COORDINATE_PRECISION=6" -f GeoJSON -t_srs "EPSG:4326" $OUTPUT $GRASS_OUTPUT
