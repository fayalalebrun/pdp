open_project ${xpr_path}
set_param general.maxThreads 16
#update_compile_order -fileset sources_1
set_property strategy {${synth}} [get_runs synth_1]
set_property strategy {${imp}} [get_runs impl_1]
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
