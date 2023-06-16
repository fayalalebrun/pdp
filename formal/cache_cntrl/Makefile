
DUT  = cache_cntrl
SRC += ../../rtl/platform/cpu_pack.vhd
SRC += ../../rtl/platform/cache_cntrl.vhd



#######################
# Formal verification
#######################

.PHONY: formal
formal: $(DUT)_cover/PASS $(DUT)_prove/PASS
$(DUT)_cover/PASS: $(DUT).sby $(DUT).psl $(SRC)
	# This is the main command line to run the formal verification
	sby --yosys "yosys -m ghdl" -f $(DUT).sby

show_prove:
	gtkwave $(DUT)_prove/engine_0/trace_induct.vcd $(DUT).gtkw


#######################
# Synthesis
#######################

.PHONY: synth
synth: work-obj08.cf
	yosys -m ghdl -p 'ghdl -fpsl -fsynopsys --std=08 -frelaxed $(DUT); synth_xilinx -top $(DUT) -edif $(DUT).edif' > yosys.log

work-obj08.cf: $(SRC)
	ghdl -a -fpsl -fsynopsys --std=08 -frelaxed $^


#######################
# Cleanup
#######################

.PHONY: clean
clean:
	rm -rf $(DUT)_cover/
	rm -rf $(DUT)_prove/
	rm -rf work-obj08.cf
	rm -rf yosys.log
	rm -rf $(DUT).edif
