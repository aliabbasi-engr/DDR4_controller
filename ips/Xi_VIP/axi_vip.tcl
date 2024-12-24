source ip_setup.tcl

file mkdir IP/axi_vip

create_project -force axi_vip IP/axi_vip -part $PART
create_ip -name axi_vip -vendor xilinx.com -library ip -version 1.1 -module_name axi_vip_0

set_property -dict [list CONFIG.INTERFACE_MODE {MASTER} CONFIG.ADDR_WIDTH {30} CONFIG.DATA_WIDTH {512} CONFIG.SUPPORTS_NARROW {0} CONFIG.HAS_BURST {0} CONFIG.HAS_LOCK {0} CONFIG.HAS_CACHE {0} CONFIG.HAS_REGION {0} CONFIG.HAS_QOS {0} CONFIG.HAS_PROT {0}] [get_ips axi_vip_0]

generate_target {instantiation_template} [get_files $IP_DIR/IP/axi_vip/axi_vip.srcs/sources_1/ip/axi_vip_0/axi_vip_0.xci]
#update_compile_order -fileset sources_1

generate_target all [get_files  $IP_DIR/IP/axi_vip/axi_vip.srcs/sources_1/ip/axi_vip_0/axi_vip_0.xci]

catch { config_ip_cache -export [get_ips -all axi_vip_0] }

export_ip_user_files -of_objects [get_files $IP_DIR/IP/axi_vip/axi_vip.srcs/sources_1/ip/axi_vip_0/axi_vip_0.xci] -no_script -sync -force -quiet

create_ip_run [get_files -of_objects [get_fileset sources_1] $IP_DIR/IP/axi_vip/axi_vip.srcs/sources_1/ip/axi_vip_0/axi_vip_0.xci]

launch_runs -jobs 4 axi_vip_0_synth_1

export_simulation -of_objects [get_files $IP_DIR/IP/axi_vip/axi_vip.srcs/sources_1/ip/axi_vip_0/axi_vip_0.xci] -simulator questasim -directory $IP_DIR/IP/axi_vip/axi_vip.ip_user_files/sim_scripts -ip_user_files_dir $IP_DIR/IP/axi_vip/axi_vip.ip_user_files -ipstatic_source_dir $IP_DIR/IP/axi_vip/axi_vip.ip_user_files/ipstatic -lib_map_path $SIM_LIB_PATH -use_ip_compiled_libs -force -quiet
