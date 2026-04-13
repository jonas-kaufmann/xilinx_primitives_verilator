`ifdef verilator3
`else
`timescale 1 ps / 1 ps
`endif
//
// BUFG primitive for Xilinx FPGAs
// Compatible with Verilator tool (www.veripool.org)
// Copyright (c) 2026 Jonas Kaufmann
// License : BSD
//

/*verilator coverage_off*/
/* verilator tracing_off */
module BUFGCE #(
    parameter string CE_TYPE        = "SYNC",             // "SYNC", "ASYNC", "HARDSYNC"
    parameter        IS_CE_INVERTED = 1'b0,
    parameter        IS_I_INVERTED  = 1'b0,
    parameter string SIM_DEVICE     = "ULTRASCALE_PLUS",
    parameter string STARTUP_SYNC   = "FALSE"             // "FALSE", "TRUE"
) (
    output wire O,
    input  wire CE,
    input  wire I
);

  wire ce_in;
  wire i_in;

  reg  ce_sync1 = 1'b0;
  reg  ce_sync2 = 1'b0;
  reg  ce_gate = 1'b0;

  assign ce_in = CE ^ IS_CE_INVERTED;
  assign i_in  = I ^ IS_I_INVERTED;

  // Approximation:
  // - ASYNC: gate follows CE directly
  // - SYNC: gate updates on falling edge of clock
  // - HARDSYNC: model as a 2-stage synchronizer, then falling-edge capture

  generate
    if (CE_TYPE == "ASYNC") begin : g_async
      always @(*) begin
        ce_gate = ce_in;
      end
    end else if (CE_TYPE == "HARDSYNC") begin : g_hardsync
      always @(negedge i_in) begin
        ce_sync1 <= ce_in;
        ce_sync2 <= ce_sync1;
        ce_gate  <= ce_sync2;
      end
    end else begin : g_sync
      always @(negedge i_in) begin
        ce_gate <= ce_in;
      end
    end
  endgenerate

  assign O = ce_gate ? i_in : 1'b0;

endmodule
/*verilator coverage_on*/
