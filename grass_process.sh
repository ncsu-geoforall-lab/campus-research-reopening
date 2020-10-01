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
for COLUMN in Research_Building AMO UPI TS
do
    v.db.renamecolumn buildings column=$COLUMN,tmp_column
    v.db.addcolumn buildings columns="$COLUMN integer"
    v.db.update buildings col=$COLUMN qcol="CAST(tmp_column AS integer)"
    v.db.dropcolumn map=buildings columns=tmp_column
done

# Replace zeros with NULLs
# Results in polygons without fill and thus makes clear distinction
# between 0 and 1 in the automatic color table.
v.db.update buildings column=AMO query_column="NULL" where="AMO = 0"
v.db.update buildings column=UPI query_column="NULL" where="UPI = 0"
v.db.update buildings column=TS query_column="NULL" where="TS = 0"

# Add more readable column
# It is easier to color and creates more readable legend.
v.db.addcolumn buildings columns="Building_Type text"
v.db.update buildings column=Building_Type query_column="case when Research_Building = 1 then 'Research' else 'Other' end"
v.db.dropcolumn map=buildings columns=tmp_column

# Remove buildings which are not part of the university
# Preserving the simple name, so using a a rename/swap.
g.rename vector=buildings,all_buildings
v.extract input=all_buildings where="Number is not NULL" output=buildings

# Rename columns for output
v.db.renamecolumn map=buildings column=AMO,Approved_Max_Occupancy
v.db.renamecolumn map=buildings column=UPI,Unique_PIs
v.db.renamecolumn map=buildings column=TS,Max_Per_Shift

# Drop unnecessary columns
v.db.dropcolumn map=buildings columns=BLDGNUM,Shape_STAr,Shape_STLe,Precinct,City

# Export data
# Using overwrite to behave like other tools in case of re-running this.
# (Consistent behavior if we are in a temporary location.)
v.out.ogr input=buildings output="$OUTPUT" format=GeoJSON -s --overwrite
