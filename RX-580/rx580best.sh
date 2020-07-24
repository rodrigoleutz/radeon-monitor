#!/bin/bash
echo "manual" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/power_dpm_force_performance_level
echo 185000000 > /sys/class/hwmon/hwmon3/power1_cap 
echo "s 0 300 750" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "s 1 600 769" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "s 2 900 862" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "s 3 1145 1068" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "s 4 1215 1110" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "s 5 1255 1130" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "s 6 1366 1150" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "s 7 1410 1150" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "m 0 300 750" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "m 1 1000 800" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "m 2 2100 980" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage 
echo "c" > /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/pp_od_clk_voltage

