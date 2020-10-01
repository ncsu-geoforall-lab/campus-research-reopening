#!/bin/bash

set -e
set -x

./create_keplergl.py AMO Approved_Max_Occupancy
./create_keplergl.py UPI Unique_PIs
./create_keplergl.py TS Max_Per_Shift
