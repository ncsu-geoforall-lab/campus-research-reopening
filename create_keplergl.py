#!/usr/bin/env python3

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
    config_file = "keplergl_config.json"
    data_id = "buildings"
    config = read_configuration(config_file, label="Buildings", data_id=data_id)
    kepler = KeplerGl(config=config)
    kepler.add_data(data=open("buildings.geojson").read(), name=data_id)
    output = "keplergl.html"
    kepler.save_to_html(file_name=output)

    # Add map creator
    with InPlace(output) as file:
        for line in file:
            line = line.replace(
                "<title>Kepler.gl</title>",
                "<title>Campus Research Reopening Map by NCSU CGA</title>",
            )
            line = line.replace("Kepler.gl Jupyter", "Kepler.gl Map by NCSU CGA")
            file.write(line)


if __name__ == "__main__":
    main()
