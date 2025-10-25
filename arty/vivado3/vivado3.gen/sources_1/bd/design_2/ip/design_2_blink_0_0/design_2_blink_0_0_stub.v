// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Sat Oct 25 20:49:11 2025
// Host        : danieltrnka-Precision-7560 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/daniel-trnka/imx6sx-lm/arty/vivado3/vivado3.gen/sources_1/bd/design_2/ip/design_2_blink_0_0/design_2_blink_0_0_stub.v
// Design      : design_2_blink_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "blink,Vivado 2024.1" *)
module design_2_blink_0_0(clk, led)
/* synthesis syn_black_box black_box_pad_pin="led" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  output led;
endmodule
