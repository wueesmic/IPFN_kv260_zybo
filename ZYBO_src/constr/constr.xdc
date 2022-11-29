#set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_p[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_p[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_p[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {xa_p[0]}]
#set_property PACKAGE_PIN D18 [get_ports {led[3]}]
#set_property PACKAGE_PIN G14 [get_ports {led[2]}]
#set_property PACKAGE_PIN M15 [get_ports {led[1]}]
#set_property PACKAGE_PIN M14 [get_ports {led[0]}]
#set_property PACKAGE_PIN T16 [get_ports {sw[3]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[2]}]
#set_property PACKAGE_PIN P15 [get_ports {sw[1]}]
#set_property PACKAGE_PIN G15 [get_ports {sw[0]}]
set_property PACKAGE_PIN J14 [get_ports {xa_n[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN L16 [get_ports clk]


#set_property IOSTANDARD LVCMOS33 [get_ports {i_SPI_CS[0]}]





#set_property PACKAGE_PIN V15 [get_ports i_SPI_Clk]
#set_property PACKAGE_PIN W15 [get_ports i_SPI_MOSI]
#set_property PACKAGE_PIN T11 [get_ports o_SPI_MISO]
#set_property PACKAGE_PIN U12 [get_ports {i_SPI_CS[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports i_SPI_Clk]
#set_property IOSTANDARD LVCMOS33 [get_ports i_SPI_MOSI]
#set_property IOSTANDARD LVCMOS33 [get_ports o_SPI_MISO]
#set_property SLEW FAST [get_ports o_SPI_MISO]


set_property PACKAGE_PIN V17 [get_ports scl_p]
set_property PACKAGE_PIN T14 [get_ports {MISO_p[0]}]


set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {MISO_p[0]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports {CS_p[0]}]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports scl_p]

set_property PACKAGE_PIN T11 [get_ports {CS_p[0]}]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets design_1_TOP_i/util_ds_buf_0/U0/IBUF_OUT[0]]  #for clock constraint error

set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_1]


