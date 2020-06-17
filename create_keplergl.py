#!/usr/bin/env python3

import sys
import json
from keplergl import KeplerGl
from in_place import InPlace
from jinja2 import Template


def read_configuration(file_name, **kwargs):
    with open(file_name) as file:
        text = file.read()
    template = Template(text)
    text = template.render(**kwargs)
    return json.loads(text)


def main():
    column_short = sys.argv[1]
    column_long = sys.argv[2]
    config_file = "keplergl_config.json"
    data_id = "buildings"
    config = read_configuration(
        config_file, label="Buildings", data_id=data_id, color_column=column_long
    )
    print("Using configuration (JSON syntax):")
    print(json.dumps(config, indent=2))
    kepler = KeplerGl(config=config)
    kepler.add_data(data=open("buildings.geojson").read(), name=data_id)
    output = f"keplergl_{column_short}.html"
    kepler.save_to_html(file_name=output)

    name = column_long.replace("_", " ")

    # Add map title and creator
    with InPlace(output) as file:
        for line in file:
            line = line.replace(
                "<title>Kepler.gl</title>",
                f"<title>{name} &ndash; Campus Research Reopening Map"
                " by NCSU CGA</title>",
            )
            line = line.replace("Kepler.gl Jupyter", "Kepler.gl Map by NCSU CGA")
            file.write(line)


if __name__ == "__main__":
    main()
