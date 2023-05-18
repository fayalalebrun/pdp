open_project {${xpr_path}}
open_bd_design {${bd_path}}
#update_compile_order -fileset sources_1
startgroup
set_property -dict [list \
			CONFIG.cache_address_width {${address_width}} \
			CONFIG.cache_index_width {${index_width}} \
			CONFIG.cache_offset_width {${offset_width}} \
			CONFIG.cache_way_width {${way_width}} \
] [get_bd_cells cpu_0]
endgroup
reset_run synth_1
launch_runs synth_1 -jobs 16
wait_on_run synth_1
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1
open_run impl_1
report_utilization -cells design_2_i/cpu_0 -file {${utilization_path}}
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -file {${timing_path}}
write_hw_platform -fixed -include_bit -force -file {${xsa_path}}
