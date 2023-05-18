
import os
import sys
import csv
import numpy as np
import matplotlib.pyplot as plt

file_names = ['cjpeg', 'divide', 'fir', 'multiply', 'pi', 'rsa', 'ssd', 'ssearch', 'susan']

adds = {'ADD', 'ADDI', 'ADDIU', 'ADDU', 'SUBU'}
mults = {'MULT', 'MULTU'}
memory = {'LB', 'LBU', 'LH', 'LHU', 'LW'}

adds_counter = dict()
mults_counter = dict()
memory_counter = dict()

for f in file_names:
    adds_counter[f] = 0
    mults_counter[f] = 0
    memory_counter[f] = 0
    with open('instruction_count/'+ f +'_count.csv') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if row[' Code'].split()[0] in adds:
                adds_counter[f] += int(row[' Count'])
                
            elif row[' Code'].split()[0] in mults:
                mults_counter[f] += int(row[' Count'])
                
            elif row[' Code'].split()[0] in memory:
                memory_counter[f] += int(row[' Count'])
    
    print(f"Benchmark {f} instruction counts:\n \
          Add count: {adds_counter[f]},\t \
              Multiplication count: {mults_counter[f]},\t \
                  Memory count: {memory_counter[f]}\n\n")
    

add_c = [adds_counter[x] for x in file_names]
mults_c = [mults_counter[x] for x in file_names]
memory_c = [memory_counter[x] for x in file_names]

x_axis = np.arange(len(adds_counter.keys()))


plt.bar(x_axis-0.2, adds_counter.values(), color='b', label='Adds',width=0.2)

plt.bar(x_axis, mults_counter.values(), color='r', label='Mults', width=0.2)

plt.bar(x_axis+0.2, memory_counter.values(), color='g', label='Mem', width=0.2)

plt.xticks(x_axis, file_names)

plt.xlabel("Benchmarks")
plt.ylabel("Instruction count")

# Comment to get full picture
plt.yscale('log')

plt.legend()
plt.show()

