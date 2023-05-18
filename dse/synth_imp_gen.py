#!/bin/python3

import os
from string import Template
import subprocess
import shutil

synths = ["Flow_PerfOptimized_high", "Flow_AreaOptimized_high", "Vivado Synthesis Defaults"]

imps = ["Performance_Auto_1", "Performance_NetDelay_high", "Congestion_SpreadLogic_high", "Area_Explore", "Power_ExploreArea", "Flow_RuntimeOptimized"]

output_folder = "si_out/"
vivado_path = "/opt/Xilinx/Vivado/2022.2/bin/vivado"
xpr_path = os.path.abspath("../fpga/zynq_fpga/zynq_fpga.xpr")

template_tcl = Template(open("template_synth_imp.tcl").read())

os.makedirs(output_folder, exist_ok=True)

for synth in synths:
    for imp in imps:
        sub_folder = output_folder + synth + "+" + imp + "/"
        print(sub_folder)
        os.makedirs(sub_folder, exist_ok=True)
        sub = dict(synth=synth, imp=imp, utilization_path=os.path.abspath(sub_folder + "utilization_report.txt"), timing_path=os.path.abspath(sub_folder + "timing_report.txt"), xsa_path=os.path.abspath(sub_folder + "design_2_wrapper.xsa"),xpr_path=xpr_path)
        tcl_path = sub_folder + "script.tcl"
        tcl_script = template_tcl.substitute(sub)
        with open(tcl_path, 'w') as f:
            f.write(tcl_script)
        subprocess.run([vivado_path, "-mode", "batch", "-source", os.path.abspath(tcl_path)])
