#!/bin/python3

import os
from string import Template
import subprocess
import shutil

way_widths = [0, 1, 2]
index_widths = [4, 5, 6, 7, 8, 9, 11]
offset_widths = [2, 4, 5, 6]
address_widths = [23]
max_cache_size = 2**17 # 16 KB
min_cache_size = 2**11 # 512 B

output_folder = "cache_out/"
vivado_path = "/opt/Xilinx/Vivado/2022.2/bin/vivado"
xpr_path = os.path.abspath("../fpga/zynq_fpga/zynq_fpga.xpr")
bd_path = os.path.abspath("../fpga/zynq_fpga/zynq_fpga.srcs/sources_1/bd/design_2/design_2.bd")

template_tcl = Template(open("template_cache.tcl").read())

os.makedirs(output_folder, exist_ok=True)

for way_width in way_widths:
    for index_width in index_widths:
        for offset_width in offset_widths:
            for address_width in address_widths:
                tag_width = address_width - index_width - offset_width
                cache_size = 2 ** way_width * 2 ** index_width * (tag_width + 2 ** offset_width * 8)
                if cache_size > max_cache_size or cache_size < min_cache_size:
                    print("Omitting cache size: ", cache_size)
                    continue
                else:
                    print("Cache size: ", cache_size)
                
                sub_folder = output_folder + str(way_width) + "+" + str(index_width) + "+" + str(offset_width) + "+" + str(address_width) + "/"
                print(sub_folder)
                os.makedirs(sub_folder, exist_ok=True)

                if os.path.exists(sub_folder + "design_2_wrapper.xsa"):
                    print("Already exists, skipping")
                    continue
                sub = dict(way_width=way_width, index_width=index_width, offset_width=offset_width, address_width=address_width, utilization_path=os.path.abspath(sub_folder + "utilization_report.txt"), timing_path=os.path.abspath(sub_folder + "timing_report.txt"), xsa_path=os.path.abspath(sub_folder + "design_2_wrapper.xsa"), xpr_path=xpr_path, bd_path=bd_path)
                tcl_path = sub_folder + "script.tcl"
                tcl_script = template_tcl.substitute(sub)
                with open(tcl_path, 'w') as f:
                    f.write(tcl_script)
                subprocess.run([vivado_path, "-mode", "batch", "-source", os.path.abspath(tcl_path)])
