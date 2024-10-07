
## Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { i_clock }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { i_clock }];


## Reset
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { i_reset }];

##USB-RS232 

set_property -dict { PACKAGE_PIN B18    IOSTANDARD LVCMOS33 } [get_ports { rx }]; 
set_property -dict { PACKAGE_PIN A18    IOSTANDARD LVCMOS33 } [get_ports { tx }]; 


## Leds

set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { result[0] }]; 
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports { result[1] }]; 
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { result[2] }]; 
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports { result[3] }]; 
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports { result[4] }]; 
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports { result[5] }]; 
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { result[6] }]; 
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { result[7] }]; 


set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports { carry }]; 

set_property -dict { PACKAGE_PIN V3 IOSTANDARD LVCMOS33 } [get_ports { full }]; 

