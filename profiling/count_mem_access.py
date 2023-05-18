import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

file_path = 'mem_access.txt'
accesses = [0 for i in range(32)]
with open(file_path, 'r') as f:
    for line in f:
        els = line.split(" ")
        address = int(els[0])
        count = int(els[1])
        
        for i in range(32):
            if address >= 2**i:
                accesses[i] = accesses[i] + count

for i in range(32):
    print("Accesses after bit", i, "\t", accesses[i])

