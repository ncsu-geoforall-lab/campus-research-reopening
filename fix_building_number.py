#!/usr/bin/env python3

import csv
import sys

def correct_number(value1):
    if len(value1) == 1:
        return f"00{value1}"
    elif len(value1) == 2:
        return f"0{value1}"
    return value1


def filter_file(input_file, output_file):
    with open(input_file, newline='') as infile:
        reader = csv.reader(infile)
        fieldnames = next(reader)
    with open(input_file, newline='') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in reader:
            value = row["Number"]
            row["Number"] = correct_number(value)
            writer.writerow(row)

def main():
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    filter_file(input_file, output_file)

if __name__ == "__main__":
    main()
