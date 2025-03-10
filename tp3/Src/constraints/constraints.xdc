
## Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { clk_in }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk_in }];


## Reset
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { Reset }];



## Leds

## Conexión de LEDs (mostrar 16 bits por registro)
# Mapear los 16 LEDs en la placa Basys 3


set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { leds[0] }]; 
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports { leds[1] }]; 
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { leds[2] }]; 
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports { leds[3] }]; 
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports { leds[4] }]; 
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports { leds[5] }]; 
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { leds[6] }]; 
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { leds[7] }]; 

set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports leds[8]] ;  # LED 8
set_property -dict { PACKAGE_PIN V3   IOSTANDARD LVCMOS33 } [get_ports leds[9]] ;  # LED 9
set_property -dict { PACKAGE_PIN W3   IOSTANDARD LVCMOS33 } [get_ports leds[10]] ;  # LED 10
set_property -dict { PACKAGE_PIN U3   IOSTANDARD LVCMOS33 } [get_ports leds[11]] ;  # LED 11
set_property -dict { PACKAGE_PIN P3   IOSTANDARD LVCMOS33 } [get_ports leds[12]] ;  # LED 12
set_property -dict { PACKAGE_PIN N3   IOSTANDARD LVCMOS33 } [get_ports leds[13]] ;  # LED 13
set_property -dict { PACKAGE_PIN P1   IOSTANDARD LVCMOS33 } [get_ports leds[14]] ;  # LED 14
set_property -dict { PACKAGE_PIN L1   IOSTANDARD LVCMOS33 } [get_ports leds[15]] ;  # LED 15

## Conexión del botón (botón para avanzar)
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports btn];   # Botón
