## Nexys A7-100T (xc7a100tcsg324-1) - Part 2 (Morse Code Terminal)
set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports CPU_RESETN]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports BTNC]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports LED0]
## USB-UART: D4 = FPGA transmit (UART_RXD_OUT in Digilent's naming)
set_property -dict {PACKAGE_PIN D4  IOSTANDARD LVCMOS33} [get_ports UART_RXD_OUT]
