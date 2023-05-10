#!/bin/python3

import os
import pandas as pd

from extract import extract_all

folder = "si_out/"


results = []

for sub in next(os.walk(folder))[1]:
    split = sub.split("+")
    results.append({"synth": split[0], "imp": split[1]} | extract_all(folder + sub + "/"))

pd.DataFrame(results).to_csv("synth_imp_results.csv")
