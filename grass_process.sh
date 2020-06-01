#!/bin/bash

# This script is to be executed in GRASS GIS.

set -e
set -x

SPATIAL_INPUT="$1"
TABULAR_INPUT="$2"
CLIP_REGION="$3"
OUTPUT="$4"

# Import data
v.import "$SPATIAL_INPUT" output=raw_buildings
db.in.ogr "$TABULAR_INPUT" output=building_counts_table
v.import "$CLIP_REGION" output=region

# Clip to the area of interest
v.clip input=raw_buildings clip=region output=buildings

# Join the tables
v.db.join buildings column=BLDGNUM other_table=building_counts_table other_column=Number

# Make integer columns integers
for COLUMN in Research_Building Daily_Total Shift_Total
do
    v.db.renamecolumn buildings column=$COLUMN,tmp_column
    v.db.addcolumn buildings columns="$COLUMN integer"
    v.db.update buildings col=$COLUMN qcol="CAST(tmp_column AS integer)"
    v.db.dropcolumn map=buildings columns=tmp_column
done

# Replace zeros with NULLs
v.db.update buildings column=Daily_Total query_column="NULL" where="Daily_Total = 0"
v.db.update buildings column=Shift_Total query_column="NULL" where="Shift_Total = 0"

# Drop unnecessary columns
v.db.dropcolumn map=buildings columns=BLDGNUM,Shape_STAr,Shape_STLe,Precinct,City

# Pick only research buildings
# Doing swap to preserve the name in the output JSON file.
g.rename vector=buildings,buildings_full
v.extract input=buildings_full where="Research_Building = 1" output=buildings

# Export data
# Using overwrite to behave like other tools in case of re-running this.
# (Consistent behavior if we are in a temporary location.)
v.out.ogr input=buildings output="$OUTPUT" format=GeoJSON -s --overwrite
