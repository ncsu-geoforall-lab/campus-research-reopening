#!/bin/bash

set -e
set -x

./create_keplergl.py Daily_Total 
./create_keplergl.py Shift_Total
