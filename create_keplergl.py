#!/usr/bin/env python3

import json
from keplergl import KeplerGl


def main():
    kepler = KeplerGl()
    kepler.add_data(data=open("buildings.geojson").read(), name="data1")
    config_file = "keplergl_config.json"
    kepler.config = json.loads(open(config_file).read())
    kepler.save_to_html(file_name="keplergl.html")


if __name__ == "__main__":
    main()
