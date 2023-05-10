#!/bin/python3

import os
import pandas as pd

from extract import extract_all

folder = "cache_out/"


results = []

for sub in next(os.walk(folder))[1]:
    split = sub.split("+")
    results.append({"way_width": split[0], "index_width": split[1], "offset_width": split[2], "address_width": split[3]} | extract_all(folder + sub + "/"))

pd.DataFrame(results).to_csv("cache_results.csv")
