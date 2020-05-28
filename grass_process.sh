#!/bin/bash

# This script is to be executed in GRASS GIS.

set -e
set -x

SPATIAL_INPUT="$1"
TABULAR_INPUT="$2"
OUTPUT="$3"

# Import data
v.import "$SPATIAL_INPUT" output=raw_buildings 
db.in.ogr "$TABULAR_INPUT" output=building_counts_table

# Join the tables
v.db.join raw_buildings column=BLDGNUM other_table=building_counts_table other_column=Number

# Make Count an integer
v.db.renamecolumn raw_buildings column=Count,count_text
v.db.addcolumn raw_buildings columns="Count integer"
v.db.update raw_buildings col=Count qcol="CAST(count_text AS integer)"

# Replace zeros with NULLs
v.db.update raw_buildings column=Count query_column="NULL" where="Count = 0"

# Export data
# Using overwrite to behave like other tools in case of re-running this.
# (Consistent behavior if we are in a temporary location.)
v.out.ogr input=raw_buildings output="$OUTPUT" format=GeoJSON -s --overwrite
