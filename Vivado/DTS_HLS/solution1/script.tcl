############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 2015 Xilinx Inc. All rights reserved.
############################################################
open_project DTS_HLS
add_files TrapezSW/TrapezSW.sdk/Trapez_CPP/src/DTS_energy.h
add_files TrapezSW/TrapezSW.sdk/Trapez_CPP/src/TPE_38_1_mod_3.txt
add_files TrapezSW/TrapezSW.sdk/Trapez_CPP/src/Tools.h
add_files -tb TrapezSW/TrapezSW.sdk/Trapez_CPP/src/main.cpp
open_solution "solution1"
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
#source "./DTS_HLS/solution1/directives.tcl"
csim_design
csynth_design
cosim_design -rtl vhdl
export_design -format ip_catalog
